import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

import '../models/project_image_data.dart';

Future<void> showProjectImageViewerDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required ProjectImageData image,
}) {
  if (image.bytes == null) {
    return Future<void>.value();
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.84),
    builder: (_) => _ProjectImageViewerDialog(
      title: title,
      subtitle: subtitle,
      image: image,
    ),
  );
}

class _ProjectImageViewerDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final ProjectImageData image;

  const _ProjectImageViewerDialog({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  State<_ProjectImageViewerDialog> createState() =>
      _ProjectImageViewerDialogState();
}

class _ProjectImageViewerDialogState extends State<_ProjectImageViewerDialog> {
  bool _isDownloading = false;
  bool _isCopying = false;

  @override
  Widget build(BuildContext context) {
    final imageBytes = widget.image.bytes;
    if (imageBytes == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedHeight = constraints.maxHeight.clamp(320.0, 760.0);

          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: constraints.maxWidth.clamp(280.0, 760.0),
              height: resolvedHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF261F25).withValues(alpha: 0.94),
                    const Color(0xFF151216).withValues(alpha: 0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.32),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFF8F3F7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Center(
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isDownloading ? null : _downloadImage,
                            icon: _isDownloading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded, size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isDownloading ? 'Baixando...' : 'Download',
                                maxLines: 1,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isCopying ? null : _copyImage,
                            icon: _isCopying
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.content_copy_rounded,
                                    size: 18,
                                  ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isCopying ? 'Copiando...' : 'Copiar',
                                maxLines: 1,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFDF6EB8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadImage() async {
    final imageBytes = widget.image.bytes;
    if (imageBytes == null || _isDownloading) {
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final pngBytes = await _convertImageToPng(imageBytes);
      final fileName = _imageFileName();

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar imagem',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['png'],
        bytes: pngBytes,
      );

      if (!mounted) {
        return;
      }

      if (kIsWeb || savedPath != null) {
        _showMessage('Imagem pronta para download.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Não foi possível baixar a imagem.');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _copyImage() async {
    final imageBytes = widget.image.bytes;
    if (imageBytes == null || _isCopying) {
      return;
    }

    setState(() {
      _isCopying = true;
    });

    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        throw StateError('Clipboard indisponível');
      }

      final pngBytes = await _convertImageToPng(imageBytes);
      final item = DataWriterItem(suggestedName: _imageFileName());
      item.add(Formats.png(pngBytes));
      await clipboard.write([item]);

      if (!mounted) {
        return;
      }

      _showMessage('Imagem copiada para a área de transferência.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Não foi possível copiar a imagem.');
    } finally {
      if (mounted) {
        setState(() {
          _isCopying = false;
        });
      }
    }
  }

  Future<Uint8List> _convertImageToPng(Uint8List sourceBytes) async {
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    codec.dispose();

    if (data == null) {
      throw StateError('Falha ao converter imagem.');
    }

    return data.buffer.asUint8List();
  }

  String _imageFileName() {
    final title = _sanitizeFileName(widget.title);
    final subtitle = _sanitizeFileName(widget.subtitle);
    final suffix = subtitle.isEmpty ? 'imagem' : subtitle;
    return '$title-$suffix.png';
  }

  String _sanitizeFileName(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]+'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();

    return sanitized;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
