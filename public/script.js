// Global variables
let products = [];
let editingProductId = null;
let filteredProducts = [];

// DOM elements
const productForm = document.getElementById('productForm');
const productsGrid = document.getElementById('productsGrid');
const loading = document.getElementById('loading');
const noProducts = document.getElementById('noProducts');
const searchInput = document.getElementById('searchInput');
const statusMessage = document.getElementById('statusMessage');
const cancelEditBtn = document.getElementById('cancelEdit');
const modal = document.getElementById('productModal');
const modalTitle = document.getElementById('modalTitle');
const modalBody = document.getElementById('modalBody');

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    loadProducts();
    setupEventListeners();
});

// Event listeners
function setupEventListeners() {
    // Form submission
    productForm.addEventListener('submit', handleFormSubmit);
    
    // Cancel edit
    cancelEditBtn.addEventListener('click', cancelEdit);
    
    // Search
    searchInput.addEventListener('input', handleSearch);
    
    // Modal close
    document.querySelector('.close').addEventListener('click', closeModal);
    window.addEventListener('click', function(event) {
        if (event.target === modal) {
            closeModal();
        }
    });
}

// API functions
async function apiCall(url, options = {}) {
    try {
        const response = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.message || 'Có lỗi xảy ra');
        }
        
        return data;
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

// Load products
async function loadProducts() {
    try {
        showLoading(true);
        const response = await apiCall('/api/products');
        products = response.data;
        filteredProducts = [...products];
        renderProducts();
    } catch (error) {
        showMessage('Lỗi khi tải danh sách sản phẩm: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

// Handle form submission
async function handleFormSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(productForm);
    const productData = {
        name: formData.get('name'),
        price: parseInt(formData.get('price')),
        description: formData.get('description'),
        category: formData.get('category')
    };
    
    try {
        if (editingProductId) {
            // Update existing product
            await apiCall(`/api/products/${editingProductId}`, {
                method: 'PUT',
                body: JSON.stringify(productData)
            });
            showMessage('Cập nhật sản phẩm thành công!', 'success');
        } else {
            // Create new product
            await apiCall('/api/products', {
                method: 'POST',
                body: JSON.stringify(productData)
            });
            showMessage('Thêm sản phẩm thành công!', 'success');
        }
        
        productForm.reset();
        cancelEdit();
        loadProducts();
    } catch (error) {
        showMessage('Lỗi: ' + error.message, 'error');
    }
}

// Delete product
async function deleteProduct(id) {
    if (!confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')) {
        return;
    }
    
    try {
        await apiCall(`/api/products/${id}`, {
            method: 'DELETE'
        });
        showMessage('Xóa sản phẩm thành công!', 'success');
        loadProducts();
    } catch (error) {
        showMessage('Lỗi khi xóa sản phẩm: ' + error.message, 'error');
    }
}

// Edit product
function editProduct(id) {
    const product = products.find(p => p.id === id);
    if (!product) return;
    
    editingProductId = id;
    
    // Fill form with product data
    document.getElementById('name').value = product.name;
    document.getElementById('price').value = product.price;
    document.getElementById('description').value = product.description;
    document.getElementById('category').value = product.category;
    
    // Show cancel button
    cancelEditBtn.style.display = 'inline-flex';
    
    // Change submit button text
    const submitBtn = productForm.querySelector('button[type="submit"]');
    submitBtn.innerHTML = '<i class="fas fa-save"></i> Cập nhật sản phẩm';
    
    // Scroll to form
    document.querySelector('.form-section').scrollIntoView({ 
        behavior: 'smooth' 
    });
}

// Cancel edit
function cancelEdit() {
    editingProductId = null;
    productForm.reset();
    cancelEditBtn.style.display = 'none';
    
    // Reset submit button text
    const submitBtn = productForm.querySelector('button[type="submit"]');
    submitBtn.innerHTML = '<i class="fas fa-save"></i> Lưu sản phẩm';
}

// View product details
async function viewProduct(id) {
    try {
        const response = await apiCall(`/api/products/${id}`);
        const product = response.data;
        
        modalTitle.textContent = product.name;
        modalBody.innerHTML = `
            <div class="product-detail">
                <div class="detail-item">
                    <strong>Giá:</strong> 
                    <span class="price">${formatPrice(product.price)}</span>
                </div>
                <div class="detail-item">
                    <strong>Danh mục:</strong> 
                    <span class="category">${product.category}</span>
                </div>
                <div class="detail-item">
                    <strong>Mô tả:</strong>
                    <p>${product.description}</p>
                </div>
                <div class="detail-item">
                    <strong>Ngày tạo:</strong> 
                    <span>${formatDate(product.createdAt)}</span>
                </div>
                ${product.updatedAt ? `
                <div class="detail-item">
                    <strong>Cập nhật lần cuối:</strong> 
                    <span>${formatDate(product.updatedAt)}</span>
                </div>
                ` : ''}
            </div>
        `;
        
        modal.style.display = 'block';
    } catch (error) {
        showMessage('Lỗi khi tải chi tiết sản phẩm: ' + error.message, 'error');
    }
}

// Close modal
function closeModal() {
    modal.style.display = 'none';
}

// Handle search
function handleSearch(e) {
    const searchTerm = e.target.value.toLowerCase();
    filteredProducts = products.filter(product => 
        product.name.toLowerCase().includes(searchTerm) ||
        product.description.toLowerCase().includes(searchTerm) ||
        product.category.toLowerCase().includes(searchTerm)
    );
    renderProducts();
}

// Render products
function renderProducts() {
    if (filteredProducts.length === 0) {
        productsGrid.style.display = 'none';
        noProducts.style.display = 'block';
        return;
    }
    
    productsGrid.style.display = 'grid';
    noProducts.style.display = 'none';
    
    productsGrid.innerHTML = filteredProducts.map(product => `
        <div class="product-card" data-id="${product.id}">
            <div class="product-header">
                <div>
                    <div class="product-name">${product.name}</div>
                </div>
                <div class="product-category">${product.category}</div>
            </div>
            
            <div class="product-price">${formatPrice(product.price)}</div>
            
            <div class="product-description">
                ${product.description.length > 100 ? 
                    product.description.substring(0, 100) + '...' : 
                    product.description
                }
            </div>
            
            <div class="product-actions">
                <button class="btn btn-primary" onclick="viewProduct('${product.id}')">
                    <i class="fas fa-eye"></i> Xem
                </button>
                <button class="btn btn-warning" onclick="editProduct('${product.id}')">
                    <i class="fas fa-edit"></i> Sửa
                </button>
                <button class="btn btn-danger" onclick="deleteProduct('${product.id}')">
                    <i class="fas fa-trash"></i> Xóa
                </button>
            </div>
            
            <div class="product-date">
                Tạo: ${formatDate(product.createdAt)}
                ${product.updatedAt ? ` | Cập nhật: ${formatDate(product.updatedAt)}` : ''}
            </div>
        </div>
    `).join('');
}

// Utility functions
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(price);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function showLoading(show) {
    loading.style.display = show ? 'block' : 'none';
    if (show) {
        productsGrid.style.display = 'none';
        noProducts.style.display = 'none';
    }
}

function showMessage(message, type = 'info') {
    statusMessage.textContent = message;
    statusMessage.className = `status-message ${type}`;
    statusMessage.classList.add('show');
    
    setTimeout(() => {
        statusMessage.classList.remove('show');
    }, 3000);
}

// Add some CSS for product detail modal
const style = document.createElement('style');
style.textContent = `
    .product-detail {
        line-height: 1.8;
    }
    
    .detail-item {
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 1px solid #e2e8f0;
    }
    
    .detail-item:last-child {
        border-bottom: none;
        margin-bottom: 0;
    }
    
    .detail-item strong {
        color: #4a5568;
        display: inline-block;
        min-width: 120px;
    }
    
    .detail-item .price {
        color: #38a169;
        font-weight: 600;
        font-size: 1.1rem;
    }
    
    .detail-item .category {
        background: #667eea;
        color: white;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 500;
    }
    
    .detail-item p {
        margin-top: 5px;
        color: #4a5568;
        line-height: 1.6;
    }
`;
document.head.appendChild(style);
