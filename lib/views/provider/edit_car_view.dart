import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_colors.dart';
import '../../models/car.dart';

class EditCarView extends StatefulWidget {
  final Car car;

  const EditCarView({required this.car, Key? key}) : super(key: key);

  @override
  State<EditCarView> createState() => _EditCarViewState();
}

class _EditCarViewState extends State<EditCarView>
    with SingleTickerProviderStateMixin {
  late TextEditingController makeCtrl;
  late TextEditingController modelCtrl;
  late TextEditingController plateCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController colorCtrl;
  late TextEditingController mileageCtrl;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    makeCtrl = TextEditingController(text: widget.car.make);
    modelCtrl = TextEditingController(text: widget.car.model);
    plateCtrl = TextEditingController(text: widget.car.plate_number);
    rateCtrl = TextEditingController(text: widget.car.daily_rate.toString());
    colorCtrl = TextEditingController(text: widget.car.color);
    mileageCtrl = TextEditingController(text: widget.car.mileage_km.toString());
  }

  Future<void> updateCar() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("cars")
        .doc(widget.car.id)
        .update({
          "make": makeCtrl.text.trim(),
          "model": modelCtrl.text.trim(),
          "plate_number": plateCtrl.text.trim(),
          "daily_rate": double.parse(rateCtrl.text.trim()),
          "color": colorCtrl.text.trim(),
          "mileage_km": mileageCtrl.text.trim(),
        });

    setState(() => loading = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("Edit Car"), elevation: 0),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // HERO IMAGE
            Hero(
              tag: widget.car.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  widget.car.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _field("Make", makeCtrl),
            _field("Model", modelCtrl),
            _field("Plate Number", plateCtrl),
            _field("Color", colorCtrl),
            _field("Daily Rate", rateCtrl, type: TextInputType.number),
            _field("Mileage (km)", mileageCtrl, type: TextInputType.number),

            const SizedBox(height: 30),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sunYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }
}
