import '../models/car.dart';

class CarController {
  // بيانات تجريبية (Mock data) بنفس روح التصميم السابق
  final List<Car> cars = [
    Car(
      provider_id: 1,
      make: 'Porsche',
      model: 'Cayman 981',
      year: 2021,
      plate_number: '12345 JO',
      color: 'Red',
      imageUrl:
          'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=1200&q=60',
      transmission: 'Automatic',
      fuel_type: 'Petrol',
      seats: 2,
      doors: 2,
      mileage_km: 15000,
      status: 'Available',
      daily_rate: 674,
      created_at: DateTime(2023, 7, 12),
    ),
    Car(
      provider_id: 2,
      make: 'Porsche',
      model: '911 Carrera',
      year: 2022,
      plate_number: '98765 JO',
      color: 'Black',
      imageUrl:
          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?auto=format&fit=crop&w=1200&q=60',
      transmission: 'Manual',
      fuel_type: 'Petrol',
      seats: 4,
      doors: 2,
      mileage_km: 10000,
      status: 'Available',
      daily_rate: 799,
      created_at: DateTime(2024, 3, 22),
    ),
    Car(
      provider_id: 3,
      make: 'BMW',
      model: 'M4 Coupe',
      year: 2023,
      plate_number: '5566 JO',
      color: 'Blue',
      imageUrl:
          'https://images.unsplash.com/photo-1600702061660-3a8c437a5b4a?auto=format&fit=crop&w=1200&q=60',
      transmission: 'Automatic',
      fuel_type: 'Gasoline',
      seats: 4,
      doors: 2,
      mileage_km: 8500,
      status: 'Available',
      daily_rate: 920,
      created_at: DateTime(2024, 10, 1),
    ),
  ];

  List<String> get brands => const [
    'All',
    'Porsche',
    'Ferrari',
    'BMW',
    'Audi',
    'Mercedes',
  ];

  /// ✅ فلترة السيارات حسب العلامة التجارية
  List<Car> filterByBrand(String brand) {
    if (brand == 'All') return cars;
    return cars
        .where((car) => car.make.toLowerCase() == brand.toLowerCase())
        .toList();
  }
}
