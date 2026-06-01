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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reportes y Registro Histórico', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Total Histórico', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('${_allReservations.length}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Reservas Completadas', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_completed', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Reservas Activas', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('$_active', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Historial de Reservas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
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
                            DataCell(Text(
                              r.status,
                              style: TextStyle(
                                color: r.status == 'Activa' ? Colors.orange : (r.status == 'Finalizada' ? Colors.green : Colors.red),
                                fontWeight: FontWeight.bold,
                              ),
                            )),
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
}
