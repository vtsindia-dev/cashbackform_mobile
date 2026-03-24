// lib/features/company_profile/screen/add_company_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/company_profile_controller.dart';
import '../model/comapany_profile.dart';
import 'address_map.dart';

// ─────────────────────────────────────────────────────────────
// Main View
// ─────────────────────────────────────────────────────────────
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.storefront_rounded,
                  iconColor: AppColor.primary,
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
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColor.secondary,
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
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.contact_phone_rounded,
                  iconColor: AppColor.orange,
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
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.share_rounded,
                  iconColor: AppColor.accent,
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
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.image_rounded,
                  iconColor: AppColor.info,
                  title: 'Store Images',
                  children: [
                    _ThumbnailPicker(controller: controller),
                    const SizedBox(height: 20),
                    _MultiImagePicker(controller: controller),
                  ],
                ),
                const SizedBox(height: 28),
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
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColor.primary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: const Text(
          'Create Vendor Store',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.primary,
                AppColor.primarylite,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                top: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
                  child: Text(
                    'Fill in your store details below',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
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
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMain,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.lightGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColor.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: AppColor.lightGrey),
            const SizedBox(height: 16),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: AppColor.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: AppColor.textMain,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColor.grey),
            prefixIcon: Icon(icon, size: 18, color: AppColor.grey),
            filled: true,
            fillColor: AppColor.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Map Picker Tile — uses controller.addressText (observable)
// instead of controller.addressController.text (NOT observable)
// ─────────────────────────────────────────────────────────────
class _MapPickerTile extends StatelessWidget {
  final VendorStoreController controller;
  const _MapPickerTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Store Address',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(color: AppColor.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ Uses controller.addressText (RxString) — fully reactive
        Obx(() {
          final address = controller.addressText.value;
          final hasAddress = address.isNotEmpty;

          return GestureDetector(
            onTap: () => Get.to(() => AddressSelectionScreen()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: hasAddress
                    ? const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [AppColor.backgroundLight, AppColor.lightGrey],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasAddress
                      ? AppColor.secondary.withOpacity(0.4)
                      : AppColor.lightGrey,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: hasAddress
                          ? AppColor.secondary.withOpacity(0.15)
                          : AppColor.lightGrey,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      hasAddress ? Icons.check_circle_rounded : Icons.map_rounded,
                      color: hasAddress ? AppColor.secondary : AppColor.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAddress ? 'Location Selected' : 'Select on Map',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: hasAddress ? AppColor.green : AppColor.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasAddress
                              ? address
                              : 'Tap to open map and pin your store location',
                          style: TextStyle(
                            fontSize: 11,
                            color: hasAddress ? AppColor.secondary : AppColor.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColor.grey, size: 18),
                ],
              ),
            ),
          );
        }),

        // ✅ Uses controller.latText / langText (RxString) — fully reactive
        Obx(() {
          final lat = controller.latText.value;
          final lng = controller.langText.value;
          if (lat.isEmpty || lng.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _CoordChip(
                    label: 'Lat',
                    value: double.tryParse(lat)?.toStringAsFixed(5) ?? ''),
                const SizedBox(width: 8),
                _CoordChip(
                    label: 'Lng',
                    value: double.tryParse(lng)?.toStringAsFixed(5) ?? ''),
              ],
            ),
          );
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
        color: AppColor.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: AppColor.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Country / State / City — each Obx only reads reactive vars
// ─────────────────────────────────────────────────────────────
class _CountryStateCity extends StatelessWidget {
  final VendorStoreController controller;
  const _CountryStateCity({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => _buildDropdown<CountryModel>(
          label: 'Country',
          icon: Icons.public_rounded,
          isLoading: controller.isCountryLoading.value,
          value: controller.selectedCountry.value,
          items: controller.countries.toList(),
          displayText: (c) => c.countryName,
          onChanged: controller.onCountryChanged,
          enabled: true,
          required: true,
        )),
        const SizedBox(height: 16),
        Obx(() => _buildDropdown<StateModel>(
          label: 'State',
          icon: Icons.location_city_rounded,
          isLoading: controller.isStateLoading.value,
          value: controller.selectedState.value,
          items: controller.states.toList(),
          displayText: (s) => s.stateName,
          onChanged: controller.onStateChanged,
          enabled: controller.selectedCountry.value != null,
          required: true,
        )),
        const SizedBox(height: 16),
        Obx(() => _buildDropdown<CityModel>(
          label: 'City',
          icon: Icons.apartment_rounded,
          isLoading: controller.isCityLoading.value,
          value: controller.selectedCity.value,
          items: controller.cities.toList(),
          displayText: (c) => c.cityName,
          onChanged: controller.onCityChanged,
          enabled: controller.selectedState.value != null,
          required: true,
        )),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                    color: AppColor.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 7),
        if (isLoading)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.lightGrey),
            ),
            child: const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColor.primary),
              ),
            ),
          )
        else
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColor.grey),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColor.grey),
              filled: true,
              fillColor:
              enabled ? AppColor.backgroundLight : AppColor.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: AppColor.primary, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: AppColor.lightGrey),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
            ),
            hint: Text(
              'Select $label',
              style: const TextStyle(fontSize: 13, color: AppColor.grey),
            ),
            items: items
                .map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayText(item),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textMain,
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
// Thumbnail Picker
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
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'THUMBNAIL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColor.info,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '* Required',
              style: TextStyle(fontSize: 11, color: AppColor.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Obx only wraps what changes reactively
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
                borderRadius: BorderRadius.circular(14),
                color: hasImage ? Colors.transparent : AppColor.backgroundLight,
                border: hasImage
                    ? null
                    : Border.all(
                  color: AppColor.info.withOpacity(0.3),
                  width: 1.5,
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
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Container(color: Colors.transparent),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _ActionBadge(
                            icon: Icons.edit_rounded,
                            onTap: controller.pickThumbnailImage,
                            color: AppColor.primary,
                          ),
                          const SizedBox(width: 8),
                          _ActionBadge(
                            icon: Icons.delete_rounded,
                            onTap: controller.clearThumbnail,
                            color: AppColor.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColor.info.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 26,
                      color: AppColor.info,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload Thumbnail',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColor.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'The main cover for your store',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Action buttons — reactive to thumbnailImage + thumbnailUrl
        Obx(() {
          if (controller.thumbnailImage.value == null &&
              controller.thumbnailUrl.value.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _OutlinedIconButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: controller.pickThumbnailImage,
                      color: AppColor.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlinedIconButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: controller.takeThumbnailPhoto,
                      color: AppColor.info,
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
// Multi Image Picker
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
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'STORE GALLERY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColor.secondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '* Min 1, max 5',
              style: TextStyle(fontSize: 11, color: AppColor.grey),
            ),
            const Spacer(),
            // ✅ Obx wraps only the counter badge
            Obx(() {
              final count = controller.storeImages.length +
                  controller.storeImageUrls.length;
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: count >= 5
                      ? AppColor.red.withOpacity(0.1)
                      : AppColor.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count / 5',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: count >= 5 ? AppColor.red : AppColor.secondary,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Obx wraps the whole image grid
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
                  color: AppColor.backgroundLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColor.secondary.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_photo_alternate_rounded,
                          size: 26, color: AppColor.secondary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add Store Photos',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColor.textMain),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Show customers what your store looks like',
                      style: TextStyle(fontSize: 11, color: AppColor.grey),
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
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
                              ? Image.file(localImages[index],
                              fit: BoxFit.cover)
                              : Image.network(
                            urlImages[index - localImages.length],
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColor.lightGrey,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.primary),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (isLocal)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () =>
                                controller.removeStoreImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColor.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 11, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (totalCount < 5)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _OutlinedIconButton(
                    icon: Icons.add_rounded,
                    label: 'Add More Photos',
                    onTap: controller.pickStoreImages,
                    color: AppColor.secondary,
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
// Submit Button
// ─────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final VendorStoreController controller;
  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCreating = controller.isCreating.value;
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isCreating ? null : controller.createStore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            disabledBackgroundColor: AppColor.primarylite,
            foregroundColor: Colors.white,
            elevation: isCreating ? 0 : 4,
            shadowColor: AppColor.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isCreating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
              SizedBox(width: 12),
              Text(
                'Creating Store...',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3),
              ),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront_rounded, size: 20),
              SizedBox(width: 10),
              Text(
                'Create Store',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3),
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

  const _ActionBadge(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, size: 15, color: Colors.white),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
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
      color: AppColor.backgroundLight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const CircularProgressIndicator(
                  color: AppColor.primary, strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            const Text(
              'Loading Store Data...',
              style: TextStyle(
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}