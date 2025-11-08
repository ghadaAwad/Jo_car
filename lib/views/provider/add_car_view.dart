import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/app_colors.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../models/car.dart'; // ✅ موديل السيارة

class AddCarView extends StatefulWidget {
  const AddCarView({super.key});

  @override
  State<AddCarView> createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final _formKey = GlobalKey<FormState>();

  //  Controllers
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

  File? _selectedImage;

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
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
              // ===== Upload Image Card =====
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
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 25),

              // ===== All Input Fields =====
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
                Icons.confirmation_number_outlined,
              ),
              _buildInput(_colorController, 'Color', Icons.color_lens),
              _buildInput(
                _transmissionController,
                'Transmission Type',
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
                Icons.speed_outlined,
                type: TextInputType.number,
              ),
              _buildInput(
                _rateController,
                'Daily Rate (\$)',
                Icons.attach_money,
                type: TextInputType.number,
              ),
              _buildInput(
                _statusController,
                'Status (Available / Rented)',
                Icons.info_outline,
              ),

              const SizedBox(height: 30),

              // ===== Add Button =====
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  // ===== TextField Builder =====
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.sunYellow, width: 2),
          ),
        ),
      ),
    );
  }

  // ===== When Add Car Pressed =====
  void _onAddCar() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a car image')),
      );
      return;
    }

    final newCar = Car(
      provider_id: 1, // 🔸 مؤقتًا (ممكن تاخده من AuthProvider)
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      plate_number: _plateController.text.trim(),
      color: _colorController.text.trim(),
      imageUrl: _selectedImage!.path,
      transmission: _transmissionController.text.trim(),
      fuel_type: _fuelTypeController.text.trim(),
      seats: int.parse(_seatsController.text.trim()),
      doors: int.parse(_doorsController.text.trim()),
      mileage_km: int.parse(_mileageController.text.trim()),
      status: _statusController.text.trim(),
      daily_rate: int.parse(_rateController.text.trim()),
      created_at: DateTime.now(),
    );

    // 🔸 عرض رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.sunYellow,
        content: Text(
          '🚗 ${newCar.make} ${newCar.model} added successfully!',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );

    // 🔸 رجوع للصفحة الرئيسية
    context.go('/home');
  }
}
