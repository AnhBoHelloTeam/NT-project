module.exports = {
  // Database Configuration
  MONGODB_URI: process.env.MONGODB_URI || 'mongodb://mongo:27017/nt_project',
  DB_NAME: process.env.DB_NAME || 'nt_project',
  
  // Server Configuration
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  
  // JWT Configuration
  JWT_SECRET: process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  
  // Frontend Configuration
  FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:3001'
};
