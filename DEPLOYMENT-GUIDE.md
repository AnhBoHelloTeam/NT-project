# 🚀 Hướng dẫn Deploy NT Project lên Ubuntu VM

## 📋 Tổng quan

Hướng dẫn này sẽ giúp bạn deploy dự án NT Project lên máy ảo Ubuntu thay vì sử dụng Render. Dự án bao gồm:

- **Frontend**: HTML/CSS/JS với Nginx
- **Backend**: Node.js + Express API
- **Database**: MongoDB
- **CI/CD**: GitHub Actions
- **Containerization**: Docker + Docker Compose

## 🎯 Mục tiêu

- ✅ Tách Frontend và Backend thành 2 service riêng biệt
- ✅ Thêm MongoDB database để lưu trữ dữ liệu
- ✅ Setup CI/CD pipeline với GitHub Actions
- ✅ Deploy lên Ubuntu VM thay vì Render
- ✅ Tự động hóa quá trình deployment

## 🏗️ Kiến trúc mới

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (Nginx)       │◄──►│   (Node.js)     │◄──►│   (MongoDB)     │
│   Port: 3001    │    │   Port: 3000    │    │   Port: 27017   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Nginx Proxy   │
                    │   Port: 80      │
                    └─────────────────┘
```

## 🛠️ Chuẩn bị

### 1. Yêu cầu hệ thống

- **Ubuntu VM**: Ubuntu 20.04/22.04 LTS
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB)
- **Storage**: Tối thiểu 20GB
- **Network**: Mở ports 22, 80, 3000, 3001, 27017

### 2. Tài khoản cần thiết

- **GitHub**: Repository với code
- **Docker Hub**: Để push/pull images
- **VM Access**: SSH key hoặc password

## 🚀 Bước 1: Setup GitHub Secrets

Vào repository GitHub > Settings > Secrets and variables > Actions, thêm:

```bash
DOCKER_USERNAME=your-dockerhub-username
DOCKER_PASSWORD=your-dockerhub-password
VM_HOST=your-vm-ip-address
VM_USERNAME=ubuntu
VM_SSH_KEY=your-private-ssh-key-content
```

## 🖥️ Bước 2: Setup Ubuntu VM

### 2.1 Tạo VM

```bash
# Tạo VM với các thông số:
# - OS: Ubuntu 22.04 LTS
# - RAM: 4GB
# - Storage: 40GB
# - Network: Public IP
```

### 2.2 Cấu hình Security Group

Mở các ports sau:
- **22**: SSH access
- **80**: HTTP (nginx proxy)
- **3000**: Backend API (optional)
- **3001**: Frontend (optional)
- **27017**: MongoDB (optional, chỉ cho development)

### 2.3 SSH vào VM

```bash
# Sử dụng SSH key
ssh -i your-key.pem ubuntu@your-vm-ip

# Hoặc sử dụng password
ssh ubuntu@your-vm-ip
```

## 🐳 Bước 3: Cài đặt Docker trên VM

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout và login lại để apply group changes
exit
ssh -i your-key.pem ubuntu@your-vm-ip
```

## 📁 Bước 4: Deploy Application

### 4.1 Automated Deployment (Khuyến nghị)

```bash
# Clone repository
git clone https://github.com/your-username/NT-project.git
cd NT-project

# Chạy script deploy tự động
chmod +x deploy-ubuntu.sh
./deploy-ubuntu.sh
```

### 4.2 Manual Deployment

```bash
# 1. Tạo project directory
sudo mkdir -p /opt/nt-project
sudo chown ubuntu:ubuntu /opt/nt-project
cd /opt/nt-project

# 2. Copy project files
# (Copy từ máy local hoặc clone từ GitHub)

# 3. Setup production
chmod +x setup-production.sh
./setup-production.sh

# 4. Start services
docker-compose up -d
```

## 🔧 Bước 5: Cấu hình CI/CD

### 5.1 Push code lên GitHub

```bash
# Add và commit changes
git add .
git commit -m "Setup full-stack architecture with MongoDB"
git push origin main
```

### 5.2 Kiểm tra GitHub Actions

1. Vào repository GitHub
2. Click tab "Actions"
3. Xem workflow "CI/CD Pipeline" chạy
4. Kiểm tra logs nếu có lỗi

## 🌐 Bước 6: Truy cập ứng dụng

### 6.1 URLs

- **Frontend**: http://your-vm-ip:3001
- **Backend API**: http://your-vm-ip:3000
- **API Health**: http://your-vm-ip:3000/health

### 6.2 Với Nginx Proxy (Production)

```bash
# Deploy với nginx reverse proxy
docker-compose -f docker-compose.yml -f docker-compose.nginx.yml up -d
```

Sau đó truy cập:
- **Application**: http://your-vm-ip (port 80)
- **API**: http://your-vm-ip/api/

## 📊 Bước 7: Monitoring & Maintenance

### 7.1 Kiểm tra trạng thái

```bash
# Xem containers đang chạy
docker-compose ps

# Xem logs
docker-compose logs -f

# Kiểm tra health
curl http://localhost:3000/health
```

### 7.2 Monitoring script

```bash
# Chạy monitoring script
./monitor.sh
```

### 7.3 Backup

```bash
# Tạo backup
./backup.sh

# Restore từ backup
./restore.sh backups/app_backup_20231201_120000.tar.gz
```

## 🔄 Bước 8: Update Application

### 8.1 Manual Update

```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose down
docker-compose up -d

# Clean up old images
docker image prune -f
```

### 8.2 Automated Update (với CI/CD)

```bash
# Push code lên GitHub
git add .
git commit -m "Update application"
git push origin main

# GitHub Actions sẽ tự động deploy
```

## 🛡️ Bước 9: Security Configuration

### 9.1 Firewall

```bash
# Cấu hình UFW
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw --force enable
```

### 9.2 SSL/HTTPS (Optional)

```bash
# Cài đặt Certbot
sudo apt install certbot python3-certbot-nginx

# Tạo SSL certificate
sudo certbot --nginx -d your-domain.com
```

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Kiểm tra ports đang sử dụng
   sudo netstat -tulpn | grep :3000
   ```

2. **Docker permission issues**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Logout và login lại
   ```

3. **MongoDB connection issues**
   ```bash
   # Kiểm tra MongoDB container
   docker-compose logs mongo
   ```

4. **GitHub Actions fails**
   - Kiểm tra secrets trong GitHub repository
   - Verify SSH key có quyền truy cập VM
   - Check VM có đủ resources

### Debug Commands

```bash
# Xem logs chi tiết
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongo

# Kiểm tra network
docker network ls
docker network inspect nt-project_app-network

# Kiểm tra volumes
docker volume ls
docker volume inspect nt-project_mongo_data
```

## 📈 Performance Optimization

### 1. Resource Limits

```yaml
# Trong docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

### 2. Database Optimization

```bash
# MongoDB indexes đã được tạo tự động
# Kiểm tra performance
docker-compose exec mongo mongosh --eval "db.products.getIndexes()"
```

### 3. Nginx Caching

```nginx
# Nginx caching đã được cấu hình
# Static files được cache 1 năm
# API responses có thể cache tùy theo use case
```

## 🎉 Kết luận

Sau khi hoàn thành các bước trên, bạn sẽ có:

- ✅ **Full-stack application** với Frontend, Backend và Database
- ✅ **MongoDB** để lưu trữ dữ liệu persistent
- ✅ **CI/CD pipeline** tự động deploy khi push code
- ✅ **Ubuntu VM deployment** thay vì Render
- ✅ **Production-ready** với monitoring, backup, security

## 📞 Support

Nếu gặp vấn đề:

1. Kiểm tra logs: `docker-compose logs -f`
2. Health checks: `curl http://localhost:3000/health`
3. Tạo issue trên GitHub repository
4. Kiểm tra GitHub Actions logs

---

**Chúc bạn deploy thành công! 🚀**
