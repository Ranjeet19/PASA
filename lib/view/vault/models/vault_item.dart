class VaultItem {
  final String id;
  final String type;
  final String platform;
  final String email;
  final String username;
  final String password;
  final String additionalInfo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VaultItem({
    required this.id,
    required this.type,
    required this.platform,
    required this.email,
    required this.username,
    required this.password,
    required this.additionalInfo,
    required this.createdAt,
    this.updatedAt,
  });

  factory VaultItem.fromMap(Map<dynamic, dynamic> map) {
    return VaultItem(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'account',
      platform: map['platform']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      additionalInfo: map['additionalInfo']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'platform': platform,
      'email': email,
      'username': username,
      'password': password,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
