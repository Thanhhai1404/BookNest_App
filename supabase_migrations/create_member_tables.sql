-- Migration: Tạo bảng goi_hoi_vien và doc_gia cho Supabase
-- Run this in Supabase SQL Editor

-- 1. Tạo bảng GOI_HOI_VIEN (Gói hội viên)
CREATE TABLE IF NOT EXISTS goi_hoi_vien (
    magoi VARCHAR(20) PRIMARY KEY,
    tengoi VARCHAR(50),
    phithang DECIMAL(18,0) DEFAULT 0,
    tiencoc DECIMAL(18,0) DEFAULT 0,
    sosachtoida INTEGER DEFAULT 5,
    songaymuon INTEGER DEFAULT 14,
    mota VARCHAR(200)
);

-- 2. Tạo bảng DOC_GIA (Hội viên/Độc giả)
CREATE TABLE IF NOT EXISTS doc_gia (
    madg CHAR(10) PRIMARY KEY,
    hodg VARCHAR(20),
    tenlotdg VARCHAR(20),
    tendg VARCHAR(10),
    ngaysinh TIMESTAMP,
    sdt CHAR(10),
    cccd CHAR(12) NOT NULL,
    email VARCHAR(100) NOT NULL,
    diachi VARCHAR(200),
    ngayhethangoi TIMESTAMP,
    soduvi DECIMAL(18,0) DEFAULT 0,
    diemtichluy INTEGER DEFAULT 0,
    trangthai BOOLEAN DEFAULT TRUE,
    magoi VARCHAR(20) NOT NULL REFERENCES goi_hoi_vien(magoi),
    anhdaidien TEXT,  -- URL ảnh đại diện
    CONSTRAINT uq_docgia_email UNIQUE (email),
    CONSTRAINT uq_docgia_cccd UNIQUE (cccd),
    CONSTRAINT uq_docgia_sdt UNIQUE (sdt)
);

-- 3. Insert dữ liệu mẫu cho GOI_HOI_VIEN
INSERT INTO goi_hoi_vien (magoi, tengoi, phithang, tiencoc, sosachtoida, songaymuon, mota) VALUES
    ('MOT_TAPSU', 'Mọt Tập Sự', 50000, 200000, 2, 7, 'Gói tiết kiệm, phù hợp sinh viên'),
    ('MOT_SANDIEU', 'Mọt Sành Điệu', 150000, 500000, 5, 14, 'Được đặt trước sách, miễn phí gửi xe'),
    ('MOT_CHUA', 'Mọt Chúa', 300000, 1000000, 10, 30, 'Ưu tiên VIP, tặng sách hàng tháng')
ON CONFLICT (magoi) DO NOTHING;

-- 4. Bật RLS cho các bảng (nếu cần)
ALTER TABLE goi_hoi_vien ENABLE ROW LEVEL SECURITY;
ALTER TABLE doc_gia ENABLE ROW LEVEL SECURITY;

-- 5. Tạo policies cho phép đọc/ghi (tuỳ chỉnh theo nhu cầu)
-- Policy cho goi_hoi_vien: cho phép tất cả authenticated users đọc
CREATE POLICY "Allow read goi_hoi_vien" ON goi_hoi_vien
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow insert goi_hoi_vien" ON goi_hoi_vien
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow update goi_hoi_vien" ON goi_hoi_vien
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow delete goi_hoi_vien" ON goi_hoi_vien
    FOR DELETE TO authenticated USING (true);

-- Policy cho doc_gia: cho phép tất cả authenticated users CRUD
CREATE POLICY "Allow read doc_gia" ON doc_gia
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow insert doc_gia" ON doc_gia
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow update doc_gia" ON doc_gia
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow delete doc_gia" ON doc_gia
    FOR DELETE TO authenticated USING (true);

-- 6. Index để tăng tốc tìm kiếm
CREATE INDEX IF NOT EXISTS idx_docgia_magoi ON doc_gia(magoi);
CREATE INDEX IF NOT EXISTS idx_docgia_sdt ON doc_gia(sdt);
CREATE INDEX IF NOT EXISTS idx_docgia_email ON doc_gia(email);
