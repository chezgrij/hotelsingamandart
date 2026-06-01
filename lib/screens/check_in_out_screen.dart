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
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Check-In / Check-Out', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Reservas Activas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14213D)),
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
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: roomStatus == 'Ocupada' ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    roomStatus,
                                    style: TextStyle(
                                      color: roomStatus == 'Ocupada' ? Colors.orange.shade800 : Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text('${r['check_in_date']} a ${r['check_out_date']}')),
                              DataCell(
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: isCheckInDisabled ? null : () => _handleCheckIn(resId, roomId),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green.shade700,
                                        side: BorderSide(color: isCheckInDisabled ? Colors.grey.shade300 : Colors.green.shade700),
                                      ),
                                      child: const Text('Check-In'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: !isCheckInDisabled ? null : () => _handleCheckOut(resId, roomId),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade700,
                                        side: BorderSide(color: !isCheckInDisabled ? Colors.grey.shade300 : Colors.red.shade700),
                                      ),
                                      child: const Text('Check-Out'),
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
