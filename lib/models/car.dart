class Car {
  final String id;

  final String provider_id;
  final String provider_name;

  final String make;
  final String model;
  final int year;
  final String plate_number;

  final String color;
  final String transmission;
  final String fuel_type;

  final int seats;
  final int doors;
  final int mileage_km;

  final String status;
  final double daily_rate;

  final String imageUrl;

  final DateTime created_at;

  Car({
    required this.id,
    required this.provider_id,
    required this.provider_name,
    required this.make,
    required this.model,
    required this.year,
    required this.plate_number,
    required this.color,
    required this.transmission,
    required this.fuel_type,
    required this.seats,
    required this.doors,
    required this.mileage_km,
    required this.status,
    required this.daily_rate,
    required this.imageUrl,
    required this.created_at,
  });

  // ============================
  //      SMART PARSING FIX 🔥
  // ============================
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory Car.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Car(
      id: documentId,
      provider_id: data['provider_id'] ?? '',
      provider_name: data['provider_name'] ?? '',

      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: _toInt(data['year']),
      plate_number: data['plate_number'] ?? '',

      color: data['color'] ?? '',
      transmission: data['transmission'] ?? '',
      fuel_type: data['fuel_type'] ?? '',

      seats: _toInt(data['seats']),
      doors: _toInt(data['doors']),
      mileage_km: _toInt(data['mileage_km']),

      status: data['status'] ?? '',
      daily_rate: _toDouble(data['daily_rate']),

      imageUrl: (data['imageUrl'] ?? '').toString().trim().replaceAll('\n', ''),

      created_at: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': provider_id,
      'provider_name': provider_name,

      'make': make,
      'model': model,
      'year': year,
      'plate_number': plate_number,

      'color': color,
      'transmission': transmission,
      'fuel_type': fuel_type,

      'seats': seats,
      'doors': doors,
      'mileage_km': mileage_km,

      'status': status,
      'daily_rate': daily_rate,

      'imageUrl': imageUrl,
      'created_at': created_at.toIso8601String(),
    };
  }
}
