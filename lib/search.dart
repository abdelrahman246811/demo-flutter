import 'dart:async';
import 'package:flutter/material.dart';
import 'package:application_demo/database_helper.dart';
import 'package:application_demo/scima.dart';

class SearchForm extends StatefulWidget {
  @override
  _SearchFormState createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // All possible tables
  final List<String> _allTables = [
    'Steinbruch', 'Vormahlung', 'Ofen',
    'MaterialEigenschaften', 'Nachmahlung',
    'MoertelZusammensetzung', 'BetonZusammensetzung'
  ];

  // Table metadata with all fields
  final Map<String, List<SearchField>> _tableFields = {
    'Steinbruch': [
      SearchField('s_name', 'Name', TextInputType.text),
      SearchField('s_menge', 'Menge', TextInputType.number),
      SearchField('s_korngroesse', 'Korngröße', TextInputType.number),
      SearchField('s_asbest_analyse', 'Asbest Analyse', TextInputType.text),
      SearchField('s_dichte', 'Dichte', TextInputType.number),
      SearchField('s_transport', 'Transport', TextInputType.text),
    ],
    'Vormahlung': [
      SearchField('v_charge', 'Charge', TextInputType.text),
      SearchField('v_erledigt', 'Erledigt', TextInputType.number),
      SearchField('v_muehle_typ', 'Mühletype', TextInputType.text),
      SearchField('v_mahl_dauer', 'Mahldauer', TextInputType.number),
      SearchField('v_grad', 'Grad', TextInputType.text),
      SearchField('v_dichte', 'Dichte', TextInputType.number),
      SearchField('v_feinheit', 'Feinheit', TextInputType.number),
    ],
    'Ofen': [
      SearchField('o_charge', 'Charge', TextInputType.text),
      SearchField('o_info', 'Info', TextInputType.text),
      SearchField('o_durchsatz', 'Durchsatz', TextInputType.number),
      SearchField('o_neigung', 'Neigung', TextInputType.number),
      SearchField('o_rotation', 'Rotation', TextInputType.number),
      SearchField('o_heiztemperatur', 'Heiztemperatur', TextInputType.number),
      SearchField('o_luftvolumen', 'Luftvolumen', TextInputType.number),
      SearchField('o_faesser', 'Fässer', TextInputType.number),
      SearchField('o_gluehverlust', 'Glühverlust', TextInputType.number),
    ],
    'MaterialEigenschaften': [
      SearchField('me_charge', 'Charge', TextInputType.text),
      SearchField('me_dichte', 'Dichte', TextInputType.number),
      SearchField('me_feinheit', 'Feinheit', TextInputType.number),
      SearchField('me_dca', 'DCA', TextInputType.number),
      SearchField('me_xrd', 'XRD', TextInputType.text),
    ],
    'Nachmahlung': [
      SearchField('n_charge', 'Charge', TextInputType.text),
      SearchField('n_erledigt', 'Erledigt', TextInputType.number),
      SearchField('n_muehle_typ', 'Mühletype', TextInputType.text),
      SearchField('n_mahl_dauer', 'Mahldauer', TextInputType.number),
      SearchField('n_grad', 'Grad', TextInputType.text),
      SearchField('n_dichte', 'Dichte', TextInputType.number),
      SearchField('n_feinheit', 'Feinheit', TextInputType.number),
      SearchField('n_gluehverlust', 'Glühverlust', TextInputType.number),
      SearchField('n_dca', 'DCA', TextInputType.number),
      SearchField('n_xrd', 'XRD', TextInputType.text),
    ],
    'MoertelZusammensetzung': [
      SearchField('mz_serie', 'Serie', TextInputType.text),
      SearchField('mz_bindemittel', 'Bindemittel', TextInputType.text),
      SearchField('mz_bindemittelgehalt', 'Bindemittelgehalt', TextInputType.number),
      SearchField('mz_wasser', 'Wasser', TextInputType.number),
      SearchField('mz_w_bm_wert', 'W/B-Wert', TextInputType.number),
      SearchField('mz_fliessmittel', 'Fließmittel', TextInputType.number),
      SearchField('mz_druckfestigkeit_7d', 'Druckfestigkeit 7d', TextInputType.number),
    ],
    'BetonZusammensetzung': [
      SearchField('b_serie', 'Serie', TextInputType.text),
      SearchField('b_bindemittel', 'Bindemittel', TextInputType.text),
      SearchField('b_bindemittelgehalt', 'Bindemittelgehalt', TextInputType.number),
      SearchField('b_wasser', 'Wasser', TextInputType.number),
      SearchField('b_w_bm_wert', 'W/B-Wert', TextInputType.number),
      SearchField('b_fliessmittel', 'Fließmittel', TextInputType.number),
      SearchField('b_sieblinie', 'Sieblinie', TextInputType.text),
      SearchField('b_druckfestigkeit', 'Druckfestigkeit', TextInputType.number),
    ],
  };

  List<String> _selectedTables = [];
  Map<String, List<SearchField>> _allSearchFields = {};
  Map<String, bool> _selectedFields = {};
  Map<String, TextEditingController> _fieldControllers = {};
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _initializeSearchFields();
  }

  void _initializeSearchFields() {
    // Combine all fields from all tables
    _selectedTables = List.from(_allTables);
    _allSearchFields.clear();
    _selectedFields.clear();
    _fieldControllers.clear();

    // Combine fields from all tables
    _allTables.forEach((table) {
      _tableFields[table]?.forEach((field) {
        if (!_allSearchFields.containsKey(field.name)) {
          _allSearchFields[field.name] = [];
        }
        _allSearchFields[field.name]!.add(field);

        // Initialize selection and controller for each field
        _selectedFields[field.name] = false;
        _fieldControllers[field.name] = TextEditingController();
      });
    });
  }

Future<void> _performCrossTableSearch() async {
  List<String> searchColumns = [];
  List<dynamic> searchValues = [];

  // Collect selected search criteria
  _selectedFields.forEach((fieldName, isSelected) {
    if (isSelected && _fieldControllers[fieldName]!.text.isNotEmpty) {
      searchColumns.add(fieldName);
      dynamic value = _fieldControllers[fieldName]!.text;

      // Convert number strings to proper numeric types
if (_tableFields.values
    .expand((fields) => fields)
    .firstWhere((field) => field.name == fieldName)
    .inputType == TextInputType.number) {
  final parsedValue = double.tryParse(value);
  if (parsedValue != null) {
    value = parsedValue;  // only update if parsing succeeded
  }
}

      searchValues.add(value);
    }
  });

  if (searchColumns.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bitte mindestens ein Suchkriterium auswählen')),
    );
    return;
  }

  try {
    final results = await dbHelper.getJoinedData(
      // searchColumns,
      // searchValues,
    );

    setState(() {
      _searchResults = results;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler bei der Suche: $e')),
    );
  }
}

// Update the _buildResultTable method to handle the joined results:
Widget _buildResultTable() {
  if (_searchResults.isEmpty) {
    return Center(child: Text('Keine Ergebnisse gefunden'));
  }

  // Get all possible columns from the results
  Set<String> allColumns = {};
  for (var result in _searchResults) {
    allColumns.addAll(result.keys);
  }

  // Filter out null values and sort columns
  List<String> displayColumns = allColumns
    .where((col) => _searchResults.any((result) => result[col] != null))
    .toList()
    ..sort();

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: displayColumns.map((col) => DataColumn(
        label: Text(_getDisplayLabel(col)),
      )).toList(),
      rows: _searchResults.map((result) {
        return DataRow(
          cells: displayColumns.map((col) => DataCell(
            Text(result[col]?.toString() ?? 'N/A')
          )).toList(),
        );
      }).toList(),
    ),
  );
}

String _getDisplayLabel(String columnName) {
  // Find the display label from _tableFields
  for (var table in _tableFields.values) {
    for (var field in table) {
      if (field.name == columnName) {
        return field.label;
      }
    }
  }
  return columnName;
}

  Widget _buildSearchFieldsGroupedByTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _tableFields.entries.map((entry) {
        final tableName = entry.key;
        final fields = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                tableName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ...fields.map((field) {
                return Row(
                  children: [
                    Checkbox(
                      value: _selectedFields[field.name],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedFields[field.name] = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _fieldControllers[field.name],
                        keyboardType: field.inputType,
                        decoration: InputDecoration(
                          labelText: field.label,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget _buildResultTable() {
  //   if (_searchResults.isEmpty) {
  //     return Center(child: Text('Keine Ergebnisse gefunden'));
  //   }

  //   // Dynamically create columns based on the first result
  //   final displayedColumns = _selectedFields.entries
  //     .where((entry) => entry.value)
  //     .map((entry) => entry.key)
  //     .toList();

  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: DataTable(
  //       columns: [
  //         ...displayedColumns.map((col) =>
  //           DataColumn(label: Text(col))
  //         ).toList(),
  //       ],
  //       rows: _searchResults.map((result) {
  //         return DataRow(
  //           cells: [
  //             ...displayedColumns.map((col) =>
  //               DataCell(Text(result[col]?.toString() ?? 'N/A'))
  //             ).toList(),
  //           ],
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datenbank Suche'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Optional: Table selection multi-select
              Wrap(
                spacing: 8.0,
                children: _allTables.map((table) {
                  return FilterChip(
                    label: Text(table),
                    selected: _selectedTables.contains(table),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTables.add(table);
                        } else {
                          _selectedTables.remove(table);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              _buildSearchFieldsGroupedByTable(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _performCrossTableSearch,
                child: Text('Suchen'),
              ),
              SizedBox(height: 16),
              _buildResultTable(),
            ],
          ),
        ),
      ),
    );
  }
}