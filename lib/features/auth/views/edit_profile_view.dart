import 'dart:typed_data';
import 'dart:io' show File; // Mobile فقط
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/config/app_colors.dart';
import '../providers/auth_provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  bool _saving = false;
  double _uploadProgress = 0;

  File? _imageFileMobile;
  Uint8List? _imageBytesWeb;

  late AnimationController _animController;
  late Animation<double> _imageScale;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user ?? {};

    _name.text = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    _phone.text = user['phone'] ?? '';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _imageScale = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user ?? {};
    final photoUrl = (user['photoUrl'] ?? '')?.toString();

    ImageProvider? imageProvider;

    if (_imageFileMobile != null) {
      imageProvider = FileImage(_imageFileMobile!);
    } else if (_imageBytesWeb != null) {
      imageProvider = MemoryImage(_imageBytesWeb!);
    } else if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      imageProvider = NetworkImage(photoUrl);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ScaleTransition(
                scale: _imageScale,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: imageProvider,
                        backgroundColor: Colors.grey.shade300,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.sunYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_uploadProgress > 0 && _uploadProgress < 1)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    color: AppColors.sunYellow,
                    backgroundColor: Colors.black12,
                  ),
                ),

              const SizedBox(height: 25),

              _field(
                label: 'Full Name',
                controller: _name,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              _field(
                label: 'Phone',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sunYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    if (kIsWeb) {
      _imageBytesWeb = await picked.readAsBytes();
    } else {
      _imageFileMobile = File(picked.path);
    }

    _animController.forward(from: 0);
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _uploadProgress = 0;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = FirebaseFirestore.instance.collection('users').doc(uid);

    final fullName = _name.text.trim();
    final parts = fullName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    await doc.update({
      'firstName': firstName,
      'lastName': lastName,
      'phone': _phone.text.trim(),
    });

    // رفع الصورة
    if (_imageBytesWeb != null || _imageFileMobile != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/$uid/profile.jpg',
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(_imageBytesWeb!);
      } else {
        uploadTask = ref.putFile(_imageFileMobile!);
      }

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      await doc.set({'photoUrl': url}, SetOptions(merge: true));
    }

    final snap = await doc.get();
    auth.updateUser(snap.data() ?? {});

    setState(() {
      _saving = false;
      _uploadProgress = 0;
    });

    if (mounted) Navigator.pop(context);
  }
}
