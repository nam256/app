# 📱 CÀI APK THỦ CÔNG

## ✅ Build APK đang chạy...

Sau khi build xong, APK sẽ ở:
```
art_collection_app\build\app\outputs\flutter-apk\app-debug.apk
```

## 📥 Cách cài APK:

### Cách 1: Qua ADB (Nhanh nhất)
```bash
adb install build\app\outputs\flutter-apk\app-debug.apk
```

### Cách 2: Copy vào điện thoại
1. Copy file `app-debug.apk` vào điện thoại (qua USB hoặc email)
2. Trên điện thoại: Settings → Security → Bật "Install from unknown sources"
3. Mở file APK trên điện thoại
4. Click "Install"

## 🧪 Test sau khi cài:

1. Mở app "Art Collection Manager"
2. Đăng ký/đăng nhập
3. Test upload ảnh từ camera:
   - Click nút **+**
   - Click image picker
   - Chọn **Camera**
   - Chụp ảnh
   - Upload và kiểm tra

## ⚠️ Lưu ý:

- **Camera Permission:** App sẽ hỏi permission khi chụp ảnh lần đầu
- **Storage Permission:** Cần để upload ảnh
- **Internet:** Cần để kết nối Supabase

## 🔄 Update app:

Mỗi lần code thay đổi, build lại APK:
```bash
flutter build apk --debug
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```
(Flag `-r` = replace, cài đè lên app cũ)

