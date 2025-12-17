# 🚀 N8N Management Script - Cài đặt và Quản lý N8N tự động

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![N8N](https://img.shields.io/badge/N8N-Latest-blue.svg)](https://n8n.io/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-orange.svg)](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

> **Script tự động cài đặt, backup và quản lý N8N với Cloudflare Tunnel - Dành cho mọi người, từ người mới bắt đầu đến chuyên gia!**

## 📋 Mục lục

- [🎯 Dành cho ai?](#-dành-cho-ai)
- [✨ Tính năng](#-tính-năng)
- [🔧 Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [💻 Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)
- [🚀 Cách sử dụng](#-cách-sử-dụng)
- [📖 Hướng dẫn chi tiết](#-hướng-dẫn-chi-tiết)
- [🔒 Bảo mật](#-bảo-mật)
- [❓ FAQ](#-faq)
- [🤝 Đóng góp](#-đóng-góp)
- [🙏 Credits](#-credits)

## 🎯 Dành cho ai?

### ✅ **Bạn NÊN sử dụng script này nếu:**

- 🏠 **Có máy tính/server** (Windows, Linux, macOS) muốn chạy 24/7
- 🔄 **Muốn tự động hóa công việc** với N8N (workflow automation)
- 🌐 **Cần truy cập N8N từ bất kỳ đâu** qua internet
- 💼 **Làm việc với API, webhook, tích hợp dịch vụ**
- 🏢 **Doanh nghiệp nhỏ** cần tự động hóa quy trình
- 👨‍💻 **Developer** muốn tự host N8N thay vì dùng cloud
- 🎓 **Học tập và thử nghiệm** automation

### 🎯 **Các trường hợp sử dụng phổ biến:**

| Lĩnh vực | Ứng dụng |
|----------|----------|
| **E-commerce** | Tự động xử lý đơn hàng, đồng bộ inventory, gửi email |
| **Marketing** | Tự động social media, email marketing, lead nurturing |
| **Doanh nghiệp** | Tự động báo cáo, quản lý CRM, tích hợp hệ thống |
| **Cá nhân** | Backup tự động, thông báo, quản lý tài chính |
| **Developer** | CI/CD, monitoring, API integration |

### ❌ **KHÔNG phù hợp nếu:**

- 📱 Chỉ có điện thoại/tablet
- ☁️ Muốn dùng cloud service (hãy dùng n8n.cloud)
- 🔌 Không có internet ổn định
- 💻 Không có máy tính để chạy 24/7

## ✨ Tính năng

### 🎛️ **Quản lý toàn diện N8N:**

- ⚡ **Cài đặt tự động** N8N + Docker + Cloudflare Tunnel
- 💾 **Backup thông minh** với thông tin chi tiết
- 🔄 **Update tự động** lên phiên bản mới nhất
- 🔙 **Rollback an toàn** từ backup
- 📊 **Monitoring** trạng thái hệ thống
- 🧹 **Cleanup tự động** backup cũ
- ⚙️ **Config management** Cloudflare

### 🌟 **Điểm nổi bật:**

- 🎨 **Giao diện thân thiện** - Menu tương tác đẹp mắt
- 🔒 **Bảo mật cao** - Mã hóa config, validation đầu vào
- 🚀 **Production-ready** - Đã test kỹ lưỡng
- 📚 **Hướng dẫn tích hợp** - Chi tiết từng bước
- 🔧 **Flexible** - Command line + Interactive menu
- 🌍 **Tiếng Việt** - Giao diện và hướng dẫn bằng tiếng Việt

## 🔧 Yêu cầu hệ thống

### 💻 **Phần cứng tối thiểu:**

| Thành phần | Yêu cầu | Khuyến nghị |
|------------|---------|-------------|
| **CPU** | 1 core | 2+ cores |
| **RAM** | 1GB | 2GB+ |
| **Ổ cứng** | 10GB trống | 20GB+ |
| **Mạng** | Internet ổn định | Băng thông cao |

### 🖥️ **Hệ điều hành hỗ trợ:**

#### ✅ **Linux (Khuyến nghị)**
- Ubuntu 18.04+ ⭐
- Debian 10+
- CentOS 7+
- Fedora 30+
- Arch Linux
- Raspberry Pi OS

#### ✅ **Windows**
- Windows 10/11 với WSL2
- Windows Server 2019+

#### ✅ **macOS**
- macOS 10.15+
- Apple Silicon (M1/M2) hỗ trợ

### 🌐 **Yêu cầu khác:**

- ☁️ **Tài khoản Cloudflare** (miễn phí)
- 🌍 **Domain name** (có thể dùng subdomain miễn phí)
- 🔑 **Quyền admin/root** trên máy

## 💻 Hướng dẫn cài đặt

### 🐧 **Linux/macOS (Khuyến nghị)**

#### **Bước 1: Chuẩn bị hệ thống**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y curl wget git

# CentOS/RHEL/Fedora
sudo yum install -y curl wget git
# hoặc
sudo dnf install -y curl wget git

# macOS (cần Homebrew)
brew install curl wget git
```

#### **Bước 2: Tải script**

```bash
# Tải script
wget https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh

# Hoặc dùng curl
curl -O https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh

# Cấp quyền thực thi
chmod +x n8n.sh
```

#### **Bước 3: Chạy script**

```bash
# Chạy với quyền root
sudo ./n8n.sh
```

### 🪟 **Windows**

#### **Phương pháp 1: WSL2 (Khuyến nghị)**

1. **Cài đặt WSL2:**
   ```powershell
   # Chạy PowerShell với quyền Admin
   wsl --install
   # Khởi động lại máy
   ```

2. **Cài đặt Ubuntu:**
   ```powershell
   wsl --install -d Ubuntu
   ```

3. **Trong Ubuntu WSL:**
   ```bash
   # Cập nhật hệ thống
   sudo apt update && sudo apt upgrade -y
   
   # Tải và chạy script
   wget https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh
   chmod +x n8n.sh
   sudo ./n8n.sh
   ```

#### **Phương pháp 2: Docker Desktop**

1. **Cài Docker Desktop** từ [docker.com](https://www.docker.com/products/docker-desktop/)

2. **Cài Git Bash** từ [git-scm.com](https://git-scm.com/download/win)

3. **Chạy Git Bash với quyền Admin:**
   ```bash
   # Tải script
   curl -O https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh
   
   # Chạy script
   bash n8n.sh
   ```

### 🍎 **macOS**

#### **Bước 1: Cài Homebrew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### **Bước 2: Cài Docker**
```bash
brew install --cask docker
# Khởi động Docker Desktop
open /Applications/Docker.app
```

#### **Bước 3: Chạy script**
```bash
# Tải script
curl -O https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh
chmod +x n8n.sh

# Chạy script
sudo ./n8n.sh
```

### 🥧 **Raspberry Pi**

```bash
# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Tải script
wget https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh
chmod +x n8n.sh

# Chạy script
sudo ./n8n.sh
```

## 🚀 Cách sử dụng

### 🎛️ **Menu tương tác**

```bash
sudo ./n8n.sh
```

Sẽ hiển thị menu:

```
================================================
    N8N MANAGEMENT SCRIPT
================================================

Chọn hành động:
1. 🚀 Cài đặt N8N mới (với Cloudflare Tunnel)
2. 💾 Backup dữ liệu N8N
3. 🔄 Update N8N lên phiên bản mới nhất
4. 🔄💾 Backup + Update N8N
5. 📊 Kiểm tra trạng thái hệ thống
6. 📋 Xem thông tin backup
7. 🔙 Rollback từ backup
8. 🧹 Dọn dẹp backup cũ
9. ⚙️ Xem/Quản lý config Cloudflare
0. ❌ Thoát
```

### ⌨️ **Command line**

```bash
# Cài đặt N8N mới
sudo ./n8n.sh install

# Backup dữ liệu
sudo ./n8n.sh backup

# Update N8N
sudo ./n8n.sh update

# Backup + Update
sudo ./n8n.sh backup-update

# Kiểm tra trạng thái
sudo ./n8n.sh status

# Rollback từ backup
sudo ./n8n.sh rollback

# Dọn dẹp backup cũ
sudo ./n8n.sh cleanup

# Quản lý config
sudo ./n8n.sh config
```

## 📖 Hướng dẫn chi tiết

### 🔧 **Lần đầu cài đặt**

#### **Bước 1: Chuẩn bị Cloudflare**

1. **Đăng ký tài khoản Cloudflare** (miễn phí): [cloudflare.com](https://cloudflare.com)

2. **Thêm domain vào Cloudflare:**
   - Nếu chưa có domain, có thể dùng subdomain miễn phí từ các dịch vụ như:
     - [FreeDNS](https://freedns.afraid.org/)
     - [No-IP](https://www.noip.com/)
     - [DuckDNS](https://www.duckdns.org/)

3. **Tạo Cloudflare Tunnel:**
   - Truy cập [Zero Trust Dashboard](https://one.dash.cloudflare.com/)
   - Chọn **Access** > **Tunnels**
   - Click **Create a tunnel**
   - Đặt tên tunnel (ví dụ: `n8n-tunnel`)
   - Copy **Tunnel Token** (dạng: `eyJhIjoiXXXXXX...`)

#### **Bước 2: Chạy script cài đặt**

```bash
sudo ./n8n.sh install
```

Script sẽ hướng dẫn bạn:

1. **Nhập Cloudflare Token**
2. **Nhập hostname** (ví dụ: `n8n.yourdomain.com`)
3. **Tự động cài đặt:**
   - Docker & Docker Compose
   - Cloudflared
   - N8N container
   - Cấu hình tunnel

#### **Bước 3: Truy cập N8N**

Sau khi cài đặt xong:
- Truy cập: `https://your-hostname.com`
- Tạo tài khoản admin đầu tiên
- Bắt đầu tạo workflow!

### 💾 **Backup và Restore**

#### **Tự động backup:**
```bash
# Backup thủ công
sudo ./n8n.sh backup

# Backup + Update
sudo ./n8n.sh backup-update
```

#### **Nội dung backup:**
- ✅ N8N workflows và database
- ✅ User settings và credentials
- ✅ Custom nodes và packages
- ✅ Cloudflare tunnel config
- ✅ Docker compose files
- ✅ Scripts quản lý

#### **Restore từ backup:**
```bash
sudo ./n8n.sh rollback
```

### 🔄 **Update N8N**

```bash
# Chỉ update
sudo ./n8n.sh update

# Backup trước khi update (khuyến nghị)
sudo ./n8n.sh backup-update
```

### 📊 **Monitoring**

```bash
# Kiểm tra trạng thái tổng quan
sudo ./n8n.sh status
```

Hiển thị:
- Phiên bản N8N hiện tại vs mới nhất
- Trạng thái container
- Thông tin hệ thống (CPU, RAM, Disk)
- Trạng thái Cloudflare tunnel
- Thống kê backup

## 🔒 Bảo mật

### 🛡️ **Các biện pháp bảo mật:**

- 🔐 **Config encryption**: File config có quyền 600 (chỉ root đọc được)
- ✅ **Input validation**: Kiểm tra format token và hostname
- 🚫 **No hardcoded secrets**: Không lưu mật khẩu trong script
- 🔒 **HTTPS only**: Tất cả traffic qua Cloudflare tunnel được mã hóa
- 🛡️ **Container isolation**: N8N chạy trong container riêng biệt

### 🔑 **Quản lý mật khẩu:**

- N8N admin password: Tự tạo khi lần đầu truy cập
- Cloudflare token: Lưu mã hóa trong `/root/.n8n_install_config`
- Database: SQLite file được backup tự động

### 🚨 **Khuyến nghị bảo mật:**

1. **Sử dụng mật khẩu mạnh** cho N8N admin
2. **Bật 2FA** trên tài khoản Cloudflare
3. **Thường xuyên backup** dữ liệu
4. **Update định kỳ** N8N và hệ thống
5. **Monitor logs** để phát hiện bất thường

## ❓ FAQ

### 🤔 **Câu hỏi thường gặp**

#### **Q: Script có miễn phí không?**
A: Hoàn toàn miễn phí! Chỉ cần trả phí domain (nếu muốn domain riêng).

#### **Q: Có cần kiến thức kỹ thuật không?**
A: Không! Script tự động hóa mọi thứ, chỉ cần làm theo hướng dẫn.

#### **Q: Cloudflare Tunnel có miễn phí không?**
A: Có! Cloudflare Tunnel hoàn toàn miễn phí cho personal use.

#### **Q: Có thể chạy trên VPS không?**
A: Có! Script hoạt động tốt trên mọi VPS Linux.

#### **Q: Dữ liệu có bị mất không?**
A: Không! Script tự động backup trước mọi thao tác quan trọng.

#### **Q: Có thể dùng domain miễn phí không?**
A: Có! Có thể dùng subdomain miễn phí từ DuckDNS, No-IP, etc.

#### **Q: N8N có giới hạn workflow không?**
A: Không! Self-hosted N8N không có giới hạn.

#### **Q: Có thể cài nhiều instance không?**
A: Có! Mỗi server có thể chạy một instance N8N.

### 🔧 **Troubleshooting**

#### **Lỗi "Permission denied":**
```bash
# Đảm bảo chạy với sudo
sudo ./n8n.sh

# Kiểm tra quyền file
chmod +x n8n.sh
```

#### **Lỗi Docker:**
```bash
# Khởi động Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Kiểm tra Docker
docker --version
```

#### **Lỗi Cloudflare Tunnel:**
```bash
# Kiểm tra token
sudo ./n8n.sh config

# Kiểm tra logs
sudo journalctl -u cloudflared -f
```

#### **N8N không truy cập được:**
```bash
# Kiểm tra container
sudo ./n8n.sh status

# Kiểm tra logs
docker logs n8n
```

## 🤝 Đóng góp

### 💡 **Cách đóng góp:**

1. **Fork repository**
2. **Tạo feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push branch**: `git push origin feature/amazing-feature`
5. **Tạo Pull Request**

### 🐛 **Báo lỗi:**

- Tạo [Issue](https://github.com/ndoanh266/setup-n8n/issues) với thông tin chi tiết
- Bao gồm: OS, error message, steps to reproduce

### 💬 **Thảo luận:**

- [Discussions](https://github.com/ndoanh266/setup-n8n/discussions) - Hỏi đáp, chia sẻ kinh nghiệm
- [Telegram Group](https://t.me/n8n_vietnam) - Cộng đồng N8N Việt Nam

---

## 📞 Liên hệ

- 📧 **Email**: nguyendoanh266@gmail.com
- 💬 **Telegram**: [@marketingvn_net](https://t.me/marketingvn_net)
- 🐙 **GitHub**: [ndoanh266](https://github.com/ndoanh266)

---

## 📄 License

MIT License - Xem [LICENSE](LICENSE) để biết thêm chi tiết.

---

## ⭐ Ủng hộ dự án

Nếu script này hữu ích, hãy:
- ⭐ **Star** repository
- 🔄 **Share** với bạn bè
- 💬 **Feedback** để cải thiện
- ☕ **Buy me a coffee**: VIB 002606 NGUYEN THE DOANH

## 🙏 Credits

Xem [CREDITS.md](CREDITS.md) để biết thêm chi tiết về:
- 🏢 J2TEAM Community
- 👨‍💻 Contributors
- 🛠️ Công nghệ sử dụng
- 🌍 Cộng đồng hỗ trợ

---

**Cảm ơn J2TEAM Community đã cho phép chia sẻ**

> 🚀 **Bắt đầu automation journey của bạn ngay hôm nay!**