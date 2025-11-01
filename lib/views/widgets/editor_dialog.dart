import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodels/gif_viewmodel.dart';

class EditorDialog extends StatelessWidget {
  final GifViewModel gifViewModel;

  const EditorDialog({
    super.key,
    required this.gifViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editor de GIFs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Escolha uma opção:'),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Tirar Foto'),
            onTap: () {
              Navigator.of(context).pop();
              _takePhoto(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Escolher da Galeria'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImageFromGallery(context);
            },
          ),
          if (gifViewModel.currentGif?.url != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar GIF Atual'),
              onTap: () {
                Navigator.of(context).pop();
                _editCurrentGif(context);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _processImage(context, File(image.path));
      }
    } catch (e) {
      _showSnackBar(context, 'Erro ao tirar foto: $e');
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _processImage(context, File(image.path));
      }
    } catch (e) {
      _showSnackBar(context, 'Erro ao escolher imagem: $e');
    }
  }

  Future<void> _processImage(BuildContext context, File imageFile) async {
    try {
      _showSnackBar(context, 'Processando imagem...');
      
      // Simulate image processing
      await Future.delayed(const Duration(seconds: 2));
      _showSnackBar(context, 'Imagem processada! (Funcionalidade em desenvolvimento)');
      
      // Add points for using editor
      gifViewModel.addEditorPoints();
    } catch (e) {
      _showSnackBar(context, 'Erro ao processar imagem: $e');
    }
  }

  void _editCurrentGif(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar GIF Atual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Funcionalidades de edição:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Adicionar Texto'),
              onTap: () {
                Navigator.of(context).pop();
                _addTextToGif(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop),
              title: const Text('Cortar GIF'),
              onTap: () {
                Navigator.of(context).pop();
                _cropGif(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Ajustar Velocidade'),
              onTap: () {
                Navigator.of(context).pop();
                _adjustSpeed(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _addTextToGif(BuildContext context) {
    _showSnackBar(context, 'Adicionar texto: Em desenvolvimento');
    gifViewModel.addEditPoints();
  }

  void _cropGif(BuildContext context) {
    _showSnackBar(context, 'Cortar GIF: Em desenvolvimento');
    gifViewModel.addEditPoints();
  }

  void _adjustSpeed(BuildContext context) {
    _showSnackBar(context, 'Ajustar velocidade: Em desenvolvimento');
    gifViewModel.addEditPoints();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
