import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/company_profile_controller.dart';
import '../model/comapany_profile.dart';
import 'address_map.dart';

class VendorStoreView extends StatefulWidget {
  const VendorStoreView({super.key});

  @override
  State<VendorStoreView> createState() => _VendorStoreViewState();
}

class _VendorStoreViewState extends State<VendorStoreView> {
  late final VendorStoreController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VendorStoreController());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Obx(() {
        if (controller.isFetching.value) {
          return const _FullScreenLoader();
        }
        return _buildBody(context);
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _SectionCard(
                  icon: Icons.storefront_rounded,
                  iconColor: const Color(0xFF4F6CF7),
                  title: 'Store Details',
                  children: [
                    _StyledTextField(
                      controller: controller.nameController,
                      label: 'Store Name',
                      hint: 'e.g. Green Bazaar',
                      icon: Icons.store_mall_directory_rounded,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.descriptionController,
                      label: 'Description',
                      hint: 'Tell customers what makes your store special...',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                      required: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Location',
                  children: [
                    _MapPickerTile(controller: controller),
                    const SizedBox(height: 16),
                    _CountryStateCity(controller: controller),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.postalCodeController,
                      label: 'Postal Code',
                      hint: 'e.g. 600001',
                      icon: Icons.pin_drop_rounded,
                      keyboardType: TextInputType.number,
                      required: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.contact_phone_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Contact Info',
                  children: [
                    _StyledTextField(
                      controller: controller.phoneController,
                      label: 'Phone Number',
                      hint: '+91 98765 43210',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.emailController,
                      label: 'Email Address',
                      hint: 'store@email.com',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.websiteController,
                      label: 'Website',
                      hint: 'https://yourstore.com',
                      icon: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.share_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Social Media',
                  subtitle: 'Optional',
                  children: [
                    _StyledTextField(
                      controller: controller.instagramController,
                      label: 'Instagram',
                      hint: 'instagram.com/yourstore',
                      icon: Icons.camera_alt_rounded,
                    ),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.facebookController,
                      label: 'Facebook',
                      hint: 'facebook.com/yourstore',
                      icon: Icons.facebook_rounded,
                    ),
                    const SizedBox(height: 16),
                    _StyledTextField(
                      controller: controller.whatsappController,
                      label: 'WhatsApp',
                      hint: '+91 98765 43210',
                      icon: Icons.chat_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.image_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Store Images',
                  children: [
                    _ThumbnailPicker(controller: controller),
                    const SizedBox(height: 20),
                    _MultiImagePicker(controller: controller),
                  ],
                ),
                const SizedBox(height: 32),
                _SubmitButton(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: const Text(
          'Create Vendor Store',
          style: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
              child: Text(
                'Fill in your store details below',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Styled Text Field
// ─────────────────────────────────────────────────────────────
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool required;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F6CF7), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Map Picker Tile - OPTIMIZED
// ─────────────────────────────────────────────────────────────
class _MapPickerTile extends StatelessWidget {
  final VendorStoreController controller;
  const _MapPickerTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Store Address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Main Map Tile - Single Obx
        Obx(() {
          final hasAddress = controller.addressController.text.isNotEmpty;
          final addressText = controller.addressController.text;

          return GestureDetector(
            onTap: () async {
              await Get.to(() => AddressSelectionScreen());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: hasAddress
                    ? const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade50, Colors.grey.shade100],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasAddress
                      ? const Color(0xFF22C55E).withOpacity(0.4)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasAddress
                          ? const Color(0xFF22C55E).withOpacity(0.15)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasAddress ? Icons.check_circle_rounded : Icons.map_rounded,
                      color: hasAddress ? const Color(0xFF22C55E) : Colors.grey.shade500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAddress ? 'Location Selected' : 'Select on Map',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: hasAddress
                                ? const Color(0xFF15803D)
                                : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasAddress ? addressText : 'Tap to open map and pin your store location',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasAddress
                                ? const Color(0xFF16A34A)
                                : Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        } ),

        // Lat/Lng chips - Separate Obx
        Obx(() {
          final lat = controller.latController.text;
          final lng = controller.langController.text;

          if (lat.isNotEmpty && lng.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  _CoordChip(
                    label: 'Lat',
                    value: double.tryParse(lat)?.toStringAsFixed(5) ?? '',
                  ),
                  const SizedBox(width: 8),
                  _CoordChip(
                    label: 'Lng',
                    value: double.tryParse(lng)?.toStringAsFixed(5) ?? '',
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class _CoordChip extends StatelessWidget {
  final String label;
  final String value;
  const _CoordChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4F6CF7).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4F6CF7).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F6CF7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Country / State / City - OPTIMIZED
// ─────────────────────────────────────────────────────────────
class _CountryStateCity extends StatelessWidget {
  final VendorStoreController controller;
  const _CountryStateCity({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country dropdown
        Obx(() {
          final isLoading = controller.isCountryLoading.value;
          final selectedValue = controller.selectedCountry.value;
          final items = controller.countries.toList();
          final enabled = true;

          return _buildDropdown<CountryModel>(
            label: 'Country',
            icon: Icons.public_rounded,
            isLoading: isLoading,
            value: selectedValue,
            items: items,
            displayText: (c) => c.countryName,
            onChanged: controller.onCountryChanged,
            enabled: enabled,
            required: true,
          );
        }),
        const SizedBox(height: 16),

        // State dropdown
        Obx(() {
          final isLoading = controller.isStateLoading.value;
          final selectedValue = controller.selectedState.value;
          final items = controller.states.toList();
          final enabled = controller.selectedCountry.value != null;

          return _buildDropdown<StateModel>(
            label: 'State',
            icon: Icons.location_city_rounded,
            isLoading: isLoading,
            value: selectedValue,
            items: items,
            displayText: (s) => s.stateName,
            onChanged: controller.onStateChanged,
            enabled: enabled,
            required: true,
          );
        }),
        const SizedBox(height: 16),

        // City dropdown
        Obx(() {
          final isLoading = controller.isCityLoading.value;
          final selectedValue = controller.selectedCity.value;
          final items = controller.cities.toList();
          final enabled = controller.selectedState.value != null;

          return _buildDropdown<CityModel>(
            label: 'City',
            icon: Icons.apartment_rounded,
            isLoading: isLoading,
            value: selectedValue,
            items: items,
            displayText: (c) => c.cityName,
            onChanged: controller.onCityChanged,
            enabled: enabled,
            required: true,
          );
        }),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required bool isLoading,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    bool enabled = true,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
              filled: true,
              fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F6CF7), width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            items: items
                .map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayText(item),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Thumbnail Picker - OPTIMIZED
// ─────────────────────────────────────────────────────────────
class _ThumbnailPicker extends StatelessWidget {
  final VendorStoreController controller;
  const _ThumbnailPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'THUMBNAIL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B5CF6),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '* Required',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Thumbnail display
        Obx(() {
          final file = controller.thumbnailImage.value;
          final url = controller.thumbnailUrl.value;
          final hasImage = file != null || url.isNotEmpty;

          return GestureDetector(
            onTap: hasImage ? null : controller.pickThumbnailImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: hasImage ? 180 : 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: hasImage ? Colors.transparent : const Color(0xFFF3F4F6),
                border: Border.all(
                  color: hasImage
                      ? Colors.transparent
                      : const Color(0xFF8B5CF6).withOpacity(0.3),
                  width: 1.5,
                  style: hasImage ? BorderStyle.none : BorderStyle.solid,
                ),
                image: hasImage
                    ? DecorationImage(
                  image: file != null
                      ? FileImage(file) as ImageProvider
                      : NetworkImage(url),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: hasImage
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(color: Colors.transparent),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        _ActionBadge(
                          icon: Icons.edit_rounded,
                          onTap: controller.pickThumbnailImage,
                          color: const Color(0xFF4F6CF7),
                        ),
                        const SizedBox(width: 8),
                        _ActionBadge(
                          icon: Icons.delete_rounded,
                          onTap: controller.clearThumbnail,
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 28,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload Thumbnail',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'The main cover for your store',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Action buttons
        Obx(() {
          if (controller.thumbnailImage.value == null &&
              controller.thumbnailUrl.value.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _OutlinedIconButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: controller.pickThumbnailImage,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlinedIconButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: controller.takeThumbnailPhoto,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Multi Image Picker - OPTIMIZED
// ─────────────────────────────────────────────────────────────
class _MultiImagePicker extends StatelessWidget {
  final VendorStoreController controller;
  const _MultiImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'STORE GALLERY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF22C55E),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '* Min 1, max 5',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const Spacer(),

            // Count indicator
            Obx(() {
              final count = controller.storeImages.length +
                  controller.storeImageUrls.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: count >= 5
                      ? const Color(0xFFEF4444).withOpacity(0.1)
                      : const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count / 5',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: count >= 5
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 14),

        // Image grid
        Obx(() {
          final localImages = controller.storeImages.toList();
          final urlImages = controller.storeImageUrls.toList();
          final totalCount = localImages.length + urlImages.length;

          if (totalCount == 0) {
            return GestureDetector(
              onTap: controller.pickStoreImages,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 26,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Add Store Photos',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Show customers what your store looks like',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  final isLocal = index < localImages.length;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.expand(
                          child: isLocal
                              ? Image.file(localImages[index], fit: BoxFit.cover)
                              : Image.network(
                            urlImages[index - localImages.length],
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (isLocal)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => controller.removeStoreImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Add more button
              if (totalCount < 5)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _OutlinedIconButton(
                    icon: Icons.add_rounded,
                    label: 'Add More Photos',
                    onTap: controller.pickStoreImages,
                    color: const Color(0xFF22C55E),
                    fullWidth: true,
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Submit Button - OPTIMIZED
// ─────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final VendorStoreController controller;
  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCreating = controller.isCreating.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: isCreating ? null : controller.createStore,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F6CF7),
            disabledBackgroundColor: const Color(0xFF4F6CF7).withOpacity(0.6),
            foregroundColor: Colors.white,
            elevation: isCreating ? 0 : 6,
            shadowColor: const Color(0xFF4F6CF7).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isCreating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Creating Store...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 22),
              SizedBox(width: 10),
              Text(
                'Create Store',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable Widgets
// ─────────────────────────────────────────────────────────────
class _ActionBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionBadge({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _OutlinedIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool fullWidth;

  const _OutlinedIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7FB),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF4F6CF7),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text('Loading Store Data...', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500, fontSize: 14,),
            ),
          ],
        ),
      ),
    );
  }
}