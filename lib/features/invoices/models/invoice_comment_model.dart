/// A single comment or history/activity entry for an invoice.
///
/// [fromJson] tolerates several common key names so the model works even if
/// the API response shape changes slightly.
class InvoiceComment {
  final String id;
  final String text;
  final String author;
  final DateTime? createdAt;

  /// True when this entry is a system-generated history/activity line rather
  /// than a user-written comment.
  final bool isSystem;

  const InvoiceComment({
    required this.id,
    required this.text,
    required this.author,
    this.createdAt,
    this.isSystem = false,
  });

  factory InvoiceComment.fromJson(Map<String, dynamic> json) {
    final type =
        (json['type'] ?? json['entry_type'] ?? '').toString().toLowerCase();
    final isSystem =
        json['is_system'] == true ||
        json['system'] == true ||
        type == 'history' ||
        type == 'activity' ||
        type == 'system';

    return InvoiceComment(
      id: (json['comment_id'] ??
              json['id'] ??
              json['history_id'] ??
              '')
          .toString(),
      text: (json['comment'] ??
              json['text'] ??
              json['description'] ??
              json['message'] ??
              json['content'] ??
              '')
          .toString(),
      author: (json['commented_by_name'] ??
              json['created_by_name'] ??
              json['author'] ??
              json['user_name'] ??
              json['added_by'] ??
              '')
          .toString(),
      createdAt: _toDate(
        json['created_at'] ?? json['commented_at'] ?? json['date'],
      ),
      isSystem: isSystem,
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
