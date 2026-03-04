-- Migration: Thêm cột solangiahan vào bảng chi_tiet_muon
-- Cột này dùng để theo dõi số lần gia hạn của mỗi sách trong phiếu mượn

-- Thêm cột solangiahan (số lần gia hạn)
ALTER TABLE chi_tiet_muon ADD COLUMN IF NOT EXISTS solangiahan INTEGER DEFAULT 0;

-- Comment mô tả
COMMENT ON COLUMN chi_tiet_muon.solangiahan IS 'Số lần gia hạn của sách này trong phiếu mượn. Tối đa 2 lần.';
