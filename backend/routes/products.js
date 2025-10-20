const express = require('express');
const router = express.Router();
const {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  getCategories
} = require('../controllers/productController');

// GET /api/products - Lấy danh sách sản phẩm
router.get('/', getProducts);

// GET /api/products/categories - Lấy danh sách danh mục
router.get('/categories', getCategories);

// GET /api/products/:id - Lấy chi tiết sản phẩm
router.get('/:id', getProductById);

// POST /api/products - Tạo sản phẩm mới
router.post('/', createProduct);

// PUT /api/products/:id - Cập nhật sản phẩm
router.put('/:id', updateProduct);

// DELETE /api/products/:id - Xóa sản phẩm
router.delete('/:id', deleteProduct);

module.exports = router;
