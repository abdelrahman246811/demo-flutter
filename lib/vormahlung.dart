import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class VormahlungForm extends StatefulWidget {
  @override
  _VormahlungFormState createState() => _VormahlungFormState();
}

class _VormahlungFormState extends State<VormahlungForm> {
  final _formKey = GlobalKey<FormState>();
  List<Vormahlung> _vormahlungList = [];
  List<Steinbruch> _steinbruchList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for each input field

  final TextEditingController _muehleTypController = TextEditingController();
  final TextEditingController _mahlDauerController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _dichteController = TextEditingController();
  final TextEditingController _feinheitController = TextEditingController();
  final TextEditingController _chargeController = TextEditingController();

  int? _selectedSteinbruchId;
  bool _isErledigt = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vormahlungData = await dbHelper.getVormahlung();
    final steinbruchData = await dbHelper.getSteinbruch();
    setState(() {
      _vormahlungList = vormahlungData;
      _steinbruchList = steinbruchData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedSteinbruchId != null) {
      final vormahlung = Vormahlung(
        steinbruchId: _selectedSteinbruchId!,
        v_charge: _chargeController.text,
        v_erledigt: _isErledigt,
        v_muehleTyp: _isErledigt ? _muehleTypController.text : '',
        v_mahlDauer: _isErledigt
            ? (double.tryParse(_mahlDauerController.text) ?? 0.0)
            : 0.0,
        v_grad: _isErledigt ? _gradController.text : '',
        v_dichte: _isErledigt
            ? (double.tryParse(_dichteController.text) ?? 0.0)
            : 0.0,
        v_feinheit: _isErledigt
            ? (double.tryParse(_feinheitController.text) ?? 0.0)
            : 0.0,
      );

      await dbHelper.insertVormahlung(vormahlung);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );
    }
  }

  void _clearForm() {
    _muehleTypController.clear();
    _mahlDauerController.clear();
    _gradController.clear();
    _dichteController.clear();
    _feinheitController.clear();
    _chargeController.clear();
    setState(() {
      _selectedSteinbruchId = null;
      _isErledigt = true;
    });
  }

  Future<void> _deleteVormahlung(int id) async {
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
        await dbHelper.deleteVormahlung(id);
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

  Widget _buildFormFields() {
    if (!_isErledigt) {
      return Container(); // Return empty container when not erledigt
    }

    return Column(
      children: [
        TextFormField(
          controller: _muehleTypController,
          decoration: _buildInputDecoration('Mühle Typ', Icons.engineering),
          validator: (value) {
            if (_isErledigt && (value == null || value.isEmpty)) {
              return 'Bitte geben Sie den Mühle Typ ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _mahlDauerController,
          decoration: _buildInputDecoration('Mahldauer (Stunden)', Icons.timer),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isErledigt &&
                (value == null || double.tryParse(value) == null)) {
              return 'Bitte geben Sie eine gültige Zahl für die Mahldauer ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _gradController,
          decoration: _buildInputDecoration('Grad', Icons.grade),
          validator: (value) {
            if (_isErledigt && (value == null || value.isEmpty)) {
              return 'Bitte geben Sie den Grad ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _dichteController,
          decoration: _buildInputDecoration('Dichte (g/cm³)', Icons.speed),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isErledigt &&
                (value == null || double.tryParse(value) == null)) {
              return 'Bitte geben Sie eine gültige Zahl für die Dichte ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _feinheitController,
          decoration: _buildInputDecoration('Feinheit (cm²/g)', Icons.gradient),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isErledigt &&
                (value == null || double.tryParse(value) == null)) {
              return 'Bitte geben Sie eine gültige Zahl für die Feinheit ein';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Steinbruch')),
          DataColumn(label: Text('Charge')),
          DataColumn(label: Text('Erledigt')),
          DataColumn(label: Text('Mühle Typ')),
          DataColumn(label: Text('Mahldauer (h)')),
          DataColumn(label: Text('Grad')),
          DataColumn(label: Text('Dichte (g/cm³)')),
          DataColumn(label: Text('Feinheit (cm²/g)')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _vormahlungList.map((vormahlung) {
          final steinbruch = _steinbruchList.firstWhere(
              (s) => s.s_id == vormahlung.steinbruchId,
              orElse: () => Steinbruch(
                  s_name: 'Unbekannt',
                  s_menge: 0.0,
                  s_korngroesse: 0.0,
                  s_asbestAnalyse: '',
                  s_dichte: 0.0,
                  s_transport: ''));
          return DataRow(
            cells: [
              DataCell(Text(steinbruch.s_name)),
              DataCell(Text(vormahlung.v_charge)),
              DataCell(Text(vormahlung.v_erledigt ? 'Ja' : 'Nein')),
              DataCell(Text(vormahlung.v_muehleTyp)),
              DataCell(Text(vormahlung.v_mahlDauer.toString())),
              DataCell(Text(vormahlung.v_grad)),
              DataCell(Text(vormahlung.v_dichte.toString())),
              DataCell(Text(vormahlung.v_feinheit.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteVormahlung(vormahlung.v_id ?? 0),
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
        title: Text('Vormahlung Formular'),
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
                          value: _selectedSteinbruchId,
                          decoration: _buildInputDecoration(
                              'Steinbruch', Icons.business),
                          items: _steinbruchList.map((steinbruch) {
                            return DropdownMenuItem<int>(
                              value: steinbruch.s_id,
                              child: Text(steinbruch.s_name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSteinbruchId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Bitte wählen Sie einen Steinbruch aus';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        CheckboxListTile(
                          title: Text('Erledigt'),
                          value: _isErledigt,
                          onChanged: (bool? value) {
                            setState(() {
                              _isErledigt = value ?? true;
                            });
                          },
                        ),
                        SizedBox(height: 15),
                        _buildFormFields(),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.save),
                          label: Text('Speichern'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
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
                    'Vormahlung Daten',
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
