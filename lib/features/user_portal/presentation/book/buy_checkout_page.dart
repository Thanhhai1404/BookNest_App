import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_book_repository.dart';
import '../../data/user_order_repository.dart';

/// Checkout Mua sách - Form giao hàng & thanh toán
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
  String _paymentMethod = 'cod';
  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from logged-in member
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
    super.dispose();
  }

  Future<void> _handleOrder(UserBook book) async {
    if (!_formKey.currentState!.validate()) return;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;

    setState(() => _isSubmitting = true);

    try {
      final orderRepo = ref.read(userOrderRepositoryProvider);
      final orderId = await orderRepo.createOrder(
        memberId: member.id,
        items: [
          {
            'bookId': book.id,
            'quantity': _quantity,
            'unitPrice': book.salePrice ?? 0,
          },
        ],
        recipientName: _nameCtrl.text.trim(),
        recipientPhone: _phoneCtrl.text.trim(),
        recipientAddress: _addressCtrl.text.trim(),
        paymentMethod: _paymentMethod == 'wallet' ? 'vi_booknest' : _paymentMethod,
        shippingFee: 30000,
        note: null,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle,
                color: AppTheme.successColor, size: 36),
          ),
          title: const Text('Đặt hàng thành công!'),
          content: Text(
            'Đơn hàng #$orderId đã được tạo.\n\n'
            '${_paymentMethod == 'cod' ? 'Bạn sẽ thanh toán khi nhận hàng.' : 'Thanh toán đã được ghi nhận.'}',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/user/home');
              },
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đặt hàng: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(userBookDetailProvider(widget.bookId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mua sách'),
        centerTitle: true,
      ),
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Không tìm thấy sách'));
          }
          final unitPrice = book.salePrice ?? 0;
          final totalPrice = unitPrice * _quantity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==================== THÔNG TIN SÁCH ====================
                  _SectionCard(
                    title: 'Sản phẩm',
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                                ? Image.network(book.imageUrl!, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.menu_book, color: Colors.white70, size: 24))
                                : const Icon(Icons.menu_book, color: Colors.white70, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authorString,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${_formatPrice(unitPrice)}đ',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  _QuantitySelector(
                                    value: _quantity,
                                    onChanged: (v) => setState(() => _quantity = v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== THÔNG TIN GIAO HÀNG ====================
                  _SectionCard(
                    title: 'Thông tin giao hàng',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên người nhận',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Bắt buộc'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Bắt buộc'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ giao hàng',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: 'Số nhà, đường, phường, quận, TP...',
                          ),
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Bắt buộc'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== PHƯƠNG THỨC THANH TOÁN ====================
                  _SectionCard(
                    title: 'Phương thức thanh toán',
                    child: Column(
                      children: [
                        _PaymentOption(
                          icon: Icons.local_shipping_outlined,
                          title: 'Thanh toán khi nhận hàng (COD)',
                          subtitle: 'Trả tiền mặt cho shipper',
                          value: 'cod',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Ví BookNest',
                          subtitle: 'Thanh toán từ ví điện tử',
                          value: 'wallet',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          icon: Icons.credit_card,
                          title: 'Thanh toán Online',
                          subtitle: 'Chuyển khoản / Thẻ',
                          value: 'online',
                          groupValue: _paymentMethod,
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== TỔNG TIỀN ====================
                  _SectionCard(
                    title: 'Tổng cộng',
                    child: Column(
                      children: [
                        _PriceRow(label: 'Tiền sách', value: '${_formatPrice(totalPrice)}đ'),
                        _PriceRow(label: 'Phí giao hàng', value: '30.000đ'),
                        const Divider(height: 16),
                        _PriceRow(
                          label: 'Tổng thanh toán',
                          value: '${_formatPrice(totalPrice + 30000)}đ',
                          isBold: true,
                          isRed: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==================== NÚT ĐẶT HÀNG ====================
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting ? null : () => _handleOrder(book),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        'Đặt hàng • ${_formatPrice(totalPrice + 30000)}đ',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ==================== SUB-COMPONENTS ====================

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slate200.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.value, required this.onChanged});

  final int value;
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
          _QtyButton(
            icon: Icons.remove,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 16,
            color: onTap != null
                ? AppTheme.textPrimaryLight
                : AppTheme.textSecondary.withAlpha(100)),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.slate200,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? AppTheme.primaryColor.withAlpha(8)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isRed = false,
  });

  final String label;
  final String value;
  final bool isBold;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isBold ? null : AppTheme.textSecondary,
                    fontWeight: isBold ? FontWeight.bold : null,
                  )),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    color: isRed ? AppTheme.primaryColor : null,
                    fontSize: isBold ? 16 : null,
                  )),
        ],
      ),
    );
  }
}
