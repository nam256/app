# ✅ BƯỚC 2: Database Schema - CHECKLIST

## 📋 Đã hoàn thành:

### 2.1. SQL Schema ✅
- [x] Tạo file `database/schema.sql` với:
  - [x] Table `artworks` với đầy đủ columns
  - [x] Indexes để tối ưu performance
  - [x] Trigger tự động update `updated_at`
  - [x] RLS (Row Level Security) policies

### 2.2. Clean Architecture Code ✅
- [x] **Domain Layer:**
  - [x] `Artwork` entity
  - [x] `ArtworkRepository` interface
- [x] **Data Layer:**
  - [x] `ArtworkModel` (JSON conversion)
  - [x] `ArtworkRemoteDataSource` (Supabase integration)
  - [x] `ArtworkRepositoryImpl` (Repository implementation)

## 🗄️ Bạn cần làm:

### Bước 1: Chạy SQL Script trong Supabase

1. Vào Supabase Dashboard:
   - https://supabase.com/dashboard/project/ysqfilaqfrzhjhkdabtz
   
2. Vào **SQL Editor** (menu bên trái)

3. Click **New query**

4. Copy toàn bộ nội dung file `database/schema.sql`

5. Paste vào SQL Editor và click **Run** (hoặc Ctrl+Enter)

6. Kiểm tra:
   - Vào **Table Editor** → Xem table `artworks` đã được tạo
   - Vào **Authentication** → **Policies** → Xem RLS policies

## 📊 Cấu trúc Database:

### Table: `artworks`
```
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key → auth.users)
- title (TEXT, Required)
- artist (TEXT, Optional)
- description (TEXT, Optional)
- image_url (TEXT, Optional)
- category (TEXT, Optional)
- year (INTEGER, Optional)
- location (TEXT, Optional) - GPS: "lat,lng"
- created_at (TIMESTAMP, Auto)
- updated_at (TIMESTAMP, Auto)
```

### RLS Policies:
- ✅ Users chỉ xem artworks của chính họ
- ✅ Users chỉ tạo artworks cho chính họ
- ✅ Users chỉ update artworks của chính họ
- ✅ Users chỉ xóa artworks của chính họ

### Indexes:
- ✅ `artworks_user_id_idx` - Tìm theo user_id
- ✅ `artworks_created_at_idx` - Sắp xếp theo thời gian

## ✅ Kết quả:

Sau khi chạy SQL script:
- ✅ Database schema đã sẵn sàng
- ✅ Code Clean Architecture đã hoàn thành
- ✅ Sẵn sàng cho Bước 3: Authentication

## 🚀 Tiếp theo:

Sau khi chạy SQL script xong, tiếp tục với:
- **Bước 3: Authentication** (20 phút)
  - Tạo AuthService
  - Tạo Login/Register screens

