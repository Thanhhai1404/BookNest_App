import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Provider for BackupRepository
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository();
});

/// Result of backup/restore operation
class BackupResult {
  const BackupResult({
    required this.success,
    this.message,
    this.filePath,
  });

  final bool success;
  final String? message;
  final String? filePath;
}

/// Repository for database backup and restore operations.
class BackupRepository {
  /// Database file name (must match app_database.dart)
  static const String _dbFileName = 'booknest_v2.sqlite';

  /// Get the path to the database file.
  Future<File> _getDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _dbFileName));
  }

  /// Get the cache directory for temporary backup files.
  Future<Directory> _getCacheDir() async {
    return await getTemporaryDirectory();
  }

  /// Backup the database file.
  ///
  /// Copies the database to cache directory with timestamp,
  /// then shares it via system share sheet.
  ///
  /// Returns [BackupResult] with success status and file path.
  Future<BackupResult> backupDatabase() async {
    try {
      // Get source database file
      final dbFile = await _getDatabaseFile();

      if (!await dbFile.exists()) {
        return const BackupResult(
          success: false,
          message: 'Không tìm thấy file cơ sở dữ liệu.',
        );
      }

      // Create backup filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'booknest_backup_$timestamp.sqlite';

      // Copy to cache directory
      final cacheDir = await _getCacheDir();
      final backupFile = File(p.join(cacheDir.path, backupFileName));

      await dbFile.copy(backupFile.path);

      // Share the backup file
      final xFile = XFile(backupFile.path);
      await Share.shareXFiles(
        [xFile],
        subject: 'BookNest Backup - $timestamp',
        text: 'File sao lưu dữ liệu BookNest\nNgày: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      );

      return BackupResult(
        success: true,
        message: 'Đã tạo file sao lưu thành công!',
        filePath: backupFile.path,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Lỗi khi sao lưu: $e',
      );
    }
  }

  /// Restore the database from a backup file.
  ///
  /// Opens file picker to select a .sqlite file,
  /// then overwrites the current database.
  ///
  /// WARNING: This will overwrite all current data!
  ///
  /// Returns [BackupResult] with success status.
  Future<BackupResult> restoreDatabase() async {
    try {
      // Open file picker to select backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        dialogTitle: 'Chọn file sao lưu (.sqlite)',
      );

      if (result == null || result.files.isEmpty) {
        return const BackupResult(
          success: false,
          message: 'Không có file nào được chọn.',
        );
      }

      final pickedFile = result.files.first;

      // Validate file extension
      if (pickedFile.path == null) {
        return const BackupResult(
          success: false,
          message: 'Không thể đọc đường dẫn file.',
        );
      }

      final extension = p.extension(pickedFile.path!).toLowerCase();
      if (extension != '.sqlite' && extension != '.db') {
        return const BackupResult(
          success: false,
          message: 'File không hợp lệ. Vui lòng chọn file .sqlite',
        );
      }

      // Get source and destination files
      final sourceFile = File(pickedFile.path!);
      final dbFile = await _getDatabaseFile();

      if (!await sourceFile.exists()) {
        return const BackupResult(
          success: false,
          message: 'File nguồn không tồn tại.',
        );
      }

      // Validate file size (must be > 0 and < 100MB)
      final fileSize = await sourceFile.length();
      if (fileSize == 0) {
        return const BackupResult(
          success: false,
          message: 'File sao lưu rỗng.',
        );
      }
      if (fileSize > 100 * 1024 * 1024) {
        return const BackupResult(
          success: false,
          message: 'File quá lớn (>100MB). Không phải file sao lưu hợp lệ.',
        );
      }

      // Create backup of current database before overwriting
      if (await dbFile.exists()) {
        final backupDir = await _getCacheDir();
        final safetyBackup = File(
          p.join(backupDir.path, 'booknest_pre_restore_backup.sqlite'),
        );
        await dbFile.copy(safetyBackup.path);
      }

      // Overwrite database file
      await sourceFile.copy(dbFile.path);

      return BackupResult(
        success: true,
        message: 'Khôi phục dữ liệu thành công!\nVui lòng khởi động lại ứng dụng.',
        filePath: dbFile.path,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Lỗi khi khôi phục: $e',
      );
    }
  }

  /// Get database file info (size, last modified).
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbFile = await _getDatabaseFile();

      if (!await dbFile.exists()) {
        return {
          'exists': false,
          'size': 0,
          'lastModified': null,
        };
      }

      final stat = await dbFile.stat();
      return {
        'exists': true,
        'size': stat.size,
        'lastModified': stat.modified,
        'path': dbFile.path,
      };
    } catch (e) {
      return {
        'exists': false,
        'error': e.toString(),
      };
    }
  }

  /// Format file size for display.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
