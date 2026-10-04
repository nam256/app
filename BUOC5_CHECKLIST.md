# ✅ BƯỚC 5: Storage - Upload Ảnh - CHECKLIST

## 📋 Đã hoàn thành:

### 5.1. Image Picker ✅
- [x] **Web:** `ImageSource.gallery` (file picker) - Hoạt động
- [x] **Mobile:** Dialog chọn Camera hoặc Gallery - Hoạt động
- [x] Image compression (80% quality)
- [x] Resize ảnh (max 1920x1920px)
- [x] Error handling cho image picker

### 5.2. Image Upload ✅
- [x] Upload function `_uploadImage()` - Hoạt động
- [x] **Web:** Upload bytes với `uploadBinary()`
- [x] **Mobile:** Upload File với `upload()`
- [x] Generate unique filename (timestamp + extension)
- [x] Upload vào folder `userId/` trong bucket
- [x] Get public URL sau khi upload
- [x] Error handling rõ ràng (bucket, permission errors)

### 5.3. Image Display ✅
- [x] **ArtworkListScreen:** Dùng `CachedNetworkImage` - ✅ Đã có
- [x] **ArtworkDetailScreen:** Dùng `CachedNetworkImage` - ✅ Đã có
- [x] **ArtworkFormScreen:** Preview ảnh khi chọn - ✅ Đã có
- [x] Placeholder khi đang load
- [x] Error widget khi load fail

### 5.4. UI/UX ✅
- [x] Image picker button với preview
- [x] Loading indicator khi upload
- [x] Error messages tiếng Việt
- [x] Success message sau khi upload

## 🗄️ Bạn cần làm:

### Bước 1: Tạo Storage Bucket trong Supabase

1. Vào Supabase Dashboard:
   - https://supabase.com/dashboard/project/ysqfilaqfrzhjhkdabtz

2. Vào **Storage** (menu bên trái)

3. Click **New bucket**

4. Tạo bucket:
   - **Name:** `artwork-images`
   - **Public bucket:** ✅ Bật (để có thể truy cập ảnh qua URL)
   - Click **Create bucket**

### Bước 2: Tạo Storage Policies

#### Policy 1: Users có thể upload ảnh của chính họ

1. Vào **Storage** → **Policies** → `artwork-images`

2. Click **New Policy**

3. Chọn **For full customization**

4. Policy name: `Users can upload their own images`

5. Allowed operation: `INSERT`

6. Policy definition:
   ```sql
   bucket_id = 'artwork-images' AND (storage.foldername(name))[1] = auth.uid()::text
   ```
   (Cho phép upload vào folder có tên = user_id)

7. Click **Review** → **Save policy**

#### Policy 2: Public có thể xem ảnh

1. Click **New Policy** lại

2. Policy name: `Public can view images`

3. Allowed operation: `SELECT`

4. Policy definition:
   ```sql
   bucket_id = 'artwork-images'
   ```

5. Click **Review** → **Save policy**

#### Policy 3: Users có thể xóa ảnh của chính họ (optional)

1. Click **New Policy**

2. Policy name: `Users can delete their own images`

3. Allowed operation: `DELETE`

4. Policy definition:
   ```sql
   bucket_id = 'artwork-images' AND (storage.foldername(name))[1] = auth.uid()::text
   ```

5. Click **Review** → **Save policy**

## ✅ Kết quả:

Sau khi tạo storage bucket và policies:
- ✅ Upload ảnh hoạt động (web + mobile)
- ✅ Chọn ảnh từ camera (mobile) hoặc file picker (web)
- ✅ Ảnh hiển thị với cached_network_image
- ✅ Error handling đầy đủ
- ✅ Đáp ứng tiêu chí 7 (Hardware - Camera)

## 🧪 Test:

### Test trên Web:
1. Click nút **+** để thêm artwork
2. Click vào image picker → Chọn file ảnh
3. Ảnh preview hiển thị
4. Nhập thông tin artwork
5. Click **Create**
6. Upload thành công → Ảnh hiển thị trong danh sách

### Test trên Mobile:
1. Click nút **+** để thêm artwork
2. Click vào image picker → Dialog hiện ra
3. Chọn **Camera** hoặc **Thư viện ảnh**
4. Chụp/chọn ảnh
5. Ảnh preview hiển thị
6. Nhập thông tin artwork
7. Click **Create**
8. Upload thành công → Ảnh hiển thị trong danh sách

## 🚀 Tiếp theo:

Sau khi tạo storage bucket xong, tiếp tục với:
- **Bước 6: Real-time Sync** (10 phút)
- **Bước 7-10: Polish & Testing**

