import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:inventario/database/db_helper.dart';
import 'package:inventario/database/proveedor_dao.dart';
import 'package:inventario/database/producto_dao.dart';
import 'package:inventario/models/proveedor_model.dart';
import 'package:inventario/models/producto_model.dart';

void main() {
  // Inicializa FFI para ejecutar SQLite en el entorno local (Linux/macOS/Windows)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    // Inicializa la base de datos antes de las pruebas
    await DBHelper.database;
  });

  group('Pruebas de Base de Datos Local (SQLite)', () {
    test('Ciclo completo: CRUD, INNER JOIN e Integridad Referencial', () async {
      // 1. Insertar Proveedor
      final idProveedor = await ProveedorDao.insertar(
        Proveedor(
          nombre: 'Proveedor Test S.A.S.',
          telefono: '3001234567',
          correo: 'contacto@proveedortest.com',
        ),
      );
      expect(
        idProveedor,
        greaterThan(0),
        reason: 'El ID del proveedor debe ser positivo.',
      );

      // 2. Insertar Producto asociado
      final idProducto = await ProductoDao.insertar(
        Producto(
          nombre: 'Producto A',
          precio: 25000.0,
          stock: 15,
          proveedorId: idProveedor,
        ),
      );
      expect(
        idProducto,
        greaterThan(0),
        reason: 'El ID del producto debe ser positivo.',
      );

      // 3. Probar consulta con INNER JOIN
      final productos = await ProductoDao.listar();
      expect(productos, isNotEmpty);

      final productoGuardado = productos.firstWhere((p) => p.id == idProducto);
      expect(productoGuardado.nombre, equals('Producto A'));
      expect(productoGuardado.proveedorId, equals(idProveedor));
      expect(
        productoGuardado.proveedorNombre,
        equals('Proveedor Test S.A.S.'),
        reason: 'El INNER JOIN debe mapear el nombre del proveedor correspondiente.',
      );

      // 4. Probar actualización
      final productoModificado = Producto(
        id: idProducto,
        nombre: 'Producto A Actualizado',
        precio: 30000.0,
        stock: 20,
        proveedorId: idProveedor,
      );
      final filasActualizadas = await ProductoDao.actualizar(
        productoModificado,
      );
      expect(filasActualizadas, equals(1));

      // 5. Validar Integridad Referencial (Debe fallar al borrar proveedor con productos)
      expect(
        () async => await ProveedorDao.eliminar(idProveedor),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'mensaje',
            contains(
              'No se puede eliminar el proveedor porque tiene productos asociados.',
            ),
          ),
        ),
        reason: 'Debe lanzar excepción si el proveedor aún tiene productos vinculados.',
      );

      // 6. Eliminar producto primero (desvinculación)
      final filasProdEliminado = await ProductoDao.eliminar(idProducto);
      expect(filasProdEliminado, equals(1));

      // 7. Eliminar proveedor tras liberar dependencias
      final filasProvEliminado = await ProveedorDao.eliminar(idProveedor);
      expect(filasProvEliminado, equals(1));
    });
  });
}
