import 'package:flutter/material.dart';

import 'package:inventario/database/proveedor_dao.dart';
import 'package:inventario/models/proveedor_model.dart';
import 'package:inventario/widgets/custom_text_field.dart';

class ProveedorFormScreen extends StatefulWidget {
  final Proveedor? proveedor;

  const ProveedorFormScreen({super.key, this.proveedor});

  @override
  State<ProveedorFormScreen> createState() => _ProveedorFormScreenState();
}

class _ProveedorFormScreenState extends State<ProveedorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  bool _guardando = false;

  bool get _esEdicion => widget.proveedor != null;

  @override
  void initState() {
    super.initState();

    if (_esEdicion) {
      _nombreController.text = widget.proveedor!.nombre;
      _telefonoController.text = widget.proveedor!.telefono;
      _correoController.text = widget.proveedor!.correo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _guardarProveedor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final proveedor = Proveedor(
      id: widget.proveedor?.id,
      nombre: _nombreController.text.trim(),
      telefono: _telefonoController.text.trim(),
      correo: _correoController.text.trim(),
    );

    try {
      if (_esEdicion) {
        await ProveedorDao.actualizar(proveedor);
      } else {
        await ProveedorDao.insertar(proveedor);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Proveedor actualizado correctamente.'
                : 'Proveedor registrado correctamente.',
          ),
          backgroundColor: const Color(0xff16A085),
        ),
      );

      // Devuelve true para indicar al listado que refresque los datos
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar el proveedor: $e'),
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
        title: Text(_esEdicion ? 'Editar proveedor' : 'Nuevo proveedor'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del proveedor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172554),
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Nombre del proveedor',
                controller: _nombreController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del proveedor';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'Teléfono',
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 7) {
                    return 'Ingresa un teléfono válido (mínimo 7 dígitos)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              CustomTextField(
                label: 'Correo electrónico',
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                    return 'Ingresa un formato de correo válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardarProveedor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff16A085),
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
                              ? 'Actualizar proveedor'
                              : 'Guardar proveedor'),
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
}
