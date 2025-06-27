import 'dart:math';
import 'constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationHelper {
  // Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Format distance for display
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()} متر';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} كم';
    } else {
      return '${distance.round()} كم';
    }
  }

  // Check if location is within Gaza Strip
  static bool isWithinGazaStrip(double latitude, double longitude) {
    // Gaza Strip boundaries (approximate)
    const double minLat = 31.2;
    const double maxLat = 31.6;
    const double minLon = 34.2;
    const double maxLon = 34.5;

    return latitude >= minLat &&
        latitude <= maxLat &&
        longitude >= minLon &&
        longitude <= maxLon;
  }

  // Get area name from coordinates
  static String getAreaName(double latitude, double longitude) {
    // Gaza areas with approximate coordinates
    final areas = [
      {
        'name': 'غزة',
        'lat': 31.5017,
        'lon': 34.4668,
        'radius': 0.1,
      },
      {
        'name': 'الشمال',
        'lat': 31.55,
        'lon': 34.5,
        'radius': 0.1,
      },
      {
        'name': 'دير البلح',
        'lat': 31.42,
        'lon': 34.35,
        'radius': 0.1,
      },
      {
        'name': 'خان يونس',
        'lat': 31.34,
        'lon': 34.3,
        'radius': 0.1,
      },
      {
        'name': 'رفح',
        'lat': 31.28,
        'lon': 34.25,
        'radius': 0.1,
      },
    ];

    for (final area in areas) {
      final distance = calculateDistance(
        latitude,
        longitude,
        area['lat'] as double,
        area['lon'] as double,
      );

      if (distance <= (area['radius'] as double)) {
        return area['name'] as String;
      }
    }

    return 'غزة، فلسطين';
  }

  // Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // Get default location
  static Map<String, dynamic> getDefaultLocation() {
    return {
      'latitude': AppConstants.defaultLatitude,
      'longitude': AppConstants.defaultLongitude,
      'location_name': AppConstants.defaultLocationName,
    };
  }

  // Parse location string to coordinates
  static Map<String, double>? parseLocationString(String locationString) {
    try {
      final parts = locationString.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lon = double.parse(parts[1].trim());

        if (isValidCoordinates(lat, lon)) {
          return {
            'latitude': lat,
            'longitude': lon,
          };
        }
      }
    } catch (e) {
      // Invalid format
    }

    return null;
  }

  // Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Get direction from current location to target
  static String getDirection(double currentLat, double currentLon,
      double targetLat, double targetLon) {
    final dLat = targetLat - currentLat;
    final dLon = targetLon - currentLon;

    if (dLat.abs() > dLon.abs()) {
      return dLat > 0 ? 'شمال' : 'جنوب';
    } else {
      return dLon > 0 ? 'شرق' : 'غرب';
    }
  }

  // Check if two locations are nearby (within specified radius)
  static bool isNearby(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusKm,
  ) {
    final distance = calculateDistance(lat1, lon1, lat2, lon2);
    return distance <= radiusKm;
  }

  // التحقق من صلاحيات الموقع
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('خطأ', 'خدمة الموقع غير مفعلة');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('خطأ', 'تم رفض صلاحية الموقع');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('خطأ', 'صلاحيات الموقع مرفوضة نهائياً');
      return false;
    }

    return true;
  }

  // الحصول على الموقع الحالي
  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await checkLocationPermission()) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      Get.snackbar('خطأ', 'فشل في الحصول على الموقع');
      return null;
    }
  }

  // الحصول على اسم الموقع من الإحداثيات
  static Future<String?> getLocationName(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName = '';

        if (place.locality?.isNotEmpty == true) {
          locationName += place.locality!;
        }
        if (place.administrativeArea?.isNotEmpty == true) {
          if (locationName.isNotEmpty) locationName += '، ';
          locationName += place.administrativeArea!;
        }
        if (place.country?.isNotEmpty == true) {
          if (locationName.isNotEmpty) locationName += '، ';
          locationName += place.country!;
        }

        return locationName.isNotEmpty ? locationName : 'موقع غير محدد';
      }
      return 'موقع غير محدد';
    } catch (e) {
      print('Error getting location name: $e');
      return 'موقع غير محدد';
    }
  }

  // حساب المسافة بين نقطتين باستخدام Geolocator
  static double calculateDistanceWithGeolocator(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) /
        1000; // بالكيلومترات
  }

  // تنسيق المسافة
  static String formatDistanceForDisplay(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} متر';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} كم';
    } else {
      return '${distanceInKm.round()} كم';
    }
  }

  // الحصول على الموقع الافتراضي (غزة)
  static Map<String, double> getDefaultLocationCoordinates() {
    return {
      'latitude': 31.5017,
      'longitude': 34.4668,
    };
  }
}
