# NT Project - Full Stack Application

Ứng dụng quản lý sản phẩm full-stack với Node.js, Express, MongoDB và Docker.

## 🚀 Tính năng

- ✅ **Full Stack Architecture** - Frontend + Backend + Database
- ✅ **MongoDB Integration** - Persistent data storage
- ✅ **RESTful API** - Complete CRUD operations
- ✅ **Responsive UI** - Modern, mobile-friendly interface
- ✅ **Docker Support** - Multi-container deployment
- ✅ **CI/CD Pipeline** - GitHub Actions automation
- ✅ **Production Ready** - Health checks, monitoring, backups
- ✅ **Ubuntu VM Deployment** - Ready for cloud deployment

## 🏗️ Kiến trúc hệ thống

```
NT Project/
├── backend/                 # Backend API (Node.js + Express)
│   ├── controllers/         # API controllers
│   ├── models/             # MongoDB models
│   ├── routes/             # API routes
│   ├── middleware/         # Custom middleware
│   ├── server.js           # Main server file
│   └── Dockerfile          # Backend container
├── frontend/               # Frontend (HTML + CSS + JS)
│   ├── index.html          # Main page
│   ├── script.js           # Frontend logic
│   ├── style.css           # Styling
│   ├── nginx.conf          # Nginx configuration
│   └── Dockerfile          # Frontend container
├── database/               # Database setup
│   ├── init/               # MongoDB initialization scripts
│   └── Dockerfile          # Database container
├── .github/workflows/      # CI/CD pipelines
├── docker-compose.yml      # Multi-container orchestration
├── deploy-ubuntu.sh        # Ubuntu VM deployment script
└── setup-production.sh     # Production setup script
```

## 🛠️ Cài đặt và chạy

### 1. Clone repository

```bash
git clone <repository-url>
cd NT-project
```

### 2. Development Mode

```bash
# Cài đặt dependencies cho backend
cd backend
npm install

# Chạy MongoDB (cần Docker)
docker run -d -p 27017:27017 --name mongo mongo:7.0

# Chạy backend
npm run dev

# Chạy frontend (terminal mới)
cd ../frontend
npm install
npm run dev
```

### 3. Docker Deployment

```bash
# Chạy tất cả services với Docker Compose
docker-compose up -d

# Xem logs
docker-compose logs -f

# Dừng services
docker-compose down
```

### 4. Production Setup

```bash
# Setup cho production
./setup-production.sh

# Deploy với nginx reverse proxy
docker-compose -f docker-compose.yml -f docker-compose.nginx.yml up -d
```

## 🌐 Truy cập ứng dụng

### Development
- **Frontend:** http://localhost:3001
- **Backend API:** http://localhost:3000
- **API Health:** http://localhost:3000/health

### Production (với nginx)
- **Application:** http://localhost (port 80)
- **API:** http://localhost/api/

## 📡 API Endpoints

### Products
- `GET /api/products` - Lấy danh sách sản phẩm (có pagination, search, filter)
- `GET /api/products/:id` - Lấy chi tiết sản phẩm
- `POST /api/products` - Tạo sản phẩm mới
- `PUT /api/products/:id` - Cập nhật sản phẩm
- `DELETE /api/products/:id` - Xóa sản phẩm (soft delete)
- `GET /api/products/categories` - Lấy danh sách danh mục

### System
- `GET /health` - Health check endpoint
- `GET /api` - API information

## 🐳 Docker Services

### Services Overview
- **mongo** - MongoDB database (port 27017)
- **backend** - Node.js API server (port 3000)
- **frontend** - Nginx web server (port 3001)
- **nginx** - Reverse proxy (port 80) - optional

### Container Management
```bash
# Xem trạng thái containers
docker-compose ps

# Restart service
docker-compose restart <service-name>

# Xem logs của service cụ thể
docker-compose logs -f <service-name>

# Update và restart
docker-compose pull && docker-compose up -d
```

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow
1. **Test** - Chạy tests và linting
2. **Build** - Build Docker images
3. **Deploy** - Deploy lên Ubuntu VM
4. **Notify** - Thông báo kết quả

### Secrets cần thiết
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password
- `VM_HOST` - Ubuntu VM IP address
- `VM_USERNAME` - VM username
- `VM_SSH_KEY` - SSH private key

## 🖥️ Ubuntu VM Deployment

### Automated Deployment
```bash
# Chạy script deploy tự động
./deploy-ubuntu.sh
```

### Manual Deployment
```bash
# 1. Copy project lên VM
scp -r . user@vm-ip:/opt/nt-project

# 2. SSH vào VM
ssh user@vm-ip

# 3. Chạy setup
cd /opt/nt-project
./setup-production.sh
docker-compose up -d
```

## 📊 Monitoring & Maintenance

### Health Monitoring
```bash
# Kiểm tra trạng thái services
./monitor.sh

# Health check endpoints
curl http://localhost:3000/health  # Backend
curl http://localhost:3001/health  # Frontend
```

### Backup & Restore
```bash
# Tạo backup
./backup.sh

# Restore từ backup
./restore.sh backups/app_backup_20231201_120000.tar.gz
```

### Logs
```bash
# Xem logs tất cả services
docker-compose logs -f

# Xem logs service cụ thể
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongo
```

## 🔧 Configuration

### Environment Variables
```env
# Docker Configuration
DOCKER_USERNAME=your-docker-username

# Database Configuration
MONGODB_URI=mongodb://mongo:27017/nt_project
DB_NAME=nt_project

# Server Configuration
NODE_ENV=production
PORT=3000

# JWT Configuration
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# Frontend Configuration
FRONTEND_URL=http://localhost:3001
```

## 🛡️ Security Features

- **Helmet.js** - Security headers
- **Rate Limiting** - API rate limiting
- **CORS** - Cross-origin resource sharing
- **Input Validation** - Data validation
- **Non-root User** - Docker security
- **Firewall** - Ubuntu firewall configuration

## 📈 Performance Features

- **MongoDB Indexing** - Database optimization
- **Nginx Caching** - Static file caching
- **Gzip Compression** - Response compression
- **Health Checks** - Container health monitoring
- **Resource Limits** - Container resource management

## 🧪 Testing

```bash
# Chạy tests
cd backend
npm test

# API testing với curl
curl -X GET http://localhost:3000/api/products
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Product","price":100000,"description":"Test","category":"Other"}'
```

## 📝 Development

### Scripts
- `npm start` - Chạy production server
- `npm run dev` - Chạy development server với nodemon
- `npm test` - Chạy tests

### Code Structure
- **MVC Pattern** - Model-View-Controller architecture
- **RESTful API** - Standard REST conventions
- **Error Handling** - Comprehensive error handling
- **Logging** - Structured logging
- **Validation** - Input validation và sanitization

## 🤝 Contributing

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Tạo Pull Request

## 📄 License

MIT License - xem file [LICENSE](LICENSE) để biết thêm chi tiết.

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Kiểm tra ports đang sử dụng
   netstat -tulpn | grep :3000
   ```

2. **MongoDB connection issues**
   ```bash
   # Kiểm tra MongoDB container
   docker-compose logs mongo
   ```

3. **Frontend không kết nối được API**
   - Kiểm tra CORS configuration
   - Verify API_BASE_URL trong script.js

4. **Docker build fails**
   ```bash
   # Clean build
   docker-compose build --no-cache
   ```

### Support
- Tạo issue trên GitHub
- Kiểm tra logs: `docker-compose logs -f`
- Health checks: `curl http://localhost:3000/health`
