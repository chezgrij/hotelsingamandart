import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/guest.dart';
import '../models/room.dart';
import '../models/reservation.dart';
import '../database/database_helper.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  
  List<Guest> _guests = [];
  List<Room> _availableRooms = [];
  
  Guest? _selectedGuest;
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    final guests = await DatabaseHelper.instance.getAllGuests();
    setState(() {
      _guests = guests;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _searchAvailableRooms() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione fechas de entrada y salida')));
      return;
    }
    if (_checkOutDate!.isBefore(_checkInDate!) || _checkOutDate!.isAtSameMomentAs(_checkInDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de salida debe ser posterior a la de entrada')));
      return;
    }
    
    final cin = _dateFormat.format(_checkInDate!);
    final cout = _dateFormat.format(_checkOutDate!);
    
    final rooms = await DatabaseHelper.instance.getAvailableRooms(cin, cout);
    setState(() {
      _availableRooms = rooms;
      _selectedRoom = null;
    });
    
    if (rooms.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay habitaciones disponibles')));
    }
  }

  Future<void> _createReservation() async {
    if (_selectedGuest == null || _selectedRoom == null || _checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debe completar todos los campos')));
      return;
    }

    final res = Reservation(
      guestId: _selectedGuest!.id!,
      roomId: _selectedRoom!.id!,
      checkInDate: _dateFormat.format(_checkInDate!),
      checkOutDate: _dateFormat.format(_checkOutDate!),
    );

    await DatabaseHelper.instance.insertReservation(res);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva creada con éxito')));
      setState(() {
        _checkInDate = null;
        _checkOutDate = null;
        _selectedGuest = null;
        _selectedRoom = null;
        _availableRooms = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reservas', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paso 1: Buscar Disponibilidad', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, true),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_checkInDate == null ? 'Check-In' : _dateFormat.format(_checkInDate!)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context, false),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_checkOutDate == null ? 'Check-Out' : _dateFormat.format(_checkOutDate!)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _searchAvailableRooms,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar Habitaciones'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paso 2: Confirmar Reserva', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Guest>(
                          decoration: const InputDecoration(labelText: 'Huésped', border: OutlineInputBorder()),
                          value: _selectedGuest,
                          items: _guests.map((g) => DropdownMenuItem(value: g, child: Text('${g.name} (${g.document})'))).toList(),
                          onChanged: (val) => setState(() => _selectedGuest = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Room>(
                          decoration: const InputDecoration(labelText: 'Habitación', border: OutlineInputBorder()),
                          value: _selectedRoom,
                          items: _availableRooms.map((r) => DropdownMenuItem(value: r, child: Text('Hab ${r.roomNumber} - ${r.roomType} - \$${r.price}'))).toList(),
                          onChanged: (val) => setState(() => _selectedRoom = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createReservation,
                      icon: const Icon(Icons.check),
                      label: const Text('Crear Reserva'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
