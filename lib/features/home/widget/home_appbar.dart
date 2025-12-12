import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../drawer/screen/drawer.dart';
import '../controller/homecontroller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeAppBar({
    super.key,
    required this.controller,
    required this.scaffoldKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(Images.appbarBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                // Logo
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Image.asset(
                      Images.logo,
                      height: 80,
                    ),
                  ),
                ),

                // 🔥 Wrap Location text area with Obx
                Expanded(
                  child: InkWell(
                    onTap: () => controller.refreshLocation(),
                    child: Obx(() => _buildLocationText()),
                  ),
                ),

                // Menu Button
                SizedBox(
                  width: 80,
                  child: Center(
                    child: _buildIconButton(
                      image: Images.menu,
                      onTap: () => scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // LOCATION TEXT VIEW
  // ================================
  Widget _buildLocationText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: AppColor.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              controller.areaName.isNotEmpty
                  ? controller.areaName.toString()
                  : "Fetching...",
              style: const TextStyle(
                fontSize: 16,
                color: AppColor.black,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),

        if (controller.fullAddress.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              controller.fullAddress.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColor.black,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  // ================================
  // MENU ICON BUTTON
  // ================================
  Widget _buildIconButton({
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          image,
          width: 20,
          height: 20,
          color: AppColor.primary,
        ),
      ),
    );
  }
}
