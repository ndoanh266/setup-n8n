#!/bin/bash

# ============================================================
# N8N Management Script with Cloudflare Tunnel Integration
# ============================================================
# Requirements:
#   - Ubuntu/Debian-based Linux (uses apt, dpkg)
#   - Root/sudo access
#   - Internet connection
#   - Cloudflare account with Zero Trust access
# ============================================================

# === Shell Compatibility Check ===
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script requires Bash. Please run with: bash $0" >&2
    exit 1
fi

# === Check if running as root ===
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root. Please use 'sudo bash $0'" >&2
   exit 1
fi

# === Determine the real user and home directory ===
# When running with sudo, $HOME points to root's home (/root)
# We need to use the original user's home directory
REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME=$(eval echo "~$REAL_USER")

# === Configuration ===
# N8N Data Directory (using real user's home, not root's)
N8N_BASE_DIR="$REAL_HOME/n8n"
N8N_VOLUME_DIR="$N8N_BASE_DIR/n8n_data"
DOCKER_COMPOSE_FILE="$N8N_BASE_DIR/docker-compose.yml"
N8N_ENCRYPTION_KEY_FILE="$N8N_BASE_DIR/.n8n_encryption_key"
# Cloudflared config file path
CLOUDFLARED_CONFIG_FILE="/etc/cloudflared/config.yml"
# Default Timezone if system TZ is not set
DEFAULT_TZ="Asia/Ho_Chi_Minh"

# Backup configuration
BACKUP_DIR="$REAL_HOME/n8n-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Config file for installation settings
CONFIG_FILE="$REAL_HOME/.n8n_install_config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === Script Execution ===
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Prevent errors in a pipeline from being masked.
set -o pipefail

# === Helper Functions ===
print_section() {
    echo -e "${BLUE}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# === Config Management Functions ===
save_config() {
    local cf_token="$1"
    local cf_hostname="$2"
    local tunnel_id="$3"
    local account_tag="$4"
    local tunnel_secret="$5"
    
    cat > "$CONFIG_FILE" << EOF
# N8N Installation Configuration
# Generated on: $(date)
CF_TOKEN="$cf_token"
CF_HOSTNAME="$cf_hostname"
TUNNEL_ID="$tunnel_id"
ACCOUNT_TAG="$account_tag"
TUNNEL_SECRET="$tunnel_secret"
INSTALL_DATE="$(date)"
EOF
    
    chown "$REAL_USER":"$REAL_USER" "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"  # Bảo mật file config
    print_success "Config đã được lưu tại: $CONFIG_FILE"
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

show_config_info() {
    if load_config; then
        echo -e "${BLUE}📋 Thông tin config hiện có:${NC}"
        echo "  🌐 Hostname: $CF_HOSTNAME"
        echo "  🔑 Tunnel ID: $TUNNEL_ID"
        echo "  📅 Ngày cài đặt: $INSTALL_DATE"
        echo ""
        return 0
    else
        return 1
    fi
}

get_cloudflare_info() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    HƯỚNG DẪN LẤY THÔNG TIN CLOUDFLARE${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo "🔗 Để lấy Cloudflare Tunnel Token và thông tin:"
    echo ""
    echo "1️⃣ Truy cập Cloudflare Zero Trust Dashboard:"
    echo "   👉 https://one.dash.cloudflare.com/"
    echo ""
    echo "2️⃣ Đăng nhập và chọn 'Access' > 'Tunnels'"
    echo ""
    echo "3️⃣ Tạo tunnel mới hoặc chọn tunnel có sẵn:"
    echo "   • Click 'Create a tunnel'"
    echo "   • Chọn 'Cloudflared' connector"
    echo "   • Đặt tên tunnel (ví dụ: n8n-tunnel)"
    echo ""
    echo "4️⃣ Lấy thông tin cần thiết:"
    echo "   🔑 Token: Trong phần 'Install and run a connector'"
    echo "   🌐 Hostname: Domain bạn muốn sử dụng (ví dụ: n8n.yourdomain.com)"
    echo ""
    echo "5️⃣ Cấu hình DNS:"
    echo "   • Trong Cloudflare DNS, tạo CNAME record"
    echo "   • Name: subdomain của bạn (ví dụ: n8n)"
    echo "   • Target: [tunnel-id].cfargotunnel.com"
    echo ""
    echo "💡 Lưu ý:"
    echo "   • Domain phải được quản lý bởi Cloudflare"
    echo "   • Token có dạng: eyJhIjoiXXXXXX..."
    echo "   • Hostname có dạng: n8n.yourdomain.com"
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

get_new_config() {
    echo ""
    read -p "❓ Bạn muốn sử dụng Cloudflare Tunnel không? (y/N): " use_cloudflare
    
    if [[ ! "$use_cloudflare" =~ ^[Yy]$ ]]; then
        # Local mode - không cần Cloudflare
        print_success "Chế độ Local được chọn"
        echo ""
        echo "📝 Thông tin cấu hình Local Mode:"
        echo "  • N8N sẽ chạy tại: http://localhost:5678"
        echo "  • Chỉ có thể truy cập từ máy local"
        echo "  • Không cần token Cloudflare"
        echo "  • Không cần cấu hình DNS"
        echo ""
        
        CF_TOKEN="local"
        CF_HOSTNAME="localhost"
        TUNNEL_ID="local"
        ACCOUNT_TAG="local"
        TUNNEL_SECRET="local"
        
        save_config "$CF_TOKEN" "$CF_HOSTNAME" "$TUNNEL_ID" "$ACCOUNT_TAG" "$TUNNEL_SECRET"
        print_success "Config Local Mode đã được lưu"
        return 0
    fi
    
    # Cloudflare mode
    read -p "❓ Bạn có cần xem hướng dẫn lấy thông tin Cloudflare không? (y/N): " show_guide
    
    if [[ "$show_guide" =~ ^[Yy]$ ]]; then
        get_cloudflare_info
        read -p "Nhấn Enter để tiếp tục sau khi đã chuẩn bị thông tin..."
    fi
    
    echo ""
    echo "📝 Nhập thông tin Cloudflare Tunnel:"
    echo ""
    
    # Lấy Cloudflare Token
    while true; do
        read -p "🔑 Nhập Cloudflare Tunnel Token (hoặc dòng lệnh cloudflared): " CF_TOKEN
        if [ -z "$CF_TOKEN" ]; then
            print_error "Token không được để trống!"
            continue
        fi
        
        # Xử lý nếu user paste toàn bộ dòng lệnh: cloudflared.exe service install TOKEN
        # Hoặc: cloudflared service install TOKEN
        if [[ "$CF_TOKEN" =~ cloudflared ]]; then
            # Trích xuất token từ dòng lệnh
            CF_TOKEN=$(echo "$CF_TOKEN" | grep -oP 'service install \K.*' | tr -d ' ')
            if [ -z "$CF_TOKEN" ]; then
                print_error "Không thể trích xuất token từ dòng lệnh. Vui lòng paste lại!"
                continue
            fi
        fi
        
        # Kiểm tra format token (JWT format hoặc payload)
        # Chấp nhận cả token đầy đủ (3 phần) hoặc payload (1 phần)
        if [[ "$CF_TOKEN" =~ ^eyJ[A-Za-z0-9_-]+ ]]; then
            print_success "Token hợp lệ"
            break
        else
            print_error "Token phải bắt đầu bằng 'eyJ'. Vui lòng kiểm tra lại!"
            continue
        fi
    done
    
    # Lấy Hostname
    while true; do
        read -p "🌐 Nhập Public Hostname (ví dụ: n8n.yourdomain.com): " CF_HOSTNAME
        if [ -z "$CF_HOSTNAME" ]; then
            print_error "Hostname không được để trống!"
            continue
        fi
        
        # Kiểm tra format hostname
        if [[ "$CF_HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
            print_success "Hostname hợp lệ"
            break
        else
            print_warning "Hostname có vẻ không đúng format. Bạn có chắc chắn muốn tiếp tục? (y/N)"
            read -p "" confirm_hostname
            if [[ "$confirm_hostname" =~ ^[Yy]$ ]]; then
                break
            fi
        fi
    done
    
    # Decode token để lấy thông tin tunnel (nếu có thể)
    echo ""
    echo "🔍 Đang phân tích token..."
    
    # Sử dụng hàm helper để decode token
    decode_token_info "$CF_TOKEN"
    
    if [ -n "$TUNNEL_ID" ]; then
        print_success "Đã phân tích được thông tin từ token:"
        echo "  🆔 Tunnel ID: $TUNNEL_ID"
        echo "  🏢 Account Tag: $ACCOUNT_TAG"
    else
        print_warning "Không thể phân tích token, sẽ sử dụng thông tin mặc định"
        TUNNEL_ID="unknown"
        ACCOUNT_TAG="unknown"
        TUNNEL_SECRET="unknown"
    fi
    
    # Lưu config
    save_config "$CF_TOKEN" "$CF_HOSTNAME" "$TUNNEL_ID" "$ACCOUNT_TAG" "$TUNNEL_SECRET"
}

manage_config() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    QUẢN LÝ CONFIG CLOUDFLARE${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    if show_config_info; then
        echo "Chọn hành động:"
        echo "1. 👁️ Xem chi tiết config"
        echo "2. ✏️ Chỉnh sửa config"
        echo "3. 🗑️ Xóa config"
        echo "4. 📋 Tạo config mới"
        echo "0. ⬅️ Quay lại"
        echo ""
        read -p "Nhập lựa chọn (0-4): " config_choice
        
        case $config_choice in
            1)
                show_detailed_config
                ;;
            2)
                edit_config
                ;;
            3)
                delete_config
                ;;
            4)
                get_new_config
                ;;
            0)
                return 0
                ;;
            *)
                print_error "Lựa chọn không hợp lệ!"
                ;;
        esac
    else
        echo "📭 Chưa có config nào được lưu."
        echo ""
        read -p "Bạn có muốn tạo config mới không? (y/N): " create_new
        if [[ "$create_new" =~ ^[Yy]$ ]]; then
            get_new_config
        fi
    fi
}

show_detailed_config() {
    if load_config; then
        echo -e "${BLUE}📋 Chi tiết config:${NC}"
        echo ""
        echo "🌐 Hostname: $CF_HOSTNAME"
        echo "🆔 Tunnel ID: $TUNNEL_ID"
        echo "🏢 Account Tag: $ACCOUNT_TAG"
        echo "🔑 Token: ${CF_TOKEN:0:20}...${CF_TOKEN: -10}"
        echo "📅 Ngày cài đặt: $INSTALL_DATE"
        echo ""
        echo "📁 File config: $CONFIG_FILE"
        echo ""
    else
        print_error "Không thể đọc config!"
    fi
}

decode_token_info() {
    local token="$1"
    local tunnel_id=""
    local account_tag=""
    local tunnel_secret=""
    
    # Decode JWT payload
    if command -v base64 >/dev/null 2>&1; then
        # Xác định payload: nếu có dấu chấm thì lấy phần thứ 2, nếu không thì lấy toàn bộ
        local TOKEN_PAYLOAD
        if [[ "$token" == *"."* ]]; then
            TOKEN_PAYLOAD=$(echo "$token" | cut -d'.' -f2)
        else
            # Token chỉ có payload (không có header và signature)
            TOKEN_PAYLOAD="$token"
        fi
        
        # Thêm padding nếu cần
        case $((${#TOKEN_PAYLOAD} % 4)) in
            2) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}==" ;;
            3) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}=" ;;
        esac
        
        local DECODED
        DECODED=$(echo "$TOKEN_PAYLOAD" | base64 -d 2>/dev/null || echo "")
        if [ -n "$DECODED" ]; then
            tunnel_id=$(echo "$DECODED" | grep -o '"t":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            account_tag=$(echo "$DECODED" | grep -o '"a":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            tunnel_secret=$(echo "$DECODE
