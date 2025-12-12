import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../../features/home/controller/homecontroller.dart';
class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController? controller;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String title;
  final bool showBackButton;
  final bool showDrawerButton;
  final bool showLocation;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color textColor;

  const DynamicAppBar({
    super.key,
    this.controller,
    this.scaffoldKey,
    required this.title,
    this.showBackButton = false,
    this.showDrawerButton = false,
    this.showLocation = false,
    this.actions,
    this.onBackPressed,
    this.backgroundColor = Colors.transparent,
    this.textColor = AppColor.black,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
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
        image: backgroundColor == Colors.transparent
            ? DecorationImage(
          image: AssetImage(Images.appbarBg),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildLeftSection(),
              Expanded(
                child: _buildMiddleSection(),
              ),
              _buildRightSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSection() {
    return SizedBox(
      width: 80,
      child: Row(
        children: [
          if (showBackButton)
            _buildIconButton(
              icon: Icons.arrow_back,
              onTap: onBackPressed ?? () => Get.back(),
            ),

          if (showDrawerButton && scaffoldKey != null)
            _buildIconButton(
              icon: Icons.menu,
              onTap: () => scaffoldKey!.currentState?.openDrawer(),
            ),
        ],
      ),
    );
  }

  Widget _buildMiddleSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showLocation && controller != null)
          _buildLocationText()
        else
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildRightSection() {
    return SizedBox(
      width: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (actions != null) ...actions!,
          if (actions == null && !showLocation && scaffoldKey != null)
            _buildIconButton(
              image: Images.profile,
              onTap: () => scaffoldKey!.currentState?.openDrawer(),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationText() {
    return InkWell(
      onTap: () => controller?.refreshLocation(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: AppColor.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                controller!.areaName.isNotEmpty ? controller!.areaName.toString() : "Fetching...",
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          if (controller!.fullAddress.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                controller!.fullAddress.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    IconData? icon,
    String? image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: icon != null
            ? Icon(
          icon,
          size: 20,
          color: AppColor.primary,
        )
            : Image.asset(
          image!,
          width: 20,
          height: 20,
          color: AppColor.primary,
        ),
      ),
    );
  }
}