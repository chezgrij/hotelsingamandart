import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final data = await DatabaseHelper.instance.getDashboardStats();
    setState(() {
      stats = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Resumen de la ocupación y huéspedes de SingaINN', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard('Huéspedes', stats!['guests'].toString(), Icons.people_outline, const Color(0xFF1E88E5)),
              const SizedBox(width: 24),
              _buildStatCard('Res. Activas', stats!['active_reservations'].toString(), Icons.book_online_outlined, const Color(0xFF43A047)),
              const SizedBox(width: 24),
              _buildStatCard('Ocupadas', stats!['occupied_rooms'].toString(), Icons.meeting_room_outlined, const Color(0xFFE53935)),
              const SizedBox(width: 24),
              _buildStatCard('Disponibles', stats!['available_rooms'].toString(), Icons.check_circle_outline, const Color(0xFF00ACC1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 24),
              Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF14213D))),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
