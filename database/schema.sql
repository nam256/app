-- ============================================
-- BƯỚC 2: Database Schema cho Art Collection App
-- ============================================
-- Chạy script này trong Supabase SQL Editor
-- Vào: https://supabase.com/dashboard/project/YOUR_PROJECT/sql/new

-- 1. Tạo table artworks
CREATE TABLE IF NOT EXISTS public.artworks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    artist TEXT,
    description TEXT,
    image_url TEXT,
    category TEXT,
    year INTEGER,
    location TEXT, -- GPS location (latitude,longitude)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Tạo indexes để tối ưu performance
CREATE INDEX IF NOT EXISTS artworks_user_id_idx ON public.artworks(user_id);
CREATE INDEX IF NOT EXISTS artworks_created_at_idx ON public.artworks(created_at DESC);

-- 3. Tạo function để tự động update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Tạo trigger để tự động update updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.artworks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 5. Enable Row Level Security (RLS)
ALTER TABLE public.artworks ENABLE ROW LEVEL SECURITY;

-- 6. Tạo RLS Policies
-- Policy: Users chỉ xem artworks của chính họ
CREATE POLICY "Users can view their own artworks"
    ON public.artworks
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users chỉ tạo artworks cho chính họ
CREATE POLICY "Users can insert their own artworks"
    ON public.artworks
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users chỉ update artworks của chính họ
CREATE POLICY "Users can update their own artworks"
    ON public.artworks
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users chỉ xóa artworks của chính họ
CREATE POLICY "Users can delete their own artworks"
    ON public.artworks
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- XONG! Database schema đã được tạo
-- ============================================

