class Profile {
  Profile({
    required this.userId,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.whatsapp,
    this.city,
    this.address,
    this.documentType,
    this.documentNumber,
    required this.role,
    required this.verificationStatus,
    required this.accountStatus,
    this.createdAt,
  });

  final String userId;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? city;
  final String? address;
  final String? documentType;
  final String? documentNumber;
  final String role;
  final String verificationStatus;
  final String accountStatus;
  final String? createdAt;

  bool get isVerified => verificationStatus == 'verificado';

  factory Profile.fromJson(Map<String, dynamic> j) {
    return Profile(
      userId: (j['userId'] ?? j['user_id'] ?? '').toString(),
      displayName: (j['displayName'] ?? j['display_name'] ?? 'Usuario').toString(),
      firstName: j['firstName']?.toString() ?? j['first_name']?.toString(),
      lastName: j['lastName']?.toString() ?? j['last_name']?.toString(),
      email: j['email']?.toString(),
      phone: j['phone']?.toString(),
      whatsapp: j['whatsapp']?.toString(),
      city: j['city']?.toString(),
      address: j['address']?.toString(),
      documentType: j['documentType']?.toString() ?? j['document_type']?.toString(),
      documentNumber: j['documentNumber']?.toString() ?? j['document_number']?.toString(),
      role: (j['role'] ?? 'cliente').toString(),
      verificationStatus: (j['verificationStatus'] ?? j['verification_status'] ?? 'sin_verificar').toString(),
      accountStatus: (j['accountStatus'] ?? j['account_status'] ?? 'activo').toString(),
      createdAt: j['createdAt']?.toString() ?? j['created_at']?.toString(),
    );
  }
}
