class Room {
  final int? id;
  final String roomNumber;
  final String roomType;
  final double price;
  final String status;

  Room({
    this.id,
    required this.roomNumber,
    required this.roomType,
    required this.price,
    this.status = 'Disponible',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType,
      'price': price,
      'status': status,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      roomNumber: map['room_number'].toString(),
      roomType: map['room_type'],
      price: map['price'] is int ? (map['price'] as int).toDouble() : map['price'],
      status: map['status'],
    );
  }
}
