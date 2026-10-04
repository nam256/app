# 📱 TEST TRÊN ĐIỆN THOẠI THẬT

## ✅ Thiết bị đã kết nối:
- **Device ID:** `f992e93a`
- **Model:** 220333QAG
- **Android:** 13 (API 33)
- **Status:** ✅ Connected

## 🧪 Test Checklist:

### 1. Test Authentication
- [ ] Đăng ký tài khoản mới
- [ ] Đăng nhập
- [ ] Đăng xuất

### 2. Test CRUD Operations
- [ ] Thêm artwork mới
- [ ] Xem danh sách artworks
- [ ] Xem chi tiết artwork
- [ ] Sửa artwork
- [ ] Xóa artwork

### 3. Test Upload Ảnh (QUAN TRỌNG) 📸

#### Test Camera:
- [ ] Click nút **+** để thêm artwork
- [ ] Click vào image picker
- [ ] Dialog hiện ra với 2 options:
  - [ ] **Camera** - Chụp ảnh mới
  - [ ] **Thư viện ảnh** - Chọn từ gallery
- [ ] Chọn **Camera**
- [ ] Camera app mở ra
- [ ] Chụp ảnh
- [ ] Ảnh preview hiển thị trong form
- [ ] Nhập thông tin artwork:
  - Title: `Test Camera`
  - Artist: `Test Artist`
  - Description: `Test từ camera`
- [ ] Click **Create**
- [ ] Loading indicator hiển thị
- [ ] Upload thành công
- [ ] Quay về danh sách
- [ ] Ảnh hiển thị trong artwork card

#### Test Gallery:
- [ ] Click nút **+** để thêm artwork
- [ ] Click vào image picker
- [ ] Chọn **Thư viện ảnh**
- [ ] Gallery mở ra
- [ ] Chọn ảnh từ gallery
- [ ] Ảnh preview hiển thị
- [ ] Nhập thông tin và save
- [ ] Upload thành công

### 4. Test Image Display
- [ ] Ảnh hiển thị trong danh sách (grid)
- [ ] Ảnh hiển thị trong detail screen
- [ ] Placeholder khi đang load
- [ ] Error widget nếu load fail

### 5. Test Performance
- [ ] App chạy mượt
- [ ] Upload ảnh không bị lag
- [ ] Navigation smooth
- [ ] Không có memory leak

## 🐛 Nếu có lỗi:

### Lỗi Camera không mở:
- Kiểm tra permissions trong Settings → Apps → Art Collection Manager → Permissions
- Bật Camera permission

### Lỗi Upload fail:
- Kiểm tra internet connection
- Kiểm tra Storage bucket đã tạo chưa
- Kiểm tra Storage policies

### Lỗi App crash:
- Xem log trong terminal
- Kiểm tra Android version (cần >= Android 5.0)

## 📝 Ghi chú:

- **USB kém:** Nếu upload chậm, đó là bình thường
- **Hot reload:** Có thể dùng `r` trong terminal để hot reload
- **Hot restart:** Dùng `R` để hot restart
- **Stop app:** Dùng `q` để stop

## ✅ Kết quả mong đợi:

- ✅ Camera hoạt động
- ✅ Gallery hoạt động
- ✅ Upload ảnh thành công
- ✅ Ảnh hiển thị đúng
- ✅ Tất cả CRUD operations hoạt động

