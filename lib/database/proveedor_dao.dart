import 'package:sqflite/sqflite.dart';
import '../models/proveedor_model.dart';
import '../database/db_helper.dart';

class ProveedorDao {
  static Future<int> insertar(Proveedor proveedor) async {
    final db = await DBHelper.database;
    return db.insert('proveedores', proveedor.toMap());
  }

  static Future<int> actualizar(Proveedor proveedor) async {
    final db = await DBHelper.database;
    return db.update(
      'proveedores',
      proveedor.toMap(),
      where: 'id = ?',
      whereArgs: [proveedor.id],
    );
  }

  static Future<int> eliminar(int id) async {
    final db = await DBHelper.database;

    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM productos WHERE proveedor_id = ?', 
      [id]
    );
    final totalProductos = Sqflite.firstIntValue(resultado) ?? 0;

    if (totalProductos > 0) {
      throw Exception('No se puede eliminar el proveedor porque tiene productos asociados.');
    }

    final filasAfectadas = await db.delete(
      'proveedores',
      where: 'id = ?',
      whereArgs: [id],
    );

    return filasAfectadas;
  }

  static Future<List<Proveedor>> listar() async {
    final db = await DBHelper.database;
    final rows = await db.query('proveedores', orderBy: 'id');
    return rows.map((row) => Proveedor.fromMap(row)).toList();
  }
}
