import 'package:flutter/material.dart';

import 'package:inventario/database/proveedor_dao.dart';
import 'package:inventario/models/proveedor_model.dart';
import 'package:inventario/routes/app_routes.dart';
import 'package:inventario/widgets/search_input.dart';
import 'package:inventario/widgets/confirm_dialog.dart';

class ProveedoresListScreen extends StatefulWidget {
  const ProveedoresListScreen({super.key});

  @override
  State<ProveedoresListScreen> createState() => _ProveedoresListScreenState();
}

class _ProveedoresListScreenState extends State<ProveedoresListScreen> {
  List<Proveedor> proveedores = [];
  List<Proveedor> proveedoresFiltrados = [];
  bool cargando = true;
  String? errorCarga;

  final buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarProveedores();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarProveedores() async {
    if (mounted) {
      setState(() {
        cargando = true;
        errorCarga = null;
      });
    }

    try {
      final resultado = await ProveedorDao.listar();

      if (!mounted) return;

      setState(() {
        proveedores = resultado;
        cargando = false;
        errorCarga = null;
        proveedoresFiltrados = resultado.where((proveedor) {
          return proveedor.nombre.toLowerCase().contains(
            buscarController.text.toLowerCase(),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error cargando proveedores: $e');
      if (mounted) {
        setState(() {
          cargando = false;
          errorCarga = 'No se pudieron cargar los proveedores.';
        });
      }
    }
  }

  void filtrarProveedores(String texto) {
    setState(() {
      proveedoresFiltrados = proveedores.where((p) {
        return p.nombre.toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  Future<void> abrirFormulario({Proveedor? proveedor}) async {
    // Navegación centralizada pasando el proveedor como argumento
    final resultado = await Navigator.pushNamed(
      context,
      AppRoutes.proveedorForm,
      arguments: proveedor,
    );

    if (!mounted) return;

    if (resultado == true || resultado == null) {
      cargarProveedores();
    }
  }

  Future<void> eliminarProveedor(Proveedor proveedor) async {
    final confirmar = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar proveedor',
      mensaje: '¿Deseas eliminar a "${proveedor.nombre}"?',
    );

    if (confirmar != true) return;

    try {
      await ProveedorDao.eliminar(proveedor.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proveedor eliminado correctamente.'),
          backgroundColor: Color(0xff16A085),
        ),
      );

      await cargarProveedores();
    } catch (e) {
      if (!mounted) return;

      // Captura la regla de negocio lanzada por el DAO si tiene productos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildTarjetaProveedor(Proveedor proveedor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE9EDF5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proveedor.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xff172554),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Color(0xff64748B)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        proveedor.telefono.trim().isEmpty
                            ? 'Sin teléfono'
                            : proveedor.telefono,
                        style: const TextStyle(
                          color: Color(0xff64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Color(0xff64748B),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        proveedor.correo.trim().isEmpty
                            ? 'Sin correo'
                            : proveedor.correo,
                        style: const TextStyle(
                          color: Color(0xff64748B),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xff64748B)),
            onSelected: (valor) {
              if (valor == 'editar') {
                abrirFormulario(proveedor: proveedor);
              } else if (valor == 'eliminar') {
                eliminarProveedor(proveedor);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: Color(0xffCBD5E1),
            ),
            const SizedBox(height: 14),
            Text(
              buscarController.text.isNotEmpty
                  ? 'No se encontraron resultados'
                  : 'No hay proveedores disponibles',
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
                  : 'Agrega un proveedor para comenzar.',
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
              onPressed: cargarProveedores,
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
        title: const Text('Proveedores'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        backgroundColor: const Color(0xff16A085),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proveedor'),
      ),
      body: RefreshIndicator(
        onRefresh: cargarProveedores,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Mis proveedores',
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
                  : '${proveedores.length} proveedores registrados',
              style: const TextStyle(color: Color(0xff64748B), fontSize: 13),
            ),
            const SizedBox(height: 18),
            SearchInput(
              controller: buscarController,
              hintText: 'Buscar proveedor por nombre...',
              onChanged: filtrarProveedores,
            ),
            const SizedBox(height: 18),
            if (cargando)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorCarga != null)
              _buildErrorState()
            else if (proveedoresFiltrados.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: proveedoresFiltrados.length,
                itemBuilder: (context, index) {
                  return _buildTarjetaProveedor(proveedoresFiltrados[index]);
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
