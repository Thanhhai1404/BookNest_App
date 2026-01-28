import '../../../../data/db/app_database.dart';

/// DTO used for displaying a book with human-readable names.
///
/// Contains the core `Book` row and resolved names from related tables.
class BookWithDetails {
  const BookWithDetails({
    required this.book,
    required this.authorName,
    required this.categoryName,
    required this.publisherName,
  });

  final Book book;
  final String authorName;
  final String categoryName;
  final String publisherName;
}
