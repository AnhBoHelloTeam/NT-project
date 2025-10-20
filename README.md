# 🚀 NT-Project

Full-stack CRUD application with Node.js, Express, MongoDB Atlas, and Docker.

## ✨ Features

- ✅ **Full CRUD Operations** - Create, Read, Update, Delete products
- ✅ **RESTful API** - Complete backend API with Express.js
- ✅ **MongoDB Atlas** - Cloud database integration
- ✅ **Docker Support** - Containerized application
- ✅ **CI/CD Pipeline** - GitHub Actions automation
- ✅ **Test Dashboard** - Built-in testing interface
- ✅ **Responsive UI** - Modern web interface

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   MongoDB       │
│   (Nginx)       │    │   (Node.js)     │    │   (Atlas)       │
│   Port: 3001    │◄──►│   Port: 3000    │◄──►│   Cloud         │
│   Container     │    │   Container     │    │   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### **Local Development:**

```bash
# Clone repository
git clone https://github.com/your-username/NT-project.git
cd NT-project

# Start with Docker
docker-compose up -d --build

# Access application
# Frontend: http://localhost:3001
# Backend: http://localhost:3000
```

### **Deploy to Render:**

1. **Follow the guide:** [RENDER-DEPLOYMENT-GUIDE.md](RENDER-DEPLOYMENT-GUIDE.md)
2. **Configure GitHub Actions**
3. **Push code to trigger deployment**

## 📱 Application URLs

### **Local Development:**
- **Frontend:** http://localhost:3001
- **Backend API:** http://localhost:3000
- **Health Check:** http://localhost:3000/health
- **Test Dashboard:** http://localhost:3001/test-dashboard.html

### **Production (Render):**
- **Frontend:** https://your-frontend-url.onrender.com
- **Backend API:** https://your-backend-url.onrender.com
- **Health Check:** https://your-backend-url.onrender.com/health

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products |
| GET | `/api/products/:id` | Get product by ID |
| POST | `/api/products` | Create new product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |
| GET | `/health` | Health check |

## 🐳 Docker Commands

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart
```

## 🔄 CI/CD Pipeline

GitHub Actions automatically:
- ✅ Run tests
- ✅ Build Docker images
- ✅ Push to Docker Hub
- ✅ Deploy to Render

## 🧪 Testing

### **Test Dashboard:**
- Access: http://localhost:3001/test-dashboard.html
- Features: API testing, health checks, deployment status

### **Manual Testing:**
```bash
# Test API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/products

# Test CRUD operations
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Product","price":100000,"description":"Test Description","category":"Electronics"}'
```

## 📊 Project Structure

```
NT-project/
├── backend/                 # Backend API
│   ├── controllers/         # API controllers
│   ├── models/             # Database models
│   ├── routes/             # API routes
│   ├── middleware/         # Express middleware
│   └── __tests__/          # Unit tests
├── frontend/               # Frontend application
│   ├── index.html          # Main page
│   ├── script.js           # Frontend logic
│   ├── style.css           # Styling
│   └── test-dashboard.html # Test interface
├── database/               # Database initialization
├── .github/workflows/      # GitHub Actions
├── docker-compose.yml      # Docker configuration
└── render.yaml            # Render deployment config
```

## 🛠️ Development

### **Prerequisites:**
- Node.js 18+
- Docker & Docker Compose
- MongoDB Atlas account
- GitHub account

### **Environment Variables:**
```bash
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/database
FRONTEND_URL=http://localhost:3001
```

## 📚 Documentation

- **Deployment Guide:** [RENDER-DEPLOYMENT-GUIDE.md](RENDER-DEPLOYMENT-GUIDE.md)
- **Project Summary:** [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md)
- **Testing Guide:** [TESTING.md](TESTING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🎉 Success Checklist

- [ ] Application running locally
- [ ] All CRUD operations working
- [ ] MongoDB Atlas connected
- [ ] Docker containers running
- [ ] GitHub Actions passing
- [ ] Deployed to Render
- [ ] Test dashboard functional

**Happy coding! 🚀**