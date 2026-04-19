import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tdd_chores/core/utils/date_time_formatter.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/save_photo.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';

class AddChorePhotoScreen extends StatefulWidget {
  final SingleChoreEntity chore;

  const AddChorePhotoScreen({super.key, required this.chore});

  @override
  State<AddChorePhotoScreen> createState() => _AddChorePhotoScreenState();
}

class _AddChorePhotoScreenState extends State<AddChorePhotoScreen> {
  final _imagePicker = ImagePicker();
  String? _selectedPhotoPath;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        _selectedPhotoPath = image.path;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to pick image: ${e.toString()}')),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhotoPath = null;
    });
  }

  Future<void> _savePhoto() async {
    if (_isSubmitting || _selectedPhotoPath == null) {
      return;
    }

    final choreId = widget.chore.id;
    if (choreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add a photo to this chore.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final choresBloc = context.read<ChoresBloc>();

    try {
      final photoUrl = await choresBloc.savePhoto(
        SavePhotoParams(choreId: choreId, photoPath: _selectedPhotoPath!),
      );

      final updatedChore = SingleChoreEntity(
        id: widget.chore.id,
        createdBy: widget.chore.createdBy,
        name: widget.chore.name,
        dateTime: widget.chore.dateTime,
        status: widget.chore.status,
        photoUrl: photoUrl,
      );

      await choresBloc.updateSingleChore(
        UpdateSingleChoreParams(chore: updatedChore),
      );

      if (!mounted) {
        return;
      }

      choresBloc.add(GetGroupChoresEvent());
      Navigator.of(context).pop(updatedChore);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save photo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSave = !_isSubmitting && _selectedPhotoPath != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo'),
        actions: [
          TextButton(
            onPressed: canSave ? _savePhoto : null,
            child: Text(
              _isSubmitting ? 'Saving...' : 'Save',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isSubmitting) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chore',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.chore.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    DateTimeFormatter.formatDateTime(widget.chore.dateTime),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a photo for this chore using the gallery or camera.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: _selectedPhotoPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_outlined,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No photo selected',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          : Image.file(
                              File(_selectedPhotoPath!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                      ),
                      if (_selectedPhotoPath != null)
                        TextButton.icon(
                          onPressed: _isSubmitting ? null : _removePhoto,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canSave ? _savePhoto : null,
            icon: Icon(
              _isSubmitting ? Icons.hourglass_top : Icons.cloud_upload,
            ),
            label: Text(_isSubmitting ? 'Saving...' : 'Save Photo'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
