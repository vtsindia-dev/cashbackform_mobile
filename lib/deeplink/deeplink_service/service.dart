import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../../common/route/router.dart';
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  Uri? pendingUri;
  bool isHandlingLink = false;
  DateTime? _lastHandledTime;
  String? _lastHandledUrl;

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('🔗 DeepLink cold start: $initialUri');
        pendingUri = initialUri;
      }
    } catch (e) {
      print('❌ DeepLink cold start error: $e');
    }
    _subscription = _appLinks.uriLinkStream.listen(
          (uri) {
        print('🔗 DeepLink warm start: $uri');
        final now = DateTime.now();
        if (_lastHandledUrl == uri.toString() &&
            _lastHandledTime != null &&
            now.difference(_lastHandledTime!).inSeconds < 2) {
          print('⏭️ DeepLink debounced — same URL fired too quickly');
          return;
        }
        _lastHandledUrl = uri.toString();
        _lastHandledTime = now;
        isHandlingLink = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          _handleUri(uri);
          Future.delayed(const Duration(seconds: 3), () {
            isHandlingLink = false;
          });
        });
      },
      onError: (e) => print('❌ DeepLink stream error: $e'),
    );
  }

  void consumePendingUri() {
    if (pendingUri != null) {
      print('🔗 DeepLink consuming pending: $pendingUri');
      final uri = pendingUri!;
      pendingUri = null;
      _handleUri(uri);
    }
  }

  void dispose() => _subscription?.cancel();

  void _handleUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length < 3 || segments[1] != 'details') {
      print('⚠️ DeepLink: unrecognized path — ${uri.path}');
      return;
    }

    final section = segments[0];
    final id = int.tryParse(segments[2]);

    if (id == null) {
      print('⚠️ DeepLink: invalid id in path — ${uri.path}');
      return;
    }

    print('✅ DeepLink navigating → section: $section, id: $id');
    _navigate(section, id);
  }

  void _navigate(String section, int id) {
    switch (section) {
      case 'plot-marketplace':
        Get.toNamed(AppRoutes.plotMarketDetails,
            arguments: {'id': id, 'title': ''});
        break;
      case 'gioo-plots':
        Get.toNamed(AppRoutes.giooDetails,
            arguments: {'id': id, 'title': ''});
        break;
      case 'syndicate-plots':
        Get.toNamed(AppRoutes.syndicateDetails,
            arguments: {'id': id, 'title': ''});
        break;
      case 'rental-yield-plots':
        Get.toNamed(AppRoutes.rentalDetails,
            arguments: {'id': id, 'title': ''});
        break;
      case 'residential-property':
        Get.toNamed(AppRoutes.residentialDetails,
            arguments: {'id': id, 'title': ''});
        break;
      default:
        print('⚠️ DeepLink: unknown section "$section"');
    }
  }
}