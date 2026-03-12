import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_book_repository.dart';
import '../../data/user_order_repository.dart';
import '../../data/user_wallet_repository.dart';

/// ============================================================================
/// Buy Checkout Page - Pro Max
/// Full e-commerce checkout: product summary, delivery info, payment method
/// selection (COD / Wallet with live balance), bill summary, submit order.
/// ============================================================================
class BuyCheckoutPage extends ConsumerStatefulWidget {
  const BuyCheckoutPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BuyCheckoutPage> createState() => _BuyCheckoutPageState();
}

class _BuyCheckoutPageState extends ConsumerState<BuyCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _paymentMethod = 'cod'; // 'cod' | 'vi_booknest'
  int _quantity = 1;
  bool _isSubmitting = false;

  static const int _shippingFee = 15000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final member = ref.read(currentMemberProvider);
      if (member != null) {
        _nameCtrl.text = member.fullName;
        _phoneCtrl.text = member.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ======================== SUBMIT ORDER ========================

  /// Tính giá cuối cùng: ưu tiên salePrice, nếu không có thì dùng coverPrice
  int _getFinalPrice(UserBook book) {
    if (book.salePrice != null && book.salePrice! > 0) {
      return book.salePrice!;
    }
    return book.coverPrice ?? 0;
  }

  Future<void> _handleOrder(UserBook book) async {
    log('Bắt đầu xử lý Đặt hàng...');

    log('Kiểm tra Form validation...');
    if (!_formKey.currentState!.validate()) {
      log('Form lỗi: Thông tin chưa hợp lệ!');
      return;
    }
    log('Form hợp lệ. Chuẩn bị gọi Repository tạo đơn...');

    final member = ref.read(currentMemberProvider);
    if (member == null) {
      log('Lỗi: Chưa đăng nhập!');
      _showError('Vui lòng đăng nhập để mua sách');
      return;
    }

    final unitPrice = _getFinalPrice(book);
    if (unitPrice <= 0) {
      log('Lỗi: Sách không có giá bán hợp lệ!');
      _showError('Sách này hiện không có giá bán');
      return;
    }

        setState(() => _isSubmitting = true);

    try {
      // Xác định phương thức thanh toán
      final paymentMethodValue = _paymentMethod == 'cod' ? 'cod' : 'vi_booknest';
      log('Phương thức thanh toán đang gửi: $paymentMethodValue (UI value: $_paymentMethod)');
      
      final orderRepo = ref.read(userOrderRepositoryProvider);
      final orderId = await orderRepo.createPurchaseOrder(
        memberId: member.id,
        items: [
          {
            'bookId': book.id,
            'bookTitle': book.title,
            'quantity': _quantity,
            'unitPrice': unitPrice,
          },
        ],
        recipientName: _nameCtrl.text.trim(),
        recipientPhone: _phoneCtrl.text.trim(),
        recipientAddress: _addressCtrl.text.trim(),
        paymentMethod: paymentMethodValue,
        shippingFee: _shippingFee,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

            log('Tạo đơn thành công! Mã đơn: $orderId');

      if (!mounted) return;

      // Invalidate providers để UI cập nhật số dư và lịch sử
      log('Invalidating providers để cập nhật UI...');
      ref.invalidate(memberOrdersProvider);
      ref.invalidate(walletBalanceProvider);
      ref.invalidate(walletTransactionsProvider);
      log('Đã invalidate: memberOrdersProvider, walletBalanceProvider, walletTransactionsProvider');

      _showSuccessDialog(orderId);
    } catch (e) {
      log('LỖI khi tạo đơn: $e');
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog(int orderId) {
    final isWallet = _paymentMethod == 'vi_booknest';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withAlpha(24),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppTheme.successColor, size: 40),
        ),
        title: const Text('Đặt hàng thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Đơn hàng #$orderId đã được tạo.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isWallet
                    ? AppTheme.successColor.withAlpha(16)
                    : AppTheme.warningColor.withAlpha(16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isWallet
                        ? Icons.account_balance_wallet
                        : Icons.local_shipping_outlined,
                    size: 16,
                    color: isWallet
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isWallet
                          ? 'Thanh toán ví đã được ghi nhận'
                          : 'Thanh toán khi nhận hàng (COD)',
                      style: TextStyle(
                        fontSize: 13,
                        color: isWallet
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/user/profile/purchases');
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xem đơn hàng'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/user/home');
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  // ======================== BUILD ========================

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(userBookDetailProvider(widget.bookId));
    final member = ref.watch(currentMemberProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppTheme.errorColor),
                const SizedBox(height: 12),
                Text('Lỗi: $e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (book) {
          if (book == null) {
            return const Center(
              child: Text('Không tìm thấy sách',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          // Sử dụng _getFinalPrice để tính giá cuối cùng
          final unitPrice = _getFinalPrice(book);
          final subtotal = unitPrice * _quantity;
          final total = subtotal + _shippingFee;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProductCard(book, unitPrice),
                        const SizedBox(height: 14),
                        _buildDeliverySection(),
                        const SizedBox(height: 14),
                        _buildPaymentSection(member, total),
                        const SizedBox(height: 14),
                        _buildNoteSection(),
                        const SizedBox(height: 14),
                        _buildBillSummary(subtotal, total),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(book, total),
            ],
          );
        },
      ),
    );
  }

  // ======================== PRODUCT CARD ========================

  Widget _buildProductCard(UserBook book, int unitPrice) {
    return _CheckoutCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.slate200.withAlpha(80),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                  ? Image.network(
                      book.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _bookPlaceholder(),
                    )
                  : _bookPlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  book.authorString,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      _formatVND(unitPrice),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (book.coverPrice != null &&
                        book.coverPrice! > unitPrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatVND(book.coverPrice!),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    _QuantitySelector(
                      value: _quantity,
                      maxValue: book.saleCopies > 0 ? book.saleCopies : 99,
                      onChanged: (v) => setState(() => _quantity = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookPlaceholder() {
    return Container(
      color: const Color(0xFFE8E0F0),
      child: const Center(
        child: Icon(Icons.menu_book_rounded,
            color: Color(0xFF9B8EC4), size: 28),
      ),
    );
  }

  // ======================== DELIVERY SECTION ========================

  Widget _buildDeliverySection() {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.local_shipping_outlined,
            title: 'Thông tin giao hàng',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Họ tên người nhận *',
              prefixIcon: Icon(Icons.person_outline, size: 20),
              isDense: true,
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại *',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
              isDense: true,
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập SĐT';
              if (v.trim().length < 9) return 'SĐT không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ giao hàng *',
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              hintText: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/TP',
              isDense: true,
            ),
            maxLines: 2,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Vui lòng nhập địa chỉ'
                : null,
          ),
        ],
      ),
    );
  }

  // ======================== PAYMENT SECTION ========================

  Widget _buildPaymentSection(UserMember? member, int total) {
    final walletAsync = member != null
        ? ref.watch(walletBalanceProvider(member.id))
        : null;

    final walletBalance = walletAsync?.valueOrNull ?? 0;
    final hasEnoughBalance = walletBalance >= total;

    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.payment_outlined,
            title: 'Phương thức thanh toán',
          ),
          const SizedBox(height: 14),

          // COD option
          _PaymentRadioCard(
            icon: Icons.money_outlined,
            title: 'Thanh toán khi nhận hàng',
            subtitle: 'Trả tiền mặt cho shipper (COD)',
            value: 'cod',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          const SizedBox(height: 10),

          // Wallet option
          _PaymentRadioCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Ví BookNest',
            subtitle: walletAsync?.isLoading == true
                ? 'Đang tải số dư...'
                : 'Số dư: ${_formatVND(walletBalance)}',
            value: 'vi_booknest',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
            trailing: _paymentMethod == 'vi_booknest' && !hasEnoughBalance
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Không đủ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),

          // Wallet insufficient warning
          if (_paymentMethod == 'vi_booknest' && !hasEnoughBalance) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withAlpha(16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.warningColor.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppTheme.warningColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Số dư ví không đủ. Cần thêm ${_formatVND(total - walletBalance)}. '
                      'Vui lòng nạp thêm hoặc chọn COD.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.warningColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ======================== NOTE SECTION ========================

  Widget _buildNoteSection() {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.note_alt_outlined,
            title: 'Ghi chú',
            iconColor: AppTheme.textSecondary,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              hintText: 'Ghi chú cho đơn hàng (tùy chọn)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ======================== BILL SUMMARY ========================

  Widget _buildBillSummary(int subtotal, int total) {
    return _CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.receipt_long_outlined,
            title: 'Chi tiết thanh toán',
          ),
          const SizedBox(height: 14),
          _BillRow(
            label: 'Tiền hàng ($_quantity sản phẩm)',
            value: _formatVND(subtotal),
          ),
          const SizedBox(height: 6),
          _BillRow(
            label: 'Phí vận chuyển',
            value: _formatVND(_shippingFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _BillRow(
            label: 'Tổng thanh toán',
            value: _formatVND(total),
            isBold: true,
            valueColor: AppTheme.primaryColor,
            valueFontSize: 18,
          ),
        ],
      ),
    );
  }

  // ======================== BOTTOM BAR ========================

  Widget _buildBottomBar(UserBook book, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatVND(total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : () => _handleOrder(book),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_bag_outlined, size: 20),
                label: Text(
                  _isSubmitting ? 'Đang xử lý...' : 'Đặt hàng',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== UTILITIES ========================

  String _formatVND(int price) {
    if (price <= 0) return '0đ';
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    buffer.write('đ');
    return buffer.toString();
  }
}

// ============================================================================
// SUB-COMPONENTS
// ============================================================================

/// Section header with icon and title
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primaryColor;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

/// Card container with soft shadow
class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Quantity selector with +/- buttons
class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.value,
    required this.onChanged,
    this.maxValue = 99,
  });

  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$value',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          _QtyBtn(
            icon: Icons.add,
            onTap: value < maxValue ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(icon,
            size: 16,
            color: onTap != null
                ? AppTheme.textPrimaryLight
                : AppTheme.slate200),
      ),
    );
  }
}

/// Payment method radio card
class _PaymentRadioCard extends StatelessWidget {
  const _PaymentRadioCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.slate200,
            width: isSelected ? 1.8 : 1,
          ),
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(8)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withAlpha(20)
                    : AppTheme.slate200.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            const SizedBox(width: 4),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary.withAlpha(100),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bill summary row
class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.valueFontSize,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            color: isBold ? AppTheme.textPrimaryLight : AppTheme.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize ?? (isBold ? 16 : 14),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppTheme.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
