import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../core/user_auth_provider.dart';
import '../../data/user_book_repository.dart';
import '../../data/user_borrow_repository.dart';

/// Checkout Mượn sách - Chọn ngày/giờ lấy sách, sinh QR
class BorrowCheckoutPage extends ConsumerStatefulWidget {
  const BorrowCheckoutPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BorrowCheckoutPage> createState() => _BorrowCheckoutPageState();
}

class _BorrowCheckoutPageState extends ConsumerState<BorrowCheckoutPage> {
  DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
    );
    if (picked != null) setState(() => _pickupTime = picked);
  }

  Future<void> _handleSubmit() async {
    final member = ref.read(currentMemberProvider);
    if (member == null) {
      _showErrorSnackBar('Vui lòng đăng nhập để mượn sách');
      return;
    }

    // Kiểm tra subscription
    if (!member.hasActiveSubscription) {
      _showNoSubscriptionDialog();
      return;
    }

    // Bắt đầu loading
    setState(() => _isLoading = true);

    try {
      // Gọi repository để tạo phiếu mượn
      final borrowRepository = ref.read(userBorrowRepositoryProvider);
      final pickupTimeStr = '${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}';
      
      final borrowId = await borrowRepository.createBorrowRequest(
        memberId: member.id,
        bookId: widget.bookId,
        pickupDate: _pickupDate,
        pickupTime: pickupTimeStr,
      );

      // Tạo mã QR cho đơn mượn
      final qrData = 'booknest://borrow/$borrowId|${widget.bookId}|${member.id}'
          '|${_pickupDate.toIso8601String()}'
          '|$pickupTimeStr';      // Invalidate cache để refresh lịch sử mượn
      ref.invalidate(borrowHistoryProvider(member.id));
      ref.invalidate(activeBorrowsProvider(member.id));
      ref.invalidate(returnedBorrowsProvider(member.id));

      // Hiển thị dialog thành công
      if (mounted) {
        _showSuccessDialog(borrowId, qrData);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Lỗi tạo phiếu mượn: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
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

  void _showSuccessDialog(String borrowId, String qrData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tạo phiếu mượn thành công!',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Mã phiếu: $borrowId',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đưa mã QR này cho Thủ thư khi đến lấy sách',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                ),                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 180,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.textPrimaryLight,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_pickupDate.day}/${_pickupDate.month}/${_pickupDate.year} '
                            'lúc ${_pickupTime.hour}:${_pickupTime.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),              // Button
              FractionallySizedBox(
                widthFactor: 1.0,
                child: FilledButton(                  onPressed: () {
                    Navigator.pop(ctx);
                    // Chuyển về trang lịch sử mượn (push để giữ back button)
                    context.push('/user/profile/borrows');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem lịch sử mượn',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.card_membership,
            color: AppTheme.warningColor,
            size: 32,
          ),
        ),
        title: const Text('Cần gói Hội viên'),
        content: const Text(
          'Bạn cần có Gói Hội Viên (Subscription) đang active để mượn sách.\n\n'
          'Hãy đăng ký gói hội viên trong phần Cá nhân > Gói Hội Viên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/user/profile');
            },
            child: const Text('Đăng ký ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(currentMemberProvider);
    final bookAsync = ref.watch(userBookDetailProvider(widget.bookId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mượn sách'),
        centerTitle: true,
      ),
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Lỗi: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(userBookDetailProvider(widget.bookId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (book) {
          if (book == null) {
            return const Center(child: Text('Không tìm thấy sách'));
          }
          return _buildFormView(context, member, book);
        },
      ),
    );
  }

  Widget _buildFormView(BuildContext context, UserMember? member, UserBook book) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==================== THÔNG TIN SÁCH ====================
          _Card(
            child: Row(
              children: [
                // Book cover
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
                        ? Image.network(
                            book.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.menu_book,
                              color: Colors.white70,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.menu_book,
                            color: Colors.white70,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authorString,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Mượn miễn phí (Gói HV)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== THÔNG TIN NGƯỜI MƯỢN ====================
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin người mượn',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  icon: Icons.person_outline,
                  label: 'Họ tên',
                  value: member?.fullName ?? 'Chưa đăng nhập',
                ),
                _InfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Mã hội viên',
                  value: member?.id ?? '---',
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'SĐT',
                  value: member?.phone ?? 'Chưa cập nhật',
                ),
                _InfoTile(
                  icon: Icons.card_membership,
                  label: 'Gói HV',
                  value: member?.hasActiveSubscription == true
                      ? '✅ Active'
                      : '❌ Chưa đăng ký',
                  valueColor: member?.hasActiveSubscription == true
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== CHỌN NGÀY GIỜ ĐẾN LẤY ====================
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn ngày & giờ đến lấy sách',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Ngày',
                        value: '${_pickupDate.day}/${_pickupDate.month}/${_pickupDate.year}',
                        onTap: _isLoading ? null : _selectDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PickerTile(
                        icon: Icons.access_time,
                        label: 'Giờ',
                        value: _pickupTime.format(context),
                        onTap: _isLoading ? null : _selectTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningColor.withAlpha(50)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Nếu không đến lấy sách trong 24h, đơn sẽ tự động bị hủy '
                          'và bạn sẽ bị trừ 20 Điểm tín nhiệm.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.warningColor,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==================== NÚT XÁC NHẬN ====================
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: AppTheme.primaryColor.withAlpha(150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'Xác nhận mượn sách',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _Card extends StatelessWidget {
  const _Card({required this.child});
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
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.slate200),
          borderRadius: BorderRadius.circular(10),
          color: onTap == null ? AppTheme.slate200.withAlpha(50) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
