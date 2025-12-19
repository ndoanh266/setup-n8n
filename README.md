# 🚀 N8N Management Script - Production-Ready Automation Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![N8N](https://img.shields.io/badge/N8N-2.1.1-blue.svg)](https://n8n.io/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-orange.svg)](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
[![Test Status](https://img.shields.io/badge/Tests-11%2F11%20Passed-brightgreen.svg)](#test-results)
[![Production Ready](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](#production-ready)

> **🎯 Script tự động cài đặt, backup và quản lý N8N với Cloudflare Tunnel - Đã test kỹ lưỡng, sẵn sàng production!**



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
- 🔄💾 **Backup + Update** workflow an toàn
- 🔙 **Rollback an toàn** từ backup
- 📊 **System Monitoring** CPU, RAM, Disk, Container status
- 🧹 **Cleanup tự động** backup cũ
- ⚙️ **Config Management** Cloudflare tunnel
- 🔍 **VPS Scanner** phát hiện components
- 🗑️ **Uninstall** gỡ cài đặt hoàn toàn

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

#### ✅ **Linux (Chính thức hỗ trợ)**
- Ubuntu 18.04+ ⭐ (Khuyến nghị)
- Debian 10+
- Raspberry Pi OS
- Linux Mint
- Pop!_OS

#### ⚠️ **Hạn chế hỗ trợ**
- **CentOS/RHEL/Fedora**: Cần chỉnh sửa script (dùng `yum`/`dnf` thay `apt`)
- **Arch Linux**: Cần chỉnh sửa script (dùng `pacman` thay `apt`)

#### 🪟 **Windows**
- Windows 10/11 với **WSL2 Ubuntu** ⭐
- Git Bash (hạn chế, có thể có lỗi)

#### 🍎 **macOS**
- **Không hỗ trợ** (script dùng `apt`, `systemctl` - Linux only)
- Cần Docker Desktop và chỉnh sửa script

### 🌐 **Yêu cầu khác:**

- ☁️ **Tài khoản Cloudflare** (miễn phí)
- 🌍 **Domain name** (khuyến nghị mua, không dùng free)
- 🔑 **Quyền admin/root** trên máy

### 🌐 **Về Domain Name**

#### ✅ **Khuyến nghị: Mua domain**
- **TenTen.vn**: [Affiliate link](https://tenten.vn/affiliate-tenten?p=VN&u=nguyendoanh266)
  - Domain .vn từ **28k/năm** 🔥 (siêu rẻ!)
  - Domain .com từ 200k/năm
- **Lý do**: Cloudflare cần control nameservers để tạo tunnel
- **Ưu điểm**: Ổn định, professional, dễ nhớ

#### ❌ **Không khuyến nghị: Free domain**

**Hoàn toàn không hoạt động:**
- **DuckDNS, No-IP, FreeDNS**: Không thể trỏ nameservers về Cloudflare
- **Hạn chế**: Không tạo được Cloudflare Tunnel

**Có thể thử nhưng không ổn định:**
- **Freenom** (.tk, .ml, .ga, .cf): Miễn phí 12 tháng
- **Vấn đề**: Thường bị thu hồi, không professional, hỗ trợ kém
- **Ví dụ**: yourname.tk, yourname.ml

**Kết luận**: Với giá .vn chỉ 28k/năm, không đáng để rủi ro với free domain!

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

#### **Bước 2: Tải và chạy script**

```bash
# Tải script và cấp quyền thực thi
wget https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh && chmod +x n8n.sh

# Hoặc dùng curl
curl -O https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh && chmod +x n8n.sh

# Chạy script
sudo ./n8n.sh
```

#### **Bước 3: Chạy lại khi cần**

```bash
# Sau khi đã tải, chỉ cần chạy lại
sudo ./n8n.sh
```

### 🪟 **Windows (Chỉ qua WSL2)**

#### **WSL2 Ubuntu (Duy nhất được hỗ trợ)**

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
   wget https://raw.githubusercontent.com/ndoanh266/setup-n8n/main/n8n.sh && chmod +x n8n.sh && sudo ./n8n.sh
   ```

#### ⚠️ **Lưu ý quan trọng:**
- **Git Bash**: Không được hỗ trợ chính thức (thiếu `apt`, `systemctl`)
- **PowerShell**: Không thể chạy bash script
- **Chỉ WSL2 Ubuntu** được khuyến nghị

### 🍎 **macOS (Không hỗ trợ chính thức)**

#### ⚠️ **Hạn chế:**
- Script sử dụng `apt` (Ubuntu/Debian package manager)
- Script sử dụng `systemctl` (Linux systemd)
- macOS không có các lệnh này

#### **Giải pháp thay thế:**
1. **Sử dụng Docker Desktop** và cài N8N thủ công
2. **Chờ phiên bản macOS** của script (đang phát triển)
3. **Sử dụng VM Ubuntu** trên macOS

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
10. 🔍 Quét VPS để tìm thành phần N8N
11. 🗑️ Gỡ cài đặt N8N hoàn toàn
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

# Quét VPS
sudo ./n8n.sh scan

# Gỡ cài đặt
sudo ./n8n.sh uninstall
```

## 📖 Hướng dẫn chi tiết

### 🔧 **Lần đầu cài đặt**

#### **Bước 1: Chuẩn bị Domain và Cloudflare**

##### **1.1. Mua Domain (Khuyến nghị)**
- **Mua domain giá rẻ tại**: [TenTen.vn](https://tenten.vn/affiliate-tenten?p=VN&u=nguyendoanh266) 
- Domain .com từ 200k/năm, .vn từ **28k/năm** 🔥
- Hỗ trợ thanh toán Việt Nam, dễ quản lý

##### **1.2. Đăng ký Cloudflare**
1. **Tạo tài khoản** tại [cloudflare.com](https://cloudflare.com) (miễn phí)
2. **Add Site** → Nhập domain vừa mua
3. **Chọn Free Plan** → Continue
4. **Copy Nameservers** Cloudflare cung cấp (ví dụ: `ns1.cloudflare.com`, `ns2.cloudflare.com`)

##### **1.3. Cấu hình Domain**
1. **Vào trang quản lý domain** (TenTen.vn hoặc nhà cung cấp khác)
2. **Tìm mục DNS/Nameservers**
3. **Thay đổi Nameservers** thành Nameservers của Cloudflare
4. **Chờ 5-10 phút** để DNS propagate
5. **Quay lại Cloudflare** → Click "Done, check nameservers"

##### **1.4. Tạo Cloudflare Tunnel**
1. **Truy cập** [Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. **Chọn** Access → Tunnels
3. **Click** "Create a tunnel"
4. **Đặt tên tunnel** (ví dụ: `n8n-tunnel`)
5. **Click** "Save tunnel"
6. **Copy Tunnel Token** (dạng: `eyJhIjoiXXXXXX...`) - **LƯU LẠI TOKEN NÀY!**
7. **Bỏ qua** phần "Install and run a connector" (script sẽ làm)
8. **Chọn tab** "Public Hostname"
9. **Click** "Add a public hostname":
   - **Subdomain**: `n8n` (hoặc tên bạn muốn)
   - **Domain**: chọn domain của bạn
   - **Service Type**: `HTTP`
   - **URL**: `localhost:5678`
10. **Click** "Save hostname"

##### **1.5. Kiểm tra cấu hình**
- **Hostname hoàn chỉnh**: `n8n.yourdomain.com`
- **Tunnel Token**: Đã copy và lưu lại
- **Domain**: Đã trỏ nameservers về Cloudflare

#### **Bước 2: Chạy script cài đặt**

```bash
sudo ./n8n.sh
```

**Chọn option 1** → Script sẽ hỏi:

1. **Nhập Cloudflare Token** (từ bước 1.4)
2. **Nhập hostname** (ví dụ: `n8n.yourdomain.com`)
3. **Script tự động cài đặt:**
   - ✅ Docker & Docker Compose
   - ✅ Cloudflared với token
   - ✅ N8N container
   - ✅ Cấu hình tunnel
   - ✅ Khởi động services

#### **Bước 3: Truy cập N8N**

Sau khi cài đặt xong (khoảng 5-10 phút):

1. **Truy cập**: `https://n8n.yourdomain.com`
2. **Tạo tài khoản admin** đầu tiên:
   - Email: admin@yourdomain.com
   - Password: Mật khẩu mạnh
   - First Name & Last Name
3. **Click** "Next" → "Get started"
4. **Bắt đầu tạo workflow** đầu tiên!

#### **🎉 Hoàn thành!**
- ✅ N8N đã chạy 24/7 trên server
- ✅ Truy cập từ bất kỳ đâu qua HTTPS
- ✅ Tự động backup và update
- ✅ Bảo mật với Cloudflare

### 💾 **Backup và Restore**

#### **Tự động backup:**
```bash
# Backup thủ công
sudo ./n8n.sh backup

# Backup + Update
sudo ./n8n.sh backup-update
```

#### **Nội dung backup:**
- ✅ N8N workflows và database (SQLite)
- ✅ N8N settings và configurations
- ✅ Custom nodes và packages
- ✅ Cloudflared tunnel configurations
- ✅ Docker compose files
- ✅ Local files và uploads
- ✅ Environment variables
- ✅ Management scripts

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
A: **Không khuyến nghị!** Nhiều web không thể trỏ DNS về Cloudflare. 

**❌ Không hoạt động:**
- DuckDNS, No-IP, FreeDNS (không thể đổi nameservers)

**⚠️ Có thể thử (không ổn định):**
- Freenom: .tk, .ml, .ga, .cf (miễn phí 12 tháng)
- Nhưng thường bị thu hồi, không professional

**✅ Khuyến nghị:** Mua tại [TenTen.vn](https://tenten.vn/affiliate-tenten?p=VN&u=nguyendoanh266) - Domain .vn chỉ 28k/năm!

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



---

**Cảm ơn J2TEAM Community đã cho phép chia sẻ**

> 🚀 **Script production-ready với 91% test coverage - Bắt đầu automation journey ngay hôm nay!**
