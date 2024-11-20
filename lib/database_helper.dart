import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:application_demo/scima.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await databaseFactory.setDatabasesPath(await getDatabasesPath());

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Steinbruch (
              s_id INTEGER PRIMARY KEY AUTOINCREMENT,
              s_name TEXT,
              s_menge REAL,
              s_korngroesse REAL,
              s_asbest_analyse TEXT,
              s_dichte REAL,
              s_transport TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE Vormahlung (
              v_id INTEGER PRIMARY KEY AUTOINCREMENT,
              steinbruch_id INTEGER,
              v_charge TEXT,
              v_erledigt INTEGER,
              v_muehle_typ TEXT,
              v_mahl_dauer REAL,
              v_grad TEXT,
              v_dichte REAL,
              v_feinheit REAL,
              FOREIGN KEY (steinbruch_id) REFERENCES Steinbruch(id)
          );
        ''');
        await db.execute('''
          CREATE TABLE Ofen (
              o_id INTEGER PRIMARY KEY AUTOINCREMENT,
              vormahlung_id INTEGER,
              o_charge TEXT,
              o_info TEXT,
              o_durchsatz REAL,
              o_neigung REAL,
              o_rotation REAL,
              o_heiztemperatur REAL,
              o_luftvolumen REAL,
              o_faesser INTEGER,
              o_gluehverlust REAL,
              FOREIGN KEY (vormahlung_id) REFERENCES Vormahlung(id)
          );
        ''');
        await db.execute('''
          CREATE TABLE MaterialEigenschaften (
              me_id INTEGER PRIMARY KEY AUTOINCREMENT,
              ofen_id INTEGER,
              me_charge TEXT,
              me_dichte REAL,
              me_feinheit REAL,
              me_dca REAL,
              me_xrd TEXT,
              FOREIGN KEY (ofen_id) REFERENCES Ofen(id)
          );
        ''');
        await db.execute('''
          CREATE TABLE Nachmahlung (
              n_id INTEGER PRIMARY KEY AUTOINCREMENT,
              material_eigenschaften_id INTEGER,
              n_charge TEXT,
              n_erledigt INTEGER,
              n_muehle_typ TEXT,
              n_mahl_dauer REAL,
              n_grad TEXT,
              n_dichte REAL,
              n_feinheit REAL,
              n_gluehverlust REAL,
              n_dca REAL,
              n_xrd TEXT,
              FOREIGN KEY (material_eigenschaften_id) REFERENCES MaterialEigenschaften(id)
          );
        ''');
        await db.execute('''
          CREATE TABLE MoertelZusammensetzung (
              mz_id INTEGER PRIMARY KEY AUTOINCREMENT,
              nachmahlung_id INTEGER,
              mz_serie TEXT,
              mz_bindemittel TEXT,
              mz_bindemittelgehalt REAL,
              mz_wasser REAL,
              mz_w_bm_wert REAL,
              mz_fliessmittel REAL,
              mz_druckfestigkeit_7d REAL,
              FOREIGN KEY (nachmahlung_id) REFERENCES nachmahlung(id)
          );
        ''');
        await db.execute('''
          CREATE TABLE BetonZusammensetzung (
              b_id INTEGER PRIMARY KEY AUTOINCREMENT,
              moertel_zusammensetzung_id INTEGER,
              b_serie TEXT,
              b_bindemittel TEXT,
              b_bindemittelgehalt REAL,
              b_wasser REAL,
              b_w_bm_wert REAL,
              b_fliessmittel REAL,
              b_sieblinie TEXT,
              b_druckfestigkeit REAL,
              FOREIGN KEY (moertel_zusammensetzung_id) REFERENCES MoertelZusammensetzung(id)
          );
        ''');
      },
    );
  }

  Future<int> insertSteinbruch(Steinbruch steinbruch) async {
    final db = await database;
    return await db.insert('steinbruch', steinbruch.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Steinbruch>> getSteinbruch() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('steinbruch');
    return List.generate(maps.length, (i) {
      return Steinbruch(
        s_id: maps[i]['s_id'] as int,
        s_name: maps[i]['s_name'] as String,
        s_menge: maps[i]['s_menge'] as double,
        s_korngroesse: maps[i]['s_korngroesse'] as double,
        s_asbestAnalyse: maps[i]['s_asbest_analyse'] as String,
        s_dichte: maps[i]['s_dichte'] as double,
        s_transport: maps[i]['s_transport'] as String,
      );
    });
  }

  Future<void> deleteSteinbruch(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'steinbruch',
      // Use a `where` clause to delete a specific dog.
      where: 's_id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<int> insertVormahlung(Vormahlung vormahlung) async {
    final db = await database;

    // First insert the Vormahlung record
    final id = await db.insert('vormahlung', vormahlung.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Get the related Steinbruch record
    final steinbruch = await db.query('steinbruch',
        where: 's_id = ?', whereArgs: [vormahlung.steinbruchId], limit: 1);

    if (steinbruch.isNotEmpty) {
      // Create the charge string: steinbruchName-V{vormahlungId}
      final charge = '${steinbruch.first['s_name']}-V$id';

      // Update the Vormahlung record with the charge
      await db.update('vormahlung', {'v_charge': charge},
          where: 'v_id = ?', whereArgs: [id]);
    }

    return id;
  }

  Future<List<Vormahlung>> getVormahlung() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vormahlung');
    return List.generate(maps.length, (i) {
      return Vormahlung(
        v_id: maps[i]['v_id'] as int,
        steinbruchId: maps[i]['steinbruch_id'] as int,
        v_charge: maps[i]['v_charge'] as String,
        v_erledigt: (maps[i]['v_erledigt'] as int) == 1,
        v_muehleTyp: maps[i]['v_muehle_typ'] as String,
        v_mahlDauer: maps[i]['v_mahl_dauer'] as double,
        v_grad: maps[i]['v_grad'] as String,
        v_dichte: maps[i]['v_dichte'] as double,
        v_feinheit: maps[i]['v_feinheit'] as double,
      );
    });
  }

  Future<void> deleteVormahlung(int id) async {
    final db = await database;
    await db.delete(
      'vormahlung',
      where: 'v_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertOfen(Ofen ofen) async {
    final db = await database;

    // First insert the Ofen record
    final id = await db.insert('ofen', ofen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Get the related Vormahlung record
    final vormahlung = await db.query('vormahlung',
        where: 'v_id = ?', whereArgs: [ofen.vormahlungId], limit: 1);

    if (vormahlung.isNotEmpty) {
      // Create the charge string: vormahlungCharge-O{ofenId}
      final charge = '${vormahlung.first['v_charge']}-O$id';

      // Update the Ofen record with the charge
      await db.update('ofen', {'o_charge': charge},
          where: 'o_id = ?', whereArgs: [id]);
    }

    return id;
  }

  Future<List<Ofen>> getOfen() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ofen');
    return List.generate(maps.length, (i) {
      return Ofen(
        o_id: maps[i]['o_id'] as int,
        vormahlungId: maps[i]['vormahlung_id'] as int,
        o_charge: maps[i]['o_charge'] as String,
        o_info: maps[i]['o_info'] as String,
        o_durchsatz: maps[i]['o_durchsatz'] as double,
        o_neigung: maps[i]['o_neigung'] as double,
        o_rotation: maps[i]['o_rotation'] as double,
        o_heiztemperatur: maps[i]['o_heiztemperatur'] as double,
        o_luftvolumen: maps[i]['o_luftvolumen'] as double,
        o_faesser: maps[i]['o_faesser'] as int,
        o_gluehverlust: maps[i]['o_gluehverlust'] as double,
      );
    });
  }

  Future<void> deleteOfen(int id) async {
    final db = await database;
    await db.delete(
      'ofen',
      where: 'o_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertMaterialEigenschaften(
      MaterialEigenschaften material) async {
    final db = await database;

    // First insert the MaterialEigenschaften record
    final id = await db.insert('MaterialEigenschaften', material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Get the related Ofen record
    final ofen = await db.query('ofen',
        where: 'o_id = ?', whereArgs: [material.ofenId], limit: 1);

    if (ofen.isNotEmpty) {
      // Create the charge string: ofenCharge-ME{materialId}
      final charge = '${ofen.first['o_charge']}-ME$id';

      // Update the MaterialEigenschaften record with the charge
      await db.update('MaterialEigenschaften', {'me_charge': charge},
          where: 'me_id = ?', whereArgs: [id]);
    }

    return id;
  }

  Future<List<MaterialEigenschaften>> getMaterialEigenschaften() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('MaterialEigenschaften');
    return List.generate(maps.length, (i) {
      return MaterialEigenschaften(
        me_id: maps[i]['me_id'] as int,
        ofenId: maps[i]['ofen_id'] as int,
        me_charge: maps[i]['me_charge'] as String,
        me_dichte: maps[i]['me_dichte'] as double,
        me_feinheit: maps[i]['me_feinheit'] as double,
        me_dca: maps[i]['me_dca'] as double,
        me_xrd: maps[i]['me_xrd'] as String,
      );
    });
  }

  Future<void> deleteMaterialEigenschaften(int id) async {
    final db = await database;
    await db.delete(
      'MaterialEigenschaften',
      where: 'me_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertNachmahlung(Nachmahlung nachmahlung) async {
    final db = await database;

    // First insert the Nachmahlung record
    final id = await db.insert(
        'nachmahlung',
        {
          'material_eigenschaften_id': nachmahlung.materialEigenschaftenId,
          'n_charge': nachmahlung.n_charge,
          'n_erledigt': nachmahlung.n_erledigt ? 1 : 0,
          'n_muehle_typ': nachmahlung.n_muehleTyp,
          'n_mahl_dauer': nachmahlung.n_mahlDauer,
          'n_grad': nachmahlung.n_grad,
          'n_dichte': nachmahlung.n_dichte,
          'n_feinheit': nachmahlung.n_feinheit,
          'n_gluehverlust': nachmahlung.n_gluehverlust,
          'n_dca': nachmahlung.n_dca,
          'n_xrd': nachmahlung.n_xrd,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Get the related MaterialEigenschaften record
    final material = await db.query('MaterialEigenschaften',
        where: 'me_id = ?',
        whereArgs: [nachmahlung.materialEigenschaftenId],
        limit: 1);

    if (material.isNotEmpty) {
      // Create the charge string: materialName-N{nachmählungId}
      final charge = '${material.first['me_charge']}-N$id';

      // Update the Nachmahlung record with the charge
      await db.update('nachmahlung', {'n_charge': charge},
          where: 'n_id = ?', whereArgs: [id]);
    }

    return id;
  }

  Future<List<Nachmahlung>> getNachmahlung() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('nachmahlung');
    return List.generate(maps.length, (i) {
      return Nachmahlung(
        n_id: maps[i]['n_id'] as int,
        materialEigenschaftenId: maps[i]['material_eigenschaften_id'] as int,
        n_charge: maps[i]['n_charge'] as String,
        n_erledigt: (maps[i]['n_erledigt'] as int) == 1,
        n_muehleTyp: maps[i]['n_muehle_typ'] as String,
        n_mahlDauer: maps[i]['n_mahl_dauer'] as double,
        n_grad: maps[i]['n_grad'] as String,
        n_dichte: maps[i]['n_dichte'] as double,
        n_feinheit: maps[i]['n_feinheit'] as double,
        n_gluehverlust: maps[i]['n_gluehverlust'] as double,
        n_dca: maps[i]['n_dca'] as double,
        n_xrd: maps[i]['n_xrd'] as String,
      );
    });
  }

  Future<void> deleteNachmahlung(int id) async {
    final db = await database;
    await db.delete(
      'nachmahlung',
      where: 'n_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertMoertelZusammensetzung(
      MoertelZusammensetzung moertelZusammensetzung) async {
    final db = await database;

    // First insert the MoertelZusammensetzung record
    final id = await db.insert(
        'MoertelZusammensetzung', moertelZusammensetzung.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // Get the related Nachmahlung record
    final nachmahlung = await db.query('nachmahlung',
        where: 'n_id = ?',
        whereArgs: [moertelZusammensetzung.nachmahlungId],
        limit: 1);

    if (nachmahlung.isNotEmpty) {
      // Create the bindemittel string: nachmählungCharge-MS{moertelZusammensetzungSerie}
      final bindemittel = '${nachmahlung.first['n_charge']}';

      // Update the MoertelZusammensetzung record with the serie
      await db.update('MoertelZusammensetzung', {'mz_bindemittel': bindemittel},
          where: 'mz_id = ?', whereArgs: [id]);
    }

    return id;
  }

  Future<List<MoertelZusammensetzung>> getMoertelZusammensetzung() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('MoertelZusammensetzung');
    return List.generate(maps.length, (i) {
      return MoertelZusammensetzung(
        mz_id: maps[i]['mz_id'] as int,
        nachmahlungId: maps[i]['nachmahlung_id'] as int,
        mz_serie: maps[i]['mz_serie'] as String,
        mz_bindemittel: maps[i]['mz_bindemittel'] as String,
        mz_bindemittelgehalt: maps[i]['mz_bindemittelgehalt'] as double,
        mz_wasser: maps[i]['mz_wasser'] as double,
        mz_wBmWert: maps[i]['mz_w_bm_wert'] as double,
        mz_fliessmittel: maps[i]['mz_fliessmittel'] as double,
        mz_druckfestigkeit7d: maps[i]['mz_druckfestigkeit_7d'] as double,
      );
    });
  }

  Future<void> deleteMoertelZusammensetzung(int id) async {
    final db = await database;
    await db.delete(
      'MoertelZusammensetzung',
      where: 'mz_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertBetonZusammensetzung(BetonZusammensetzung betonZusammensetzung) async {
  final db = await database;

  // Insert the BetonZusammensetzung record
  final id = await db.insert(
    'BetonZusammensetzung',
    betonZusammensetzung.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace
  );

  // Get the related MoertelZusammensetzung record
  final moertelZusammensetzung = await db.query(
    'MoertelZusammensetzung',
    where: 'mz_id = ?',
    whereArgs: [betonZusammensetzung.moertelZusammensetzungId],
    limit: 1
  );

  if (moertelZusammensetzung.isNotEmpty) {
    // Update any related fields if needed
    final bindemittel = '${moertelZusammensetzung.first['mz_bindemittel']}-${moertelZusammensetzung.first['mz_serie']}';
    await db.update(
      'BetonZusammensetzung',
      {'b_bindemittel': bindemittel},
      where: 'b_id = ?',
      whereArgs: [id]
    );
  }

  return id;
}

Future<List<BetonZusammensetzung>> getBetonZusammensetzung() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('BetonZusammensetzung');

  return List.generate(maps.length, (i) {
    return BetonZusammensetzung(
      b_id: maps[i]['b_id'] as int,
      moertelZusammensetzungId: maps[i]['moertel_zusammensetzung_id'] as int,
      b_serie: maps[i]['b_serie'] as String,
      b_bindemittel: maps[i]['b_bindemittel'] as String,
      b_bindemittelgehalt: maps[i]['b_bindemittelgehalt'] as double,
      b_wasser: maps[i]['b_wasser'] as double,
      b_wBmWert: maps[i]['b_w_bm_wert'] as double,
      b_fliessmittel: maps[i]['b_fliessmittel'] as double,
      b_sieblinie: maps[i]['b_sieblinie'] as String,
      b_druckfestigkeit: maps[i]['b_druckfestigkeit'] as double,
    );
  });
}

Future<void> deleteBetonZusammensetzung(int id) async {
  final db = await database;
  await db.delete(
    'BetonZusammensetzung',
    where: 'b_id = ?',
    whereArgs: [id],
  );
}

Future<List<Map<String, dynamic>>> getJoinedData() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT
        s.s_id, s.s_name, s.s_menge, s.s_korngroesse, s.s_asbest_analyse, s.s_dichte, s.s_transport,
        v.v_id, v.v_charge, v.v_erledigt, v.v_muehle_typ, v.v_mahl_dauer, v.v_grad, v.v_dichte, v.v_feinheit,
        o.o_id, o.o_charge, o.o_info, o.o_durchsatz, o.o_neigung, o.o_rotation, o.o_heiztemperatur, o.o_luftvolumen, o.o_faesser, o.o_gluehverlust,
        me.me_id, me.me_charge, me.me_dichte, me.me_feinheit, me.me_dca, me.me_xrd,
        n.n_id, n.n_charge, n.n_erledigt, n.n_muehle_typ, n.n_mahl_dauer, n.n_grad, n.n_dichte, n.n_feinheit, n.n_gluehverlust, n.n_dca, n.n_xrd,
        mz.mz_id, mz.mz_serie, mz.mz_bindemittel, mz.mz_bindemittelgehalt, mz.mz_wasser, mz.mz_w_bm_wert, mz.mz_fliessmittel, mz.mz_druckfestigkeit_7d,
        b.b_id, b.b_serie, b.b_bindemittel, b.b_bindemittelgehalt, b.b_wasser, b.b_w_bm_wert, b.b_fliessmittel, b.b_sieblinie, b.b_druckfestigkeit
    FROM Steinbruch s
    LEFT JOIN Vormahlung v ON s.s_id = v.steinbruch_id
    LEFT JOIN Ofen o ON v.v_id = o.vormahlung_id
    LEFT JOIN MaterialEigenschaften me ON o.o_id = me.ofen_id
    LEFT JOIN Nachmahlung n ON me.me_id = n.material_eigenschaften_id
    LEFT JOIN MoertelZusammensetzung mz ON n.n_id = mz.nachmahlung_id
    LEFT JOIN BetonZusammensetzung b ON mz.mz_id = b.moertel_zusammensetzung_id;
  ''');
}

Future<List<Map<String, dynamic>>> searchJoinedData({
  required List<String> searchColumns,
  required List<dynamic> searchValues
}) async {
  final db = await database;

  if (searchColumns.length != searchValues.length) {
    throw ArgumentError('Search columns and values must have equal length');
  }

  final where = searchColumns.map((column) => '$column = ?').join(' AND ');
  return await db.rawQuery('''
    SELECT
        s.s_id, s.s_name, s.s_menge, s.s_korngroesse, s.s_asbest_analyse, s.s_dichte, s.s_transport,
        v.v_id, v.v_charge, v.v_erledigt, v.v_muehle_typ, v.v_mahl_dauer, v.v_grad, v.v_dichte, v.v_feinheit,
        o.o_id, o.o_charge, o.o_info, o.o_durchsatz, o.o_neigung, o.o_rotation, o.o_heiztemperatur, o.o_luftvolumen, o.o_faesser, o.o_gluehverlust,
        me.me_id, me.me_charge, me.me_dichte, me.me_feinheit, me.me_dca, me.me_xrd,
        n.n_id, n.n_charge, n.n_erledigt, n.n_muehle_typ, n.n_mahl_dauer, n.n_grad, n.n_dichte, n.n_feinheit, n.n_gluehverlust, n.n_dca, n.n_xrd,
        mz.mz_id, mz.mz_serie, mz.mz_bindemittel, mz.mz_bindemittelgehalt, mz.mz_wasser, mz.mz_w_bm_wert, mz.mz_fliessmittel, mz.mz_druckfestigkeit_7d,
        b.b_id, b.b_serie, b.b_bindemittel, b.b_bindemittelgehalt, b.b_wasser, b.b_w_bm_wert, b.b_fliessmittel, b.b_sieblinie, b.b_druckfestigkeit
    FROM Steinbruch s
    LEFT JOIN Vormahlung v ON s.s_id = v.steinbruch_id
    LEFT JOIN Ofen o ON v.v_id = o.vormahlung_id
    LEFT JOIN MaterialEigenschaften me ON o.o_id = me.ofen_id
    LEFT JOIN Nachmahlung n ON me.me_id = n.material_eigenschaften_id
    LEFT JOIN MoertelZusammensetzung mz ON n.n_id = mz.nachmahlung_id
    LEFT JOIN BetonZusammensetzung b ON mz.mz_id = b.moertel_zusammensetzung_id
    WHERE $where;
  ''', searchValues);
}

}
