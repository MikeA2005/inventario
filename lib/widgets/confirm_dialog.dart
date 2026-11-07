import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(mensaje, style: const TextStyle(fontSize: 16)),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, minimumSize: const Size(100, 40)),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(100, 40)),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        );
      },
    );
    debugPrint('Resultado del diálogo: $resultado');
    return resultado ?? false;
  }
}
