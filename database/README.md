# Database Schema Setup

## Hướng dẫn tạo Database Schema trong Supabase

### Bước 1: Mở SQL Editor
1. Vào Supabase Dashboard: https://supabase.com/dashboard
2. Chọn project của bạn
3. Vào **SQL Editor** (menu bên trái)
4. Click **New query**

### Bước 2: Chạy SQL Script
1. Copy toàn bộ nội dung file `schema.sql`
2. Paste vào SQL Editor
3. Click **Run** (hoặc Ctrl+Enter)

### Bước 3: Kiểm tra
1. Vào **Table Editor** (menu bên trái)
2. Kiểm tra xem table `artworks` đã được tạo chưa
3. Kiểm tra RLS policies trong **Authentication** → **Policies**

## Cấu trúc Table `artworks`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key, tự động generate |
| `user_id` | UUID | Foreign key đến auth.users |
| `title` | TEXT | Tên artwork (required) |
| `artist` | TEXT | Tên nghệ sĩ |
| `description` | TEXT | Mô tả artwork |
| `image_url` | TEXT | URL ảnh từ Supabase Storage |
| `category` | TEXT | Danh mục (ví dụ: Painting, Sculpture, etc.) |
| `year` | INTEGER | Năm sáng tác |
| `location` | TEXT | GPS location (format: "lat,lng") |
| `created_at` | TIMESTAMP | Thời gian tạo (auto) |
| `updated_at` | TIMESTAMP | Thời gian cập nhật (auto) |

## Row Level Security (RLS)

RLS đã được enable với các policies:
- ✅ Users chỉ xem artworks của chính họ
- ✅ Users chỉ tạo artworks cho chính họ
- ✅ Users chỉ update artworks của chính họ
- ✅ Users chỉ xóa artworks của chính họ

## Indexes

Đã tạo indexes để tối ưu performance:
- `artworks_user_id_idx` - Tìm artworks theo user_id
- `artworks_created_at_idx` - Sắp xếp theo thời gian tạo

