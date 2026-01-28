import 'package:drift/drift.dart';

import '../../core/constants/enums.dart';
import 'app_database.dart';

class SeedData {
  const SeedData._();

  /// Inserts initial data only when the database is empty.
  ///
  /// Data source: `QLTV - V2.sql` (INSERT INTO ...)
  static Future<void> seedIfNeeded(AppDatabase db) async {
    final existing = await (db.select(db.subscriptions)..limit(1)).get();
    if (existing.isNotEmpty) return;

    await db.transaction(() async {
      // 1) Categories (THE_LOAI) - keep insertion order so IDs match SQL (1..)
      await db.batch((b) {
        b.insertAll(db.categories, [
          CategoriesCompanion.insert(name: const Value('Văn học trong nước')),
          CategoriesCompanion.insert(name: const Value('Văn học nước ngoài')),
          CategoriesCompanion.insert(name: const Value('Kinh tế - Quản trị')),
          CategoriesCompanion.insert(name: const Value('Công nghệ thông tin')),
          CategoriesCompanion.insert(
              name: const Value('Tâm lý - Kỹ năng sống')),
          CategoriesCompanion.insert(name: const Value('Truyện tranh - Manga')),
        ]);
      });

      // 2) Publishers (NHA_XUAT_BAN) - keep insertion order so IDs match SQL (1..)
      await db.batch((b) {
        b.insertAll(db.publishers, [
          PublishersCompanion.insert(
            name: const Value('NXB Trẻ'),
            address: const Value('161B Lý Chính Thắng, Q.3, TP.HCM'),
          ),
          PublishersCompanion.insert(
            name: const Value('NXB Kim Đồng'),
            address: const Value('55 Quang Trung, Hai Bà Trưng, Hà Nội'),
          ),
          PublishersCompanion.insert(
            name: const Value('NXB Nhã Nam'),
            address: const Value('59 Đỗ Quang, Cầu Giấy, Hà Nội'),
          ),
          PublishersCompanion.insert(
            name: const Value('NXB Thế Giới'),
            address: const Value('Hà Nội'),
          ),
          PublishersCompanion.insert(
            name: const Value('NXB Lao Động'),
            address: const Value('Hà Nội'),
          ),
        ]);
      });

      // 3) Authors (TAC_GIA) - keep insertion order so IDs match SQL (1..)
      await db.batch((b) {
        b.insertAll(db.authors, [
          AuthorsCompanion.insert(
            lastName: const Value('Nguyễn'),
            middleName: const Value('Nhật'),
            firstName: const Value('Ánh'),
            hometown: const Value('Quảng Nam'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Rosie'),
            middleName: const Value(''),
            firstName: const Value('Nguyễn'),
            hometown: const Value('Việt Nam'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Paulo'),
            middleName: const Value(''),
            firstName: const Value('Coelho'),
            hometown: const Value('Brazil'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Robert'),
            middleName: const Value('C.'),
            firstName: const Value('Martin'),
            hometown: const Value('USA'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Fujiko'),
            middleName: const Value('F'),
            firstName: const Value('Fujio'),
            hometown: const Value('Japan'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Đặng'),
            middleName: const Value('Hoàng'),
            firstName: const Value('Giang'),
            hometown: const Value('Việt Nam'),
          ),
          AuthorsCompanion.insert(
            lastName: const Value('Napoleon'),
            middleName: const Value(''),
            firstName: const Value('Hill'),
            hometown: const Value('USA'),
          ),
        ]);
      });

      // 4) Subscriptions (GOI_HOI_VIEN)
      await db.batch((b) {
        b.insertAll(db.subscriptions, [
          SubscriptionsCompanion.insert(
            id: 'MOT_TAPSU',
            name: const Value('Mọt Tập Sự'),
            monthlyFee: const Value(50000),
            deposit: const Value(200000),
            maxBooks: const Value(2),
            maxDays: const Value(7),
            description: const Value('Gói tiết kiệm, phù hợp sinh viên'),
            allowReservation: const Value(false),
            allowRenewal: const Value(false),
          ),
          SubscriptionsCompanion.insert(
            id: 'MOT_SANDIEU',
            name: const Value('Mọt Sành Điệu'),
            monthlyFee: const Value(150000),
            deposit: const Value(500000),
            maxBooks: const Value(5),
            maxDays: const Value(14),
            description: const Value('Được đặt trước sách, miễn phí gửi xe'),
            allowReservation: const Value(true),
            allowRenewal: const Value(true),
          ),
          SubscriptionsCompanion.insert(
            id: 'MOT_CHUA',
            name: const Value('Mọt Chúa'),
            monthlyFee: const Value(500000),
            deposit: const Value(0),
            maxBooks: const Value(10),
            maxDays: const Value(30),
            description: const Value('VIP, Không cần cọc, Giao sách tận nhà'),
            allowReservation: const Value(true),
            allowRenewal: const Value(true),
          ),
        ]);
      });

      // 5) Staff accounts (NHAN_VIEN) - seed exactly as SQL inserts.
      await db.batch((b) {
        b.insertAll(db.staffAccounts, [
          StaffAccountsCompanion.insert(
            id: 'NV01',
            lastName: const Value('Đỗ'),
            middleName: const Value('Thanh'),
            firstName: const Value('Hải'),
            role: const Value('Quản trị viên (Admin)'),
            username: 'admin',
            password: 'e10adc3949ba59abbe56e057f20f883e',
          ),
          StaffAccountsCompanion.insert(
            id: 'NV02',
            lastName: const Value('Lê'),
            middleName: const Value('Thị'),
            firstName: const Value('Bích'),
            role: const Value('Thủ thư'),
            username: 'thuthu01',
            password: 'e10adc3949ba59abbe56e057f20f883e',
          ),
          StaffAccountsCompanion.insert(
            id: 'NV03',
            lastName: const Value('Trần'),
            middleName: const Value('Quang'),
            firstName: const Value('Khải'),
            role: const Value('Thủ kho'),
            username: 'thukho01',
            password: 'e10adc3949ba59abbe56e057f20f883e',
          ),
        ]);
      });

      // 6) Books (DAU_SACH) - insert full list from SQL so later relations match
      await db.batch((b) {
        b.insertAll(db.books, [
          BooksCompanion.insert(
            id: 'DS001',
            title: const Value('Mắt Biếc'),
            publishedYear: const Value(2019),
            coverPrice: const Value(110000),
            totalQuantity: const Value(5),
            description:
                const Value('Câu chuyện tình đơn phương kinh điển của Ngạn.'),
            categoryId: 1,
            publisherId: 1,
          ),
          BooksCompanion.insert(
            id: 'DS002',
            title: const Value('Tuổi trẻ đáng giá bao nhiêu?'),
            publishedYear: const Value(2018),
            coverPrice: const Value(80000),
            totalQuantity: const Value(10),
            description:
                const Value('Cuốn sách self-help quốc dân cho giới trẻ.'),
            categoryId: 5,
            publisherId: 3,
          ),
          BooksCompanion.insert(
            id: 'DS003',
            title: const Value('Nhà Giả Kim'),
            publishedYear: const Value(2020),
            coverPrice: const Value(79000),
            totalQuantity: const Value(8),
            description:
                const Value('Hành trình theo đuổi ước mơ của Santiago.'),
            categoryId: 2,
            publisherId: 3,
          ),
          BooksCompanion.insert(
            id: 'DS004',
            title: const Value(
                'Clean Code: A Handbook of Agile Software Craftsmanship'),
            publishedYear: const Value(2008),
            coverPrice: const Value(950000),
            totalQuantity: const Value(3),
            description: const Value('Kinh thánh cho lập trình viên.'),
            categoryId: 4,
            publisherId: 4,
          ),
          BooksCompanion.insert(
            id: 'DS005',
            title: const Value('Doraemon - Tập 1'),
            publishedYear: const Value(2023),
            coverPrice: const Value(25000),
            totalQuantity: const Value(20),
            description: const Value('Truyện tranh thiếu nhi.'),
            categoryId: 6,
            publisherId: 2,
          ),
          BooksCompanion.insert(
            id: 'DS006',
            title: const Value('Nghĩ Giàu Làm Giàu'),
            publishedYear: const Value(2021),
            coverPrice: const Value(115000),
            totalQuantity: const Value(6),
            description: const Value('Tư duy làm giàu của Napoleon Hill.'),
            categoryId: 3,
            publisherId: 5,
          ),
          BooksCompanion.insert(
            id: 'DS007',
            title: const Value('Tìm mình trong thế giới hậu tuổi thơ'),
            publishedYear: const Value(2022),
            coverPrice: const Value(150000),
            totalQuantity: const Value(4),
            description:
                const Value('Tâm lý học hiện đại của Đặng Hoàng Giang.'),
            categoryId: 5,
            publisherId: 3,
          ),
        ]);
      });

      // 7) BookAuthors (CHI_TIET_TAC_GIA)
      await db.batch((b) {
        b.insertAll(db.bookAuthors, [
          BookAuthorsCompanion.insert(
            bookId: 'DS001',
            authorId: 1,
            role: const Value('Tác giả'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS002',
            authorId: 2,
            role: const Value('Tác giả'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS003',
            authorId: 3,
            role: const Value('Tác giả'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS004',
            authorId: 4,
            role: const Value('Tác giả'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS005',
            authorId: 5,
            role: const Value('Họa sĩ'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS006',
            authorId: 7,
            role: const Value('Tác giả'),
          ),
          BookAuthorsCompanion.insert(
            bookId: 'DS007',
            authorId: 6,
            role: const Value('Tác giả'),
          ),
        ]);
      });

      // 8) BookCopies (SACH) - status map matches SQL constraint CK_SACH_TrangThai
      await db.batch((b) {
        b.insertAll(db.bookCopies, [
          // Mắt Biếc
          BookCopiesCompanion.insert(
            id: 'MB-001',
            bookId: 'DS001',
            location: const Value('Kệ A1-01'),
            condition: const Value('Mới'),
            status: Value(BookStatus.borrowed.code),
          ),
          BookCopiesCompanion.insert(
            id: 'MB-002',
            bookId: 'DS001',
            location: const Value('Kệ A1-01'),
            condition: const Value('Mới'),
            status: Value(BookStatus.available.code),
          ),
          BookCopiesCompanion.insert(
            id: 'MB-003',
            bookId: 'DS001',
            location: const Value('Kệ A1-01'),
            condition: const Value('Cũ nhẹ'),
            status: Value(BookStatus.available.code),
          ),

          // Tuổi trẻ đáng giá bao nhiêu?
          BookCopiesCompanion.insert(
            id: 'TT-001',
            bookId: 'DS002',
            location: const Value('Kệ B2-05'),
            condition: const Value('Mới'),
            status: Value(BookStatus.available.code),
          ),
          BookCopiesCompanion.insert(
            id: 'TT-002',
            bookId: 'DS002',
            location: const Value('Kệ B2-05'),
            condition: const Value('Mới'),
            status: Value(BookStatus.available.code),
          ),
          BookCopiesCompanion.insert(
            id: 'TT-003',
            bookId: 'DS002',
            location: const Value('Kệ B2-05'),
            condition: const Value('Rách bìa'),
            status: Value(BookStatus.borrowed.code),
          ),

          // Clean Code
          BookCopiesCompanion.insert(
            id: 'CC-001',
            bookId: 'DS004',
            location: const Value('Kệ IT-Pro'),
            condition: const Value('Mới'),
            status: Value(BookStatus.available.code),
          ),
          BookCopiesCompanion.insert(
            id: 'CC-002',
            bookId: 'DS004',
            location: const Value('Kệ IT-Pro'),
            condition: const Value('Mới'),
            status: Value(BookStatus.borrowed.code),
          ),
        ]);
      });

      // 9) Members (DOC_GIA) - seed exactly as SQL inserts.
      await db.batch((b) {
        b.insertAll(db.members, [
          MembersCompanion.insert(
            id: 'DG001',
            lastName: const Value('Phạm'),
            middleName: const Value('Minh'),
            firstName: const Value('Tuấn'),
            dateOfBirth: Value(DateTime(2003, 5, 15)),
            phone: const Value('0909111222'),
            nationalId: '079203001234',
            email: 'tuandev@gmail.com',
            address: const Value('Q.Thủ Đức, TP.HCM'),
            subscriptionId: 'MOT_TAPSU',
            isActive: const Value(true),
            walletBalance: const Value(50000),
            points: const Value(100),
          ),
          MembersCompanion.insert(
            id: 'DG002',
            lastName: const Value('Nguyễn'),
            middleName: const Value('Thu'),
            firstName: const Value('Hà'),
            dateOfBirth: Value(DateTime(1998, 11, 20)),
            phone: const Value('0918333444'),
            nationalId: '079198005678',
            email: 'hnguyen@gmail.com',
            address: const Value('Q.1, TP.HCM'),
            subscriptionId: 'MOT_SANDIEU',
            isActive: const Value(true),
            walletBalance: const Value(300000),
            points: const Value(500),
          ),
          MembersCompanion.insert(
            id: 'DG003',
            lastName: const Value('Trần'),
            middleName: const Value('Văn'),
            firstName: const Value('Bình'),
            dateOfBirth: Value(DateTime(1995, 2, 10)),
            phone: const Value('0939555666'),
            nationalId: '079195009999',
            email: 'binhtran@outlook.com',
            address: const Value('Q.7, TP.HCM'),
            subscriptionId: 'MOT_CHUA',
            isActive: const Value(true),
            walletBalance: const Value(1500000),
            points: const Value(1200),
          ),
          MembersCompanion.insert(
            id: 'DG004',
            lastName: const Value('Lê'),
            middleName: const Value('Thị'),
            firstName: const Value('Mai'),
            dateOfBirth: Value(DateTime(2004, 1, 1)),
            phone: const Value('0988777888'),
            nationalId: '079204001111',
            email: 'maile@gmail.com',
            address: const Value('Q.Bình Thạnh, TP.HCM'),
            subscriptionId: 'MOT_TAPSU',
            isActive: const Value(false),
            walletBalance: const Value(0),
            points: const Value(0),
          ),
        ]);
      });
    });
  }
}
