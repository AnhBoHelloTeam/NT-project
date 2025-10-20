// Initialize database with sample data
db = db.getSiblingDB('nt_project');

// Create collections
db.createCollection('products');

// Insert sample products
db.products.insertMany([
  {
    name: 'iPhone 15 Pro',
    price: 29990000,
    description: 'Điện thoại iPhone 15 Pro với chip A17 Pro mạnh mẽ',
    category: 'Electronics',
    stock: 10,
    isActive: true,
    createdAt: new Date(),
    updatedAt: null
  },
  {
    name: 'MacBook Air M2',
    price: 25990000,
    description: 'Laptop MacBook Air với chip M2 hiệu năng cao',
    category: 'Electronics',
    stock: 5,
    isActive: true,
    createdAt: new Date(),
    updatedAt: null
  },
  {
    name: 'Sách Lập Trình Node.js',
    price: 150000,
    description: 'Sách hướng dẫn lập trình Node.js từ cơ bản đến nâng cao',
    category: 'Books',
    stock: 20,
    isActive: true,
    createdAt: new Date(),
    updatedAt: null
  },
  {
    name: 'Áo Thun Cotton',
    price: 120000,
    description: 'Áo thun cotton chất lượng cao, thoáng mát',
    category: 'Fashion',
    stock: 50,
    isActive: true,
    createdAt: new Date(),
    updatedAt: null
  },
  {
    name: 'Tạ Tay 5kg',
    price: 250000,
    description: 'Tạ tay 5kg cho tập luyện tại nhà',
    category: 'Sports',
    stock: 15,
    isActive: true,
    createdAt: new Date(),
    updatedAt: null
  }
]);

// Create indexes for better performance
db.products.createIndex({ name: 'text', description: 'text' });
db.products.createIndex({ category: 1 });
db.products.createIndex({ price: 1 });
db.products.createIndex({ isActive: 1 });

print('Database initialized successfully with sample data!');
