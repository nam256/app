# 🔧 SỬA LỖI INSTALL_FAILED_USER_RESTRICTED

## ❌ Lỗi:
```
INSTALL_FAILED_USER_RESTRICTED: Install canceled by user
```

## ✅ Cách sửa:

### Bước 1: Bật "Install from unknown sources" trên điện thoại

1. **Trên điện thoại Android:**
   - Vào **Settings** (Cài đặt)
   - Tìm **Security** hoặc **Privacy** hoặc **Apps**
   - Tìm **"Install unknown apps"** hoặc **"Install from unknown sources"**
   - Bật cho **ADB** hoặc **Package Installer**

2. **Hoặc khi cài đặt:**
   - Khi ADB cố cài, trên điện thoại sẽ hiện popup
   - Click **"Allow"** hoặc **"Install"**
   - Chấp nhận permission

### Bước 2: Bật USB Debugging (nếu chưa)

1. Vào **Settings** → **About phone**
2. Tap 7 lần vào **"Build number"** (để bật Developer Options)
3. Vào **Settings** → **Developer Options**
4. Bật **"USB Debugging"**
5. Bật **"Install via USB"** (nếu có)

### Bước 3: Chấp nhận USB Debugging trên điện thoại

- Khi kết nối USB, điện thoại sẽ hỏi **"Allow USB debugging?"**
- Tick **"Always allow from this computer"**
- Click **"Allow"**

### Bước 4: Thử cài lại

```bash
# Cách 1: Cài trực tiếp qua ADB
adb install -r build\app\outputs\flutter-apk\app-debug.apk

# Cách 2: Chạy Flutter run lại
flutter run -d f992e93a
```

## 🔄 Nếu vẫn lỗi:

### Option 1: Cài APK thủ công
1. Copy file `build\app\outputs\flutter-apk\app-debug.apk` vào điện thoại
2. Trên điện thoại: Mở file manager
3. Tìm file APK và click
4. Click **"Install"** (có thể cần bật "Install from unknown sources")

### Option 2: Dùng Wireless Debugging (Android 11+)
1. Trên điện thoại: Settings → Developer Options → Wireless debugging
2. Bật Wireless debugging
3. Kết nối qua IP:
   ```bash
   adb connect <phone-ip>:5555
   ```

### Option 3: Kiểm tra Developer Options
- Đảm bảo **Developer Options** đã bật
- Đảm bảo **USB Debugging** đã bật
- Đảm bảo **Install via USB** đã bật (nếu có)

## ✅ Sau khi cài thành công:

1. Mở app trên điện thoại
2. Test upload ảnh từ camera:
   - Click nút **+**
   - Click image picker
   - Chọn **Camera**
   - Chụp ảnh và upload

