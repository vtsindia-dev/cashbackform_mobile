import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find();

  final _connectivity = Connectivity();
  StreamSubscription? _subscription;
  final isConnected = true.obs;

  // Route name of the no-internet screen so we can close it
  static const String _noInternetRoute = '/noInternet';

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkInitial() async {
    final result = await _connectivity.checkConnectivity();
    _update(result);
  }

  void _onChanged(List<ConnectivityResult> results) {
    _update(results);
  }

  void _update(List<ConnectivityResult> results) {
    final connected = results.any((r) => r != ConnectivityResult.none);
    isConnected.value = connected;

    if (!connected) {
      // Only push the no-internet screen if it's not already on top
      if (Get.currentRoute != _noInternetRoute) {
        Get.toNamed(_noInternetRoute);
      }
    } else {
      // If back online and no-internet screen is showing, close it
      if (Get.currentRoute == _noInternetRoute) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}