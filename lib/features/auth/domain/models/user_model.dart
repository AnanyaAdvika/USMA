class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String aadhaarLast4;
  final String tribe;
  final String state;
  final String district;
  final double familyAnnualIncome;
  final bool isAadhaarLinked;
  final bool isDigiLockerLinked;
  final String? bankAccountLast4;
  final String? bankIfsc;
  final String? apaarId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.aadhaarLast4,
    required this.tribe,
    required this.state,
    required this.district,
    required this.familyAnnualIncome,
    this.isAadhaarLinked = false,
    this.isDigiLockerLinked = false,
    this.bankAccountLast4,
    this.bankIfsc,
    this.apaarId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      aadhaarLast4: map['aadhaarLast4'] ?? 'XXXX',
      tribe: map['tribe'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      familyAnnualIncome: (map['familyAnnualIncome'] as num?)?.toDouble() ?? 0.0,
      isAadhaarLinked: map['isAadhaarLinked'] ?? false,
      isDigiLockerLinked: map['isDigiLockerLinked'] ?? false,
      bankAccountLast4: map['bankAccountLast4'],
      bankIfsc: map['bankIfsc'],
      apaarId: map['apaarId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'aadhaarLast4': aadhaarLast4,
      'tribe': tribe,
      'state': state,
      'district': district,
      'familyAnnualIncome': familyAnnualIncome,
      'isAadhaarLinked': isAadhaarLinked,
      'isDigiLockerLinked': isDigiLockerLinked,
      'bankAccountLast4': bankAccountLast4,
      'bankIfsc': bankIfsc,
      'apaarId': apaarId,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? aadhaarLast4,
    String? tribe,
    String? state,
    String? district,
    double? familyAnnualIncome,
    bool? isAadhaarLinked,
    bool? isDigiLockerLinked,
    String? bankAccountLast4,
    String? bankIfsc,
    String? apaarId,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      aadhaarLast4: aadhaarLast4 ?? this.aadhaarLast4,
      tribe: tribe ?? this.tribe,
      state: state ?? this.state,
      district: district ?? this.district,
      familyAnnualIncome: familyAnnualIncome ?? this.familyAnnualIncome,
      isAadhaarLinked: isAadhaarLinked ?? this.isAadhaarLinked,
      isDigiLockerLinked: isDigiLockerLinked ?? this.isDigiLockerLinked,
      bankAccountLast4: bankAccountLast4 ?? this.bankAccountLast4,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      apaarId: apaarId ?? this.apaarId,
    );
  }
}
