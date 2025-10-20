# 🚀 Hướng dẫn Deploy NT-Project lên Render

## 📋 Tổng quan

Hướng dẫn đơn giản để deploy ứng dụng NT-Project lên Render với Docker và GitHub Actions CI/CD.

## 🎯 Mục tiêu

- ✅ Deploy ứng dụng CRUD hoàn chỉnh lên Render
- ✅ Sử dụng Docker containers (Frontend + Backend + MongoDB Atlas)
- ✅ Thiết lập GitHub Actions CI/CD pipeline
- ✅ Tự động build Docker images khi push code

## 🚀 Quick Start

### **Bước 1: Chuẩn bị Render**

1. **Tạo tài khoản Render:**
   - Truy cập: https://render.com
   - Đăng ký tài khoản miễn phí

2. **Kết nối GitHub:**
   - Vào Render Dashboard
   - Connect GitHub repository

### **Bước 2: Tạo Services trên Render**

#### **2.1. Tạo Backend Service:**

1. **Vào Render Dashboard** → **New** → **Web Service**
2. **Cấu hình:**
   - **Name:** `nt-project-backend`
   - **Environment:** `Docker`
   - **Docker Image:** `your-dockerhub-username/nt-project-backend:latest`
   - **Port:** `3000`
   - **Environment Variables:**
     ```
     NODE_ENV=production
     PORT=3000
     MONGODB_URI=mongodb+srv://root:21082004@cluster0.oqhctgp.mongodb.net/nt_project?retryWrites=true&w=majority&appName=Cluster0
     FRONTEND_URL=https://your-frontend-url.onrender.com
     ```

#### **2.2. Tạo Frontend Service:**

1. **Vào Render Dashboard** → **New** → **Web Service**
2. **Cấu hình:**
   - **Name:** `nt-project-frontend`
   - **Environment:** `Docker`
   - **Docker Image:** `your-dockerhub-username/nt-project-frontend:latest`
   - **Port:** `80`

### **Bước 3: Cấu hình GitHub Actions**

1. **Vào GitHub repository** → **Settings** → **Secrets and variables** → **Actions**

2. **Thêm secrets:**
   ```
   DOCKER_USERNAME=your-dockerhub-username
   DOCKER_PASSWORD=your-dockerhub-password
   ```

### **Bước 4: Deploy**

1. **Push code lên GitHub:**
   ```bash
   git add .
   git commit -m "Deploy to Render"
   git push origin main
   ```

2. **GitHub Actions sẽ:**
   - ✅ Chạy tests
   - ✅ Build Docker images
   - ✅ Push images lên Docker Hub

3. **Trên Render:**
   - ✅ Update services với images mới
   - ✅ Deploy services

## 🔧 Cấu hình chi tiết

### **Backend Service Configuration:**

```yaml
Name: nt-project-backend
Environment: Docker
Docker Image: your-username/nt-project-backend:latest
Port: 3000
Environment Variables:
  - NODE_ENV: production
  - PORT: 3000
  - MONGODB_URI: mongodb+srv://root:21082004@cluster0.oqhctgp.mongodb.net/nt_project?retryWrites=true&w=majority&appName=Cluster0
  - FRONTEND_URL: https://your-frontend-url.onrender.com
```

### **Frontend Service Configuration:**

```yaml
Name: nt-project-frontend
Environment: Docker
Docker Image: your-username/nt-project-frontend:latest
Port: 80
```

## 🐳 Docker Images

GitHub Actions sẽ tự động build và push các images:

- `your-username/nt-project-backend:latest`
- `your-username/nt-project-frontend:latest`
- `your-username/nt-project-db-init:latest`

## 🔄 CI/CD Pipeline

```mermaid
graph LR
    A[Push Code] --> B[GitHub Actions]
    B --> C[Run Tests]
    C --> D[Build Docker Images]
    D --> E[Push to Docker Hub]
    E --> F[Update Render Services]
    F --> G[Deploy to Render]
```

## 📊 Monitoring

### **Application URLs:**
- **Backend:** `https://nt-project-backend.onrender.com`
- **Frontend:** `https://nt-project-frontend.onrender.com`
- **Health Check:** `https://nt-project-backend.onrender.com/health`
- **API:** `https://nt-project-backend.onrender.com/api/products`

### **Render Dashboard:**
- **Services:** https://dashboard.render.com
- **Logs:** Available in Render Dashboard
- **Metrics:** CPU, Memory, Response time

## 🛠️ Troubleshooting

### **Common Issues:**

1. **Service không start:**
   - Kiểm tra logs trong Render Dashboard
   - Kiểm tra environment variables
   - Kiểm tra Docker image có đúng không

2. **Database connection failed:**
   - Kiểm tra MongoDB Atlas connection string
   - Kiểm tra network access trong MongoDB Atlas

3. **Frontend không load:**
   - Kiểm tra FRONTEND_URL trong backend
   - Kiểm tra CORS settings

### **Useful Commands:**

```bash
# Check GitHub Actions
# Vào repository → Actions tab

# Check Render logs
# Vào Render Dashboard → Service → Logs

# Update service manually
# Vào Render Dashboard → Service → Manual Deploy
```

## 📈 Performance Optimization

### **Render Free Tier Limits:**
- **CPU:** 0.1 CPU
- **RAM:** 512MB
- **Sleep:** Services sleep after 15 minutes of inactivity
- **Cold start:** ~30 seconds

### **Upgrade Options:**
- **Starter Plan:** $7/month - No sleep, 0.5 CPU, 512MB RAM
- **Standard Plan:** $25/month - 1 CPU, 2GB RAM

## 🔒 Security

1. **Environment Variables:** Never commit secrets to git
2. **MongoDB Atlas:** Use strong passwords and network restrictions
3. **HTTPS:** Render provides free SSL certificates
4. **CORS:** Configure properly for production

## 📞 Support

### **Render Support:**
- **Documentation:** https://render.com/docs
- **Community:** https://community.render.com
- **Status:** https://status.render.com

### **GitHub Actions:**
- **Documentation:** https://docs.github.com/en/actions
- **Marketplace:** https://github.com/marketplace

## 🎉 Success Checklist

- [ ] Render account created
- [ ] GitHub repository connected
- [ ] Backend service created
- [ ] Frontend service created
- [ ] GitHub Actions configured
- [ ] Docker images built and pushed
- [ ] Services deployed successfully
- [ ] Application accessible via URLs
- [ ] CRUD functions working
- [ ] MongoDB Atlas connected

## 📚 Additional Resources

- **Render Documentation:** https://render.com/docs
- **Docker Documentation:** https://docs.docker.com
- **GitHub Actions:** https://docs.github.com/en/actions
- **MongoDB Atlas:** https://docs.atlas.mongodb.com

**Chúc bạn deploy thành công! 🚀**
