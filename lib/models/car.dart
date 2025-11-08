class Car {
  final int provider_id;
  final String make;
  final String model;
  final int year;
  final String plate_number;
  final String color;
  final String imageUrl;
  final String transmission;
  final String fuel_type;
  final int seats;
  final int doors;
  final int mileage_km;
  final String status;
  final int daily_rate;
  final DateTime created_at;

  const Car({
    required this.provider_id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate_number,
    required this.color,
    required this.imageUrl,
    required this.transmission,
    required this.fuel_type,
    required this.seats,
    required this.doors,
    required this.mileage_km,
    required this.status,
    required this.daily_rate,
    required this.created_at,
  });

  String get displayName => '$make $model';
}
