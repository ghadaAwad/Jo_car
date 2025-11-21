import 'dart:io' show File;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/car_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/car_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddCarView extends StatefulWidget {
  const AddCarView({super.key});

  @override
  State<AddCarView> createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final _formKey = GlobalKey<FormState>();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _transmissionController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _seatsController = TextEditingController();
  final _doorsController = TextEditingController();
  final _mileageController = TextEditingController();
  final _rateController = TextEditingController();
  final _statusController = TextEditingController();

  final carService = CarService();

  XFile? _selectedImage;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Add New Car',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.sunYellow, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 50,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to Upload Car Image',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                ),
              ),
              const SizedBox(height: 25),

              _buildInput(_makeController, 'Make (Brand)', Icons.local_offer),
              _buildInput(_modelController, 'Model', Icons.directions_car),
              _buildInput(
                _yearController,
                'Year',
                Icons.calendar_month,
                type: TextInputType.number,
              ),
              _buildInput(
                _plateController,
                'Plate Number',
                Icons.confirmation_number,
              ),
              _buildInput(_colorController, 'Color', Icons.color_lens),
              _buildInput(
                _transmissionController,
                'Transmission',
                Icons.settings,
              ),
              _buildInput(
                _fuelTypeController,
                'Fuel Type',
                Icons.local_gas_station,
              ),
              _buildInput(
                _seatsController,
                'Seats',
                Icons.event_seat,
                type: TextInputType.number,
              ),
              _buildInput(
                _doorsController,
                'Doors',
                Icons.door_front_door,
                type: TextInputType.number,
              ),
              _buildInput(
                _mileageController,
                'Mileage (km)',
                Icons.speed,
                type: TextInputType.number,
              ),
              _buildInput(
                _rateController,
                'Daily Rate (\$)',
                Icons.attach_money_outlined,
                type: TextInputType.number,
              ),
              _buildInput(
                _statusController,
                'Status',
                Icons.info_outline_rounded,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _onAddCar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sunYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add Car',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _onAddCar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload an image')));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Get provider name
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final providerName = userDoc.data()?['name'] ?? 'Unknown';

    await carService.addCar(
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      plateNumber: _plateController.text.trim(),
      color: _colorController.text.trim(),
      transmission: _transmissionController.text.trim(),
      fuelType: _fuelTypeController.text.trim(),
      seats: int.parse(_seatsController.text.trim()),
      doors: int.parse(_doorsController.text.trim()),
      mileageKm: int.parse(_mileageController.text.trim()),
      status: _statusController.text.trim(),
      dailyRate: double.parse(_rateController.text.trim()),
      providerId: uid,
      providerName: providerName,
      imageBytes: _imageBytes!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Car Added Successfully!"),
          backgroundColor: AppColors.sunYellow,
        ),
      );
      context.go('/home');
    }
  }
}
