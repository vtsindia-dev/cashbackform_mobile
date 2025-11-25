import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends GetxController {
  bool isLoading = true;
  String currentLocation = "Fetching location...";
  String areaName = "";
  String fullAddress = "";
  var services = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUserLocation();
    loadDummyData();

  }
  void loadDummyData() {
    services.value = [
      {
        "title": "Electrician",
        "image": "https://picsum.photos/300/200?1",
      },
      {
        "title": "Plumber",
        "image": "https://picsum.photos/300/200?2",
      },
      {
        "title": "Cleaning Service",
        "image": "https://picsum.photos/300/200?3",
      },
      {
        "title": "AC Repair",
        "image": "https://picsum.photos/300/200?4",
      },
    ];
  }
  Future<void> getUserLocation() async {
    isLoading = true;
    update();

    PermissionStatus status = await Permission.location.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      currentLocation = "Enable location in Settings";
      areaName = "Enable location";
      fullAddress = "Go to Settings to enable";
      isLoading = false;
      update();
      openAppSettings();
      return;
    }

    if (status.isGranted) {
      await fetchLocationFromDevice();
    } else {
      currentLocation = "Location permission denied";
      areaName = "Permission denied";
      fullAddress = "Enable location access";
      isLoading = false;
      update();
    }
  }

  Future<void> fetchLocationFromDevice() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      Placemark place = placemarks.first;

      String locality = place.locality ?? "";
      String subLocality = place.subLocality ?? "";
      String administrativeArea = place.administrativeArea ?? "";
      String postalCode = place.postalCode ?? "";

      areaName = subLocality.isNotEmpty ? subLocality : locality;

      List<String> addressParts = [];
      if (locality.isNotEmpty && locality != areaName) addressParts.add(locality);
      if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
      if (postalCode.isNotEmpty) addressParts.add(postalCode);

      fullAddress = addressParts.join(', ');

      currentLocation = "$areaName, $fullAddress";

      print("Location Details:");
      print("Area Name: $areaName");
      print("Full Address: $fullAddress");
      print("Locality: ${place.locality}");
      print("SubLocality: ${place.subLocality}");
      print("AdministrativeArea: ${place.administrativeArea}");
      print("PostalCode: ${place.postalCode}");
      print("Full Placemark: $place");

    } catch (e) {
      currentLocation = "Unable to fetch location";
      areaName = "Location error";
      fullAddress = "Try again later";
      print("Location Error: $e");
    }

    isLoading = false;
    update();
  }

  void refreshLocation() {
    currentLocation = "Updating...";
    areaName = "Updating...";
    fullAddress = "";
    update();
    getUserLocation();
  }
}