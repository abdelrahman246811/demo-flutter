import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class OfenForm extends StatefulWidget {
  @override
  _OfenFormState createState() => _OfenFormState();
}

class _OfenFormState extends State<OfenForm> {
  final _formKey = GlobalKey<FormState>();
  List<Ofen> _ofenList = [];
  List<Vormahlung> _vormahlungList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for each input field
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _durchsatzController = TextEditingController();
  final TextEditingController _neigungController = TextEditingController();
  final TextEditingController _rotationController = TextEditingController();
  final TextEditingController _heiztemperaturController = TextEditingController();
  final TextEditingController _luftvolumenController = TextEditingController();
  final TextEditingController _faesserController = TextEditingController();
  final TextEditingController _gluehverlustController = TextEditingController();

  int? _selectedVormahlungId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ofenData = await dbHelper.getOfen();
    final vormahlungData = await dbHelper.getVormahlung();
    setState(() {
      _ofenList = ofenData;
      _vormahlungList = vormahlungData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedVormahlungId != null) {
      final ofen = Ofen(
        vormahlungId: _selectedVormahlungId!,
        o_charge: _chargeController.text,
        o_info: _infoController.text,
        o_durchsatz: double.tryParse(_durchsatzController.text) ?? 0.0,
        o_neigung: double.tryParse(_neigungController.text) ?? 0.0,
        o_rotation: double.tryParse(_rotationController.text) ?? 0.0,
        o_heiztemperatur: double.tryParse(_heiztemperaturController.text) ?? 0.0,
        o_luftvolumen: double.tryParse(_luftvolumenController.text) ?? 0.0,
        o_faesser: int.tryParse(_faesserController.text) ?? 0,
        o_gluehverlust: double.tryParse(_gluehverlustController.text) ?? 0.0,
      );

      await dbHelper.insertOfen(ofen);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );
    }
  }

  void _clearForm() {
    _chargeController.clear();
    _infoController.clear();
    _durchsatzController.clear();
    _neigungController.clear();
    _rotationController.clear();
    _heiztemperaturController.clear();
    _luftvolumenController.clear();
    _faesserController.clear();
    _gluehverlustController.clear();
    setState(() {
      _selectedVormahlungId = null;
    });
  }

  Future<void> _deleteOfen(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Löschen bestätigen'),
          content: Text('Möchten Sie diesen Eintrag wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Löschen'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await dbHelper.deleteOfen(id);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eintrag erfolgreich gelöscht!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(width: 2.0),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Charge')),
          DataColumn(label: Text('Info')),
          DataColumn(label: Text('Durchsatz')),
          DataColumn(label: Text('Neigung')),
          DataColumn(label: Text('Rotation')),
          DataColumn(label: Text('Heiztemperatur')),
          DataColumn(label: Text('Luftvolumen')),
          DataColumn(label: Text('Fässer')),
          DataColumn(label: Text('Glühverlust')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _ofenList.map((ofen) {
          return DataRow(
            cells: [
              DataCell(Text(ofen.o_charge)),
              DataCell(Text(ofen.o_info)),
              DataCell(Text(ofen.o_durchsatz.toString())),
              DataCell(Text(ofen.o_neigung.toString())),
              DataCell(Text(ofen.o_rotation.toString())),
              DataCell(Text(ofen.o_heiztemperatur.toString())),
              DataCell(Text(ofen.o_luftvolumen.toString())),
              DataCell(Text(ofen.o_faesser.toString())),
              DataCell(Text(ofen.o_gluehverlust.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteOfen(ofen.o_id ?? 0),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ofen Formular'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_chargeController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Aktuelle Charge',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 8),
                              Text(
                                _chargeController.text,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedVormahlungId,
                          decoration: _buildInputDecoration(
                              'Vormahlung Charge', Icons.all_inbox),
                          items: _vormahlungList.map((vormahlung) {
                            return DropdownMenuItem<int>(
                              value: vormahlung.v_id,
                              child: Text(vormahlung.v_charge),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedVormahlungId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Bitte wählen Sie eine Vormahlung Charge aus';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _infoController,
                          decoration: _buildInputDecoration('Info', Icons.info),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _durchsatzController,
                          decoration: _buildInputDecoration('Durchsatz', Icons.speed),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _neigungController,
                          decoration: _buildInputDecoration('Neigung', Icons.trending_up),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _rotationController,
                          decoration: _buildInputDecoration('Rotation', Icons.rotate_right),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _heiztemperaturController,
                          decoration: _buildInputDecoration('Heiztemperatur', Icons.thermostat),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _luftvolumenController,
                          decoration: _buildInputDecoration('Luftvolumen', Icons.air),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _faesserController,
                          decoration: _buildInputDecoration('Fässer', Icons.storage),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || int.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Ganzzahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _gluehverlustController,
                          decoration: _buildInputDecoration('Glühverlust', Icons.opacity),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.save),
                          label: Text('Speichern'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            textStyle: TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Ofen Daten',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 15),
                  _buildDataTable(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}