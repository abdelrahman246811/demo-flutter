import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class BetonZusammensetzungForm extends StatefulWidget {
  @override
  _BetonZusammensetzungFormState createState() => _BetonZusammensetzungFormState();
}

class _BetonZusammensetzungFormState extends State<BetonZusammensetzungForm> {
  final _formKey = GlobalKey<FormState>();
  List<BetonZusammensetzung> _betonList = [];
  List<MoertelZusammensetzung> _moertelList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for form fields
  final TextEditingController _serieController = TextEditingController();
  final TextEditingController _bindemittelController = TextEditingController();
  final TextEditingController _bindemittelgehaltController = TextEditingController();
  final TextEditingController _wasserController = TextEditingController();
  final TextEditingController _wBmWertController = TextEditingController();
  final TextEditingController _fliessmittelController = TextEditingController();
  final TextEditingController _sieblinieController = TextEditingController();
  final TextEditingController _druckfestigkeitController = TextEditingController();

  int? _selectedMoertelZusammensetzungId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final betonData = await dbHelper.getBetonZusammensetzung();
    final moertelData = await dbHelper.getMoertelZusammensetzung();
    setState(() {
      _betonList = betonData;
      _moertelList = moertelData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedMoertelZusammensetzungId != null) {
      final beton = BetonZusammensetzung(
        moertelZusammensetzungId: _selectedMoertelZusammensetzungId!,
        b_serie: _serieController.text,
        b_bindemittel: _bindemittelController.text,
        b_bindemittelgehalt: double.parse(_bindemittelgehaltController.text),
        b_wasser: double.parse(_wasserController.text),
        b_wBmWert: double.parse(_wBmWertController.text),
        b_fliessmittel: double.parse(_fliessmittelController.text),
        b_sieblinie: _sieblinieController.text,
        b_druckfestigkeit: double.parse(_druckfestigkeitController.text),
      );

      await dbHelper.insertBetonZusammensetzung(beton);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Betonzusammensetzung erfolgreich gespeichert!')),
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
    _sieblinieController.clear();
    _druckfestigkeitController.clear();
    setState(() {
      _selectedMoertelZusammensetzungId = null;
    });
  }

  Future<void> _deleteBeton(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Löschen bestätigen'),
          content: Text('Möchten Sie diese Betonzusammensetzung wirklich löschen?'),
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
        await dbHelper.deleteBetonZusammensetzung(id);
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
          value: _selectedMoertelZusammensetzungId,
          decoration: _buildInputDecoration('Mörtelzusammensetzung', Icons.engineering),
          items: _moertelList.map((moertel) {
            return DropdownMenuItem<int>(
              value: moertel.mz_id,
              child: Text('${moertel.mz_bindemittel}-${moertel.mz_serie}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMoertelZusammensetzungId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Bitte wählen Sie eine Mörtelzusammensetzung aus';
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
          controller: _sieblinieController,
          decoration: _buildInputDecoration('Sieblinie', Icons.layers_outlined),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie die Sieblinie ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _druckfestigkeitController,
          decoration: _buildInputDecoration('Druckfestigkeit (MPa)', Icons.fitness_center),
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
          DataColumn(label: Text('Sieblinie')),
          DataColumn(label: Text('Druckfestigkeit\n(MPa)')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _betonList.map((beton) {
          return DataRow(
            cells: [
              DataCell(Text(beton.b_serie)),
              DataCell(Text(beton.b_bindemittel)),
              DataCell(Text(beton.b_bindemittelgehalt.toString())),
              DataCell(Text(beton.b_wasser.toString())),
              DataCell(Text(beton.b_wBmWert.toString())),
              DataCell(Text(beton.b_fliessmittel.toString())),
              DataCell(Text(beton.b_sieblinie)),
              DataCell(Text(beton.b_druckfestigkeit.toString())),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBeton(beton.b_id ?? 0),
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
        title: Text('Betonzusammensetzung Formular'),
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