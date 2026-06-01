import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  List<Map<String, dynamic>> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final res = await DatabaseHelper.instance.getActiveReservationsWithStatus();
    setState(() {
      _reservations = res;
    });
  }

  Future<void> _handleCheckIn(int resId, int roomId) async {
    await DatabaseHelper.instance.updateRoomStatus(roomId, 'Ocupada');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-In completado. Habitación ocupada.')));
      _loadReservations();
    }
  }

  Future<void> _handleCheckOut(int resId, int roomId) async {
    await DatabaseHelper.instance.updateReservationStatus(resId, 'Finalizada');
    await DatabaseHelper.instance.updateRoomStatus(roomId, 'Disponible');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-Out completado. Habitación disponible.')));
      _loadReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Check-In / Check-Out', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Reservas Activas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID Reserva')),
                            DataColumn(label: Text('Huésped')),
                            DataColumn(label: Text('Habitación')),
                            DataColumn(label: Text('Estado Hab.')),
                            DataColumn(label: Text('Fechas')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: _reservations.map((r) {
                            final resId = r['id'] as int;
                            final roomId = r['room_id'] as int;
                            final roomStatus = r['room_status'] as String;
                            
                            final isCheckInDisabled = roomStatus == 'Ocupada';
                            
                            return DataRow(cells: [
                              DataCell(Text(resId.toString())),
                              DataCell(Text(r['guest_name'])),
                              DataCell(Text('Hab ${r['room_number']}')),
                              DataCell(Text(roomStatus)),
                              DataCell(Text('${r['check_in_date']} a ${r['check_out_date']}')),
                              DataCell(
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: isCheckInDisabled ? null : () => _handleCheckIn(resId, roomId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Check-In', style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: !isCheckInDisabled ? null : () => _handleCheckOut(resId, roomId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Check-Out', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
