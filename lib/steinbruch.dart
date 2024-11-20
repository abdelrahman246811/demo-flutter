import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class SteinbruchForm extends StatefulWidget {
  @override
  _SteinbruchFormState createState() => _SteinbruchFormState();
}

class _SteinbruchFormState extends State<SteinbruchForm> {
  final _formKey = GlobalKey<FormState>();
  List<Steinbruch> _steinbruchList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for each input field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mengeController = TextEditingController();
  final TextEditingController _korngroesseController = TextEditingController();
  final TextEditingController _asbestAnalyseController = TextEditingController();
  final TextEditingController _dichteController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSteinbruchData();
  }

  Future<void> _loadSteinbruchData() async {
    final steinbruchData = await dbHelper.getSteinbruch();
    setState(() {
      _steinbruchList = steinbruchData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Collect data from the controllers
      final String name = _nameController.text;
      final double menge = double.tryParse(_mengeController.text) ?? 0.0;
      final double korngroesse = double.tryParse(_korngroesseController.text) ?? 0.0;
      final String asbestAnalyse = _asbestAnalyseController.text;
      final double dichte = double.tryParse(_dichteController.text) ?? 0.0;
      final String transport = _transportController.text;

      // Create a new Steinbruch object
      final steinbruch = Steinbruch(
        s_name: name,
        s_menge: menge,
        s_korngroesse: korngroesse,
        s_asbestAnalyse: asbestAnalyse,
        s_dichte: dichte,
        s_transport: transport,
      );

      // Save the data to the database
      await dbHelper.insertSteinbruch(steinbruch);

      // Reload the data
      await _loadSteinbruchData();

      // Clear form after saving
      _nameController.clear();
      _mengeController.clear();
      _korngroesseController.clear();
      _asbestAnalyseController.clear();
      _dichteController.clear();
      _transportController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );
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
Future<void> _deleteSteinbruch(int id) async {
    // Show confirmation dialog
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
        await dbHelper.deleteSteinbruch(id);
        await _loadSteinbruchData();
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
  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Menge (t)')),
          DataColumn(label: Text('Korngröße (mm)')),
          DataColumn(label: Text('Asbestanalyse')),
          DataColumn(label: Text('Dichte (g/cm³)')),
          DataColumn(label: Text('Transport')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _steinbruchList.map((steinbruch) {
          return DataRow(
            cells: [
              DataCell(Text(steinbruch.s_name)),
              DataCell(Text(steinbruch.s_menge.toString())),
              DataCell(Text(steinbruch.s_korngroesse.toString())),
              DataCell(Text(steinbruch.s_asbestAnalyse)),
              DataCell(Text(steinbruch.s_dichte.toString())),
              DataCell(Text(steinbruch.s_transport)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSteinbruch(steinbruch.s_id ?? 0),
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
        title: Text('Steinbruch Formular'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200), // Increased max width
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Name', Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie einen Namen ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _mengeController,
                          decoration: _buildInputDecoration('Menge (Menge in Tonnen)', Icons.production_quantity_limits),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl für die Menge ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _korngroesseController,
                          decoration: _buildInputDecoration('korngröße (korngröße in mm)', Icons.science),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl für das korngröße ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _asbestAnalyseController,
                          decoration: _buildInputDecoration('Asbestanalyse', Icons.analytics),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie die Asbestanalyse ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _dichteController,
                          decoration: _buildInputDecoration('Dichte (Dichte in g/cm³)', Icons.speed),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || double.tryParse(value) == null) {
                              return 'Bitte geben Sie eine gültige Zahl für die Dichte ein';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _transportController,
                          decoration: _buildInputDecoration('Transportart', Icons.local_shipping),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie die Transportart ein';
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
                    'Steinbruch Daten',
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