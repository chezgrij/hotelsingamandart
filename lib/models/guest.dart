class Guest {
  final int? id;
  final String name;
  final String document;
  final String? phone;
  final String? email;

  Guest({
    this.id,
    required this.name,
    required this.document,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'document': document,
      'phone': phone,
      'email': email,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'],
      name: map['name'],
      document: map['document'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}
