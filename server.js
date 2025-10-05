const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));

// In-memory storage (replace with database in production)
let products = [
  {
    id: '1',
    name: 'iPhone 15 Pro',
    price: 29990000,
    description: 'Điện thoại iPhone 15 Pro với chip A17 Pro mạnh mẽ',
    category: 'Electronics',
    createdAt: new Date().toISOString(),
    updatedAt: null
  },
  {
    id: '2',
    name: 'MacBook Air M2',
    price: 25990000,
    description: 'Laptop MacBook Air với chip M2 hiệu năng cao',
    category: 'Electronics',
    createdAt: new Date().toISOString(),
    updatedAt: null
  }
];

// API Routes

// GET /api/products - Lấy danh sách sản phẩm
app.get('/api/products', (req, res) => {
  try {
    res.json({
      success: true,
      data: products,
      message: 'Lấy danh sách sản phẩm thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server: ' + error.message
    });
  }
});

// GET /api/products/:id - Lấy chi tiết sản phẩm
app.get('/api/products/:id', (req, res) => {
  try {
    const { id } = req.params;
    const product = products.find(p => p.id === id);
    
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy sản phẩm'
      });
    }
    
    res.json({
      success: true,
      data: product,
      message: 'Lấy chi tiết sản phẩm thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server: ' + error.message
    });
  }
});

// POST /api/products - Tạo sản phẩm mới
app.post('/api/products', (req, res) => {
  try {
    const { name, price, description, category } = req.body;
    
    // Validation
    if (!name || !price || !description || !category) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng điền đầy đủ thông tin'
      });
    }
    
    const newProduct = {
      id: uuidv4(),
      name,
      price: parseInt(price),
      description,
      category,
      createdAt: new Date().toISOString(),
      updatedAt: null
    };
    
    products.push(newProduct);
    
    res.status(201).json({
      success: true,
      data: newProduct,
      message: 'Tạo sản phẩm thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server: ' + error.message
    });
  }
});

// PUT /api/products/:id - Cập nhật sản phẩm
app.put('/api/products/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, description, category } = req.body;
    
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy sản phẩm'
      });
    }
    
    // Validation
    if (!name || !price || !description || !category) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng điền đầy đủ thông tin'
      });
    }
    
    products[productIndex] = {
      ...products[productIndex],
      name,
      price: parseInt(price),
      description,
      category,
      updatedAt: new Date().toISOString()
    };
    
    res.json({
      success: true,
      data: products[productIndex],
      message: 'Cập nhật sản phẩm thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server: ' + error.message
    });
  }
});

// DELETE /api/products/:id - Xóa sản phẩm
app.delete('/api/products/:id', (req, res) => {
  try {
    const { id } = req.params;
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy sản phẩm'
      });
    }
    
    products.splice(productIndex, 1);
    
    res.json({
      success: true,
      message: 'Xóa sản phẩm thành công'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Lỗi server: ' + error.message
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
  console.log(`📱 Ứng dụng CRUD sẵn sàng phục vụ!`);
});

module.exports = app;
