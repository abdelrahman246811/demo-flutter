import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class NachmahlungForm extends StatefulWidget {
  @override
  _NachmahlungFormState createState() => _NachmahlungFormState();
}

class _NachmahlungFormState extends State<NachmahlungForm> {
  final _formKey = GlobalKey<FormState>();
  List<Nachmahlung> _nachmahlungList = [];
  List<MaterialEigenschaften> _materialEigenschaftenList = [];
  final dbHelper = DatabaseHelper();

  // Controllers for each input field
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _muehleTypController = TextEditingController();
  final TextEditingController _mahlDauerController = TextEditingController();
  final TextEditingController _gradController = TextEditingController();
  final TextEditingController _dichteController = TextEditingController();
  final TextEditingController _feinheitController = TextEditingController();
  final TextEditingController _gluehverlustController = TextEditingController();
  final TextEditingController _dcaController = TextEditingController();
  final TextEditingController _xrdController = TextEditingController();

  int? _selectedMaterialEigenschaftenId;
  bool _isErledigt = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nachmahlungData = await dbHelper.getNachmahlung();
    final materialEigenschaftenData = await dbHelper.getMaterialEigenschaften();
    setState(() {
      _nachmahlungList = nachmahlungData;
      _materialEigenschaftenList = materialEigenschaftenData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedMaterialEigenschaftenId != null) {
      final nachmahlung = Nachmahlung(
        materialEigenschaftenId: _selectedMaterialEigenschaftenId!,
        n_charge: _chargeController.text,
        n_erledigt: _isErledigt,
        n_muehleTyp: _isErledigt ? _muehleTypController.text : '',
        n_mahlDauer: _isErledigt
            ? (double.tryParse(_mahlDauerController.text) ?? 0.0)
            : 0.0,
        n_grad: _isErledigt ? _gradController.text : '',
        n_dichte: _isErledigt
            ? (double.tryParse(_dichteController.text) ?? 0.0)
            : 0.0,
        n_feinheit: _isErledigt
            ? (double.tryParse(_feinheitController.text) ?? 0.0)
            : 0.0,
        n_gluehverlust: _isErledigt
            ? (double.tryParse(_gluehverlustController.text) ?? 0.0)
            : 0.0,
        n_dca: _isErledigt ? (double.tryParse(_dcaController.text) ?? 0.0) : 0.0,
        n_xrd: _isErledigt ? _xrdController.text : '',
      );

      await dbHelper.insertNachmahlung(nachmahlung);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );
    }
  }

  void _clearForm() {
    _chargeController.clear();
    _muehleTypController.clear();
    _mahlDauerController.clear();
    _gradController.clear();
    _dichteController.clear();
    _feinheitController.clear();
    _gluehverlustController.clear();
    _dcaController.clear();
    _xrdController.clear();
    setState(() {
      _selectedMaterialEigenschaftenId = null;
      _isErledigt = true;
    });
  }

  Future<void> _deleteNachmahlung(int id) async {
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
        await dbHelper.deleteNachmahlung(id);
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
      return Container();
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
        SizedBox(height: 15),
        TextFormField(
          controller: _gluehverlustController,
          decoration:
              _buildInputDecoration('Glühverlust', Icons.local_fire_department),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isErledigt &&
                (value == null || double.tryParse(value) == null)) {
              return 'Bitte geben Sie einen gültigen Wert für den Glühverlust ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _dcaController,
          decoration: _buildInputDecoration('DCA', Icons.science),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isErledigt &&
                (value == null || double.tryParse(value) == null)) {
              return 'Bitte geben Sie einen gültigen Wert für DCA ein';
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _xrdController,
          decoration: _buildInputDecoration('XRD', Icons.dashboard),
          validator: (value) {
            if (_isErledigt && (value == null || value.isEmpty)) {
              return 'Bitte geben Sie den XRD-Wert ein';
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
          DataColumn(label: Text('Charge')),
          DataColumn(label: Text('Erledigt')),
          DataColumn(label: Text('Mühle Typ')),
          DataColumn(label: Text('Mahldauer (h)')),
          DataColumn(label: Text('Grad')),
          DataColumn(label: Text('Dichte (g/cm³)')),
          DataColumn(label: Text('Feinheit (cm²/g)')),
          DataColumn(label: Text('Glühverlust')),
          DataColumn(label: Text('DCA')),
          DataColumn(label: Text('XRD')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _nachmahlungList.map((nachmahlung) {

          return DataRow(
            cells: [
              DataCell(Text(nachmahlung.n_charge)),
              DataCell(Text(nachmahlung.n_erledigt ? 'Ja' : 'Nein')),
              DataCell(Text(nachmahlung.n_muehleTyp)),
              DataCell(Text(nachmahlung.n_mahlDauer.toString())),
              DataCell(Text(nachmahlung.n_grad)),
              DataCell(Text(nachmahlung.n_dichte.toString())),
              DataCell(Text(nachmahlung.n_feinheit.toString())),
              DataCell(Text(nachmahlung.n_gluehverlust.toString())),
              DataCell(Text(nachmahlung.n_dca.toString())),
              DataCell(Text(nachmahlung.n_xrd)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteNachmahlung(nachmahlung.n_id ?? 0),
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
        title: Text('Nachmahlung Formular'),
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
                          value: _selectedMaterialEigenschaftenId,
                          decoration: _buildInputDecoration(
                              'Material', Icons.inventory_2),
                          items: _materialEigenschaftenList.map((material) {
                            return DropdownMenuItem<int>(
                              value: material.me_id,
                              child: Text(material.me_charge),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMaterialEigenschaftenId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Bitte wählen Sie ein Material aus';
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
