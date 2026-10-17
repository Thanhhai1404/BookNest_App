-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.chi_tiet_don_hang (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ma_don_hang bigint NOT NULL,
  mads character NOT NULL,
  so_luong integer NOT NULL DEFAULT 1,
  don_gia numeric NOT NULL DEFAULT 0,
  thanh_tien numeric NOT NULL DEFAULT 0,
  CONSTRAINT chi_tiet_don_hang_pkey PRIMARY KEY (id),
  CONSTRAINT chi_tiet_don_hang_ma_don_hang_fkey FOREIGN KEY (ma_don_hang) REFERENCES public.don_hang(ma_don_hang),
  CONSTRAINT chi_tiet_don_hang_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads)
);
CREATE TABLE public.chi_tiet_muon (
  mapm text NOT NULL,
  mavach text NOT NULL,
  ngayhentra timestamp with time zone,
  ngaytrathucte timestamp with time zone,
  tinhtrangsachkhitra text,
  tienphatphatsinh bigint,
  trangthai integer,
  solangiahan integer DEFAULT 0,
  CONSTRAINT chi_tiet_muon_pkey PRIMARY KEY (mapm, mavach),
  CONSTRAINT chi_tiet_muon_mapm_fkey FOREIGN KEY (mapm) REFERENCES public.phieu_muon(mapm),
  CONSTRAINT chi_tiet_muon_mavach_fkey FOREIGN KEY (mavach) REFERENCES public.sach(mavach)
);
CREATE TABLE public.chi_tiet_phat (
  mactp bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  mapp bigint,
  mavach text,
  lydophat text,
  sotien bigint,
  CONSTRAINT chi_tiet_phat_pkey PRIMARY KEY (mactp),
  CONSTRAINT chi_tiet_phat_mapp_fkey FOREIGN KEY (mapp) REFERENCES public.phieu_phat(mapp),
  CONSTRAINT chi_tiet_phat_mavach_fkey FOREIGN KEY (mavach) REFERENCES public.sach(mavach)
);
CREATE TABLE public.chi_tiet_tac_gia (
  mads text NOT NULL,
  matg bigint NOT NULL,
  vaitro text,
  CONSTRAINT chi_tiet_tac_gia_pkey PRIMARY KEY (mads, matg),
  CONSTRAINT chi_tiet_tac_gia_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads),
  CONSTRAINT chi_tiet_tac_gia_matg_fkey FOREIGN KEY (matg) REFERENCES public.tac_gia(matg)
);
CREATE TABLE public.danh_gia (
  ma_danh_gia bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg character NOT NULL,
  mads character NOT NULL,
  diem_so integer NOT NULL CHECK (diem_so >= 1 AND diem_so <= 5),
  noi_dung text,
  tieu_de character varying,
  so_thich integer DEFAULT 0,
  trang_thai character varying DEFAULT 'active'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT danh_gia_pkey PRIMARY KEY (ma_danh_gia),
  CONSTRAINT danh_gia_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT danh_gia_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads)
);
CREATE TABLE public.dau_sach (
  mads text NOT NULL,
  tensach text,
  namxb integer,
  giabia bigint CHECK (giabia >= 0),
  tongsoluong integer CHECK (tongsoluong >= 0),
  mota text,
  matl bigint,
  manxb bigint,
  anhbia text,
  gia_ban numeric,
  so_luong_ban integer DEFAULT 0,
  so_luong_cho_muon bigint DEFAULT '0'::bigint,
  giam_gia integer DEFAULT 0,
  CONSTRAINT dau_sach_pkey PRIMARY KEY (mads),
  CONSTRAINT dau_sach_matl_fkey FOREIGN KEY (matl) REFERENCES public.the_loai(matl),
  CONSTRAINT dau_sach_manxb_fkey FOREIGN KEY (manxb) REFERENCES public.nha_xuat_ban(manxb)
);
CREATE TABLE public.doc_gia (
  madg text NOT NULL,
  hodg text,
  tenlotdg text,
  tendg text,
  ngaysinh timestamp with time zone CHECK (ngaysinh < now()),
  sdt text UNIQUE CHECK (length(sdt) = 10),
  cccd text UNIQUE CHECK (length(cccd) = 12),
  email text UNIQUE,
  dia_chi text,
  ngayhethangoi timestamp with time zone,
  soduvi bigint DEFAULT 0,
  diemtichluy integer DEFAULT 0,
  trangthai boolean DEFAULT true,
  magoi text,
  avatar_url text,
  diem_tin_nhiem integer DEFAULT 100,
  matkhau character varying,
  CONSTRAINT doc_gia_pkey PRIMARY KEY (madg),
  CONSTRAINT doc_gia_magoi_fkey FOREIGN KEY (magoi) REFERENCES public.goi_hoi_vien(magoi)
);
CREATE TABLE public.don_hang (
  ma_don_hang bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg character NOT NULL,
  ngay_dat timestamp with time zone DEFAULT now(),
  ho_ten_nhan character varying,
  sdt_nhan character,
  dia_chi_nhan character varying,
  phuong_thuc_thanh_toan character varying DEFAULT 'vi_booknest'::character varying,
  tong_tien numeric DEFAULT 0,
  phi_van_chuyen numeric DEFAULT 0,
  giam_gia numeric DEFAULT 0,
  thanh_toan numeric DEFAULT 0,
  trang_thai character varying DEFAULT 'cho_xac_nhan'::character varying,
  ghi_chu character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  ma_voucher character varying,
  CONSTRAINT don_hang_pkey PRIMARY KEY (ma_don_hang),
  CONSTRAINT don_hang_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.giao_dich_vi (
  magd bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  loaigiaodich text,
  sotien bigint,
  ngaygiaodich timestamp with time zone DEFAULT now(),
  noidung text,
  madg text,
  CONSTRAINT giao_dich_vi_pkey PRIMARY KEY (magd),
  CONSTRAINT giao_dich_vi_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.goi_hoi_vien (
  magoi text NOT NULL,
  tengoi text,
  phithang bigint CHECK (phithang >= 0),
  tiencoc bigint CHECK (tiencoc >= 0),
  sosachtoida integer CHECK (sosachtoida > 0),
  songaymuon integer,
  mota text,
  CONSTRAINT goi_hoi_vien_pkey PRIMARY KEY (magoi)
);
CREATE TABLE public.luot_thich_danh_gia (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg character NOT NULL,
  ma_danh_gia bigint NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT luot_thich_danh_gia_pkey PRIMARY KEY (id),
  CONSTRAINT luot_thich_danh_gia_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT luot_thich_danh_gia_ma_danh_gia_fkey FOREIGN KEY (ma_danh_gia) REFERENCES public.danh_gia(ma_danh_gia)
);
CREATE TABLE public.nha_xuat_ban (
  manxb bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  tennxb text,
  diachi text,
  CONSTRAINT nha_xuat_ban_pkey PRIMARY KEY (manxb)
);
CREATE TABLE public.nhan_vien (
  manv text NOT NULL,
  honv text,
  tenlotnv text,
  tennv text,
  chucvu text,
  taikhoan text UNIQUE,
  matkhau text,
  trang_thai boolean DEFAULT true,
  CONSTRAINT nhan_vien_pkey PRIMARY KEY (manv)
);
CREATE TABLE public.nhat_ky_hoat_dong (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  manv text,
  module text NOT NULL,
  hanhdong text NOT NULL,
  noidung text NOT NULL,
  madg text,
  thamchieu_id text,
  thoigian timestamp with time zone DEFAULT now(),
  CONSTRAINT nhat_ky_hoat_dong_pkey PRIMARY KEY (id),
  CONSTRAINT nhat_ky_hoat_dong_manv_fkey FOREIGN KEY (manv) REFERENCES public.nhan_vien(manv),
  CONSTRAINT nhat_ky_hoat_dong_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.phieu_cap_the (
  mapc bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ngaycap timestamp with time zone DEFAULT now(),
  loaicap text,
  philamthe bigint CHECK (philamthe >= 0),
  madg text,
  manv text,
  CONSTRAINT phieu_cap_the_pkey PRIMARY KEY (mapc),
  CONSTRAINT phieu_cap_the_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT phieu_cap_the_manv_fkey FOREIGN KEY (manv) REFERENCES public.nhan_vien(manv)
);
CREATE TABLE public.phieu_dat_truoc (
  madat bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ngaydat timestamp with time zone DEFAULT now(),
  trangthai integer,
  madg text,
  mads text,
  CONSTRAINT phieu_dat_truoc_pkey PRIMARY KEY (madat),
  CONSTRAINT phieu_dat_truoc_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT phieu_dat_truoc_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads)
);
CREATE TABLE public.phieu_muon (
  mapm text NOT NULL,
  ngaymuon timestamp with time zone DEFAULT now(),
  ghichu text,
  madg text,
  manv text,
  mast text,
  CONSTRAINT phieu_muon_pkey PRIMARY KEY (mapm),
  CONSTRAINT phieu_muon_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT phieu_muon_manv_fkey FOREIGN KEY (manv) REFERENCES public.nhan_vien(manv),
  CONSTRAINT phieu_muon_mast_fkey FOREIGN KEY (mast) REFERENCES public.the_thanh_vien(mast)
);
CREATE TABLE public.phieu_phat (
  mapp bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ngaylap timestamp with time zone DEFAULT now(),
  tongtienphat bigint CHECK (tongtienphat >= 0),
  lydophat text,
  trangthai boolean,
  madg text,
  mapm text,
  CONSTRAINT phieu_phat_pkey PRIMARY KEY (mapp),
  CONSTRAINT phieu_phat_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT phieu_phat_mapm_fkey FOREIGN KEY (mapm) REFERENCES public.phieu_muon(mapm)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text,
  role text DEFAULT 'admin'::text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.sach (
  mavach text NOT NULL,
  vitri text,
  tinhtrang text,
  trangthai integer CHECK (trangthai = ANY (ARRAY[0, 1, 2, 3])),
  mads text,
  CONSTRAINT sach_pkey PRIMARY KEY (mavach),
  CONSTRAINT sach_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads)
);
CREATE TABLE public.tac_gia (
  matg bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  hotg text,
  tenlottg text,
  tentg text,
  quequan text,
  CONSTRAINT tac_gia_pkey PRIMARY KEY (matg)
);
CREATE TABLE public.tham_so (
  tenthamso text NOT NULL,
  giatri text,
  mota text,
  CONSTRAINT tham_so_pkey PRIMARY KEY (tenthamso)
);
CREATE TABLE public.the_loai (
  matl bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  tentl text,
  CONSTRAINT the_loai_pkey PRIMARY KEY (matl)
);
CREATE TABLE public.the_thanh_vien (
  mast text NOT NULL,
  ngaykichhoat timestamp with time zone,
  ngayhethan timestamp with time zone,
  trangthai boolean DEFAULT true,
  madg text UNIQUE,
  CONSTRAINT the_thanh_vien_pkey PRIMARY KEY (mast),
  CONSTRAINT the_thanh_vien_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.theo_doi (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  nguoi_theo_doi character NOT NULL,
  nguoi_duoc_theo_doi character NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT theo_doi_pkey PRIMARY KEY (id),
  CONSTRAINT theo_doi_nguoi_theo_doi_fkey FOREIGN KEY (nguoi_theo_doi) REFERENCES public.doc_gia(madg),
  CONSTRAINT theo_doi_nguoi_duoc_theo_doi_fkey FOREIGN KEY (nguoi_duoc_theo_doi) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.thong_bao (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  tieu_de text NOT NULL,
  noi_dung text,
  loai_thong_bao text,
  da_doc boolean DEFAULT false,
  ngay_tao timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT thong_bao_pkey PRIMARY KEY (id)
);
CREATE TABLE public.thong_bao_app (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg text,
  tieu_de text NOT NULL,
  noi_dung text,
  loai_thong_bao text,
  da_doc boolean DEFAULT false,
  ngay_tao timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT thong_bao_app_pkey PRIMARY KEY (id)
);
CREATE TABLE public.trang_thai_doc (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg character NOT NULL,
  mads character NOT NULL,
  trang_thai character varying NOT NULL DEFAULT 'muon_doc'::character varying,
  tien_do integer DEFAULT 0,
  bat_dau_doc timestamp with time zone,
  doc_xong timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT trang_thai_doc_pkey PRIMARY KEY (id),
  CONSTRAINT trang_thai_doc_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg),
  CONSTRAINT trang_thai_doc_mads_fkey FOREIGN KEY (mads) REFERENCES public.dau_sach(mads)
);
CREATE TABLE public.vi_voucher (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  madg text NOT NULL,
  ma_voucher character varying NOT NULL,
  da_su_dung boolean DEFAULT false,
  ngay_nhan timestamp with time zone DEFAULT now(),
  CONSTRAINT vi_voucher_pkey PRIMARY KEY (id),
  CONSTRAINT vi_voucher_madg_fkey FOREIGN KEY (madg) REFERENCES public.doc_gia(madg)
);
CREATE TABLE public.voucher (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ma_voucher character varying NOT NULL UNIQUE,
  ten_voucher character varying NOT NULL,
  loai_giam character varying NOT NULL CHECK (loai_giam::text = ANY (ARRAY['tien_mat'::character varying, 'phan_tram'::character varying]::text[])),
  gia_tri numeric NOT NULL,
  giam_toi_da numeric,
  don_toi_thieu numeric DEFAULT 0,
  so_luong_tong integer NOT NULL,
  so_luong_da_dung integer DEFAULT 0,
  ngay_bat_dau timestamp with time zone DEFAULT now(),
  ngay_ket_thuc timestamp with time zone NOT NULL,
  trang_thai boolean DEFAULT true,
  CONSTRAINT voucher_pkey PRIMARY KEY (id)
);