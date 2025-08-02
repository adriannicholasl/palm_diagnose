import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// ✅ Global state untuk menyimpan lokasi terakhir yang valid
class AppLocationState {
  static Position? position;
  static String? locationName;

  static bool get isAvailable => position != null && locationName != null;

  static void update(Position pos, String name) {
    position = pos;
    locationName = name;
  }

  static void clear() {
    position = null;
    locationName = null;
  }
}

/// ✅ Service untuk mengambil lokasi dan alamat pengguna
class LocationService {
  /// Ambil koordinat lokasi pengguna (Latitude & Longitude)
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 👇 Buka pengaturan lokasi jika GPS mati
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) {
      // 👇 Redirect ke pengaturan aplikasi karena user block permanen
      await Geolocator.openAppSettings();
      return null;
    }

    // ✅ Semua permission OK, ambil lokasi
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Ambil nama lokasi (nama kota/kecamatan) dari posisi GPS
  static Future<String> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.first;

      final List<String> parts = [
        if (place.subLocality?.isNotEmpty == true) place.subLocality!,
        if (place.locality?.isNotEmpty == true) place.locality!,
        if (place.subAdministrativeArea?.isNotEmpty == true)
          place.subAdministrativeArea!,
        if (place.administrativeArea?.isNotEmpty == true)
          place.administrativeArea!,
      ];

      return parts.join(', ');
    } catch (e) {
      return 'Lokasi tidak diketahui';
    }
  }
}
