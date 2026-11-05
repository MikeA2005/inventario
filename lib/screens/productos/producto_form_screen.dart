import 'package:flutter/material.dart';

import 'package:inventario/database/producto_dao.dart';
import 'package:inventario/database/proveedor_dao.dart';
import 'package:inventario/models/producto_model.dart';
import 'package:inventario/models/proveedor_model.dart';
import 'package:inventario/widgets/custom_text_field.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();

  List<Proveedor> _proveedores = [];
  int? _proveedorSeleccionado;

  bool _cargando = true;
  bool _guardando = false;
  String? _errorCarga;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();

    if (_esEdicion) {
      _nombreController.text = widget.producto!.nombre;
      _precioController.text = widget.producto!.precio.toString();
      _stockController.text = widget.producto!.stock.toString();
      _proveedorSeleccionado = widget.producto!.proveedorId;
    }

    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _errorCarga = null;
      });
    }

    try {
      final resultado = await ProveedorDao.listar();

      if (!mounted) return;

      setState(() {
        _proveedores = resultado;
        _cargando = false;
        _errorCarga = null;
      });
    } catch (e) {
      debugPrint('Error cargando proveedores: $e');
      if (mounted) {
        setState(() {
          _cargando = false;
          _errorCarga = 'No se pudieron cargar los proveedores.';
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    // Normalizar comas por puntos en precios decimales
    final precioLimpio = _precioController.text.trim().replaceAll(',', '.');

    final producto = Producto(
      id: widget.producto?.id,
      nombre: _nombreController.text.trim(),
      precio: double.parse(precioLimpio),
      stock: int.parse(_stockController.text.trim()),
      proveedorId: _proveedorSeleccionado!,
    );

    try {
      if (_esEdicion) {
        await ProductoDao.actualizar(producto);
      } else {
        await ProductoDao.insertar(producto);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Producto actualizado correctamente.'
                : 'Producto registrado correctamente.',
          ),
          backgroundColor: const Color(0xff16A085),
        ),
      );

      // Devuelve true para notificar que hubo cambios a la pantalla de listado
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _errorCarga != null
          ? _buildErrorState()
          : _proveedores.isEmpty
          ? _buildSinProveedoresState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff172554),
                      ),
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Nombre del producto',
                      controller: _nombreController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el nombre del producto';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Precio unitario',
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final precio = double.tryParse(
                          (value ?? '').replaceAll(',', '.').trim(),
                        );

                        if (precio == null || precio <= 0) {
                          return 'Ingresa un precio mayor a 0';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Cantidad en stock',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final stock = int.tryParse((value ?? '').trim());

                        if (stock == null || stock < 0) {
                          return 'Ingresa una cantidad válida (>= 0)';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Proveedor asociado',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff172554),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DROPDOWN ESTILIZADO
                    DropdownButtonFormField<int>(
                      initialValue:
                          _proveedores.any(
                            (p) => p.id == _proveedorSeleccionado,
                          )
                          ? _proveedorSeleccionado
                          : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xffE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xffE2E8F0),
                          ),
                        ),
                        hintText: 'Selecciona un proveedor',
                        hintStyle: const TextStyle(
                          color: Color(0xff94A3B8),
                          fontSize: 14,
                        ),
                      ),
                      items: _proveedores.map((proveedor) {
                        return DropdownMenuItem<int>(
                          value: proveedor.id,
                          child: Text(
                            proveedor.nombre,
                            style: const TextStyle(
                              color: Color(0xff1E293B),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _proveedorSeleccionado = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Debes seleccionar un proveedor';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // BOTONES DE ACCIÓN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardarProducto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3157D5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(_esEdicion ? Icons.save : Icons.add),
                        label: Text(
                          _guardando
                              ? 'Guardando...'
                              : (_esEdicion
                                    ? 'Actualizar producto'
                                    : 'Guardar producto'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff64748B),
                          side: const BorderSide(color: Color(0xffE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorCarga!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff64748B)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _cargarProveedores,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinProveedoresState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 65,
              color: Color(0xff94A3B8),
            ),
            const SizedBox(height: 15),
            const Text(
              'No hay proveedores registrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff172554),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Primero debes registrar un proveedor para poder asociarlo al producto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3157D5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
