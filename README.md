# Art Collection Manager

Ứng dụng Quản lý Bộ Sưu Tập Nghệ Thuật Cá Nhân - Flutter + Supabase

## 🚀 Setup

### 1. Cài đặt dependencies
```bash
flutter pub get
```

### 2. Setup Supabase

1. Vào https://supabase.com
2. Sign up (dùng GitHub - nhanh nhất)
3. Tạo project mới
4. Copy **Project URL** và **anon key** từ:
   - Settings → API → Project URL
   - Settings → API → anon/public key

### 3. Tạo file `.env`

Tạo file `.env` trong thư mục root của project với nội dung:

```env
SUPABASE_URL=your_supabase_project_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

**Lưu ý:** File `.env` đã được thêm vào `.gitignore`, không commit lên Git!

### 4. Chạy ứng dụng

#### Chạy trên Web (Khuyến nghị):
```bash
flutter run -d chrome
```

#### Chạy trên thiết bị thật:
```bash
flutter devices
flutter run -d <device-id>
```

## 📁 Cấu trúc Project

```
lib/
├── core/
│   └── config/          # Configuration (Supabase, etc.)
├── data/
│   ├── datasources/     # Data sources (API, Local)
│   ├── models/          # Data models
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Business entities
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── providers/       # Riverpod providers
    ├── screens/         # UI screens
    └── widgets/         # Reusable widgets
```

## ✅ Checklist Bước 1

- [x] Tạo Flutter project
- [x] Enable web platform
- [x] Cài packages: supabase_flutter, flutter_dotenv, image_picker, riverpod
- [x] Tạo cấu trúc Clean Architecture
- [x] Setup Supabase config
- [ ] **Bạn cần:** Tạo file `.env` với Supabase credentials
- [ ] **Test:** Chạy `flutter run -d chrome` để kiểm tra

## 📝 Next Steps

Sau khi setup Supabase xong, tiếp tục với:
- Bước 2: Database Schema
- Bước 3: Authentication
- Bước 4: CRUD Operations

Xem `tiendo.md` để biết chi tiết!
