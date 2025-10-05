# Hướng dẫn kiểm thử end-to-end (Local, Docker, GitHub Actions, Render)

Tài liệu này giúp bạn kiểm tra nhanh toàn bộ luồng từ chạy local → container Docker → CI trên GitHub → deploy thủ công Render và xác thực kết quả.

## 1) Kiểm thử Local (Node.js)

Yêu cầu: Node.js 18+

```bash
# Cài dependencies
npm install

# Chạy server
node server.js
# Mở http://localhost:3000
# Health check
curl http://localhost:3000/health
```
Kỳ vọng:
- Health trả JSON có status OK
- UI CRUD hiển thị từ thư mục `public/`

API nhanh (ví dụ):
```bash
# Danh sách sản phẩm
curl http://localhost:3000/api/products

# Tạo sản phẩm mới
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Book","price":10000,"description":"A book","category":"Books"}'
```

## 2) Kiểm thử Docker (Local)

Yêu cầu: Docker Desktop

```bash
# Build image
docker build -t crud-app:latest .

# Chạy container
docker run --name crud-app --rm -p 3000:3000 crud-app:latest
# Kiểm tra
curl http://localhost:3000/health
```
Dùng docker-compose:
```bash
docker-compose up -d
curl http://localhost:3000/health
docker-compose down
```

## 3) Kiểm thử CI trên GitHub Actions

Workflow: `.github/workflows/deploy.yml` (CI-only, an toàn)

- Trigger bằng cách push commit nhỏ:
```bash
echo "trigger ci $(date)" >> ci-note.md
git add ci-note.md
git commit -m "chore: trigger CI"
git push origin main
```
- Mở tab Actions → chọn run mới nhất "CRUD App CI (safe)"
- Kỳ vọng: Job CI xanh (checkout → setup node → install deps → test/lint nếu có → success)

Tùy chọn build/push Docker (nếu muốn):
- Thêm repo secrets: `DOCKER_USERNAME`, `DOCKER_PASSWORD` (Docker Hub Access Token)
- Chuyển workflow sang bản có job Docker (nếu cần), hoặc build/push thủ công từ local.

## 4) Deploy thủ công lên Render (KHÔNG dùng Blueprints)

A. Từ GitHub repo (sử dụng Dockerfile của repo):
1. Render → New → Web Service → Connect repo `AnhBoHelloTeam/NT-project`
2. Thiết lập:
   - Name: nt-crud-app (tùy chọn)
   - Branch: main
   - Runtime: Auto (Render phát hiện Dockerfile)
   - Health Check Path: `/health`
   - Environment variables: `NODE_ENV=production`, `PORT=3000`
   - Start/Build Command: để trống (Dockerfile đã có CMD)
3. Create Web Service → chờ "Live"
4. Xác thực:
   - Mở URL app của Render
   - `curl https://<your-render-url>/health` → 200 OK

B. Từ Docker Hub image (tùy chọn):
1. Push image: `docker tag crud-app:latest nhanng0808/crud-app:latest && docker push nhanng0808/crud-app:latest`
2. Render → New → Web Service → Public Docker Image → nhập `nhanng0808/crud-app:latest`
3. Env: `NODE_ENV=production`, `PORT=3000` → Create
4. Kiểm tra `/health` tương tự.

## 5) Kiểm thử chức năng CRUD trên Render

- Mở URL ứng dụng
- Thêm sản phẩm mới (form ở trang chính)
- Sửa/Xóa/Xem chi tiết sản phẩm
- Tìm kiếm qua ô search
- Theo dõi thông báo trạng thái (toast ở góc phải)

API (ví dụ, thay URL cho đúng Render):
```bash
BASE=https://<your-render-url>

curl "$BASE/api/products"

curl -X POST "$BASE/api/products" \
  -H "Content-Type: application/json" \
  -d '{"name":"Pen","price":5000,"description":"Blue pen","category":"Other"}'
```

## 6) Troubleshooting nhanh

- Render 404/502:
  - Kiểm tra logs dịch vụ trên Render (tab Logs)
  - Đảm bảo `PORT=3000` và Health Check Path = `/health`
- Docker build fail:
  - Xóa cache: `docker builder prune -f`
  - Kiểm tra quyền file, dòng COPY trong Dockerfile
- Actions đỏ (CI-only):
  - Đảm bảo chỉ còn 1 workflow `deploy.yml` như hiện tại
  - Kiểm tra log step Install deps

## 7) Kết luận

Sau khi các phần trên đều pass:
- Local: OK
- Docker local: OK
- GitHub Actions (CI-only): xanh
- Render (Web Service): URL live, `/health` trả 200, CRUD hoạt động
