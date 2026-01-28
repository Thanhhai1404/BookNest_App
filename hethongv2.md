# BookNest – Implementation Roadmap (Version 2.1)

## Flutter (Fresher/Junior) – Offline (Single-Device / Kiosk Mode) + Drift (SQLite)

> **Mục tiêu**: Xây dựng ứng dụng **Quản lý thư viện BookNest** chạy **trên 1 thiết bị duy nhất** (quầy/kiosk).
> **Dữ liệu**: Lưu trữ cục bộ (Offline) trên thiết bị bằng **Drift (SQLite)**.
> **Đối tượng**: Fresher/Junior Flutter – Ưu tiên "Dễ làm - Dễ test - Đầy đủ nghiệp vụ".

---

## 0) Nguyên tắc thiết kế (V2.1)

### 0.1 Single-Device (Kiosk Mode)

- Ứng dụng chạy độc lập trên 1 thiết bị (Android/iOS tablet hoặc phone).
- Dữ liệu nằm trong bộ nhớ máy.
- **Không** backend, **Không** đồng bộ cloud, **Không** nhiều người dùng cùng lúc.

### 0.2 Logic "Re-compute on App Start"

- Thay vì chạy ngầm (background service) phức tạp tốn pin.
- **Mỗi lần mở app** -> Hệ thống tự động quét và cập nhật trạng thái:
  - Hội viên hết hạn -> Chuyển status `Expired`.
  - Sách đang mượn quá hạn -> Đánh dấu `Overdue` để cảnh báo.
  - Đơn đặt trước (Reservation) quá hạn lấy sách -> Chuyển status `Cancelled`.

### 0.3 Digital-First (Không in ấn vật lý)

- **Hóa đơn điện tử (Digital Receipt)**: Hiển thị chi tiết giao dịch trên màn hình sau khi xong.
- **Thẻ thành viên ảo (Digital Card)**: Hiển thị mã QR trên màn hình để nhân viên quét.
- **Sao lưu thủ công**: Export/Import file database thay vì tự động backup online.

---

## 1) Tech Stack khuyến nghị

### 1.1 Core

- **Framework**: `Flutter 3.x` + Material 3 (Light/Dark theme).
- **State Management**: `flutter_riverpod` (Quản lý state, tách biệt UI và Logic).
- **Navigation**: `go_router` (Quản lý luồng màn hình).
- **Database**: `drift`, `drift_flutter`, `sqlite3_flutter_libs` (SQLite ORM mạnh mẽ).

### 1.2 Utilities & Hardware Access

- **Quét mã**: `mobile_scanner` (Quét ISBN, Mã thành viên, Mã sách).
- **Tạo mã QR**: `qr_flutter` (Hiển thị mã QR trên thẻ thành viên).
- **Format dữ liệu**: `intl` (Tiền tệ VNĐ, Ngày tháng dd/MM/yyyy).
- **Xử lý file/ảnh**:
  - `image_picker`: Chọn ảnh bìa sách/avatar từ thư viện máy.
  - `path_provider`: Lấy đường dẫn lưu file ảnh/DB trong máy.
  - `share_plus` & `file_picker`: Để Export/Import file backup DB.

### 1.3 Tooling

- `flutter_test`: Unit test logic.
- `mocktail`: Mock dữ liệu để test UI.
- `build_runner`: Sinh code cho Drift và Riverpod.

---

## 2) Phạm vi nghiệp vụ (Scope)

### 2.1 Nhóm chức năng chính

1.  **Hệ thống & Tài khoản**:
    - Đăng nhập (Admin/Member - tài khoản lưu local).
    - **Sao lưu & Khôi phục DB** (Backup/Restore).
2.  **Hội viên (Membership)**:
    - Quản lý hồ sơ, Gói cước (Mọt Tập Sự/Sành Điệu/Chúa).
    - **Thẻ ảo (QR)**.
    - **Điểm thưởng (Nest Point)**.
    - Ảnh đại diện.
3.  **Kho sách (Inventory)**:
    - Quản lý đầu sách, Bản copy (Mã cá biệt).
    - **Ảnh bìa sách**.
    - Vị trí kệ.
4.  **Lưu thông (Circulation)**:
    - Mượn (Checkout).
    - Trả (Check-in) & Tính phạt.
    - **Gia hạn (Renewal)** (Nghiệp vụ gói cao cấp).
    - **Đặt trước (Reservation)** (Nghiệp vụ gói cao cấp).
5.  **Tài chính**:
    - Thu phí gói, Thu phạt, Nạp ví.
6.  **Báo cáo**:
    - Doanh thu theo ngày/tháng.
    - Top sách mượn nhiều (Best-seller).
    - Tăng trưởng hội viên.

### 2.2 Ngoài scope (Không làm)

- API, Server, Cloud Sync.
- Kết nối máy in Bluetooth/LAN.
- Gửi Email/SMS thực tế (Chỉ hiện thông báo UI).

---

## 3) Cấu trúc thư mục (Feature-first)

Mục tiêu: **nhìn vào là hiểu ngay** phần nào thuộc `app/core/data/features`, dễ cho Fresher/Junior bám theo.

### 3.1 Cấu trúc đề xuất (rõ ràng, dễ mở rộng)

```text
lib/
  main.dart

  app/
    app.dart
    router.dart
    theme.dart

  core/
    constants/
    utils/
      money_format.dart
      date_format.dart
      image_helper.dart
    widgets/
      app_scaffold.dart
      empty_state.dart
      digital_receipt_widget.dart
    startup/
      app_startup_recompute.dart
    session/
      session_manager.dart

  data/
    db/
      app_database.dart
      tables/
        members.dart
        staff_accounts.dart
        subscriptions.dart
        books.dart
        book_copies.dart
        loans.dart
        reservations.dart
        renewals.dart
        fines.dart
        transactions.dart
        receipts.dart               # Lưu dữ liệu hóa đơn điện tử
    repositories/
      auth_repository.dart
      member_repository.dart
      inventory_repository.dart
      circulation_repository.dart
      finance_repository.dart
      receipt_repository.dart

  features/
    auth/
      presentation/
        login_page.dart
        login_view_model.dart

    member/
      presentation/
        member_list_page.dart
        member_detail_page.dart
        member_form_page.dart
        digital_card_page.dart      # Màn hình thẻ thành viên ảo (QR)

    inventory/
      presentation/
        book_search_page.dart       # Màn hình tìm kiếm sách
        book_detail_page.dart
        book_form_page.dart
        copy_register_page.dart

    circulation/
      presentation/
        checkout_page.dart
        checkin_page.dart
        reservation_modal.dart      # Popup đặt trước sách
        renewal_dialog.dart         # Popup gia hạn sách
        circulation_view_model.dart

    finance/
      presentation/
        wallet_page.dart
        fine_list_page.dart
        finance_view_model.dart

    receipts/
      presentation/
        receipt_view_page.dart      # Xem chi tiết hóa đơn sau giao dịch
        receipt_view_model.dart

    settings/
      presentation/
        backup_restore_page.dart    # Màn hình Sao lưu/Khôi phục DB
        settings_view_model.dart
```

### 3.2 Ghi chú để tránh rối

- `core/` chỉ chứa **đồ dùng chung** (utils/widgets/session/startup).
- `data/` là **Drift + repositories** (không UI).
- `features/` là **UI theo nghiệp vụ** (mỗi feature một cụm màn hình + view model).
- Những file “(Mới)” không cần ghi trong cây; chỉ cần đặt đúng vị trí như trên.

---

## 4) Nghiệp vụ chi tiết

### 4.1 Hội viên & Thẻ ảo

- **Dữ liệu**: Tên, SĐT, Gói cước, Ngày hết hạn, **Ảnh đại diện (Avatar path)**, **Điểm tích lũy (Points)**.
- **Thẻ ảo (Digital Card)**:
  - Hiển thị: Avatar + Tên + Hạng thẻ + Điểm thưởng + Ngày hết hạn.
  - Mã QR: Tạo từ `memberId` (để nhân viên quét nhanh khi mượn).
- **Lưu ý ảnh**: Không lưu file ảnh vào DB. Lưu file vào `AppDocumentDirectory`, chỉ lưu **đường dẫn (String path)** vào cột `avatarPath` trong DB.

### 4.2 Kho sách & Ảnh bìa

- **Dữ liệu**: Đầu sách + List Copy (Mã cá biệt Copy ID).
- **Ảnh bìa**: Tương tự hội viên, lưu path ảnh bìa vào bảng `Books`.
- **Trạng thái Copy**: `Available` (Sẵn sàng), `Borrowed` (Đang mượn), `Reserved` (Đã có người đặt), `Lost` (Mất), `Liquidated` (Thanh lý).
- **Tra cứu sách (Search & Filter)**:
  - **Tìm kiếm theo**: Tên sách, Tác giả, Mã ISBN (Nhập tay hoặc quét mã).
  - **Lọc theo**: Thể loại, Trạng thái (Ví dụ: Chỉ hiện sách `Available` để biết cuốn nào còn mượn được).

### 4.3 Mượn - Trả (Cốt lõi)

- **Mượn (Checkout)**:

  - **Input**: Scan thẻ Member -> Scan mã sách Copy ID.
  - **Validate**:
    1. Hội viên Active?
    2. Còn hạn mức mượn (số cuốn)?
    3. Sách trạng thái `Available`? (Nếu `Reserved` bởi người khác -> Chặn).
  - **Action**: Tạo `Loan` (Trạng thái Open), Update Copy sang `Borrowed`.
  - **Output**: Điều hướng sang màn hình **Digital Receipt**.

- **Trả (Check-in)**:
  - **Input**: Scan mã sách Copy ID.
  - **Logic Tính phạt**:
    - `lateDays = (Today - DueDate)`.
    - Nếu `lateDays > 0`: Tạo phiếu phạt `Fine`.
  - **Logic Điểm thưởng (Nest Points)**:
    - Nếu `lateDays <= 0` (Trả đúng/sớm hạn): Cộng điểm vào `Members.points` (Ví dụ: +10 điểm/cuốn).
  - **Logic Đặt trước (Reservation fulfillment)**:
    - Kiểm tra bảng `Reservations`: Có ai đang chờ cuốn này không?
    - Nếu CÓ: Đổi trạng thái Copy thành `Reserved`. Hiện Popup: _"Sách này được đặt bởi [Tên khách]. Vui lòng giữ lại quầy."_
    - Nếu KHÔNG: Đổi trạng thái Copy thành `Available`.

### 4.4 Gia hạn (Renewal) - (Tính năng Mới)

- **Quyền lợi**: Kiểm tra cấu hình gói cước (VD: Mọt Sành Điệu được gia hạn 1 lần).
- **Validate**:
  1. Sách chưa quá hạn (Quá hạn không được gia hạn, phải trả & nộp phạt).
  2. Chưa gia hạn quá số lần quy định.
  3. **Quan trọng**: Không có ai đang Đặt trước (Reservation) cuốn này.
- **Action**:
  - Cập nhật `Loan.dueDate` mới.
  - Tạo bản ghi vào bảng `Renewals` để lưu vết.

### 4.5 Đặt trước (Reservation) - (Tính năng Mới)

- **Quyền lợi**: Chỉ gói Mọt Sành Điệu/Mọt Chúa.
- **Trigger**: Khi tìm sách, nếu tất cả bản copy đều đang `Borrowed`.
- **Action**:
  - Tạo phiếu `Reservation`: `MemberId` + `BookId` + `CreatedDate` + `Status=Active`.
- **Hết hạn đặt**: Khi "Re-compute on App Start", nếu đơn đặt quá X ngày mà chưa có sách -> `Cancelled`.

### 4.6 Sao lưu & Khôi phục (Backup/Restore) - (An toàn dữ liệu)

- **Vị trí**: Màn hình Cài đặt (Settings) hoặc Admin Dashboard.
- **Export (Sao lưu)**:
  - Copy file `db.sqlite` (từ `getApplicationDocumentsDirectory`) ra thư mục Cache/Temp.
  - Dùng `share_plus` mở dialog chia sẻ (Lưu vào Google Drive, Zalo, hoặc Save to Files).
- **Import (Khôi phục)**:
  - Dùng `file_picker` chọn file `.sqlite` từ máy.
  - Cảnh báo: "Dữ liệu hiện tại sẽ bị ghi đè".
  - Copy file được chọn đè vào vị trí `db.sqlite` của app.
  - Yêu cầu người dùng khởi động lại App.

---

## 5) Database Schema (Drift - Định hướng)

Bạn cần ánh xạ các bảng sau từ SQL sang Drift (Dart code):

1.  **Subscriptions** (Gói cước): `id`, `name`, `price`, `maxBooks`, `maxDays`, `allowReservation` (Bool), `allowRenewal` (Bool).
2.  **Members** (Hội viên): `id`, `fullName`, `phone`, `subscriptionId`, `expiryDate`, `points` (Int), `avatarPath` (String), `status`.
3.  **Books** (Đầu sách): `id`, `title`, `author`, `publisher`, `isbn`, `coverPath` (String).
4.  **BookCopies** (Bản sách): `id` (Barcode), `bookId`, `status`, `location`.
5.  **Loans** (Phiếu mượn): `id`, `copyId`, `memberId`, `borrowedAt`, `dueDate`, `returnedAt`.
6.  **Reservations** (Phiếu đặt): `id`, `bookId`, `memberId`, `createdAt`, `status` (Active/Fulfilled/Cancelled).
7.  **Renewals** (Lịch sử gia hạn): `id`, `loanId`, `renewedAt`, `oldDueDate`, `newDueDate`.
8.  **Transactions** (Giao dịch tài chính): `id`, `memberId`, `amount`, `type` (Fee/Fine/Topup), `createdAt`, `description`.

---

## 6) Lộ trình thực hiện (Milestones)

### Milestone 1: Setup & Cơ sở (2-3 ngày)

- Setup project, Riverpod, Drift.
- Tạo 2 user mẫu trong DB (1 Admin, 1 Member).
- **Tính năng Backup/Restore** (Ưu tiên làm sớm để tiện backup dữ liệu test).

### Milestone 2: Hội viên & Kho sách (3-4 ngày)

- CRUD Hội viên + Upload Avatar.
- CRUD Sách + Upload Ảnh bìa.
- Màn hình **Digital Member Card** (Có QR Code).

### Milestone 3: Mượn - Trả cơ bản (4-5 ngày)

- Tích hợp `mobile_scanner` để quét mã.
- Chức năng Checkout (Mượn) -> Ra Hóa đơn.
- Chức năng Check-in (Trả) + Tính phạt + **Cộng điểm thưởng**.

### Milestone 4: Gia hạn & Đặt trước (3-4 ngày)

- Thêm nút "Gia hạn" trong chi tiết phiếu mượn (Check quyền & Logic).
- Thêm nút "Đặt trước" khi tìm sách hết hàng.
- Cập nhật luồng Check-in: Báo hiệu khi sách trả là sách đang được đặt.

### Milestone 5: Báo cáo & Hoàn thiện (2-3 ngày)

- Báo cáo doanh thu, Top sách, Sách sắp hết hạn.
- Logic "Re-compute" khi mở app (Quét quá hạn).
- UI Polish (Dark mode, Icon đẹp, Empty states).

---

## 7) Tổng kết

Với bản V2.1 này, ứng dụng BookNest của bạn sẽ:

1.  **Hiện đại**: Dùng QR, Hóa đơn ảo, Thẻ ảo.
2.  **An toàn**: Có chức năng Backup/Restore thủ công.
3.  **Đúng nghiệp vụ thư viện**: Đầy đủ Gia hạn, Đặt trước, Tích điểm.
4.  **Khả thi cho người mới**: Không server, không phần cứng phức tạp.

## 8) UI/UX Guidelines (Bổ sung)

- **Primary Color**: Amber/Orange (Màu thương hiệu BookNest - Vàng cam ấm cúng).
- **Typography**: Font mặc định của Material 3 hoặc Google Fonts (ví dụ: Poppins/Roboto).
- **Components**: Sử dụng `Card`, `ListTile` chuẩn Material 3. Các nút hành động chính (FloatingActionButton) phải nổi bật.
- **Dark Mode**: Hỗ trợ đầy đủ giao diện tối.
