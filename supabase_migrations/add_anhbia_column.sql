-- Migration: Thêm cột anhbia (ảnh bìa) vào bảng dau_sach
-- Chạy trên Supabase SQL Editor

-- Thêm cột anhbia để lưu URL ảnh bìa
ALTER TABLE dau_sach ADD COLUMN IF NOT EXISTS anhbia TEXT;

-- Comment mô tả cột
COMMENT ON COLUMN dau_sach.anhbia IS 'URL ảnh bìa sách từ Supabase Storage';
