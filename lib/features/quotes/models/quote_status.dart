import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum QuoteStatus { draft, sent, accepted, declined, expired, converted }

extension QuoteStatusLabel on QuoteStatus {
  String get label => switch (this) {
    QuoteStatus.draft => 'DRAFT',
    QuoteStatus.sent => 'SENT',
    QuoteStatus.accepted => 'ACCEPTED',
    QuoteStatus.declined => 'DECLINED',
    QuoteStatus.expired => 'EXPIRED',
    QuoteStatus.converted => 'CONVERTED',
  };
}

extension QuoteStatusColor on QuoteStatus {
  Color get color => switch (this) {
    QuoteStatus.draft => AppColors.statusDraft,
    QuoteStatus.sent => AppColors.primaryLight,
    QuoteStatus.accepted => AppColors.success,
    QuoteStatus.declined => AppColors.error,
    QuoteStatus.expired => AppColors.error,
    QuoteStatus.converted => AppColors.success,
  };
}