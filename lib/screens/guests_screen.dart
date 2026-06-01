import 'package:flutter/material.dart';
import '../models/guest.dart';
import '../database/database_helper.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _docCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  List<Guest> _guests = [];

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests([String? query]) async {
    final guests = await DatabaseHelper.instance.getAllGuests(query: query);
    setState(() {
      _guests = guests;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final guest = Guest(
        name: _nameCtrl.text.trim(),
        document: _docCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      );
      final id = await DatabaseHelper.instance.insertGuest(guest);
      if (id != -1) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Huésped registrado con éxito')));
        _nameCtrl.clear();
        _docCtrl.clear();
        _phoneCtrl.clear();
        _emailCtrl.clear();
        _loadGuests();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: El documento ya existe')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gestión de Huéspedes', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formulario
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Registrar Huésped', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(labelText: 'Nombre Completo'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _docCtrl,
                              decoration: const InputDecoration(labelText: 'Documento (ID)'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(labelText: 'Teléfono'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Registrar Huésped'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Lista
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Directorio de Huéspedes', style: Theme.of(context).textTheme.titleLarge),
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: _searchCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Buscar por nombre o documento...',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: _loadGuests,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF14213D)),
                                  columns: const [
                                    DataColumn(label: Text('Nombre')),
                                    DataColumn(label: Text('Documento')),
                                    DataColumn(label: Text('Teléfono')),
                                    DataColumn(label: Text('Email')),
                                  ],
                                  rows: _guests.map((g) => DataRow(cells: [
                                    DataCell(Text(g.name)),
                                    DataCell(Text(g.document)),
                                    DataCell(Text(g.phone ?? '')),
                                    DataCell(Text(g.email ?? '')),
                                  ])).toList(),
                                ),
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
          )
        ],
      ),
    );
  }
}
