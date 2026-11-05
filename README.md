# Inventario

Aplicación móvil Flutter para administrar productos y proveedores de un pequeño
negocio. La información se almacena localmente en SQLite y permanece
disponible después de cerrar y volver a abrir la aplicación.

## Requisitos

- Flutter instalado y configurado.
- Dart incluido con Flutter.
- Un dispositivo Android, emulador o plataforma de escritorio compatible.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

Para seleccionar un dispositivo específico:

```bash
flutter devices
flutter run -d <device-id>
```

## Funcionalidades

- Dashboard con total de productos y proveedores.
- CRUD completo de proveedores.
- CRUD completo de productos.
- Búsqueda por nombre.
- Validación de nombre, precio, stock y correo electrónico.
- Asociación de cada producto con un proveedor existente.
- Mensajes de éxito, error, confirmación y estados vacíos.
- Persistencia local sin Firebase ni servicios en la nube.

## Estructura del proyecto

```text
lib/
├── database/     Acceso SQLite y objetos DAO
├── models/       Modelos de Producto y Proveedor
├── routes/       Rutas y navegación
├── screens/      Dashboard, listados y formularios
└── widgets/      Componentes visuales reutilizables
```

## Base de datos

La base de datos local se crea como `bdinventario.db`. Las claves foráneas se
activan al abrir la conexión mediante:

```sql
PRAGMA foreign_keys = ON;
```

### Tabla `proveedores`

| Campo | Tipo | Restricción |
|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT |
| `nombre` | TEXT | NOT NULL |
| `telefono` | TEXT | Opcional |
| `correo` | TEXT | Opcional |

### Tabla `productos`

| Campo | Tipo | Restricción |
|---|---|---|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT |
| `nombre` | TEXT | NOT NULL |
| `precio` | REAL | NOT NULL |
| `stock` | INTEGER | NOT NULL |
| `proveedor_id` | INTEGER | NOT NULL, FOREIGN KEY |

La relación es de uno a muchos: un proveedor puede suministrar varios
productos. Un proveedor no puede eliminarse mientras tenga productos
asociados; primero deben eliminarse o reasignarse esos productos.

Los productos se consultan junto con el nombre de su proveedor mediante:

```sql
SELECT p.id, p.nombre, p.precio, p.stock, p.proveedor_id,
       pr.nombre AS proveedor_nombre
FROM productos p
INNER JOIN proveedores pr ON p.proveedor_id = pr.id
ORDER BY p.id DESC;
```

## Flujo de demostración

Para la presentación o el video, se recomienda seguir este orden:

1. Abrir el dashboard y mostrar los contadores.
2. Registrar un proveedor con nombre, teléfono y correo.
3. Editar el proveedor y verificar el cambio en el listado.
4. Registrar un producto con precio, stock y el proveedor creado.
5. Consultar el listado de productos y mostrar el proveedor asociado.
6. Buscar el producto por nombre.
7. Editar el producto y verificar el precio o stock actualizado.
8. Intentar eliminar el proveedor mientras el producto está asociado y mostrar
   el mensaje de protección de integridad referencial.
9. Eliminar el producto y después eliminar el proveedor.
10. Cerrar y abrir la aplicación para comprobar la persistencia local.

## Pruebas

Ejecutar el análisis estático y las pruebas de SQLite con:

```bash
flutter analyze
flutter test
```

La prueba de base de datos comprueba inserción, consulta con `INNER JOIN`,
actualización, eliminación y la restricción de proveedores con productos.
