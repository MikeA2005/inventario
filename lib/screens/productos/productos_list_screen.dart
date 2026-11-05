import 'package:flutter/material.dart';

import 'package:inventario/database/producto_dao.dart';
import 'package:inventario/models/producto_model.dart';
import 'package:inventario/routes/app_routes.dart';
import 'package:inventario/widgets/search_input.dart';
import 'package:inventario/widgets/confirm_dialog.dart';

class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

class _ProductosListScreenState extends State<ProductosListScreen> {
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  bool cargando = true;
  String? errorCarga;

  final buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarProductos() async {
    if (mounted) {
      setState(() {
        cargando = true;
        errorCarga = null;
      });
    }

    try {
      final resultado = await ProductoDao.listar();

      if (!mounted) return;

      setState(() {
        productos = resultado;
        cargando = false;
        errorCarga = null;
        productosFiltrados = resultado.where((producto) {
          return producto.nombre.toLowerCase().contains(
            buscarController.text.toLowerCase(),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error cargando productos: $e');
      if (mounted) {
        setState(() {
          cargando = false;
          errorCarga = 'No se pudieron cargar los productos.';
        });
      }
    }
  }

  void filtrarProductos(String texto) {
    setState(() {
      productosFiltrados = productos.where((producto) {
        return producto.nombre.toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  Future<void> eliminarProducto(Producto producto) async {
    final confirmar = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar producto',
      mensaje: '¿Deseas eliminar "${producto.nombre}"?',
    );

    if (confirmar == true) {
      try {
        final filasBorradas = await ProductoDao.eliminar(producto.id!);

        if (!mounted) return;

        if (filasBorradas > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado con éxito.'),
              backgroundColor: Colors.green,
            ),
          );
          await cargarProductos();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> abrirFormulario({Producto? producto}) async {
    final resultado = await Navigator.pushNamed(
      context,
      AppRoutes.productoForm,
      arguments: producto,
    );

    if (!mounted) return;

    if (resultado == true || resultado == null) {
      cargarProductos();
    }
  }

  Widget _buildTarjetaProducto(Producto producto) {
    final sinStock = producto.stock <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE9EDF5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xff172554),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      producto.proveedorNombre ?? 'Sin proveedor',
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xff64748B)),
                onSelected: (valor) {
                  if (valor == 'editar') {
                    abrirFormulario(producto: producto);
                  } else if (valor == 'eliminar') {
                    eliminarProducto(producto);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Precio',
                    style: TextStyle(color: Color(0xff94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff172554),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sinStock
                      ? const Color(0xffFEF2F2)
                      : const Color(0xffECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Stock: ${producto.stock}',
                  style: TextStyle(
                    color: sinStock ? Colors.red : const Color(0xff059669),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Color(0xffCBD5E1),
            ),
            const SizedBox(height: 14),
            Text(
              buscarController.text.isNotEmpty
                  ? 'No se encontraron resultados'
                  : 'No hay productos disponibles',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xff64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              buscarController.text.isNotEmpty
                  ? 'Intenta con otro término de búsqueda.'
                  : 'Agrega un producto para comenzar.',
              style: const TextStyle(color: Color(0xff94A3B8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 14),
            Text(
              errorCarga!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff64748B),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: cargarProductos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        backgroundColor: const Color(0xff3157D5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
      body: RefreshIndicator(
        onRefresh: cargarProductos,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Tu inventario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff172554),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cargando
                  ? 'Cargando...'
                  : '${productos.length} productos registrados',
              style: const TextStyle(color: Color(0xff64748B), fontSize: 13),
            ),
            const SizedBox(height: 18),
            SearchInput(
              controller: buscarController,
              hintText: 'Buscar producto por nombre...',
              onChanged: filtrarProductos,
            ),
            const SizedBox(height: 18),
            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorCarga != null)
              _buildErrorState()
            else if (productosFiltrados.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productosFiltrados.length,
                itemBuilder: (context, index) {
                  return _buildTarjetaProducto(productosFiltrados[index]);
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
