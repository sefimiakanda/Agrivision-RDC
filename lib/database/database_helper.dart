import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/parcelle.dart';
import 'parcelle_repository.dart';

class DatabaseHelper implements ParcelleRepository {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'agrivision.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) {
      return currentDatabase;
    }

    final databasesPath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasesPath, _databaseName),
      version: _databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE parcelles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ville TEXT NOT NULL,
            nom TEXT NOT NULL,
            culture TEXT NOT NULL,
            superficie REAL NOT NULL
          )
        ''');
        await database.execute('''
          CREATE TABLE activites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            parcelle_id INTEGER NOT NULL,
            type TEXT NOT NULL,
            date TEXT NOT NULL,
            description TEXT NOT NULL,
            FOREIGN KEY (parcelle_id) REFERENCES parcelles (id) ON DELETE CASCADE
          )
        ''');
      },
    );
    _database = database;
    return database;
  }

  @override
  Future<List<Parcelle>> getParcelles() async {
    final database = await this.database;
    final rows = await database.query(
      'parcelles',
      orderBy: 'nom COLLATE NOCASE',
    );
    return rows.map(Parcelle.fromMap).toList(growable: false);
  }

  @override
  Future<Parcelle> createParcelle(Parcelle parcelle) async {
    final database = await this.database;
    final id = await database.insert(
      'parcelles',
      parcelle.toMap()..remove('id'),
    );
    return parcelle.copyWith(id: id);
  }

  @override
  Future<void> updateParcelle(Parcelle parcelle) async {
    final id = parcelle.id;
    if (id == null) {
      throw ArgumentError('Une parcelle à modifier doit avoir un identifiant.');
    }

    final database = await this.database;
    await database.update(
      'parcelles',
      parcelle.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteParcelle(int id) async {
    final database = await this.database;
    await database.delete('parcelles', where: 'id = ?', whereArgs: [id]);
  }
}
