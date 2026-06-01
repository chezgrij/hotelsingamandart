import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Reservation> _allReservations = [];
  int _completed = 0;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final res = await DatabaseHelper.instance.getAllReservations();
    setState(() {
      _allReservations = res;
      _active = res.where((r) => r.status == 'Activa').length;
      _completed = res.where((r) => r.status == 'Finalizada').length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reportes y Registro Histórico', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard('Total Histórico', '${_allReservations.length}', const Color(0xFF1E88E5)),
              const SizedBox(width: 24),
              _buildStatCard('Reservas Completadas', '$_completed', const Color(0xFF43A047)),
              const SizedBox(width: 24),
              _buildStatCard('Reservas Activas', '$_active', const Color(0xFFFCA311)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Historial de Reservas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14213D)),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Huésped')),
                            DataColumn(label: Text('Habitación')),
                            DataColumn(label: Text('Fechas')),
                            DataColumn(label: Text('Estado')),
                          ],
                          rows: _allReservations.map((r) => DataRow(cells: [
                            DataCell(Text(r.id.toString())),
                            DataCell(Text(r.guestName ?? '')),
                            DataCell(Text('Hab ${r.roomNumber}')),
                            DataCell(Text('${r.checkInDate} a ${r.checkOutDate}')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(r.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  r.status,
                                  style: TextStyle(
                                    color: _getStatusColor(r.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ])).toList(),
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

  Color _getStatusColor(String status) {
    if (status == 'Activa') return Colors.orange.shade800;
    if (status == 'Finalizada') return Colors.green.shade800;
    return Colors.red.shade800;
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text(value, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
