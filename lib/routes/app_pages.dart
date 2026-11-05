import 'package:flutter/material.dart';

import 'app_routes.dart';

// Screens
import 'package:inventario/screens/dashboard_screen.dart';
import 'package:inventario/screens/proveedores/proveedores_list_screen.dart';
import 'package:inventario/screens/proveedores/proveedor_form_screen.dart';
import 'package:inventario/screens/productos/productos_list_screen.dart';
import 'package:inventario/screens/productos/producto_form_screen.dart';

// Models
import 'package:inventario/models/proveedor_model.dart';
import 'package:inventario/models/producto_model.dart';

class AppPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      // Proveedores
      case AppRoutes.proveedoresList:
        return MaterialPageRoute(builder: (_) => const ProveedoresListScreen());
      case AppRoutes.proveedorForm:
        final proveedor = settings.arguments as Proveedor?;
        return MaterialPageRoute(
          builder: (_) => ProveedorFormScreen(proveedor: proveedor),
        );

      // Productos
      case AppRoutes.productosList:
        return MaterialPageRoute(builder: (_) => const ProductosListScreen());
      case AppRoutes.productoForm:
        final producto = settings.arguments as Producto?;
        return MaterialPageRoute(
          builder: (_) => ProductoFormScreen(producto: producto),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
