const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Tên sản phẩm là bắt buộc'],
    trim: true,
    maxlength: [100, 'Tên sản phẩm không được quá 100 ký tự']
  },
  price: {
    type: Number,
    required: [true, 'Giá sản phẩm là bắt buộc'],
    min: [0, 'Giá sản phẩm phải lớn hơn hoặc bằng 0']
  },
  description: {
    type: String,
    required: [true, 'Mô tả sản phẩm là bắt buộc'],
    trim: true,
    maxlength: [500, 'Mô tả sản phẩm không được quá 500 ký tự']
  },
  category: {
    type: String,
    required: [true, 'Danh mục sản phẩm là bắt buộc'],
    enum: {
      values: ['Electronics', 'Fashion', 'Books', 'Home', 'Sports', 'Other'],
      message: 'Danh mục không hợp lệ'
    }
  },
  image: {
    type: String,
    default: null
  },
  stock: {
    type: Number,
    default: 0,
    min: [0, 'Số lượng tồn kho phải lớn hơn hoặc bằng 0']
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual field for formatted price
productSchema.virtual('formattedPrice').get(function() {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(this.price);
});

// Index for better search performance
productSchema.index({ name: 'text', description: 'text' });
productSchema.index({ category: 1 });
productSchema.index({ price: 1 });

module.exports = mongoose.model('Product', productSchema);
