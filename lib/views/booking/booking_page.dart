import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_colors.dart';
import '../../models/car.dart';
import '../../models/booking.dart';
import '../../features/auth/providers/booking_provider.dart';
import 'booking_success_page.dart';
import '../../views/map_picker_page.dart';
import '../../views/payment_webview.dart';

class BookingPage extends StatefulWidget {
  final Car car;

  const BookingPage({super.key, required this.car});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  int _days = 1;
  String _paymentMethod = 'cash';

  double _lat = 0;
  double _lng = 0;

  DateTime? _startDate;

  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailCtrl.text = user?.email ?? '';
    _nameCtrl.text = user?.displayName ?? '';

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  double get _totalPrice => widget.car.daily_rate * _days;

  Future<bool> _isCarBooked(DateTime start, DateTime end) async {
    final snap = await FirebaseFirestore.instance
        .collection("bookings")
        .where("carId", isEqualTo: widget.car.id)
        .get();

    for (var doc in snap.docs) {
      final data = doc.data();
      final bookedStart =
          DateTime.tryParse(data["startDate"] ?? "") ?? DateTime.now();
      final bookedEnd = bookedStart.add(Duration(days: data["days"] ?? 1));

      final overlap = start.isBefore(bookedEnd) && end.isAfter(bookedStart);

      if (overlap) return true;
    }

    return false;
  }

  // 🔥 SUBMIT BOOKING
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select start date')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      return;
    }

    final start = _startDate!;
    final end = start.add(Duration(days: _days));

    final isBooked = await _isCarBooked(start, end);
    if (isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Car is already booked in this date range"),
        ),
      );
      return;
    }

    final booking = Booking(
      userId: user.uid,
      providerId: widget.car.provider_id,
      carId: widget.car.id,
      userName: _nameCtrl.text.trim(),
      userEmail: _emailCtrl.text.trim(),
      userPhone: _phoneCtrl.text.trim(),
      latitude: _lat,
      longitude: _lng,
      startDate: start,
      days: _days,
      dailyRate: widget.car.daily_rate,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
      carImageUrl: widget.car.imageUrl,
      carMake: widget.car.make,
      carModel: widget.car.model,
      status: 'pending',
    );

    final bookingProvider = context.read<BookingProvider>();

    try {
      // 🟡 الدفع Stripe
      if (_paymentMethod == 'payment') {
        final url = await bookingProvider.createStripePayment(
          amount: (_totalPrice * 100).toInt(),
          carId: widget.car.id,
          userEmail: _emailCtrl.text.trim(),
        );

        if (url == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment error, try again")),
          );
          return;
        }

        final paid = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => PaymentWebView(checkoutUrl: url)),
        );

        if (paid != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment was cancelled or failed")),
          );
          return;
        }
      }

      // 🟢 كاش أو دفع ناجح → خزّن الحجز
      await bookingProvider.createBooking(booking);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: BookingSuccessPage(booking: booking),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while booking, try again')),
      );
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarHeader(),
              const SizedBox(height: 18),
              _buildForm(),
              const SizedBox(height: 18),
              _buildStartDatePicker(),
              const SizedBox(height: 18),
              _buildDaysAndTotal(),
              const SizedBox(height: 18),
              _buildPaymentMethods(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: bookingProvider.loading ? null : _submit,
            child: bookingProvider.loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Confirm Booking - \$${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarHeader() {
    return Container(
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
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(widget.car.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.car.make} ${widget.car.model}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${widget.car.daily_rate} / day',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.sunYellow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField(_nameCtrl, 'Full Name', Icons.person),
            _buildField(
              _emailCtrl,
              'Email',
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildField(
              _phoneCtrl,
              'Phone',
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _buildLocationPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return InkWell(
      onTap: () async {
        final picked = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapPickerPage()),
        );

        if (picked != null) {
          setState(() {
            _lat = picked.latitude;
            _lng = picked.longitude;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.bg,
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.sunYellow),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                (_lat == 0 && _lng == 0)
                    ? 'Pick your location on map'
                    : 'Location: ($_lat, $_lng)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.map_outlined, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Icon(Icons.date_range, color: AppColors.sunYellow),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _startDate == null
                  ? "Select start date"
                  : _startDate!.toString().substring(0, 16),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
                initialDate: now,
              );

              if (picked != null) {
                setState(() => _startDate = picked);
              }
            },
            child: const Text(
              "Pick",
              style: TextStyle(
                color: AppColors.sunYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysAndTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          const Text(
            'Days',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (_days > 1) setState(() => _days--);
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            '$_days',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          IconButton(
            onPressed: () => setState(() => _days++),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _paymentChip('cash', 'Cash'),
              const SizedBox(width: 10),
              _paymentChip('payment', 'Payment'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String value, String label) {
    final selected = _paymentMethod == value;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _paymentMethod = value);

          if (value == 'payment') {
            final bookingProvider = context.read<BookingProvider>();

            final url = await bookingProvider.createStripePayment(
              amount: (_totalPrice * 100).toInt(),
              carId: widget.car.id,
              userEmail: _emailCtrl.text.trim(),
            );

            if (url != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentWebView(checkoutUrl: url),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment error, try again")),
              );
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sunYellow : AppColors.bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
