import 'package:flutter/material.dart';

import 'package:inventario/database/producto_dao.dart';
import 'package:inventario/database/proveedor_dao.dart';
import 'package:inventario/routes/app_routes.dart';
import 'package:inventario/widgets/metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProductos = 0;
  int totalProveedores = 0;
  bool cargando = true;
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    if (mounted) {
      setState(() {
        cargando = true;
        errorCarga = null;
      });
    }

    try {
      final resultados = await Future.wait([
        ProductoDao.listar(),
        ProveedorDao.listar(),
      ]);

      if (!mounted) return;

      setState(() {
        totalProductos = resultados[0].length;
        totalProveedores = resultados[1].length;
        cargando = false;
        errorCarga = null;
      });
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      if (mounted) {
        setState(() {
          cargando = false;
          errorCarga = 'No se pudieron cargar las estadísticas.';
        });
      }
    }
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            errorCarga!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff64748B)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: cargarEstadisticas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesoRapido({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color color,
    required String ruta,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await Navigator.pushNamed(context, ruta);
        cargarEstadisticas();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffE9EDF5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icono, color: color, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      color: Color(0xff64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xff64748B),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: cargarEstadisticas,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ENCABEZADO
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xff172554),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.inventory_2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVENTARIO',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Color(0xff172554),
                        ),
                      ),
                      Text(
                        'Control de inventario',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // RESUMEN GENERAL
              const Text(
                'Resumen general',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172554),
                ),
              ),

              const SizedBox(height: 14),

              // TARJETAS MÉTRICAS
              if (errorCarga != null)
                _buildErrorState()
              else
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Productos',
                        quantity: cargando ? '...' : '$totalProductos',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Proveedores',
                        quantity: cargando ? '...' : '$totalProveedores',
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 28),

              // ACCESOS RÁPIDOS
              const Text(
                'Accesos rápidos',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172554),
                ),
              ),

              const SizedBox(height: 14),

              _buildAccesoRapido(
                titulo: 'Productos',
                descripcion: 'Consulta y administra tus artículos',
                icono: Icons.shopping_bag,
                color: const Color(0xff3157D5),
                ruta: AppRoutes.productosList,
              ),

              const SizedBox(height: 12),

              _buildAccesoRapido(
                titulo: 'Proveedores',
                descripcion: 'Administra tus proveedores',
                icono: Icons.storefront,
                color: const Color(0xff16A085),
                ruta: AppRoutes.proveedoresList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
