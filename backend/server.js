const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');

const config = require('./config');
const connectDB = require('./middleware/database');

// Import routes
const productRoutes = require('./routes/products');

const app = express();

// Connect to MongoDB
connectDB();

// Security middleware
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Quá nhiều requests từ IP này, vui lòng thử lại sau 15 phút'
  }
});
app.use('/api/', limiter);

// CORS configuration
app.use(cors({
  origin: config.FRONTEND_URL,
  credentials: true
}));

// Body parser middleware
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Routes
app.use('/api/products', productRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: config.NODE_ENV,
    version: '1.0.0'
  });
});

// API info endpoint
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'NT Project API',
    version: '1.0.0',
    endpoints: {
      products: '/api/products',
      health: '/health'
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint không tồn tại'
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('Error:', error);
  
  res.status(error.status || 500).json({
    success: false,
    message: error.message || 'Lỗi server nội bộ',
    ...(config.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Start server
app.listen(config.PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend server đang chạy tại http://localhost:${config.PORT}`);
  console.log(`📱 API sẵn sàng phục vụ!`);
  console.log(`🌍 Environment: ${config.NODE_ENV}`);
});

module.exports = app;
