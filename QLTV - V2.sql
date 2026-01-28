/*********************************************************************************************************
* *
* ██████╗  ██████╗  ██████╗ ██╗  ██╗███╗   ██╗███████╗███████╗███████╗                          *
* ██╔══██╗██╔═══██╗██╔═══██╗██║ ██╔╝████╗  ██║██╔════╝██╔════╝╚══███╔╝                          *
* ██████╔╝██║   ██║██║   ██║█████╔╝ ██╔██╗ ██║█████╗  ███████╗  ███╔╝                           *
* ██╔══██╗██║   ██║██║   ██║██╔═██╗ ██║╚██╗██║██╔══╝  ╚════██║ ███╔╝                            *
* ██████╔╝╚██████╔╝╚██████╔╝██║  ██╗██║ ╚████║███████╗███████║███████╗                          *
* ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝                          *
* *
* --------------------------------------------------------------------------------------------      *
* PROJECT NAME   : BOOKNEST LIBRARY MANAGEMENT SYSTEM                                               *
* DATABASE NAME  : QLTVBOOKNEST                                                                     *
* AUTHOR         : ĐỖ THANH HẢI - 221A010630                                                        *
* CREATED DATE   : 25/01/2026                                                                       *                                 *
* *
*********************************************************************************************************/

CREATE DATABASE QLTVBOOKNESTv3
GO
USE QLTVBOOKNESTv3
GO




Create table [GOI_HOI_VIEN] (
	[MaGoi] Varchar(20) NOT NULL,
	[TenGoi] Nvarchar(50) NULL,
	[PhiThang] Decimal(18,0) NULL,
	[TienCoc] Decimal(18,0) NULL,
	[SoSachToiDa] Integer NULL,
	[SoNgayMuon] Integer NULL,
	[MoTa] Nvarchar(200) NULL,
Primary Key  ([MaGoi])
) 
go

Create table [DOC_GIA] (
	[MaDG] Char(10) NOT NULL,
	[HoDG] Nvarchar(20) NULL,
	[TenLotDG] Nvarchar(20) NULL,
	[TenDG] Nvarchar(10) NULL,
	[NgaySinh] Datetime NULL,
	[SDT] Char(10) NULL,
	[CCCD] Char(12) NOT NULL,
	[Email] Varchar(100) NOT NULL,
	[DiaChi] Nvarchar(200) NULL,
	[NgayHetHanGoi] Datetime NULL,
	[SoDuVi] Decimal(18,0) NULL,
	[DiemTichLuy] Integer NULL,
	[TrangThai] Bit NULL,
	[MaGoi] Varchar(20) NOT NULL,
Primary Key  ([MaDG]),
	CONSTRAINT [UQ_DOC_GIA_Email] UNIQUE ([Email]),
	CONSTRAINT [UQ_DOC_GIA_CCCD] UNIQUE ([CCCD]),
	CONSTRAINT [UQ_DOC_GIA_SDT] UNIQUE ([SDT])
) 
go

Create table [NHAN_VIEN] (
	[MaNV] Char(10) NOT NULL,
	[HoNV] Nvarchar(20) NULL,
	[TenLotNV] Nvarchar(20) NULL,
	[TenNV] Nvarchar(10) NULL,
	[ChucVu] Nvarchar(100) NULL,
	[TaiKhoan] Varchar(100) NOT NULL,
	[MatKhau] Varchar(100) NOT NULL,
Primary Key  ([MaNV]),
	CONSTRAINT [UQ_NHAN_VIEN_TaiKhoan] UNIQUE ([TaiKhoan])
) 
go

Create table [PHIEU_CAP_THE] (
	[MaPhieuCap] INT IDENTITY(1,1) NOT NULL,
	[NgayCap] Datetime NULL,
	[LoaiCap] Nvarchar(20) NULL,
	[PhiLamThe] Decimal(18,0) NULL,
	[MaDG] Char(10) NOT NULL,
	[MaNV] Char(10) NOT NULL,
Primary Key  ([MaPhieuCap])
) 
go

Create table [THE_LOAI] (
	[MaTL] INT IDENTITY(1,1) NOT NULL,
	[TenTL] Nvarchar(100) NULL,
Primary Key  ([MaTL])
) 
go

Create table [NHA_XUAT_BAN] (
	[MaNXB] INT IDENTITY(1,1) NOT NULL,
	[TenNXB] Nvarchar(100) NULL,
	[DiaChi] Nvarchar(200) NULL,
Primary Key  ([MaNXB])
) 
go

Create table [TAC_GIA] (
	[MaTG] INT IDENTITY(1,1) NOT NULL,
	[HoTG] Nvarchar(20) NULL,
	[TenLotTG] Nvarchar(20) NULL,
	[TenTG] Nvarchar(10) NULL,
	[QueQuan] Nvarchar(200) NULL,
Primary Key  ([MaTG])
) 
go

Create table [DAU_SACH] (
	[MaDauSach] Char(10) NOT NULL,
	[TenSach] Nvarchar(200) NULL,
	[NamXB] Integer NULL,
	[GiaBia] Decimal(18,0) NULL,
	[TongSoLuong] Integer NULL,
	[MoTa] Nvarchar(200) NULL,
	[MaTL] Integer NOT NULL,
	[MaNXB] Integer NOT NULL,
Primary Key  ([MaDauSach])
) 
go

Create table [SACH] (
	[MaVach] Varchar(20) NOT NULL,
	[ViTri] Nvarchar(50) NULL,
	[TinhTrang] Nvarchar(50) NULL,
	[TrangThai] Tinyint NULL,
	[MaDauSach] Char(10) NOT NULL,
Primary Key  ([MaVach])
) 
go

Create table [PHIEU_THANH_LY] (
	[MaPhieuTL] INT IDENTITY(1,1) NOT NULL,
	[NgayThanhLy] Datetime NULL,
	[LyDo] Nvarchar(200) NULL,
	[MaVach] Varchar(20) NOT NULL,
	[MaNV] Char(10) NOT NULL,
Primary Key  ([MaPhieuTL])
) 
go

Create table [PHIEU_DAT_TRUOC] (
	[MaDat] INT IDENTITY(1,1) NOT NULL,
	[NgayDat] Datetime NULL,
	[TrangThai] Tinyint NULL,
	[MaDG] Char(10) NOT NULL,
	[MaDauSach] Char(10) NOT NULL,
Primary Key  ([MaDat])
) 
go

Create table [PHIEU_MUON] (
	[MaPhieuMuon] Char(15) NOT NULL,
	[NgayMuon] Datetime NULL,
	[GhiChu] Nvarchar(200) NULL,
	[MaDG] Char(10) NOT NULL,
	[MaNV] Char(10) NOT NULL,
	[MaSoThe] Varchar(20) NOT NULL,
Primary Key  ([MaPhieuMuon])
) 
go

Create table [PHIEU_GIA_HAN] (
	[MaPhieuGH] INT IDENTITY(1,1) NOT NULL,
	[NgayGiaHan] Datetime NULL,
	[SoTien] Decimal(18,0) NULL,
	[NgayHetHanMoi] Datetime NULL,
	[MaDG] Char(10) NOT NULL,
	[MaGoi] Varchar(20) NOT NULL,
Primary Key  ([MaPhieuGH])
) 
go

Create table [PHIEU_PHAT] (
	[MaPhieuPhat] INT IDENTITY(1,1) NOT NULL,
	[NgayLap] Datetime NULL,
	[TongTienPhat] Decimal(18,0) NULL,
	[LyDoPhat] Nvarchar(200) NULL,
	[TrangThai] Bit NULL,
	[MaDG] Char(10) NOT NULL,
	[MaPhieuMuon] Char(15) NOT NULL,
Primary Key  ([MaPhieuPhat])
) 
go

Create table [GIAO_DICH_VI] (
	[MaGD] INT IDENTITY(1,1) NOT NULL,
	[LoaiGiaoDich] Varchar(20) NULL,
	[SoTien] Decimal(18,0) NULL,
	[NgayGiaoDich] Datetime NULL,
	[NoiDung] Nvarchar(200) NULL,
	[MaDG] Char(10) NOT NULL,
Primary Key  ([MaGD])
) 
go

Create table [CHI_TIET_TAC_GIA] (
	[MaDauSach] Char(10) NOT NULL,
	[MaTG] Integer NOT NULL,
	[VaiTro] Nvarchar(50) NULL,
Primary Key  ([MaDauSach],[MaTG])
) 
go

Create table [CHI_TIET_MUON] (
	[MaPhieuMuon] Char(15) NOT NULL,
	[MaVach] Varchar(20) NOT NULL,
	[NgayHenTra] Datetime NULL,
	[NgayTraThucTe] Datetime NULL,
	[TinhTrangSachKhiTra] Nvarchar(100) NULL,
	[TienPhatPhatSinh] Decimal(18,0) NULL,
	[TrangThai] Tinyint NULL,
Primary Key  ([MaPhieuMuon],[MaVach])
) 
go

Create table [CHI_TIET_PHAT] (
	[MaChiTietPhat] INT IDENTITY(1,1) NOT NULL,
	[MaPhieuPhat] INT NOT NULL,
	[MaVach] Varchar(20) NOT NULL,
	[LyDoPhat] Nvarchar(100) NULL,
	[SoTien] Decimal(18,0) NULL,
Primary Key  ([MaChiTietPhat]),
	CONSTRAINT [UQ_CHI_TIET_PHAT_MaPhieuPhat_MaVach] UNIQUE ([MaPhieuPhat],[MaVach])
) 
go

Create table [THAM_SO] (
	[TenThamSo] Varchar(50) NOT NULL,
	[GiaTri] Nvarchar(50) NULL,
	[MoTa] Nvarchar(50) NULL,
Primary Key  ([TenThamSo])
) 
go

Create table [THE_THANH_VIEN] (
	[MaSoThe] Varchar(20) NOT NULL,
	[NgayKichHoat] Datetime NULL,
	[NgayHetHan] Datetime NULL,
	[TrangThai] Tinyint NULL,
	[MaDG] Char(10) NOT NULL,
Primary Key  ([MaSoThe]),
	CONSTRAINT [UQ_THE_THANH_VIEN_MaDG] UNIQUE ([MaDG])
) 
go


Alter table [DOC_GIA] add  foreign key([MaGoi]) references [GOI_HOI_VIEN] ([MaGoi]) 
go
Alter table [PHIEU_GIA_HAN] add  foreign key([MaGoi]) references [GOI_HOI_VIEN] ([MaGoi]) 
go
Alter table [PHIEU_CAP_THE] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [PHIEU_MUON] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [PHIEU_DAT_TRUOC] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [PHIEU_GIA_HAN] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [GIAO_DICH_VI] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [PHIEU_PHAT] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [THE_THANH_VIEN] add  foreign key([MaDG]) references [DOC_GIA] ([MaDG]) 
go
Alter table [PHIEU_CAP_THE] add  foreign key([MaNV]) references [NHAN_VIEN] ([MaNV]) 
go
Alter table [PHIEU_THANH_LY] add  foreign key([MaNV]) references [NHAN_VIEN] ([MaNV]) 
go
Alter table [PHIEU_MUON] add  foreign key([MaNV]) references [NHAN_VIEN] ([MaNV]) 
go
Alter table [DAU_SACH] add  foreign key([MaTL]) references [THE_LOAI] ([MaTL]) 
go
Alter table [DAU_SACH] add  foreign key([MaNXB]) references [NHA_XUAT_BAN] ([MaNXB]) 
go
Alter table [CHI_TIET_TAC_GIA] add  foreign key([MaTG]) references [TAC_GIA] ([MaTG]) 
go
Alter table [CHI_TIET_TAC_GIA] add  foreign key([MaDauSach]) references [DAU_SACH] ([MaDauSach]) 
go
Alter table [SACH] add  foreign key([MaDauSach]) references [DAU_SACH] ([MaDauSach]) 
go
Alter table [PHIEU_DAT_TRUOC] add  foreign key([MaDauSach]) references [DAU_SACH] ([MaDauSach]) 
go
Alter table [PHIEU_THANH_LY] add  foreign key([MaVach]) references [SACH] ([MaVach]) 
go
Alter table [CHI_TIET_MUON] add  foreign key([MaVach]) references [SACH] ([MaVach]) 
go
Alter table [CHI_TIET_PHAT] add  foreign key([MaVach]) references [SACH] ([MaVach]) 
go
Alter table [CHI_TIET_MUON] add  foreign key([MaPhieuMuon]) references [PHIEU_MUON] ([MaPhieuMuon]) 
go
Alter table [PHIEU_PHAT] add  foreign key([MaPhieuMuon]) references [PHIEU_MUON] ([MaPhieuMuon]) 
go
Alter table [CHI_TIET_PHAT] add  foreign key([MaPhieuPhat]) references [PHIEU_PHAT] ([MaPhieuPhat]) 
go
Alter table [PHIEU_MUON] add  foreign key([MaSoThe]) references [THE_THANH_VIEN] ([MaSoThe]) 
go


Set quoted_identifier on
go

Set quoted_identifier off
go


/* =============================================
   RÀNG BUỘC TOÀN VẸN
   Ngày cập nhật: 25/01/2026
   ============================================= */

-- 1. CHỨC NĂNG TÀI CHÍNH
-- Phí tháng, Tiền cọc, Số dư ví, Tiền phạt KHÔNG được âm
ALTER TABLE GOI_HOI_VIEN ADD CONSTRAINT CK_GOI_PhiThang CHECK (PhiThang >= 0);
ALTER TABLE GOI_HOI_VIEN ADD CONSTRAINT CK_GOI_TienCoc CHECK (TienCoc >= 0);
ALTER TABLE PHIEU_GIA_HAN ADD CONSTRAINT CK_GH_SoTien CHECK (SoTien > 0);
ALTER TABLE PHIEU_PHAT ADD CONSTRAINT CK_PHAT_TongTien CHECK (TongTienPhat >= 0);
ALTER TABLE PHIEU_CAP_THE ADD CONSTRAINT CK_CAPTHE_Phi CHECK (PhiLamThe >= 0);
ALTER TABLE DAU_SACH ADD CONSTRAINT CK_SACH_GiaBia CHECK (GiaBia >= 0);

-- 2. CHỨC NĂNG MƯỢN TRẢ GIA HẠN
-- Ngày hết hạn thẻ phải sau ngày kích hoạt
ALTER TABLE THE_THANH_VIEN ADD CONSTRAINT CK_THE_NgayHetHan CHECK (NgayHetHan >= NgayKichHoat);
-- Ngày sinh độc giả phải nhỏ hơn ngày hiện tại (và hợp lý, ví dụ > 1900)
ALTER TABLE DOC_GIA ADD CONSTRAINT CK_DG_NgaySinh CHECK (NgaySinh < GETDATE() AND YEAR(NgaySinh) > 1900);

-- 3. CHỨC NĂNG QUẢN LÝ SÁCH THẺ
-- Trạng thái Sách chỉ được là: 0 (Sẵn sàng), 1 (Đang mượn), 2 (Hỏng), 3 (Mất)
ALTER TABLE SACH ADD CONSTRAINT CK_SACH_TrangThai CHECK (TrangThai IN (0, 1, 2, 3));
-- Trạng thái Thẻ chỉ được là: 0 (Khóa), 1 (Hoạt động)
ALTER TABLE THE_THANH_VIEN ADD CONSTRAINT CK_THE_TrangThai CHECK (TrangThai IN (0, 1));
-- Trạng thái Độc giả chỉ được là: 0 (Khóa), 1 (Hoạt động)
ALTER TABLE DOC_GIA ADD CONSTRAINT CK_DG_TrangThai CHECK (TrangThai IN (0, 1));

-- 4. Ràng buộc về SỐ LƯỢNG (Chức năng Kho/Gói cước)
-- Số lượng sách tồn kho không âm
ALTER TABLE DAU_SACH ADD CONSTRAINT CK_DAUSACH_SL CHECK (TongSoLuong >= 0);
-- Số sách tối đa được mượn của gói phải > 0
ALTER TABLE GOI_HOI_VIEN ADD CONSTRAINT CK_GOI_SoSach CHECK (SoSachToiDa > 0);

-- 5. Ràng buộc QUY CHUẨN DỮ LIỆU
-- Số điện thoại phải đủ 10 số (Giả định đơn giản cho VN)
ALTER TABLE DOC_GIA ADD CONSTRAINT CK_DG_SDT CHECK (LEN(SDT) = 10);
-- CCCD phải đủ 12 số
ALTER TABLE DOC_GIA ADD CONSTRAINT CK_DG_CCCD CHECK (LEN(CCCD) = 12);



/* =============================================================
   DATA
   ============================================================= */

-- 1. CẤU HÌNH HỆ THỐNG
INSERT INTO THAM_SO (TenThamSo, GiaTri, MoTa) VALUES 
('TIEN_PHAT_QUA_HAN', '5000', N'Tiền phạt quá hạn mỗi ngày/cuốn'),
('TIEN_PHAT_MAT_SACH', '100', N'Phạt bằng 100% giá bìa khi mất sách'),
('VAT', '8', N'Thuế VAT (%)');

-- 2. CÁC DANH MỤC (Identity tự tăng từ 1)
-- Thể loại
INSERT INTO THE_LOAI (TenTL) VALUES 
(N'Văn học trong nước'),      -- Sẽ tự sinh ID: 1
(N'Văn học nước ngoài'),      -- Sẽ tự sinh ID: 2
(N'Kinh tế - Quản trị'),      -- Sẽ tự sinh ID: 3
(N'Công nghệ thông tin'),     -- Sẽ tự sinh ID: 4
(N'Tâm lý - Kỹ năng sống'),   -- Sẽ tự sinh ID: 5
(N'Truyện tranh - Manga');    -- Sẽ tự sinh ID: 6

-- Nhà xuất bản
INSERT INTO NHA_XUAT_BAN (TenNXB, DiaChi) VALUES 
(N'NXB Trẻ', N'161B Lý Chính Thắng, Q.3, TP.HCM'),           -- ID: 1
(N'NXB Kim Đồng', N'55 Quang Trung, Hai Bà Trưng, Hà Nội'),  -- ID: 2
(N'NXB Nhã Nam', N'59 Đỗ Quang, Cầu Giấy, Hà Nội'),          -- ID: 3
(N'NXB Thế Giới', N'Hà Nội'),                                -- ID: 4
(N'NXB Lao Động', N'Hà Nội');                                -- ID: 5

-- Tác giả
INSERT INTO TAC_GIA (HoTG, TenLotTG, TenTG, QueQuan) VALUES 
(N'Nguyễn', N'Nhật', N'Ánh', N'Quảng Nam'),          -- ID: 1
(N'Rosie', N'', N'Nguyễn', N'Việt Nam'),             -- ID: 2
(N'Paulo', N'', N'Coelho', N'Brazil'),               -- ID: 3
(N'Robert', N'C.', N'Martin', N'USA'),               -- ID: 4
(N'Fujiko', N'F', N'Fujio', N'Japan'),               -- ID: 5
(N'Đặng', N'Hoàng', N'Giang', N'Việt Nam'),          -- ID: 6
(N'Napoleon', N'', N'Hill', N'USA');                 -- ID: 7

-- 3. GÓI HỘI VIÊN & NHÂN VIÊN
-- Gói cước
INSERT INTO GOI_HOI_VIEN (MaGoi, TenGoi, PhiThang, TienCoc, SoSachToiDa, SoNgayMuon, MoTa) VALUES 
('MOT_TAPSU', N'Mọt Tập Sự', 50000, 200000, 2, 7, N'Gói tiết kiệm, phù hợp sinh viên'),
('MOT_SANDIEU', N'Mọt Sành Điệu', 150000, 500000, 5, 14, N'Được đặt trước sách, miễn phí gửi xe'),
('MOT_CHUA', N'Mọt Chúa', 500000, 0, 10, 30, N'VIP, Không cần cọc, Giao sách tận nhà');

-- Nhân viên
INSERT INTO NHAN_VIEN (MaNV, HoNV, TenLotNV, TenNV, ChucVu, TaiKhoan, MatKhau) VALUES 
('NV01', N'Đỗ', N'Thanh', N'Hải', N'Quản trị viên (Admin)', 'admin', 'e10adc3949ba59abbe56e057f20f883e'), 
('NV02', N'Lê', N'Thị', N'Bích', N'Thủ thư', 'thuthu01', 'e10adc3949ba59abbe56e057f20f883e'),
('NV03', N'Trần', N'Quang', N'Khải', N'Thủ kho', 'thukho01', 'e10adc3949ba59abbe56e057f20f883e');

-- 4. KHO SÁCH
-- Đầu sách
INSERT INTO DAU_SACH (MaDauSach, TenSach, NamXB, GiaBia, TongSoLuong, MaTL, MaNXB, MoTa) VALUES 
('DS001', N'Mắt Biếc', 2019, 110000, 5, 1, 1, N'Câu chuyện tình đơn phương kinh điển của Ngạn.'),
('DS002', N'Tuổi trẻ đáng giá bao nhiêu?', 2018, 80000, 10, 5, 3, N'Cuốn sách self-help quốc dân cho giới trẻ.'),
('DS003', N'Nhà Giả Kim', 2020, 79000, 8, 2, 3, N'Hành trình theo đuổi ước mơ của Santiago.'),
('DS004', N'Clean Code: A Handbook of Agile Software Craftsmanship', 2008, 950000, 3, 4, 4, N'Kinh thánh cho lập trình viên.'),
('DS005', N'Doraemon - Tập 1', 2023, 25000, 20, 6, 2, N'Truyện tranh thiếu nhi.'),
('DS006', N'Nghĩ Giàu Làm Giàu', 2021, 115000, 6, 3, 5, N'Tư duy làm giàu của Napoleon Hill.'),
('DS007', N'Tìm mình trong thế giới hậu tuổi thơ', 2022, 150000, 4, 5, 3, N'Tâm lý học hiện đại của Đặng Hoàng Giang.');

-- Tác giả viết sách nào
INSERT INTO CHI_TIET_TAC_GIA (MaDauSach, MaTG, VaiTro) VALUES 
('DS001', 1, N'Tác giả'),
('DS002', 2, N'Tác giả'),
('DS003', 3, N'Tác giả'),
('DS004', 4, N'Tác giả'),
('DS005', 5, N'Họa sĩ'),
('DS006', 7, N'Tác giả'),
('DS007', 6, N'Tác giả');

-- Cuốn sách (Barcode dán trên sách)
-- INSERT INTO SACH(MaVach, MaDauSach, ViTri, TinhTrang, TrangThai) VALUES 
-- -- Mắt Biếc
-- ('MB-001', 'DS001', N'Kệ A1-01', N'Mới', 1), -- Đang mượn
-- ('MB-002', 'DS001', N'Kệ A1-01', N'Mới', 0),
-- ('MB-003', 'DS001', N'Kệ A1-01', N'Cũ nhẹ', 0),
-- -- Tuổi trẻ đáng giá bao nhiêu
-- ('TT-001', 'DS002', N'Kệ B2-05', N'Mới', 0),
-- ('TT-002', 'DS002', N'Kệ B2-05', N'Mới', 1), -- Đang mượn
-- ('TT-003', 'DS002', N'Kệ B2-05', N'Rách bìa', 2), -- Hỏng để thanh lý
-- -- Clean Code
-- ('CC-001', 'DS004', N'Kệ IT-Pro', N'Mới', 0),
-- ('CC-002', 'DS004', N'Kệ IT-Pro', N'Mới', 1); -- Đang mượn

INSERT INTO SACH(MaVach, MaDauSach, ViTri, TinhTrang, TrangThai) VALUES 
-- Mắt Biếc
('MB-001', 'DS001', N'Kệ A1-01', N'Mới', 1), -- Đang mượn
('MB-002', 'DS001', N'Kệ A1-01', N'Mới', 0),
('MB-003', 'DS001', N'Kệ A1-01', N'Cũ nhẹ', 0),
-- Tuổi trẻ đáng giá bao nhiêu
('TT-001', 'DS002', N'Kệ B2-05', N'Mới', 0),
('TT-002', 'DS002', N'Kệ B2-05', N'Mới', 0), 
('TT-003', 'DS002', N'Kệ B2-05', N'Rách bìa', 1), 
-- Clean Code
('CC-001', 'DS004', N'Kệ IT-Pro', N'Mới', 0),
('CC-002', 'DS004', N'Kệ IT-Pro', N'Mới', 1); -- Đang mượn

-- ...existing code...

-- 5. ĐỘC GIẢ
INSERT INTO DOC_GIA (MaDG, HoDG, TenLotDG, TenDG, NgaySinh, SDT, CCCD, Email, DiaChi, MaGoi, TrangThai, SoDuVi, DiemTichLuy) VALUES 
('DG001', N'Phạm', N'Minh', N'Tuấn', '2003-05-15', '0909111222', '079203001234', 'tuandev@gmail.com', N'Q.Thủ Đức, TP.HCM', 'MOT_TAPSU', 1, 50000, 100),
('DG002', N'Nguyễn', N'Thu', N'Hà', '1998-11-20', '0918333444', '079198005678', 'hnguyen@gmail.com', N'Q.1, TP.HCM', 'MOT_SANDIEU', 1, 300000, 500),
('DG003', N'Trần', N'Văn', N'Bình', '1995-02-10', '0939555666', '079195009999', 'binhtran@outlook.com', N'Q.7, TP.HCM', 'MOT_CHUA', 1, 1500000, 1200),
('DG004', N'Lê', N'Thị', N'Mai', '2004-01-01', '0988777888', '079204001111', 'maile@gmail.com', N'Q.Bình Thạnh, TP.HCM', 'MOT_TAPSU', 0, 0, 0);

-- 6. THẺ & GIAO DỊCH
-- Thẻ thành viên
INSERT INTO THE_THANH_VIEN (MaSoThe, MaDG, NgayKichHoat, NgayHetHan, TrangThai) VALUES 
('CARD-2024-001', 'DG001', '2024-01-01', '2026-01-01', 1),
('CARD-2024-002', 'DG002', '2024-02-15', '2026-02-15', 1),
('CARD-2024-003', 'DG003', '2024-03-20', '2026-03-20', 1),
('CARD-OLD-004', 'DG004', '2023-01-01', '2023-12-31', 0);

-- Lịch sử cấp thẻ
INSERT INTO PHIEU_CAP_THE (MaDG, MaNV, NgayCap, LoaiCap, PhiLamThe) VALUES 
('DG001', 'NV02', '2024-01-01', N'Cấp mới', 0),
('DG002', 'NV02', '2024-02-15', N'Cấp mới', 0),
('DG003', 'NV02', '2024-03-20', N'Cấp lại', 50000);

-- Giao dịch Ví
INSERT INTO GIAO_DICH_VI (MaDG, LoaiGiaoDich, SoTien, NgayGiaoDich, NoiDung) VALUES 
('DG002', 'NAP_TIEN', 500000, '2024-02-15', N'Nạp tiền kích hoạt tài khoản'),
('DG003', 'NAP_TIEN', 2000000, '2024-03-20', N'Nạp tiền gói VIP'),
('DG002', 'TRU_PHI_GOI', -150000, '2024-02-15', N'Trừ phí tháng 2/2024');

-- 7. MƯỢN TRẢ
-- PM1: Đã trả
INSERT INTO PHIEU_MUON (MaPhieuMuon, MaDG, MaNV, NgayMuon, GhiChu, MaSoThe) VALUES 
('PM240101001', 'DG002', 'NV02', '2024-02-20 08:30:00', N'Mượn sách đọc tại chỗ', 'CARD-2024-002');
INSERT INTO CHI_TIET_MUON (MaPhieuMuon, MaVach, NgayHenTra, NgayTraThucTe, TinhTrangSachKhiTra, TienPhatPhatSinh, TrangThai) VALUES 
('PM240101001', 'TT-001', '2024-02-27', '2024-02-25 10:00:00', N'Bình thường', 0, 1); 

-- PM2: Đang mượn (DG001 mượn Mắt Biếc)
INSERT INTO PHIEU_MUON (MaPhieuMuon, MaDG, MaNV, NgayMuon, GhiChu, MaSoThe) VALUES 
('PM240105002', 'DG001', 'NV02', GETDATE(), N'Mượn về nhà', 'CARD-2024-001');
INSERT INTO CHI_TIET_MUON (MaPhieuMuon, MaVach, NgayHenTra, NgayTraThucTe, TrangThai) VALUES 
('PM240105002', 'MB-001', DATEADD(DAY, 7, GETDATE()), NULL, 0); 

-- PM3: Đang mượn (Quá hạn - DG003 mượn Clean Code)
INSERT INTO PHIEU_MUON (MaPhieuMuon, MaDG, MaNV, NgayMuon, GhiChu, MaSoThe) VALUES 
('PM240105003', 'DG003', 'NV02', '2024-01-01', N'Mượn nghiên cứu', 'CARD-2024-003');
INSERT INTO CHI_TIET_MUON (MaPhieuMuon, MaVach, NgayHenTra, NgayTraThucTe, TrangThai) VALUES 
('PM240105003', 'CC-002', '2024-01-15', NULL, 0);

-- 8. PHẠT
INSERT INTO PHIEU_MUON (MaPhieuMuon, MaDG, MaNV, NgayMuon, GhiChu, MaSoThe) VALUES
('PM240115004', 'DG001', 'NV02', '2024-01-15 09:00:00', N'Mượn về nhà', 'CARD-2024-001');

INSERT INTO CHI_TIET_MUON (MaPhieuMuon, MaVach, NgayHenTra, NgayTraThucTe, TrangThai) VALUES
('PM240115004', 'TT-003', '2024-01-22', NULL, 0);

-- Phiếu phạt: gắn với PM240115004 để khớp TT-003
INSERT INTO PHIEU_PHAT (MaDG, MaPhieuMuon, NgayLap, TongTienPhat, LyDoPhat, TrangThai) VALUES 
('DG001', 'PM240115004', '2024-01-20', 20000, N'Làm rách bìa sách Tuổi trẻ đáng giá bao nhiêu', 1);

DECLARE @MaPhieuPhat INT = SCOPE_IDENTITY();

INSERT INTO CHI_TIET_PHAT (MaPhieuPhat, MaVach, LyDoPhat, SoTien) VALUES 
(@MaPhieuPhat, 'TT-003', N'Rách bìa', 20000);

-- Trừ tiền ví
INSERT INTO GIAO_DICH_VI (MaDG, LoaiGiaoDich, SoTien, NgayGiaoDich, NoiDung) VALUES 
('DG001', 'TRU_TIEN_PHAT', -20000, '2024-01-20', N'Trừ tiền phạt rách sách');


--123