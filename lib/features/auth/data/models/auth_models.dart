/// توكنات المصادقة
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final access = json['token'] ??
        json['access_token'] ??
        json['accessToken'] ??
        json['jwt'];
    final refresh = json['refresh_token'] ??
        json['refreshToken'] ??
        json['token_refresh'];

    return AuthTokens(
      accessToken: access?.toString() ?? '',
      refreshToken: refresh?.toString(),
    );
  }
}

/// بيانات المستخدم بعد تسجيل الدخول
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.city,
    this.cosmeticName,
    this.erpId,
    this.uuid,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? city;
  final String? cosmeticName;
  final String? erpId;
  final String? uuid;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName']?.toString().trim() ?? '';
    final lastName = json['lastName']?.toString().trim() ?? '';
    final combinedName = '$firstName $lastName'.trim();
    final name = (json['name'] ?? json['user_name'] ?? combinedName)
        .toString()
        .trim();

    return AuthUser(
      id: (json['id'] ?? json['user_id'] ?? json['uuid'] ?? '').toString(),
      name: name.isNotEmpty ? name : combinedName,
      email: json['email']?.toString() ?? json['user_email']?.toString(),
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      cosmeticName: json['cosmetic_name']?.toString(),
      erpId: json['id_erp']?.toString(),
      uuid: json['uuid']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'cosmetic_name': cosmeticName,
        'id_erp': erpId,
        'uuid': uuid,
      };

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? cosmeticName,
    String? erpId,
    String? uuid,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      cosmeticName: cosmeticName ?? this.cosmeticName,
      erpId: erpId ?? this.erpId,
      uuid: uuid ?? this.uuid,
    );
  }
}

/// نتيجة تسجيل الدخول
class AuthSession {
  const AuthSession({
    required this.tokens,
    this.user,
  });

  final AuthTokens tokens;
  final AuthUser? user;
}
