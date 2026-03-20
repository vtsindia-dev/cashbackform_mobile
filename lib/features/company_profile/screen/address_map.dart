import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
                // Map - wrap only the GoogleMap in Obx, not the entire Stack
                Obx(() => GoogleMap(
                  initialCameraPosition: controller.initialCameraPosition,
                  onMapCreated: controller.onMapCreated,
                  markers: Set<Marker>.of(controller.mapMarkers),
                  onTap: controller.onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  compassEnabled: true,
                )),

                const _CenterPin(),

                // Loading overlay
                Obx(() {
                  if (!controller.isMapLoading.value) return const SizedBox.shrink();
                  return _LoadingOverlay();
                }),

                // Location FAB
                Positioned(
                  right: 16,
                  bottom: 160,
                  child: Obx(() => _LocationFAB(
                    isLocating: controller.isLocatingUser.value,
                    onTap: controller.getCurrentLocation,
                  )),
                ),

                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: 230,
                  child: _ZoomControls(controller: controller),
                ),

                // Address preview card
                Positioned(
                  bottom: 80,
                  left: 16,
                  right: 16,
                  child: Obx(() {
                    if (controller.addressController.text.isEmpty) {
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
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
              onPressed: () => Get.back(),
            ),
            const Expanded(
              child: Text(
                'Select Store Location',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            // Use Obx only around the conditional content
            Obx(() {
              if (controller.isLocatingUser.value) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  height: 24,
                  width: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4F6CF7),
                  ),
                );
              }
              return IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F6CF7).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    size: 20,
                    color: Color(0xFF4F6CF7),
                  ),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: controller.searchAddressController,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search address, landmark or area...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF4F6CF7),
                  size: 22,
                ),
                suffixIcon: Obx(() {
                  if (controller.isSearching.value) {
                    return Container(
                      margin: const EdgeInsets.all(12),
                      height: 18,
                      width: 18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4F6CF7),
                      ),
                    );
                  } else if (controller.searchAddressController.text.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        controller.searchAddressController.clear();
                        controller.searchResults.clear();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: controller.searchLocation,
            ),
          ),

          Obx(() {
            if (controller.searchResults.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: controller.searchResults.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 52,
                  ),
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];
                    final mainText =
                        result['structured_formatting']?['main_text'] as String? ??
                            result['description'] as String? ??
                            '';
                    final secondaryText = result['structured_formatting']
                    ?['secondary_text'] as String? ??
                        '';

                    return InkWell(
                      onTap: () {
                        controller.selectSearchResult(result);
                        controller.searchResults.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F6CF7).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Color(0xFF4F6CF7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mainText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (secondaryText.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      secondaryText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
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
// Center Pin
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                '📍 Tap or drag to place pin',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F6CF7),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              Icons.location_pin,
              size: 44,
              color: const Color(0xFF4F6CF7).withOpacity(0.9),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Location FAB
// ─────────────────────────────────────────────────────────────
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
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLocating
            ? const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4F6CF7),
            ),
          ),
        )
            : const Icon(
          Icons.my_location_rounded,
          color: Color(0xFF4F6CF7),
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Zoom Controls
// ─────────────────────────────────────────────────────────────
class _ZoomControls extends StatelessWidget {
  final VendorStoreController controller;
  const _ZoomControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.mapController
                ?.animateCamera(CameraUpdate.zoomIn()),
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              child: const Icon(Icons.add_rounded, color: Color(0xFF374151), size: 22),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          GestureDetector(
            onTap: () => controller.mapController
                ?.animateCamera(CameraUpdate.zoomOut()),
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              child: const Icon(Icons.remove_rounded,
                  color: Color(0xFF374151), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Address Preview Card
// ─────────────────────────────────────────────────────────────
class _AddressPreviewCard extends StatelessWidget {
  final VendorStoreController controller;
  const _AddressPreviewCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF22C55E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Address',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.addressController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
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
// Confirm Button
// ─────────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  final VendorStoreController controller;
  const _ConfirmButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          if (controller.selectedLocation.value != null) {
            Get.back(result: true);
          } else {
            Get.snackbar(
              'Location Required',
              'Please tap on the map to select a location',
              backgroundColor: const Color(0xFFEF4444),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              icon: const Icon(Icons.location_off_rounded, color: Colors.white),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F6CF7),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0xFF4F6CF7).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Icon(
              controller.selectedLocation.value != null
                  ? Icons.check_circle_rounded
                  : Icons.location_on_rounded,
              size: 22,
            )),
            const SizedBox(width: 10),
            Obx(() => Text(
              controller.selectedLocation.value != null
                  ? 'Confirm This Location'
                  : 'Select a Location First',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Loading Overlay
// ─────────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F6CF7), strokeWidth: 3),
              SizedBox(height: 14),
              Text(
                'Getting location details...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}