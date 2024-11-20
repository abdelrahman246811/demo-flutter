import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class MaterialEigenschaftenForm extends StatefulWidget {
  @override
  _MaterialEigenschaftenFormState createState() => _MaterialEigenschaftenFormState();
}

class _MaterialEigenschaftenFormState extends State<MaterialEigenschaftenForm> {
  final _formKey = GlobalKey<FormState>();
  List<MaterialEigenschaften> _materialList = [];
  List<Ofen> _ofenList = [];
  final dbHelper = DatabaseHelper();

  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _dichteController = TextEditingController();
  final TextEditingController _feinheitController = TextEditingController();
  final TextEditingController _dcaController = TextEditingController();
  final TextEditingController _xrdController = TextEditingController();

  int? _selectedOfenId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final materialData = await dbHelper.getMaterialEigenschaften();
    final ofenData = await dbHelper.getOfen();
    setState(() {
      _materialList = materialData;
      _ofenList = ofenData;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedOfenId != null) {
      final material = MaterialEigenschaften(
        ofenId: _selectedOfenId!,
        me_charge: _chargeController.text,
        me_dichte: double.tryParse(_dichteController.text) ?? 0.0,
        me_feinheit: double.tryParse(_feinheitController.text) ?? 0.0,
        me_dca: double.tryParse(_dcaController.text) ?? 0.0,
        me_xrd: _xrdController.text,
      );

      await dbHelper.insertMaterialEigenschaften(material);
      await _loadData();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daten erfolgreich gespeichert!')),
      );
    }
  }

  void _clearForm() {
    _dichteController.clear();
    _feinheitController.clear();
    _dcaController.clear();
    _xrdController.clear();
    setState(() {
      _selectedOfenId = null;
    });
  }

  Future<void> _deleteMaterialEigenschaften(int id) async {
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
        await dbHelper.deleteMaterialEigenschaften(id);
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

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Charge')),
          DataColumn(label: Text('Dichte')),
          DataColumn(label: Text('Feinheit')),
          DataColumn(label: Text('DCA')),
          DataColumn(label: Text('XRD')),
          DataColumn(label: Text('Aktionen')),
        ],
        rows: _materialList.map((material) {
          return DataRow(
            cells: [
              DataCell(Text(material.me_charge)),
              DataCell(Text(material.me_dichte.toString())),
              DataCell(Text(material.me_feinheit.toString())),
              DataCell(Text(material.me_dca.toString())),
              DataCell(Text(material.me_xrd)),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMaterialEigenschaften(material.me_id ?? 0),
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
        title: Text('Material Eigenschaften Formular'),
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
                        DropdownButtonFormField<int>(
                          value: _selectedOfenId,
                          decoration: InputDecoration(
                            labelText: 'Ofen Charge',
                            border: OutlineInputBorder(),
                          ),
                          items: _ofenList.map((ofen) {
                            return DropdownMenuItem<int>(
                              value: ofen.o_id,
                              child: Text(ofen.o_charge),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOfenId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Bitte wählen Sie eine Ofen Charge aus';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _dichteController,
                          decoration: InputDecoration(
                            labelText: 'Dichte',
                            border: OutlineInputBorder(),
                          ),
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
                          controller: _feinheitController,
                          decoration: InputDecoration(
                            labelText: 'Feinheit',
                            border: OutlineInputBorder(),
                          ),
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
                          controller: _dcaController,
                          decoration: InputDecoration(
                            labelText: 'DCA',
                            border: OutlineInputBorder(),
                          ),
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
                          controller: _xrdController,
                          decoration: InputDecoration(
                            labelText: 'XRD',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie XRD Daten ein';
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
                  SizedBox(height: 30),
                  Text(
                    'Material Eigenschaften',
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