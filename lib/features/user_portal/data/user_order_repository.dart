import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// User Portal Order Repository
// Handles purchase orders (buy books) and borrow orders
// ============================================================================

/// Đơn hàng mua sách
class UserOrder {
  final int id;
  final String memberId;
  final DateTime orderDate;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientAddress;
  final String paymentMethod;
  final int totalAmount;
  final int shippingFee;
  final int discount;
  final int finalAmount;
  final String status;
  final String? note;
  final List<OrderItem> items;

  const UserOrder({
    required this.id,
    required this.memberId,
    required this.orderDate,
    this.recipientName,
    this.recipientPhone,
    this.recipientAddress,
    this.paymentMethod = 'vi_booknest',
    this.totalAmount = 0,
    this.shippingFee = 0,
    this.discount = 0,
    this.finalAmount = 0,
    this.status = 'cho_xac_nhan',
    this.note,
    this.items = const [],
  });

  String get statusLabel {
    switch (status) {
      case 'cho_xac_nhan':
        return 'Chờ xác nhận';
      case 'da_xac_nhan':
        return 'Đã xác nhận';
      case 'dang_giao':
        return 'Đang giao';
      case 'da_giao':
        return 'Đã giao';
      case 'da_huy':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    List<OrderItem> items = [];
    if (json['chi_tiet_don_hang'] is List) {
      items = (json['chi_tiet_don_hang'] as List)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return UserOrder(
      id: parseNum(json['ma_don_hang']),
      memberId: json['madg'] as String? ?? '',
      orderDate: DateTime.tryParse(json['ngay_dat']?.toString() ?? '') ?? DateTime.now(),
      recipientName: json['ho_ten_nhan'] as String?,
      recipientPhone: json['sdt_nhan'] as String?,
      recipientAddress: json['dia_chi_nhan'] as String?,
      paymentMethod: json['phuong_thuc_thanh_toan'] as String? ?? 'vi_booknest',
      totalAmount: parseNum(json['tong_tien']),
      shippingFee: parseNum(json['phi_van_chuyen']),
      discount: parseNum(json['giam_gia']),
      finalAmount: parseNum(json['thanh_toan']),
      status: json['trang_thai'] as String? ?? 'cho_xac_nhan',
      note: json['ghi_chu'] as String?,
      items: items,
    );
  }
}

/// Chi tiết đơn hàng (1 dòng sách)
class OrderItem {
  final int id;
  final String bookId;
  final String? bookTitle;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  const OrderItem({
    required this.id,
    required this.bookId,
    this.bookTitle,
    this.quantity = 1,
    this.unitPrice = 0,
    this.subtotal = 0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    int parseNum(dynamic v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    String? bookTitle;
    if (json['dau_sach'] is Map) {
      bookTitle = json['dau_sach']['tensach'] as String?;
    }

    return OrderItem(
      id: parseNum(json['id']),
      bookId: json['mads'] as String? ?? '',
      bookTitle: bookTitle,
      quantity: parseNum(json['so_luong']),
      unitPrice: parseNum(json['don_gia']),
      subtotal: parseNum(json['thanh_tien']),
    );
  }
}

/// Repository
class UserOrderRepository {
  final SupabaseClient _client;

  UserOrderRepository(this._client);

  /// Tạo đơn hàng mua sách
  Future<int> createOrder({
    required String memberId,
    required List<Map<String, dynamic>> items, // [{bookId, quantity, unitPrice}]
    required String recipientName,
    required String recipientPhone,
    required String recipientAddress,
    String paymentMethod = 'vi_booknest',
    int shippingFee = 0,
    int discount = 0,
    String? note,
  }) async {
    int totalAmount = 0;
    for (final item in items) {
      totalAmount += ((item['quantity'] as int) * (item['unitPrice'] as int));
    }
    final finalAmount = totalAmount + shippingFee - discount;

    // Insert đơn hàng
    final orderData = await _client.from('don_hang').insert({
      'madg': memberId,
      'ho_ten_nhan': recipientName,
      'sdt_nhan': recipientPhone,
      'dia_chi_nhan': recipientAddress,
      'phuong_thuc_thanh_toan': paymentMethod,
      'tong_tien': totalAmount,
      'phi_van_chuyen': shippingFee,
      'giam_gia': discount,
      'thanh_toan': finalAmount,
      'ghi_chu': note,
      'trang_thai': 'cho_xac_nhan',
    }).select('ma_don_hang').single();

    final orderId = orderData['ma_don_hang'] as int;

    // Insert chi tiết đơn hàng
    final details = items.map((item) => {
      'ma_don_hang': orderId,
      'mads': item['bookId'],
      'so_luong': item['quantity'],
      'don_gia': item['unitPrice'],
      'thanh_tien': (item['quantity'] as int) * (item['unitPrice'] as int),
    }).toList();

    await _client.from('chi_tiet_don_hang').insert(details);

    // Trừ tồn kho bán nếu cần
    for (final item in items) {
      await _client.rpc('decrement_sale_stock', params: {
        'book_id': item['bookId'],
        'qty': item['quantity'],
      }).catchError((_) => null); // Ignore if function doesn't exist
    }

    return orderId;
  }

  /// Lấy đơn hàng theo member
  Future<List<UserOrder>> getOrdersByMember(String memberId) async {
    final data = await _client
        .from('don_hang')
        .select('''
          *,
          chi_tiet_don_hang(*, dau_sach(tensach))
        ''')
        .eq('madg', memberId)
        .order('ngay_dat', ascending: false);

    return data.map((e) => UserOrder.fromJson(e)).toList();
  }

  /// Lấy chi tiết 1 đơn hàng
  Future<UserOrder?> getOrderById(int orderId) async {
    final data = await _client
        .from('don_hang')
        .select('''
          *,
          chi_tiet_don_hang(*, dau_sach(tensach))
        ''')
        .eq('ma_don_hang', orderId)
        .maybeSingle();

    if (data == null) return null;
    return UserOrder.fromJson(data);
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(int orderId) async {
    await _client
        .from('don_hang')
        .update({'trang_thai': 'da_huy'})
        .eq('ma_don_hang', orderId);
  }
}

// ======================== Providers ========================

final userOrderRepositoryProvider = Provider<UserOrderRepository>((ref) {
  return UserOrderRepository(Supabase.instance.client);
});

final memberOrdersProvider = FutureProvider.family<List<UserOrder>, String>(
  (ref, memberId) {
    return ref.read(userOrderRepositoryProvider).getOrdersByMember(memberId);
  },
);
