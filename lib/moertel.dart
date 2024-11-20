import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class MoertelZusammensetzungForm extends StatefulWidget {
  @override
  _MoertelZusammensetzungFormState createState() => _MoertelZusammensetzungFormState();
}

class _MoertelZusammensetzungFormState extends State<MoertelZusammensetzungForm> {
  final _formKey = GlobalKey<FormState>();
  List<MoertelZusammensetzung> _moertelList = [];
  List<Nachmahlung> _nachmahlungList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for form fields
  final TextEditingController _serieController = TextEditingController();
  final TextEditingController _bindemittelController = TextEditingController();
  final TextEditingController _bindemittelgehaltController = TextEditingController();
  final TextEditingController _wasserController = TextEditingController();
  final TextEditingController _wBmWertController = TextEditingController();
  final TextEditingController _fliessmittelController = TextEditingController();
  final TextEditingController _druckfestigkeit7dController = TextEditingController();

  int? _selectedNachmahlungId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final moertelData = await dbHelper.getMoertelZusammensetzung();
    final nachmahlungData = await dbHelper.getNachmahlung();
    setState(() {
      _moertelList = moertelData;
      _nachmahlungList = nachmahlungData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedNachmahlungId != null) {
      final moertel = MoertelZusammensetzung(
        nachmahlungId: _selectedNachmahlungId!,
        mz_serie: _serieController.text,
        mz_bindemittel: _bindemittelController.text,
        mz_bindemittelgehalt: double.parse(_bindemittelgehaltController.text),
        mz_wasser: double.parse(_wasserController.text),
        mz_wBmWert: double.parse(_wBmWertController.text),
        mz_fliessmittel: double.parse(_fliessmittelController.text),
        mz_druckfestigkeit7d: double.parse(_druckfestigkeit7dController.text),
      );

      await dbHelper.insertMoertelZusammensetzung(moertel);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mörtelzusammensetzung erfolgreich gespeichert!')),
      );
    }
  }

  void _clearForm() {
    _serieController.clear();
    _bindemittelController.clear();
    _bindemittelgehaltController.clear();
    _wasserController.clear();
    _wBmWertController.clear();
    _fliessmittelController.clear();
    _druckfestigkeit7dController.clear();
    setState(() {
      _selectedNachmahlungId = null;
    });
  }

  Future<void> _deleteMoertel(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Löschen bestätigen'),
          content: Text('Möchten Sie diese Mörtelzusammensetzung wirklich löschen?'),
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
        await dbHelper.deleteMoertelZusammensetzung(id);
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
    return Column(
      children: [
        DropdownButtonFormField<int>(
          value: _selectedNachmahlungId,
          decoration: _buildInputDecoration('Nachmahlung', Icons.engineering),
          items: _nachmahlungList.map((nachmahlung) {
            return DropdownMenuItem<int>(
              value: nachmahlung.n_id,
              child: Text(nachmahlung.n_charge),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedNachmahlungId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Bitte wählen Sie eine Nachmahlung aus';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _serieController,
          decoration: _buildInputDecoration('Serie', Icons.numbers),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie die Serie ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _bindemittelgehaltController,
          decoration: _buildInputDecoration('Bindemittelgehalt (kg/m³)', Icons.scale),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || double.tryParse(value) == null) {
              return 'Bitte geben Sie einen gültigen Bindemittelgehalt ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _wasserController,
          decoration: _buildInputDecoration('Wasser (kg/m³)', Icons.water_drop),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || double.tryParse(value) == null) {
              return 'Bitte geben Sie eine gültige Wassermenge ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _wBmWertController,
          decoration: _buildInputDecoration('w/b-Wert', Icons.calculate),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || double.tryParse(value) == null) {
              return 'Bitte geben Sie einen gültigen w/b-Wert ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _fliessmittelController,
          decoration: _buildInputDecoration('Fließmittel (M.-%)', Icons.water),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || double.tryParse(value) == null) {
              return 'Bitte geben Sie eine gültige Fließmittelmenge ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _druckfestigkeit7dController,
          decoration: _buildInputDecoration('Druckfestigkeit 7d (MPa)', Icons.fitness_center),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || double.tryParse(value) == null) {
              return 'Bitte geben Sie eine gültige Druckfestigkeit ein';
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
          DataColumn(label: Text('Serie')),
          DataColumn(label: Text('Bindemittel')),
          DataColumn(label: Text('Bindemittelgehalt\n(kg/m³)')),
          DataColumn(label: Text('Wasser\n(kg/m³)')),
          DataColumn(label: Text('w/b-Wert')),
          DataColumn(label: Text('Fließmittel\n(M.-%)')),
          DataColumn(label: Text('Druckfestigkeit\n7d (MPa)')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _moertelList.map((moertel) {

          return DataRow(
            cells: [
              DataCell(Text(moertel.mz_serie)),
              DataCell(Text(moertel.mz_bindemittel)),
              DataCell(Text(moertel.mz_bindemittelgehalt.toString())),
              DataCell(Text(moertel.mz_wasser.toString())),
              DataCell(Text(moertel.mz_wBmWert.toString())),
              DataCell(Text(moertel.mz_fliessmittel.toString())),
              DataCell(Text(moertel.mz_druckfestigkeit7d.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMoertel(moertel.mz_id ?? 0),
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
        title: Text('Mörtelzusammensetzung Formular'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildFormFields(),
                        SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.save),
                          label: Text('Speichern'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 30,
                            ),
                            textStyle: TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
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