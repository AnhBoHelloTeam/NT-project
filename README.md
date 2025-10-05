# CRUD App với Docker & GitHub Actions CI/CD

Ứng dụng CRUD đơn giản sử dụng Node.js, Express, Docker và GitHub Actions để triển khai lên AWS EC2.

## 🚀 Tính năng

- ✅ CRUD operations cho sản phẩm
- ✅ RESTful API với Express.js
- ✅ Frontend responsive với HTML/CSS/JavaScript
- ✅ Docker containerization
- ✅ CI/CD pipeline với GitHub Actions
- ✅ Auto deployment lên AWS EC2

/////
## 📋 Yêu cầu

- Node.js 18+
- Docker & Docker Compose
- GitHub repository
- Docker Hub account
- AWS EC2 instance

## 🛠️ Cài đặt

### 1. Clone repository
```bash
git clone https://github.com/AnhBoHelloTeam/NT-project.git
cd NT-project
```

### 2. Cài đặt dependencies
```bash
npm install
```

### 3. Chạy development
```bash
npm run dev
```

### 4. Build Docker image
```bash
docker build -t crud-app .
```

### 5. Chạy với Docker Compose
```bash
docker-compose up -d
```

## 🔧 Cấu hình CI/CD

### 1. Thiết lập GitHub Secrets

Vào repository GitHub > Settings > Secrets and variables > Actions, thêm các secrets sau:

- `DOCKER_USERNAME`: Tên đăng nhập Docker Hub
- `DOCKER_PASSWORD`: Mật khẩu Docker Hub
- `SERVER_HOST`: IP của EC2 instance
- `SERVER_USERNAME`: Username của EC2 (thường là `ubuntu`)
- `SERVER_SSH_KEY`: Nội dung file .pem key

### 2. Cấu hình EC2

#### Tạo EC2 instance:
- OS: Ubuntu 20.04/22.04
- Instance type: t2.micro (free tier)
- Security Group: Mở port 22 (SSH), 80 (HTTP), 443 (HTTPS)

#### Cài đặt Docker trên EC2:
```bash
# SSH vào EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Cài đặt Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout và login lại
exit
```

### 3. Push code lên GitHub

```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

## 📁 Cấu trúc project

```
NT-project/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── public/                     # Frontend files
│   ├── index.html
│   ├── script.js
│   └── style.css
├── server.js                   # Backend API
├── package.json               # Node.js dependencies
├── Dockerfile                 # Docker configuration
├── docker-compose.yml         # Docker Compose config
└── README.md                  # Documentation
```

## 🔄 CI/CD Pipeline

Khi push code lên branch `main`, GitHub Actions sẽ:

1. **Build**: Build Docker image
2. **Test**: Chạy tests (nếu có)
3. **Push**: Push image lên Docker Hub
4. **Deploy**: Deploy lên EC2 server
5. **Verify**: Kiểm tra health check

## 🌐 API Endpoints

- `GET /api/products` - Lấy danh sách sản phẩm
- `GET /api/products/:id` - Lấy chi tiết sản phẩm
- `POST /api/products` - Tạo sản phẩm mới
- `PUT /api/products/:id` - Cập nhật sản phẩm
- `DELETE /api/products/:id` - Xóa sản phẩm
- `GET /health` - Health check

## 🐳 Docker Commands

```bash
# Build image
docker build -t crud-app .

# Run container
docker run -p 3000:3000 crud-app

# Run với Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

## 🔍 Troubleshooting

### Kiểm tra deployment:
```bash
# SSH vào EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Kiểm tra containers
docker ps

# Xem logs
docker-compose logs

# Kiểm tra health
curl http://localhost/health
```

### GitHub Actions logs:
- Vào repository > Actions tab
- Click vào workflow run để xem logs chi tiết

## 📝 Notes

- Ứng dụng chạy trên port 3000 trong container
- EC2 expose port 80 để truy cập từ internet
- Health check endpoint: `/health`
- Auto restart container khi crash

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch
3. Commit changes
4. Push lên branch
5. Tạo Pull Request

## 📄 License

MIT License
