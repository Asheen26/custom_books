class CustomerAddressDraft {
  final String attention;
  final String country;
  final String street1;
  final String street2;
  final String city;
  final String state;
  final String zipCode;
  final String fax;
  final String phoneCountryCode;
  final String phone;

  const CustomerAddressDraft({
    this.attention = '',
    this.country = '',
    this.street1 = '',
    this.street2 = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.fax = '',
    this.phoneCountryCode = '+91',
    this.phone = '',
  });

  bool get isEmpty =>
      attention.trim().isEmpty &&
      country.trim().isEmpty &&
      street1.trim().isEmpty &&
      street2.trim().isEmpty &&
      city.trim().isEmpty &&
      state.trim().isEmpty &&
      zipCode.trim().isEmpty &&
      fax.trim().isEmpty &&
      phone.trim().isEmpty;

  factory CustomerAddressDraft.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString();
    return CustomerAddressDraft(
      attention: s(json['attention']),
      country: s(json['country']),
      street1: s(json['street1']),
      street2: s(json['street2']),
      city: s(json['city']),
      state: s(json['state']),
      zipCode: s(json['zip_code']),
      fax: s(json['fax']),
      phoneCountryCode: s(json['phone_country_code']).isEmpty
          ? '+91'
          : s(json['phone_country_code']),
      phone: s(json['phone']),
    );
  }

  Map<String, dynamic> toJson() => {
    'attention': attention.trim(),
    'country': country.trim(),
    'street1': street1.trim(),
    'street2': street2.trim(),
    'city': city.trim(),
    'state': state.trim(),
    'zip_code': zipCode.trim(),
    'fax': fax.trim(),
    'phone_country_code': phoneCountryCode,
    'phone': phone.trim(),
  };
}

class CustomerContactPersonDraft {
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String workPhoneCountryCode;
  final String workPhone;
  final String mobileCountryCode;
  final String mobile;
  final String designation;
  final String department;

  const CustomerContactPersonDraft({
    this.salutation = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.workPhoneCountryCode = '+91',
    this.workPhone = '',
    this.mobileCountryCode = '+91',
    this.mobile = '',
    this.designation = '',
    this.department = '',
  });

  bool get isEmpty =>
      firstName.trim().isEmpty &&
      lastName.trim().isEmpty &&
      email.trim().isEmpty &&
      workPhone.trim().isEmpty &&
      mobile.trim().isEmpty &&
      designation.trim().isEmpty &&
      department.trim().isEmpty;

  factory CustomerContactPersonDraft.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => (v ?? '').toString();
    return CustomerContactPersonDraft(
      salutation: s(json['salutation']),
      firstName: s(json['first_name']),
      lastName: s(json['last_name']),
      email: s(json['email']),
      workPhoneCountryCode: s(json['work_phone_country_code']).isEmpty
          ? '+91'
          : s(json['work_phone_country_code']),
      workPhone: s(json['work_phone']),
      mobileCountryCode: s(json['mobile_country_code']).isEmpty
          ? '+91'
          : s(json['mobile_country_code']),
      mobile: s(json['mobile']),
      designation: s(json['designation']),
      department: s(json['department']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (salutation.isNotEmpty) 'salutation': salutation,
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    'email': email.trim(),
    'work_phone_country_code': workPhoneCountryCode,
    'work_phone': workPhone.trim(),
    'mobile_country_code': mobileCountryCode,
    'mobile': mobile.trim(),
    'designation': designation.trim(),
    'department': department.trim(),
  };
}

class CustomerSocialLinkDraft {
  final String platform;
  final String url;

  const CustomerSocialLinkDraft({required this.platform, required this.url});

  Map<String, dynamic> toJson() => {'platform': platform, 'url': url.trim()};
}

class CustomerFieldMaps {
  const CustomerFieldMaps._();

  static const Map<String, String> salutation = {
    'Mr.': 'mr',
    'Mrs.': 'mrs',
    'Ms.': 'ms',
    'Miss.': 'miss',
    'Dr.': 'dr',
  };

  static const Map<String, String> taxTreatment = {
    'GST Registered': 'gst_registered',
    'Non GST Registered': 'non_gst_registered',
    'GST Registered - Composition': 'gst_registered_composition',
    'Consumer': 'consumer',
    'Overseas': 'overseas',
    'SEZ': 'sez',
  };

  static const Map<String, String> currency = {
    'INR- Indian Rupee': 'INR',
    'USD- United States Dollar': 'USD',
    'EUR- Euro': 'EUR',
    'GBP- Pound Sterling': 'GBP',
    'AED- UAE Dirham': 'AED',
    'CAD- Canadian Dollar': 'CAD',
    'AUD- Australian Dollar': 'AUD',
    'SGD- Singapore Dollar': 'SGD',
    'JPY- Japanese Yen': 'JPY',
    'CNY- Yuan Renminbi': 'CNY',
  };

  static const Map<String, String> accountsReceivable = {
    'Accounts Receivable': 'accounts_receivable',
    'Accounts Receivable - Domestic': 'accounts_receivable_domestic',
    'Accounts Receivable - Foreign': 'accounts_receivable_foreign',
  };

  static const Map<String, String> paymentTerms = {
    'Due on Receipt': 'due_on_receipt',
    'Net 15': 'net_15',
    'Net 30': 'net_30',
    'Net 45': 'net_45',
    'Net 60': 'net_60',
    'Due end of the month': 'due_end_of_month',
    'Due end of next month': 'due_end_of_next_month',
  };

  static const Map<String, String> portalLanguage = {
    'English': 'en',
    'Hindi': 'hi',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Marathi': 'mr',
    'Bengali': 'bn',
    'Gujarati': 'gu',
  };

  static String? keyFor(Map<String, String> map, String? label) {
    if (label == null) return null;
    return map[label];
  }

  static String? labelFor(Map<String, String> map, String? key) {
    if (key == null || key.isEmpty) return null;
    for (final entry in map.entries) {
      if (entry.value == key) return entry.key;
    }
    return null;
  }
}
