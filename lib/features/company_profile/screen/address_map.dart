// lib/features/company_profile/screen/address_map.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../common/colours.dart';
import '../controller/company_profile_controller.dart';

class AddressSelectionScreen extends StatelessWidget {
  final VendorStoreController controller = Get.find<VendorStoreController>();

  AddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildAppBar(context),
          _SearchPanel(controller: controller),
          Expanded(
            child: Stack(
              children: [
                // ✅ GoogleMap — only mapMarkers is reactive, wrapped properly
                Obx(() => GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition,
                  onMapCreated: controller.onMapCreated,
                  markers: controller.mapMarkers.value,
                  onTap: controller.onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  compassEnabled: true,
                )),

                const _CenterPin(),

                // ✅ Loading overlay — only isMapLoading is read
                Obx(() => controller.isMapLoading.value
                    ? _LoadingOverlay()
                    : const SizedBox.shrink()),

                // Location FAB — only isLocatingUser is read
                Positioned(
                  right: 16,
                  bottom: 160,
                  child: Obx(() => _LocationFAB(
                    isLocating: controller.isLocatingUser.value,
                    onTap: controller.getCurrentLocation,
                  )),
                ),

                // Zoom controls — no reactive data, always visible
                Positioned(
                  right: 16,
                  bottom: 228,
                  child: _ZoomControls(controller: controller),
                ),

                // ✅ Address preview — uses controller.addressText (RxString)
                Positioned(
                  bottom: 84,
                  left: 16,
                  right: 16,
                  child: Obx(() {
                    if (controller.addressText.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _AddressPreviewCard(controller: controller);
                  }),
                ),

                // Confirm button
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _ConfirmButton(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColor.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    size: 20, color: AppColor.textMain),
              ),
              onPressed: () => Get.back(),
            ),
            const Expanded(
              child: Text(
                'Select Store Location',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColor.textMain,
                ),
              ),
            ),
            // ✅ Only isLocatingUser reactive
            Obx(() {
              if (controller.isLocatingUser.value) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  height: 22,
                  width: 22,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: AppColor.primary),
                );
              }
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      size: 20, color: AppColor.primary),
                ),
                onPressed: controller.getCurrentLocation,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Search Panel
// ─────────────────────────────────────────────────────────────
class _SearchPanel extends StatelessWidget {
  final VendorStoreController controller;
  const _SearchPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColor.lightGrey),
            ),
            child: TextField(
              controller: controller.searchAddressController,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textMain,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search address, landmark or area...',
                hintStyle:
                const TextStyle(color: AppColor.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColor.primary, size: 22),
                // ✅ Only isSearching + searchAddressController text — wrap suffix in Obx
                suffixIcon: Obx(() {
                  if (controller.isSearching.value) {
                    return Container(
                      margin: const EdgeInsets.all(12),
                      height: 18,
                      width: 18,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.primary),
                    );
                  }
                  // Use a ValueListenableBuilder for non-reactive controller text
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.searchAddressController,
                    builder: (_, value, __) {
                      if (value.text.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColor.grey),
                          onPressed: () {
                            controller.searchAddressController.clear();
                            controller.searchResults.clear();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              onChanged: controller.searchLocation,
            ),
          ),

          // ✅ Search results — only searchResults is reactive
          Obx(() {
            if (controller.searchResults.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 1, color: AppColor.lightGrey, indent: 50),
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];
                    final mainText =
                        result['structured_formatting']?['main_text']
                        as String? ??
                            result['description'] as String? ??
                            '';
                    final secondaryText =
                        result['structured_formatting']?['secondary_text']
                        as String? ??
                            '';

                    return InkWell(
                      onTap: () {
                        controller.selectSearchResult(result);
                        controller.searchResults.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  size: 15, color: AppColor.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mainText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: AppColor.textMain,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (secondaryText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      secondaryText,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColor.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Center Pin (static — no reactive data)
// ─────────────────────────────────────────────────────────────
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Text(
                '📍 Tap or drag to place pin',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Icon(
              Icons.location_pin,
              size: 44,
              color: AppColor.primary,
              shadows: [
                Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationFAB extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onTap;
  const _LocationFAB({required this.isLocating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocating ? null : onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: AppColor.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: isLocating
            ? const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColor.primary),
          ),
        )
            : const Icon(Icons.my_location_rounded,
            color: AppColor.primary, size: 24),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VendorStoreController controller;
  const _ZoomControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                controller.mapController?.animateCamera(CameraUpdate.zoomIn()),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.add_rounded, color: AppColor.textMain, size: 22),
            ),
          ),
          const Divider(height: 1, color: AppColor.lightGrey),
          GestureDetector(
            onTap: () => controller.mapController
                ?.animateCamera(CameraUpdate.zoomOut()),
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.remove_rounded,
                  color: AppColor.textMain, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Address Preview Card — uses controller.addressText (RxString)
// ─────────────────────────────────────────────────────────────
class _AddressPreviewCard extends StatelessWidget {
  final VendorStoreController controller;
  const _AddressPreviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.secondary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColor.secondary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Address',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColor.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                // ✅ reads addressText (RxString) — but we're already inside Obx from parent
                Text(
                  controller.addressText.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColor.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Confirm Button — uses selectedLocation (reactive)
// ─────────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final VendorStoreController controller;
  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Obx(() {
        final hasLocation = controller.selectedLocation.value != null;
        return ElevatedButton(
          onPressed: () {
            if (hasLocation) {
              Get.back(result: true);
            } else {
              Get.snackbar(
                'Location Required',
                'Please tap on the map to select a location',
                backgroundColor: AppColor.red,
                colorText: AppColor.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.location_off_rounded,
                    color: Colors.white),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.white,
            elevation: 5,
            shadowColor: AppColor.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasLocation
                    ? Icons.check_circle_rounded
                    : Icons.location_on_rounded,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                hasLocation
                    ? 'Confirm This Location'
                    : 'Select a Location First',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading Overlay (static widget — shown/hidden by parent Obx)
// ─────────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  color: AppColor.primary, strokeWidth: 3),
              SizedBox(height: 12),
              Text(
                'Getting location details...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}