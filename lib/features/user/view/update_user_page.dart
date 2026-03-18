import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:m3t_attendee/features/user/bloc/user_cubit.dart';
import 'package:m3t_attendee/features/user/view/user_avatar.dart';

final class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

final class _UpdateUserPageState extends State<UpdateUserPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _lastNameFocusNode;
  // Emits the cross-field error message, or null when cleared.
  // Only transitions when the actual error state changes — not on every
  // keystroke — so each field rebuilds at most once per state edge, not
  // once per character.
  late final ValueNotifier<String?> _nameErrorNotifier;
  late final ImagePicker _picker;

  // Flipped on the first failed save attempt. Never reset — clearing is
  // handled by _nameErrorNotifier transitioning to null automatically.
  bool _saveAttempted = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _nameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _nameErrorNotifier = ValueNotifier(null);
    _nameController.addListener(_onNameInputChanged);
    _lastNameController.addListener(_onNameInputChanged);
    _picker = ImagePicker();
  }

  // Recomputes the cross-field error on every keystroke, but only notifies
  // listeners when the message actually changes (empty <-> non-empty).
  void _onNameInputChanged() {
    if (!_saveAttempted) return;
    final bothEmpty =
        _nameController.text.trim().isEmpty &&
        _lastNameController.text.trim().isEmpty;
    final next = bothEmpty ? 'Enter a first name, last name, or both' : null;
    if (_nameErrorNotifier.value != next) _nameErrorNotifier.value = next;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameInputChanged)
      ..dispose();
    _lastNameController
      ..removeListener(_onNameInputChanged)
      ..dispose();
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _nameErrorNotifier.dispose();
    super.dispose();
  }

  // Fire-and-forget: BlocListener handles the result reactively.
  void _onSavePressed() {
    final bothEmpty =
        _nameController.text.trim().isEmpty &&
        _lastNameController.text.trim().isEmpty;
    if (bothEmpty) {
      _saveAttempted = true;
      _nameErrorNotifier.value = 'Enter a first name, last name, or both';
      return;
    }
    unawaited(
      context.read<UserCubit>().updateProfile(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
      ),
    );
  }

  void _showImageSourceBottomSheet() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: .min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(.gallery));
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImageAndUpload(.camera));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndUpload(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        if (!mounted) return;
        _showSnackBar('Could not read image. Please try again.');
        return;
      }

      final path = picked.name.toLowerCase();
      final contentType = source == .camera
          ? 'image/jpeg'
          : (path.endsWith('.png') ? 'image/png' : 'image/jpeg');

      if (!mounted) return;
      // Fire-and-forget: BlocListener handles avatar-update result.
      unawaited(
        context.read<UserCubit>().updateAvatar(
          bytes: bytes,
          contentType: contentType,
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isChannelError = e.code == 'channel-error';
      _showSnackBar(
        isChannelError
            ? 'Photo picker unavailable on emulator. '
                  'Stop app and do a full restart, or try on device.'
            : 'Could not open photo picker: ${e.message ?? e.code}',
        duration: const Duration(seconds: 5),
      );
    } on Object catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not open photo picker: $e');
    }
  }

  void _showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: .floating,
          duration: duration ?? const Duration(seconds: 4),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Profile update completed — pop on success; error is shown
        // inline by the BlocBuilder.
        BlocListener<UserCubit, UserState>(
          listenWhen: (previous, current) =>
              previous.updatingProfile && !current.updatingProfile,
          listener: (context, state) {
            if (state.errorMessage == null) {
              Navigator.of(context).pop();
            }
          },
        ),
        // Avatar upload completed — show error only (success is visual).
        BlocListener<UserCubit, UserState>(
          listenWhen: (previous, current) =>
              previous.updatingAvatar && !current.updatingAvatar,
          listener: (context, state) {
            if (state.errorMessage != null) {
              _showSnackBar(state.errorMessage!);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Update profile')),
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            final textTheme = Theme.of(context).textTheme;
            final colorScheme = Theme.of(context).colorScheme;

            return SingleChildScrollView(
              padding: const .all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      GestureDetector(
                        onTap: state.updatingAvatar
                            ? null
                            : _showImageSourceBottomSheet,
                        child: Stack(
                          alignment: .bottomRight,
                          children: [
                            UserAvatar(user: state.user, radius: 64),
                            if (state.updatingAvatar)
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    shape: .circle,
                                  ),
                                  child: Center(
                                    child: SizedBox.square(
                                      dimension: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (state.user != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.user!.email,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ValueListenableBuilder<String?>(
                        valueListenable: _nameErrorNotifier,
                        builder: (context, errorText, _) => TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: InputDecoration(
                            labelText: 'First name',
                            errorText: errorText,
                          ),
                          textCapitalization: .words,
                          textInputAction: .next,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<String?>(
                        valueListenable: _nameErrorNotifier,
                        builder: (context, errorText, _) => TextField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Last name',
                            errorText: errorText,
                          ),
                          textCapitalization: .words,
                          textInputAction: .done,
                          onSubmitted: (_) => _onSavePressed(),
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: state.updatingProfile
                            ? null
                            : _onSavePressed,
                        child: state.updatingProfile
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
