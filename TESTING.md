# Hướng dẫn kiểm thử end-to-end (Local, API, Docker, CI, Render)

Tài liệu này hướng dẫn bạn tự kiểm thử toàn bộ quy trình: chạy local, test API, build/chạy Docker, xác minh CI trên GitHub Actions, và deploy kiểm thử trên Render. Mỗi phần đều có lệnh mẫu (PowerShell trên Windows và Bash).

Lưu ý: Thư mục gốc dự án là `NT-project`.

---

## 1) Kiểm thử Local (Node.js)
Yêu cầu: Node.js 18+

- Cài dependencies
```bash
npm install
```
- Chạy server (mặc định port 3000)
```bash
node server.js
```
- Mở trình duyệt: http://localhost:3000
- Health check nhanh:
```bash
curl http://localhost:3000/health
```
Kỳ vọng: trả về JSON `{ "status": "OK", ... }`.

### Test CRUD qua giao diện
- Thêm mới: điền form → Lưu → thấy toast “Thêm sản phẩm thành công!” và card mới xuất hiện.
- Tìm kiếm: gõ từ khóa → danh sách lọc đúng.
- Xem chi tiết: bấm “Xem” → modal hiển thị đầy đủ thông tin.
- Sửa: bấm “Sửa”, chỉnh nội dung → “Cập nhật sản phẩm” → thấy toast thành công.
- Xóa: bấm “Xóa” → xác nhận → card biến mất, thấy toast thành công.

---

## 2) Kiểm thử API (curl / Postman)
API chạy tại http://localhost:3000

### 2.1 curl (Bash/PowerShell)
- Lấy danh sách sản phẩm:
```bash
curl http://localhost:3000/api/products | jq .
```
- Tạo sản phẩm mới:
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Pen","price":5000,"description":"Blue pen","category":"Other"}' | jq .
```
- Lấy chi tiết (thay <id>):
```bash
curl http://localhost:3000/api/products/<id> | jq .
```
- Cập nhật (thay <id>):
```bash
curl -X PUT http://localhost:3000/api/products/<id> \
  -H "Content-Type: application/json" \
  -d '{"name":"Pen Updated","price":6000,"description":"Blue pen updated","category":"Other"}' | jq .
```
- Xóa (thay <id>):
```bash
curl -X DELETE http://localhost:3000/api/products/<id> | jq .
```

Gợi ý Windows PowerShell (không cần jq):
```powershell
# Health
Invoke-RestMethod http://localhost:3000/health | ConvertTo-Json -Depth 5

# Tạo
$body = @{ name='Pen'; price=5000; description='Blue pen'; category='Other' } | ConvertTo-Json
$new = Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/products -ContentType 'application/json' -Body $body
$new | ConvertTo-Json -Depth 5
$id = $new.data.id

# Chi tiết
Invoke-RestMethod -Uri ("http://localhost:3000/api/products/" + $id) | ConvertTo-Json -Depth 5

# Cập nhật
$ubody = @{ name='Pen Updated'; price=6000; description='Blue pen updated'; category='Other' } | ConvertTo-Json
Invoke-RestMethod -Method Put -Uri ("http://localhost:3000/api/products/" + $id) -ContentType 'application/json' -Body $ubody | ConvertTo-Json -Depth 5

# Xóa
Invoke-RestMethod -Method Delete -Uri ("http://localhost:3000/api/products/" + $id) | ConvertTo-Json -Depth 5
```

### 2.2 Postman
- Tạo Collection “NT-project”. Thêm các request:
  - GET http://localhost:3000/health
  - GET http://localhost:3000/api/products
  - POST http://localhost:3000/api/products
    - Headers: `Content-Type: application/json`
    - Body (raw JSON): `{"name":"Pen","price":5000,"description":"Blue pen","category":"Other"}`
  - GET http://localhost:3000/api/products/:id
  - PUT http://localhost:3000/api/products/:id (Body như trên nhưng sửa nội dung)
  - DELETE http://localhost:3000/api/products/:id
- Lưu Example responses để demo nhanh.

---

## 3) Kiểm thử Docker (Local)
Yêu cầu: Docker Desktop

### 3.1 Build & run bằng Dockerfile
```bash
# Build image
docker build -t crud-app:latest .

# Run container port 3000
docker run --name crud-app --rm -p 3000:3000 crud-app:latest

# Kiểm tra (tab khác)
curl http://localhost:3000/health
```
Dừng: Ctrl+C nếu chạy foreground, hoặc `docker stop crud-app` nếu chạy background.

### 3.2 docker-compose
```bash
docker-compose up -d
curl http://localhost:3000/health
docker-compose ps
docker-compose logs -f
# Dừng
docker-compose down
```

---

## 4) Kiểm thử CI trên GitHub Actions (CI-only, an toàn)
Workflow: `.github/workflows/deploy.yml` – chỉ chạy các bước an toàn: checkout → setup Node → install deps → test/lint nếu có.

### 4.1 Trigger run mới
- Tạo commit nhỏ (trên máy hoặc GitHub web) rồi push lên `main`:
```bash
echo "trigger ci $(date)" >> ci-note.md
git add ci-note.md
git commit -m "chore: trigger CI"
git push origin main
```
- Mở tab Actions → chọn workflow “CRUD App CI (safe)” → mở run mới nhất.
- Kỳ vọng: tất cả step xanh, job CI pass.

### 4.2 (Tùy chọn) Build & push Docker image
- Thêm repo secrets trong GitHub: `DOCKER_USERNAME`, `DOCKER_PASSWORD` (Docker Hub Access Token).
- Chuyển sang workflow có job Docker (hoặc build/push thủ công local):
```bash
# Thủ công (nếu muốn):
docker login -u <docker_username>
docker build -t <docker_username>/crud-app:latest .
docker push <docker_username>/crud-app:latest
```

---

## 5) Deploy thủ công lên Render (KHÔNG dùng Blueprints)
### 5.1 Từ GitHub repo (Render build bằng Dockerfile của repo)
1) Vào Render → New → Web Service → Connect repo `AnhBoHelloTeam/NT-project` (nhánh `main`).
2) Thiết lập:
   - Runtime: Auto (Render phát hiện Dockerfile)
   - Health Check Path: `/health`
   - Env Vars: `NODE_ENV=production`, `PORT=3000`
   - Build/Start Command: để trống (Dockerfile đã quy định CMD)
3) Create Web Service → chờ status “Live”.
4) Kiểm tra:
   - Mở URL service: thấy UI CRUD.
   - Health: `https://<render-url>/health` → 200 OK.

### 5.2 Từ Docker Hub image (tùy chọn)
1) Đẩy image lên Docker Hub (xem mục 4.2).
2) Render → New → Web Service → Public Docker Image → nhập `<docker_username>/crud-app:latest`.
3) Env: `NODE_ENV=production`, `PORT=3000` → Create.
4) Kiểm tra `/health` tương tự.

---

## 6) Checklist demo nhanh
- Local UI: mở `http://localhost:3000` → CRUD đủ 5 thao tác + search.
- API: test 5 endpoints bằng Postman hoặc curl.
- Docker: build/run → `/health` 200; docker-compose up/down hoạt động.
- CI: run “CRUD App CI (safe)” xanh ổn định sau mỗi commit.
- Render: service Live, URL truy cập OK, `/health` 200, CRUD hoạt động.

---

## 7) Troubleshooting
- Không truy cập được `localhost:3000`:
  - Kiểm tra server có chạy (cửa sổ chạy `node server.js`).
  - Port 3000 có bị chiếm không (đổi `PORT` env nếu cần).
- Docker build lỗi:
  - Kiểm tra phiên bản Docker Desktop.
  - Xóa cache builder: `docker builder prune -f`.
- Actions đỏ:
  - Đảm bảo workflow hiện tại là bản “CRUD App CI (safe)”.
  - Xem logs step “Install dependencies” và “Test/Lint”.
- Render 404/502:
  - Logs trong Render (tab Logs).
  - Đúng `PORT=3000` và Health Check path `/health`.

---

## 8) Mở rộng test (khuyến nghị)
- Thêm ESLint và bật fail CI nếu lint lỗi.
- Thêm Jest test cơ bản cho API/utility.
- Tag Docker image theo phiên bản (latest + vX.Y.Z).
- Postman Collection: export và lưu cùng repo để share cho team.
