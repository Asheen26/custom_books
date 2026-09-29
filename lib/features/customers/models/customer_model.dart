import 'package:custom_books/features/customers/models/customer_draft.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? email;
  final String? mobileNumber;
  final String? workPhone;
  final double receivables;
  final double unusedCredits;
  final bool isActive;

  final String? organizationId;
  final String? customerType;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? companyName;
  final String? phone;
  final String? gstin;
  final String? taxTreatment;
  final String? placeOfSupply;
  final String? currency;
  final String? paymentTerms;
  final double openingBalance;
  final bool portalEnabled;
  final String? website;
  final String? remarks;
  final String? status;
  final bool isOverdue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? phoneCountryCode;
  final String? mobileCountryCode;
  final bool allowPortalAccess;
  final String? portalLanguage;
  final CustomerAddressDraft? billingAddress;
  final CustomerAddressDraft? shippingAddress;
  final List<CustomerContactPersonDraft> contactPersons;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    this.mobileNumber,
    this.workPhone,
    required this.receivables,
    required this.unusedCredits,
    this.isActive = true,
    this.organizationId,
    this.customerType,
    this.salutation,
    this.firstName,
    this.lastName,
    this.displayName,
    this.companyName,
    this.phone,
    this.gstin,
    this.taxTreatment,
    this.placeOfSupply,
    this.currency,
    this.paymentTerms,
    this.openingBalance = 0.0,
    this.portalEnabled = false,
    this.website,
    this.remarks,
    this.status,
    this.isOverdue = false,
    this.createdAt,
    this.updatedAt,
    this.phoneCountryCode,
    this.mobileCountryCode,
    this.allowPortalAccess = false,
    this.portalLanguage,
    this.billingAddress,
    this.shippingAddress,
    this.contactPersons = const [],
  });

  String get initials {
    final words = name.trim().split(' ');
    if (words.isEmpty || words.first.isEmpty) return 'UN';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length > 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final contacts = (json['contact_persons'] as List<dynamic>?) ?? const [];
    final Map<String, dynamic>? primaryContact = contacts
        .whereType<Map<String, dynamic>>()
        .cast<Map<String, dynamic>?>()
        .firstWhere((_) => true, orElse: () => null);

    final String? contactWorkPhone = primaryContact != null
        ? _nullIfBlank(primaryContact['work_phone'])
        : null;

    final billing = json['billing_address'];
    final shipping = json['shipping_address'];

    return CustomerModel(
      id: (json['customer_id'] ?? json['id'] ?? '').toString(),
      name: (json['display_name'] ?? json['name'] ?? '').toString(),
      email: _nullIfBlank(json['email']),
      mobileNumber: _nullIfBlank(json['mobile']),
      workPhone: contactWorkPhone ?? _nullIfBlank(json['phone']),
      receivables: _toDouble(json['receivables']),
      unusedCredits: _toDouble(json['unused_credits']),
      isActive:
          (json['status']?.toString().toLowerCase() ?? 'active') == 'active',
      organizationId: _nullIfBlank(json['organization_id']),
      customerType: _nullIfBlank(json['customer_type']),
      salutation: _nullIfBlank(json['salutation']),
      firstName: _nullIfBlank(json['first_name']),
      lastName: _nullIfBlank(json['last_name']),
      displayName: _nullIfBlank(json['display_name']),
      companyName: _nullIfBlank(json['company_name']),
      phone: _nullIfBlank(json['phone']),
      gstin: _nullIfBlank(json['gstin']),
      taxTreatment: _nullIfBlank(json['tax_treatment']),
      placeOfSupply: _nullIfBlank(json['place_of_supply']),
      currency: _nullIfBlank(json['currency']),
      paymentTerms: _nullIfBlank(json['payment_terms']),
      openingBalance: _toDouble(json['opening_balance']),
      portalEnabled: json['portal_enabled'] == true,
      website: _nullIfBlank(json['website']),
      remarks: _nullIfBlank(json['remarks']),
      status: _nullIfBlank(json['status']),
      isOverdue: json['is_overdue'] == true,
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
      phoneCountryCode: _nullIfBlank(json['phone_country_code']),
      mobileCountryCode: _nullIfBlank(json['mobile_country_code']),
      allowPortalAccess: json['allow_portal_access'] == true,
      portalLanguage: _nullIfBlank(json['portal_language']),
      billingAddress: billing is Map<String, dynamic>
          ? CustomerAddressDraft.fromJson(billing)
          : null,
      shippingAddress: shipping is Map<String, dynamic>
          ? CustomerAddressDraft.fromJson(shipping)
          : null,
      contactPersons: contacts
          .whereType<Map<String, dynamic>>()
          .map(CustomerContactPersonDraft.fromJson)
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String? _nullIfBlank(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
