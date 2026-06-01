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
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Formulario
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Registrar Huésped', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _docCtrl,
                        decoration: const InputDecoration(labelText: 'Documento (ID)', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Lista
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lista de Huéspedes', style: Theme.of(context).textTheme.titleLarge),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Buscar...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _loadGuests,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Documento')),
                            DataColumn(label: Text('Teléfono')),
                            DataColumn(label: Text('Email')),
                          ],
                          rows: _guests.map((g) => DataRow(cells: [
                            DataCell(Text(g.id.toString())),
                            DataCell(Text(g.name)),
                            DataCell(Text(g.document)),
                            DataCell(Text(g.phone ?? '')),
                            DataCell(Text(g.email ?? '')),
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
