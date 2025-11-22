import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking.dart';
import '../../../core/config/app_colors.dart';

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(booking.carImageUrl, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              '${booking.carMake} ${booking.carModel}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 8),

            Text(
              'Booking ID: ${booking.id}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            _detailRow('Full Name:', booking.userName),
            _detailRow('Email:', booking.userEmail),
            _detailRow('Phone:', booking.userPhone),
            _detailRow('Payment Method:', booking.paymentMethod),
            _detailRow('Days:', booking.days.toString()),
            _detailRow('Daily Rate:', '\$${booking.dailyRate}'),
            _detailRow(
              'Total:',
              '\$${(booking.dailyRate * booking.days).toStringAsFixed(2)}',
            ),
            _detailRow(
              'Start Date:',
              booking.startDate.toString().substring(0, 16),
            ),
            _detailRow(
              'Created At:',
              booking.createdAt.toString().substring(0, 16),
            ),

            const SizedBox(height: 26),

            _actionButton(
              label: 'Show Location on Map',
              icon: Icons.map_outlined,
              color: Colors.blue,
              onTap: () => _openMap(booking.latitude, booking.longitude),
            ),

            const SizedBox(height: 12),

            _actionButton(
              label: 'Call Provider',
              icon: Icons.phone,
              color: Colors.green,
              onTap: () => _callNumber(booking.userPhone),
            ),

            const SizedBox(height: 12),

            _actionButton(
              label: 'Cancel Booking',
              icon: Icons.cancel,
              color: Colors.red,
              onTap: () async {
                final confirm = await _confirm(context);
                if (confirm) {
                  await _cancelBooking(context, booking.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Function() onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _openMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
    if (await canLaunchUrl(url)) {
      launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callNumber(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    }
  }

  Future<bool> _confirm(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: const Text('Do you really want to cancel this booking?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _cancelBooking(BuildContext context, String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).delete();
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
  }
}
