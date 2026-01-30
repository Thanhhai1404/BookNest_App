import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/loan/data/repositories/loan_repository.dart';

/// Provider for PdfService
final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

/// Service for generating PDF receipts and printing.
/// 
/// Supports:
/// - Loan receipt (phiếu mượn)
/// - Return receipt (phiếu trả)
/// - Fine receipt (biên lai phạt)
class PdfService {
  /// Date format for receipts
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _dateOnlyFormat = DateFormat('dd/MM/yyyy');
  
  /// Currency formatter for VND
  final _currencyFormat = NumberFormat('#,###', 'vi_VN');
  /// Cached font for Vietnamese support
  pw.Font? _cachedFont;
  pw.Font? _cachedBoldFont;

  /// Load Vietnamese-compatible font.
  /// Uses Google Fonts NotoSans which has full Vietnamese support.
  Future<pw.Font> _loadVietnameseFont() async {
    if (_cachedFont != null) return _cachedFont!;
    
    // Use NotoSans from Google Fonts - has full Vietnamese support
    _cachedFont = await PdfGoogleFonts.notoSansRegular();
    return _cachedFont!;
  }

  /// Load Vietnamese-compatible bold font.
  Future<pw.Font> _loadVietnameseBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    
    _cachedBoldFont = await PdfGoogleFonts.notoSansBold();
    return _cachedBoldFont!;
  }

  /// Create theme with Vietnamese font support.
  Future<pw.ThemeData> _createVietnameseTheme() async {
    final baseFont = await _loadVietnameseFont();
    final boldFont = await _loadVietnameseBoldFont();
    return pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      italic: baseFont,
      boldItalic: boldFont,
    );
  }

  // ============================================================
  // LOAN RECEIPT
  // ============================================================
  /// Generate a loan receipt PDF for a borrowed book.
  /// 
  /// Layout designed for thermal printer (80mm width) or A5 paper.
  Future<Uint8List> generateLoanReceipt(LoanWithDetails loan) async {
    final pdf = pw.Document();
    final theme = await _createVietnameseTheme();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Receipt title
              pw.Center(
                child: pw.Text(
                  'PHIẾU MƯỢN SÁCH',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Mã phiếu: #${loan.loan.id}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 16),
              
              // Member info section
              _buildSectionTitle('THÔNG TIN HỘI VIÊN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Mã hội viên:', loan.memberId),
              _buildInfoRow('Họ tên:', loan.memberName),
              if (loan.memberPhone != null)
                _buildInfoRow('Số điện thoại:', loan.memberPhone!),
              pw.SizedBox(height: 16),
              
              // Book info section
              _buildSectionTitle('THÔNG TIN SÁCH'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Mã sách:', loan.bookId),
              _buildInfoRow('Mã bản sao:', loan.copyId),
              _buildInfoRow('Tên sách:', loan.bookTitle),
              pw.SizedBox(height: 16),
              
              // Loan dates section
              _buildSectionTitle('THỜI GIAN MƯỢN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Ngày mượn:', _dateFormat.format(loan.loan.borrowDate)),
              _buildInfoRow('Hạn trả:', _dateOnlyFormat.format(loan.loan.dueDate)),
              if (loan.loan.renewalCount > 0)
                _buildInfoRow('Số lần gia hạn:', '${loan.loan.renewalCount}/2'),
              pw.SizedBox(height: 24),
              
              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Terms & notes
              pw.Text(
                'Lưu ý:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '• Vui lòng trả sách đúng hạn.\n'
                '• Phí phạt trễ hạn: ${_currencyFormat.format(kFineRatePerDay)}đ/ngày.\n'
                '• Bảo quản sách cẩn thận, tránh hư hỏng.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 24),
              
              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // RETURN RECEIPT
  // ============================================================
  /// Generate a return receipt PDF when book is returned.
  Future<Uint8List> generateReturnReceipt({
    required LoanWithDetails loan,
    required DateTime returnDate,
    int? overdueDays,
    int? fineAmount,
  }) async {
    final pdf = pw.Document();
    final theme = await _createVietnameseTheme();
    final isOverdue = (overdueDays ?? 0) > 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Receipt title
              pw.Center(
                child: pw.Text(
                  'PHIẾU TRẢ SÁCH',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Mã phiếu mượn: #${loan.loan.id}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 16),
              
              // Member info section
              _buildSectionTitle('THÔNG TIN HỘI VIÊN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Mã hội viên:', loan.memberId),
              _buildInfoRow('Họ tên:', loan.memberName),
              pw.SizedBox(height: 16),
              
              // Book info section
              _buildSectionTitle('THÔNG TIN SÁCH'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Mã sách:', loan.bookId),
              _buildInfoRow('Tên sách:', loan.bookTitle),
              _buildInfoRow('Mã bản sao:', loan.copyId),
              pw.SizedBox(height: 16),
              
              // Loan dates section
              _buildSectionTitle('THỜI GIAN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Ngày mượn:', _dateOnlyFormat.format(loan.loan.borrowDate)),
              _buildInfoRow('Hạn trả:', _dateOnlyFormat.format(loan.loan.dueDate)),
              _buildInfoRow('Ngày trả:', _dateFormat.format(returnDate)),
              pw.SizedBox(height: 16),
              
              // Fine section (if overdue)
              if (isOverdue) ...[
                _buildSectionTitle('PHẠT TRỄ HẠN', isWarning: true),
                pw.SizedBox(height: 8),
                _buildInfoRow('Số ngày trễ:', '$overdueDays ngày'),
                _buildInfoRow('Mức phạt:', '${_currencyFormat.format(kFineRatePerDay)}đ/ngày'),
                _buildInfoRow('Tổng phạt:', '${_currencyFormat.format(fineAmount ?? 0)}đ', isBold: true),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'Vui lòng thanh toán khoản phạt tại quầy.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
              
              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Status
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    isOverdue ? 'TRẢ TRỄ - CÓ PHẠT' : 'TRẢ ĐÚNG HẠN',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // FINE RECEIPT
  // ============================================================
  /// Generate a fine payment receipt.
  Future<Uint8List> generateFineReceipt({
    required int fineId,
    required String memberId,
    required String memberName,
    required int amount,
    required String reason,
    required int overdueDays,
    required DateTime paidAt,
    int? balanceAfter,
  }) async {
    final pdf = pw.Document();
    final theme = await _createVietnameseTheme();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Receipt title
              pw.Center(
                child: pw.Text(
                  'BIÊN LAI THANH TOÁN PHẠT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Mã phạt: #$fineId',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 16),
              
              // Member info
              _buildSectionTitle('THÔNG TIN HỘI VIÊN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Mã hội viên:', memberId),
              _buildInfoRow('Họ tên:', memberName),
              pw.SizedBox(height: 16),
              
              // Fine details
              _buildSectionTitle('CHI TIẾT PHẠT'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Lý do:', _translateReason(reason)),
              if (overdueDays > 0)
                _buildInfoRow('Số ngày trễ:', '$overdueDays ngày'),
              _buildInfoRow('Số tiền phạt:', '${_currencyFormat.format(amount)}đ', isBold: true),
              pw.SizedBox(height: 16),
              
              // Payment info
              _buildSectionTitle('THANH TOÁN'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Phương thức:', 'Trừ từ ví hội viên'),
              _buildInfoRow('Thời gian:', _dateFormat.format(paidAt)),
              if (balanceAfter != null)
                _buildInfoRow('Số dư còn lại:', '${_currencyFormat.format(balanceAfter)}đ'),
              pw.SizedBox(height: 24),
              
              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),
              
              // Status
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'ĐÃ THANH TOÁN',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // PRINTING
  // ============================================================

  /// Print PDF data using system print dialog.
  /// 
  /// Shows print dialog on both Android and Windows.
  Future<bool> printReceipt(Uint8List pdfData, {String? documentName}) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: documentName ?? 'BookNest Receipt',
        format: PdfPageFormat.a5,
      );
      return true;
    } catch (e) {
      debugPrint('Print error: $e');
      return false;
    }
  }

  /// Preview PDF before printing.
  /// 
  /// Opens a preview dialog with print option.
  Future<void> previewReceipt(BuildContext context, Uint8List pdfData, {String? title}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title ?? 'Xem trước phiếu'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'In phiếu',
                onPressed: () => printReceipt(pdfData, documentName: title),
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) async => pdfData,
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            pdfFileName: '${title ?? 'receipt'}.pdf',
          ),
        ),
      ),
    );
  }

  /// Share PDF as a file.
  Future<void> shareReceipt(Uint8List pdfData, {String? filename}) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: filename ?? 'booknest_receipt.pdf',
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  /// Build the standard header with logo.
  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        // Logo (text-based for simplicity)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'BN',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BOOKNEST',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.Text(
                  'Thu vien thong minh',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Build a section title.
  pw.Widget _buildSectionTitle(String title, {bool isWarning = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: isWarning ? PdfColors.red100 : PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: isWarning ? PdfColors.red900 : PdfColors.grey900,
        ),
      ),
    );
  }

  /// Build an info row with label and value.
  pw.Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the standard footer.
  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'Cảm ơn quý khách đã sử dụng dịch vụ!',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Ngày in: ${_dateFormat.format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  /// Translate fine reason to Vietnamese.
  String _translateReason(String reason) {
    switch (reason.toLowerCase()) {
      case 'overdue':
        return 'Trả sách trễ hạn';
      case 'damaged':
        return 'Sách bị hư hỏng';
      case 'lost':
        return 'Mất sách';
      default:
        return reason;
    }
  }
}
