import '../models/producto_model.dart';
import '../database/db_helper.dart';

class ProductoDao {
  static Future<int> insertar(Producto producto) async {
    final db = await DBHelper.database;
    return db.insert('productos', producto.toMap());
  }

  static Future<int> actualizar(Producto producto) async {
    final db = await DBHelper.database;
    return db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  static Future<int> eliminar(int id) async {
    final db = await DBHelper.database;
    return db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Producto>> listar() async {
    final db = await DBHelper.database;

    final rows = await db.rawQuery(
      '''
        SELECT p.id, p.nombre, p.precio, p.stock, p.proveedor_id, pr.nombre AS proveedor_nombre
        FROM productos p
        INNER JOIN proveedores pr ON p.proveedor_id = pr.id
        ORDER BY p.id DESC
      '''
    );

    return rows.map((row) => Producto.fromMap(row)).toList();
  }
}