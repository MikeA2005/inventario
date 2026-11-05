import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database>? _database;

  static Future<Database> get database {
    return _database ??= openDatabase(
      'bdinventario.db',
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE proveedores(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT,
            correo TEXT
          )
        ''');
        await database.execute('''
          CREATE TABLE productos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            proveedor_id INTEGER NOT NULL,
            FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE RESTRICT
          );
        ''');
      },
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
}
