class Reservation {
  final int? id;
  final int guestId;
  final int roomId;
  final String checkInDate;
  final String checkOutDate;
  final String status;

  // Campos adicionales para mostrar información relacionada
  final String? guestName;
  final String? roomNumber;

  Reservation({
    this.id,
    required this.guestId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    this.status = 'Activa',
    this.guestName,
    this.roomNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guest_id': guestId,
      'room_id': roomId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'status': status,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      guestId: map['guest_id'],
      roomId: map['room_id'],
      checkInDate: map['check_in_date'],
      checkOutDate: map['check_out_date'],
      status: map['status'],
      guestName: map['guest_name'],
      roomNumber: map['room_number']?.toString(),
    );
  }
}
