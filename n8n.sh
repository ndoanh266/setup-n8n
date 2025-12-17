#!/bin/bash

# === Configuration ===
# N8N Data Directory (relative to the user running the script, e.g., /root/n8n-data if run as root)
N8N_BASE_DIR="$HOME/n8n" # You can change this path if desired
N8N_VOLUME_DIR="$N8N_BASE_DIR/n8n_data"
DOCKER_COMPOSE_FILE="$N8N_BASE_DIR/docker-compose.yml"
# Cloudflared config file path
CLOUDFLARED_CONFIG_FILE="/etc/cloudflared/config.yml"
# Default Timezone if system TZ is not set
DEFAULT_TZ="Asia/Ho_Chi_Minh"

# Backup configuration
BACKUP_DIR="$HOME/n8n-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Config file for installation settings
CONFIG_FILE="$HOME/.n8n_install_config"

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
    read -p "❓ Bạn có cần xem hướng dẫn lấy thông tin Cloudflare không? (y/N): " show_guide
    
    if [ "$show_guide" = "y" ] || [ "$show_guide" = "Y" ]; then
        get_cloudflare_info
        read -p "Nhấn Enter để tiếp tục sau khi đã chuẩn bị thông tin..."
    fi
    
    echo ""
    echo "📝 Nhập thông tin Cloudflare Tunnel:"
    echo ""
    
    # Lấy Cloudflare Token
    while true; do
        read -p "🔑 Nhập Cloudflare Tunnel Token: " CF_TOKEN
        if [ -z "$CF_TOKEN" ]; then
            print_error "Token không được để trống!"
            continue
        fi
        
        # Kiểm tra format token (JWT format)
        if [[ "$CF_TOKEN" =~ ^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
            print_success "Token hợp lệ"
            break
        else
            print_warning "Token có vẻ không đúng format JWT. Bạn có chắc chắn muốn tiếp tục? (y/N)"
            read -p "" confirm_token
            if [ "$confirm_token" = "y" ] || [ "$confirm_token" = "Y" ]; then
                break
            fi
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
            if [ "$confirm_hostname" = "y" ] || [ "$confirm_hostname" = "Y" ]; then
                break
            fi
        fi
    done
    
    # Decode token để lấy thông tin tunnel (nếu có thể)
    echo ""
    echo "🔍 Đang phân tích token..."
    
    # Thử decode JWT token để lấy thông tin
    TUNNEL_ID=""
    ACCOUNT_TAG=""
    TUNNEL_SECRET=""
    
    # Decode JWT payload (phần thứ 2)
    if command -v base64 >/dev/null 2>&1; then
        TOKEN_PAYLOAD=$(echo "$CF_TOKEN" | cut -d'.' -f2)
        # Thêm padding nếu cần
        case $((${#TOKEN_PAYLOAD} % 4)) in
            2) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}==" ;;
            3) TOKEN_PAYLOAD="${TOKEN_PAYLOAD}=" ;;
        esac
        
        DECODED=$(echo "$TOKEN_PAYLOAD" | base64 -d 2>/dev/null || echo "")
        if [ -n "$DECODED" ]; then
            TUNNEL_ID=$(echo "$DECODED" | grep -o '"t":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            ACCOUNT_TAG=$(echo "$DECODED" | grep -o '"a":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
            TUNNEL_SECRET=$(echo "$DECODED" | grep -o '"s":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
        fi
    fi
    
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
        if [ "$create_new" = "y" ] || [ "$create_new" = "Y" ]; then
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

edit_config() {
    echo "✏️ Chỉnh sửa config:"
    echo ""
    
    if load_config; then
        echo "Config hiện tại:"
        echo "  🌐 Hostname: $CF_HOSTNAME"
        echo "  🔑 Token: ${CF_TOKEN:0:20}...${CF_TOKEN: -10}"
        echo ""
        
        read -p "Nhập hostname mới (Enter để giữ nguyên): " new_hostname
        read -p "Nhập token mới (Enter để giữ nguyên): " new_token
        
        if [ -n "$new_hostname" ]; then
            CF_HOSTNAME="$new_hostname"
        fi
        
        if [ -n "$new_token" ]; then
            CF_TOKEN="$new_token"
        fi
        
        save_config "$CF_TOKEN" "$CF_HOSTNAME" "$TUNNEL_ID" "$ACCOUNT_TAG" "$TUNNEL_SECRET"
        print_success "Config đã được cập nhật!"
    else
        print_error "Không thể đọc config hiện tại!"
    fi
}

delete_config() {
    echo "🗑️ Xóa config:"
    echo ""
    
    if [ -f "$CONFIG_FILE" ]; then
        show_config_info
        echo ""
        read -p "⚠️ Bạn có chắc chắn muốn xóa config này không? (y/N): " confirm_delete
        
        if [ "$confirm_delete" = "y" ] || [ "$confirm_delete" = "Y" ]; then
            rm -f "$CONFIG_FILE"
            print_success "Config đã được xóa!"
        else
            echo "Hủy xóa config"
        fi
    else
        print_warning "Không có config nào để xóa"
    fi
}

# === Utility Functions ===
cleanup_old_backups() {
    print_section "Dọn dẹp backup cũ"
    
    if [ -d "$BACKUP_DIR" ]; then
        BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        
        # Giữ lại 10 backup gần nhất
        if [ $BACKUP_COUNT -gt 10 ]; then
            echo "🧹 Tìm thấy $BACKUP_COUNT backup, giữ lại 10 backup gần nhất..."
            ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | while read old_backup; do
                echo "  🗑️ Xóa: $(basename "$old_backup")"
                rm -f "$old_backup"
                # Xóa file info tương ứng
                info_file="${old_backup%.tar.gz}.info"
                [ -f "$info_file" ] && rm -f "$info_file"
            done
            print_success "Đã dọn dẹp backup cũ"
        else
            echo "✅ Số lượng backup ($BACKUP_COUNT) trong giới hạn cho phép"
        fi
    fi
    echo ""
}

get_latest_version() {
    # Cải thiện cách lấy phiên bản mới nhất
    echo "🔍 Đang kiểm tra phiên bản mới nhất..."
    
    # Thử nhiều cách để lấy version
    LATEST_VERSION=""
    
    # Cách 1: Docker Hub API
    if [ -z "$LATEST_VERSION" ]; then
        LATEST_VERSION=$(curl -s "https://registry.hub.docker.com/v2/repositories/n8nio/n8n/tags/?page_size=100" | \
            grep -o '"name":"[0-9][^"]*"' | grep -v "latest\|beta\|alpha\|rc\|exp" | head -1 | cut -d'"' -f4 2>/dev/null || echo "")
    fi
    
    # Cách 2: GitHub API
    if [ -z "$LATEST_VERSION" ]; then
        LATEST_VERSION=$(curl -s "https://api.github.com/repos/n8n-io/n8n/releases/latest" | \
            grep '"tag_name":' | cut -d'"' -f4 | sed 's/^n8n@//' 2>/dev/null || echo "")
    fi
    
    # Fallback
    if [ -z "$LATEST_VERSION" ]; then
        LATEST_VERSION="latest"
    fi
    
    echo "$LATEST_VERSION"
}

health_check() {
    print_section "Kiểm tra sức khỏe N8N"
    
    local max_attempts=6
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "🔍 Thử kết nối lần $attempt/$max_attempts..."
        
        # Kiểm tra container đang chạy
        if ! docker compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
            print_error "Container không chạy!"
            return 1
        fi
        
        # Kiểm tra port 5678
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|302\|401"; then
            print_success "N8N service đang hoạt động bình thường"
            print_success "Truy cập: https://n8n.doanh.id.vn"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            echo "⏳ Đợi 10 giây trước khi thử lại..."
            sleep 10
        fi
        
        attempt=$((attempt + 1))
    done
    
    print_warning "N8N service có thể chưa sẵn sàng hoặc có vấn đề"
    echo "📋 Container logs (20 dòng cuối):"
    docker compose -f "$DOCKER_COMPOSE_FILE" logs --tail=20
    return 1
}

rollback_backup() {
    print_section "Rollback từ backup"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR"/*.tar.gz 2>/dev/null)" ]; then
        print_error "Không tìm thấy backup nào để rollback!"
        return 1
    fi
    
    echo "📋 Danh sách backup khả dụng:"
    ls -lah "$BACKUP_DIR"/*.tar.gz | nl
    echo ""
    
    read -p "Nhập số thứ tự backup muốn rollback (hoặc Enter để hủy): " backup_choice
    
    if [ -z "$backup_choice" ]; then
        echo "Hủy rollback"
        return 0
    fi
    
    SELECTED_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz | sed -n "${backup_choice}p")
    
    if [ -z "$SELECTED_BACKUP" ] || [ ! -f "$SELECTED_BACKUP" ]; then
        print_error "Backup không hợp lệ!"
        return 1
    fi
    
    echo "🔄 Rollback từ: $(basename "$SELECTED_BACKUP")"
    read -p "Bạn có chắc chắn muốn rollback? (y/N): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Hủy rollback"
        return 0
    fi
    
    # Dừng container hiện tại
    print_warning "Dừng N8N container..."
    docker compose -f "$DOCKER_COMPOSE_FILE" down
    
    # Backup trạng thái hiện tại trước khi rollback
    ROLLBACK_BACKUP="n8n_before_rollback_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "💾 Tạo backup trạng thái hiện tại: $ROLLBACK_BACKUP"
    tar -czf "$BACKUP_DIR/$ROLLBACK_BACKUP" -C "$(dirname "$N8N_BASE_DIR")" "$(basename "$N8N_BASE_DIR")" 2>/dev/null || true
    
    # Restore từ backup
    echo "📦 Restore từ backup..."
    cd "$(dirname "$N8N_BASE_DIR")"
    tar -xzf "$SELECTED_BACKUP"
    
    # Khởi động lại
    echo "🚀 Khởi động N8N..."
    docker compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    sleep 15
    
    if health_check; then
        print_success "Rollback thành công!"
        print_success "Backup trạng thái trước rollback: $ROLLBACK_BACKUP"
    else
        print_error "Có vấn đề sau rollback, hãy kiểm tra logs"
        return 1
    fi
}

# === Backup & Update Functions ===
check_current_version() {
    print_section "Kiểm tra phiên bản hiện tại"
    
    if [ -f "$DOCKER_COMPOSE_FILE" ] && docker compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
        CURRENT_VERSION=$(docker compose -f "$DOCKER_COMPOSE_FILE" exec -T n8n n8n --version 2>/dev/null || echo "Unknown")
        print_success "Phiên bản hiện tại: $CURRENT_VERSION"
        
        # Kiểm tra phiên bản mới nhất
        print_section "Kiểm tra phiên bản mới nhất"
        LATEST_VERSION=$(get_latest_version)
        print_success "Tìm thấy phiên bản mới nhất: $LATEST_VERSION"
        
        if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && [ "$LATEST_VERSION" != "latest" ]; then
            print_warning "Có phiên bản mới khả dụng!"
        else
            print_success "Bạn đang sử dụng phiên bản mới nhất"
        fi
    else
        print_warning "N8N chưa được cài đặt hoặc không chạy"
        CURRENT_VERSION="Not installed"
    fi
    echo ""
}

show_server_status() {
    print_section "Trạng thái server"
    echo -e "${YELLOW}Thời gian: $(date)${NC}"
    
    echo "System Info:"
    echo "  - Uptime: $(uptime -p)"
    echo "  - Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "  - Memory: $(free -h | awk 'NR==2{printf "%.1f%% (%s/%s)", $3*100/$2, $3, $2}')"
    echo "  - Disk: $(df -h / | awk 'NR==2{printf "%s (%s used)", $5, $3}')"
    echo ""
    
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        echo "N8N Container Status:"
        docker compose -f "$DOCKER_COMPOSE_FILE" ps
        echo ""
        
        echo "Cloudflared Service Status:"
        systemctl status cloudflared --no-pager -l | head -5
    fi
    echo ""
}

count_backups() {
    print_section "Thông báo đã backup bao nhiêu bản và mô tả chi tiết"
    
    if [ -d "$BACKUP_DIR" ]; then
        BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        
        echo "📦 Số lượng backup hiện có: $BACKUP_COUNT bản"
        echo "💾 Tổng dung lượng backup: $TOTAL_SIZE"
        echo ""
        
        if [ $BACKUP_COUNT -gt 0 ]; then
            echo "📋 Danh sách backup gần đây:"
            ls -lah "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -5 | while read line; do
                echo "  $line"
            done
            echo ""
            
            echo "📄 Chi tiết nội dung backup:"
            echo "  ✓ N8N workflows và database (SQLite)"
            echo "  ✓ N8N settings và configurations"
            echo "  ✓ Custom nodes và packages"
            echo "  ✓ Cloudflared tunnel configurations"
            echo "  ✓ Docker compose files"
            echo "  ✓ Local files và uploads"
            echo "  ✓ Environment variables"
            echo "  ✓ Management scripts"
        else
            echo "📭 Chưa có backup nào được tạo"
        fi
    else
        echo "📁 Thư mục backup chưa tồn tại"
    fi
    echo ""
}

create_backup() {
    print_section "Backup tại $(date)"
    
    # Tạo thư mục backup nếu chưa có
    mkdir -p "$BACKUP_DIR"
    
    BACKUP_FILE="n8n_backup_${TIMESTAMP}.tar.gz"
    echo "📦 Backup file: $BACKUP_FILE"
    echo "⏰ Thời gian backup: $(date)"
    
    # Dừng container để backup an toàn
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        print_warning "Dừng N8N container để backup an toàn..."
        docker compose -f "$DOCKER_COMPOSE_FILE" down
    fi
    
    # Tạo backup chi tiết
    echo ""
    echo "🔄 Đang backup các thành phần:"
    echo "  📁 N8N data directory: $N8N_BASE_DIR"
    echo "  🔧 Cloudflared config: /etc/cloudflared/"
    echo "  📜 Scripts và configs"
    echo "  🗃️ Local files và uploads"
    
    # Backup toàn bộ
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
        -C "$(dirname "$N8N_BASE_DIR")" "$(basename "$N8N_BASE_DIR")" \
        -C /etc cloudflared/ \
        -C "$HOME" install_n8n.sh \
        2>/dev/null || true
    
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    print_success "Backup hoàn thành: $BACKUP_DIR/$BACKUP_FILE ($BACKUP_SIZE)"
    
    # Cập nhật thống kê backup
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
    echo "📊 Tổng số backup: $BACKUP_COUNT bản"
    
    # Dọn dẹp backup cũ nếu cần
    cleanup_old_backups
    
    # Tạo file mô tả backup
    cat > "$BACKUP_DIR/backup_${TIMESTAMP}.info" << EOF
N8N Backup Information
======================
Timestamp: $(date)
Backup File: $BACKUP_FILE
Size: $BACKUP_SIZE
N8N Version: ${CURRENT_VERSION:-Unknown}
Server IP: $(hostname -I | awk '{print $1}')
Hostname: $(hostname)

Backup Contents:
================
✓ N8N workflows và database (SQLite)
✓ N8N user settings và preferences  
✓ Custom nodes và installed packages
✓ Cloudflared tunnel configurations
✓ Docker compose files
✓ Local files và file uploads
✓ Environment variables
✓ SSL certificates (if any)
✓ Management scripts

Restore Instructions:
====================
1. Stop current N8N: docker compose -f $DOCKER_COMPOSE_FILE down
2. Extract backup: cd $(dirname "$N8N_BASE_DIR") && tar -xzf $BACKUP_DIR/$BACKUP_FILE
3. Start N8N: docker compose -f $DOCKER_COMPOSE_FILE up -d

System Info at Backup:
======================
Uptime: $(uptime -p)
Load: $(uptime | awk -F'load average:' '{print $2}')
Memory: $(free -h | awk 'NR==2{printf "%.1f%% (%s/%s)", $3*100/$2, $3, $2}')
Disk: $(df -h / | awk 'NR==2{printf "%s (%s used)", $5, $3}')
EOF
    
    print_success "Thông tin backup đã lưu: backup_${TIMESTAMP}.info"
    echo ""
}

update_n8n() {
    print_section "Cập nhật N8N lên phiên bản mới nhất"
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        print_error "N8N chưa được cài đặt!"
        return 1
    fi
    
    echo "🔄 Đang pull image mới nhất từ Docker Hub..."
    docker compose -f "$DOCKER_COMPOSE_FILE" pull
    
    echo "🚀 Khởi động lại với phiên bản mới..."
    docker compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    echo "⏳ Đợi container khởi động (15 giây)..."
    sleep 15
    
    # Kiểm tra trạng thái
    if docker compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
        NEW_VERSION=$(docker compose -f "$DOCKER_COMPOSE_FILE" exec -T n8n n8n --version 2>/dev/null || echo "Unknown")
        print_success "Update thành công!"
        print_success "Phiên bản mới: $NEW_VERSION"
        
        echo ""
        echo "📊 Container status:"
        docker compose -f "$DOCKER_COMPOSE_FILE" ps
        
        # Kiểm tra service health
        health_check
    else
        print_error "Có lỗi khi khởi động container!"
        echo "📋 Container logs:"
        docker compose -f "$DOCKER_COMPOSE_FILE" logs --tail=20
        return 1
    fi
    echo ""
}

backup_and_update() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    N8N BACKUP & UPDATE PROCESS${NC}"
    echo -e "${BLUE}================================================${NC}"
    
    check_current_version
    show_server_status
    count_backups
    create_backup
    update_n8n
    
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}    BACKUP & UPDATE HOÀN THÀNH${NC}"
    echo -e "${GREEN}================================================${NC}"
    print_success "Backup: $BACKUP_DIR/n8n_backup_${TIMESTAMP}.tar.gz"
    print_success "N8N đã được cập nhật và đang chạy"
    print_success "Truy cập: https://n8n.doanh.id.vn"
}

# === Original Installation Functions ===
install_n8n() {
    # --- Check if running as root ---
    if [ "$(id -u)" -ne 0 ]; then
       echo "This script must be run as root. Please use 'sudo ./install_n8n.sh'" >&2
       exit 1
    fi

    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    CLOUDFLARE TUNNEL & N8N SETUP${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo "Script này sẽ cài đặt Docker, Cloudflared và cấu hình N8N"
    echo "để truy cập qua Cloudflare Tunnel."
    echo ""

    # --- Check for existing config ---
    if show_config_info; then
        echo -e "${YELLOW}🔍 Bạn đã có config trước đó!${NC}"
        read -p "Bạn có muốn sử dụng lại config này không? (y/N): " use_existing
        
        if [ "$use_existing" = "y" ] || [ "$use_existing" = "Y" ]; then
            load_config
            print_success "Sử dụng config có sẵn"
        else
            echo "📝 Nhập config mới..."
            get_new_config
        fi
    else
        echo "📝 Chưa có config, cần nhập thông tin mới..."
        get_new_config
    fi
    
    echo "" # Newline for better formatting

    # --- System Update and Prerequisites ---
    echo ">>> Updating system packages..."
    apt update
    echo ">>> Installing prerequisites (curl, wget, gpg, etc.)..."
    apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release wget

    # --- Install Docker ---
    if ! command -v docker &> /dev/null; then
        echo ">>> Docker not found. Installing Docker..."
        # Add Docker's official GPG key:
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        
        # Add the repository to Apt sources:
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update

        # Install Docker packages
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo ">>> Docker installed successfully."

        # Add the current sudo user (if exists) to the docker group
        # This avoids needing sudo for every docker command AFTER logging out/in again
        REAL_USER="${SUDO_USER:-$(whoami)}"
        if id "$REAL_USER" &>/dev/null && ! getent group docker | grep -qw "$REAL_USER"; then
          echo ">>> Adding user '$REAL_USER' to the 'docker' group..."
          usermod -aG docker "$REAL_USER"
          echo ">>> NOTE: User '$REAL_USER' needs to log out and log back in for docker group changes to take full effect."
        fi

    else
        echo ">>> Docker is already installed."
    fi

    # Ensure Docker service is running and enabled
    echo ">>> Ensuring Docker service is running and enabled..."
    systemctl start docker
    systemctl enable docker
    echo ">>> Docker service check complete."

    # --- Install Cloudflared ---
    if ! command -v cloudflared &> /dev/null; then
        echo ">>> Cloudflared not found. Installing Cloudflared..."
        # Download the ARM64 package
        CLOUDFLARED_DEB_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb"
        CLOUDFLARED_DEB_PATH="/tmp/cloudflared-linux-arm64.deb"
        echo ">>> Downloading Cloudflared package from $CLOUDFLARED_DEB_URL..."
        wget -q "$CLOUDFLARED_DEB_URL" -O "$CLOUDFLARED_DEB_PATH"
        echo ">>> Installing Cloudflared package..."
        dpkg -i "$CLOUDFLARED_DEB_PATH"
        rm "$CLOUDFLARED_DEB_PATH" # Clean up downloaded file
        echo ">>> Cloudflared installed successfully."
    else
        echo ">>> Cloudflared is already installed."
    fi

    # --- Setup n8n Directory and Permissions ---
    echo ">>> Setting up n8n data directory: $N8N_BASE_DIR"
    mkdir -p "$N8N_VOLUME_DIR" # Create the specific volume dir as well
    # Set ownership to UID 1000, GID 1000 (standard 'node' user in n8n container)
    # This prevents permission errors when n8n tries to write data
    echo ">>> Setting permissions for n8n data volume..."
    chown -R 1000:1000 "$N8N_VOLUME_DIR"

    # --- Create Docker Compose File ---
    echo ">>> Creating Docker Compose file: $DOCKER_COMPOSE_FILE"
    # Determine Timezone
    SYSTEM_TZ=$(cat /etc/timezone 2>/dev/null || echo "$DEFAULT_TZ")
    cat <<EOF > "$DOCKER_COMPOSE_FILE"
services:
  n8n:
    image: n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      # Bind only to localhost, as Cloudflared will handle external access
      - "127.0.0.1:5678:5678"
    environment:
      # Use system timezone if available, otherwise default
      - TZ=${SYSTEM_TZ}
      # N8N_SECURE_COOKIE=false # DO NOT USE THIS when accessing via HTTPS (Cloudflared)
      # Add any other specific n8n environment variables here:
      # - N8N_HOST=$CF_HOSTNAME # Optional: Tell n8n its public hostname
      # - WEBHOOK_URL=https://$CF_HOSTNAME/ # Optional: Base URL for webhooks
    volumes:
      # Mount the local data directory into the container
      - ./n8n_local_data:/home/node/.n8n

networks:
  default:
    name: n8n-network # Define a specific network name (optional but good practice)

EOF
    echo ">>> Docker Compose file created."

    # --- Configure Cloudflared Service ---
    echo ">>> Configuring Cloudflared..."
    # Create directory if it doesn't exist
    mkdir -p /etc/cloudflared

    # Create cloudflared config.yml
    echo ">>> Creating Cloudflared config file: $CLOUDFLARED_CONFIG_FILE"
    cat <<EOF > "$CLOUDFLARED_CONFIG_FILE"
# This file is configured for tunnel runs via 'cloudflared service install'
# It defines the ingress rules. Tunnel ID and credentials file are managed
# automatically by the service install command using the provided token.
# Do not add 'tunnel:' or 'credentials-file:' lines here.

ingress:
  - hostname: ${CF_HOSTNAME}
    service: http://localhost:5678 # Points to n8n running locally via Docker port mapping
  - service: http_status:404 # Catch-all rule
EOF
    echo ">>> Cloudflared config file created."

    # Install cloudflared as a service using the token
    echo ">>> Installing Cloudflared service using the provided token..."
    # The service install command handles storing the token securely
    cloudflared service install "$CF_TOKEN"
    echo ">>> Cloudflared service installed."

    # --- Start Services ---
    echo ">>> Enabling and starting Cloudflared service..."
    systemctl enable cloudflared
    systemctl start cloudflared

    # Brief pause to allow service to stabilize
    sleep 5
    echo ">>> Checking Cloudflared service status:"
    systemctl status cloudflared --no-pager || echo "Warning: Cloudflared status check indicates an issue. Use 'sudo journalctl -u cloudflared' for details."

    echo ">>> Starting n8n container via Docker Compose..."
    # Use -f to specify the file, ensuring it runs from anywhere
    # Use --remove-orphans to clean up any old containers if the compose file changed significantly
    # Use -d to run in detached mode
    docker compose -f "$DOCKER_COMPOSE_FILE" up --remove-orphans -d

    # --- Final Instructions ---
    echo ""
    echo "--------------------------------------------------"
    echo " Setup Complete! "
    echo "--------------------------------------------------"
    echo "n8n should now be running in Docker and accessible via Cloudflare Tunnel."
    echo ""
    echo "Access your n8n instance at:"
    echo "  https://${CF_HOSTNAME}"
    echo ""
    echo "Notes:"
    echo "- It might take a minute or two for the Cloudflare Tunnel connection to be fully established."
    echo "- If you encounter issues, check the n8n container logs: 'docker logs n8n'"
    echo "- Check Cloudflared service logs: 'sudo journalctl -u cloudflared -f'"
    echo "- Ensure DNS for ${CF_HOSTNAME} is correctly pointing to your Cloudflare Tunnel (usually handled automatically by Cloudflare)."
    echo "- Remember to log out and log back in if user '$REAL_USER' was just added to the 'docker' group."
    echo ""
    echo "🔧 Additional Commands:"
    echo "- Backup N8N: $0 backup"
    echo "- Update N8N: $0 update"  
    echo "- Backup & Update: $0 backup-update"
    echo "- Check Status: $0 status"
    echo "--------------------------------------------------"
}

show_menu() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}    N8N MANAGEMENT SCRIPT${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo "Chọn hành động:"
    echo "1. 🚀 Cài đặt N8N mới (với Cloudflare Tunnel)"
    echo "2. 💾 Backup dữ liệu N8N"
    echo "3. 🔄 Update N8N lên phiên bản mới nhất"
    echo "4. 🔄💾 Backup + Update N8N"
    echo "5. 📊 Kiểm tra trạng thái hệ thống"
    echo "6. 📋 Xem thông tin backup"
    echo "7. 🔙 Rollback từ backup"
    echo "8. 🧹 Dọn dẹp backup cũ"
    echo "9. ⚙️ Xem/Quản lý config Cloudflare"
    echo "0. ❌ Thoát"
    echo ""
    read -p "Nhập lựa chọn (0-9): " choice
}

# === Main Script Logic ===
# Nếu có tham số dòng lệnh
if [ $# -gt 0 ]; then
    case $1 in
        "install")
            install_n8n
            ;;
        "backup")
            check_current_version
            show_server_status
            count_backups
            create_backup
            ;;
        "update")
            check_current_version
            update_n8n
            ;;
        "backup-update")
            backup_and_update
            ;;
        "status")
            check_current_version
            show_server_status
            count_backups
            ;;
        "rollback")
            rollback_backup
            ;;
        "cleanup")
            cleanup_old_backups
            ;;
        "config")
            manage_config
            ;;
        *)
            echo "Sử dụng: $0 [install|backup|update|backup-update|status|rollback|cleanup|config]"
            echo ""
            echo "Ví dụ:"
            echo "  $0 install        # Cài đặt N8N mới"
            echo "  $0 backup         # Backup dữ liệu"
            echo "  $0 update         # Update N8N"
            echo "  $0 backup-update  # Backup và update"
            echo "  $0 status         # Kiểm tra trạng thái"
            echo "  $0 rollback       # Rollback từ backup"
            echo "  $0 cleanup        # Dọn dẹp backup cũ"
            echo "  $0 config         # Quản lý config"
            exit 1
            ;;
    esac
else
    # Menu tương tác
    while true; do
        show_menu
        case $choice in
            1)
                install_n8n
                ;;
            2)
                check_current_version
                show_server_status
                count_backups
                create_backup
                ;;
            3)
                check_current_version
                update_n8n
                ;;
            4)
                backup_and_update
                ;;
            5)
                check_current_version
                show_server_status
                count_backups
                ;;
            6)
                count_backups
                ;;
            7)
                rollback_backup
                ;;
            8)
                cleanup_old_backups
                ;;
            9)
                manage_config
                ;;
            0)
                echo "Tạm biệt!"
                exit 0
                ;;
            *)
                print_error "Lựa chọn không hợp lệ!"
                ;;
        esac
        echo ""
        read -p "Nhấn Enter để tiếp tục..."
        clear
    done
fi

exit 0
