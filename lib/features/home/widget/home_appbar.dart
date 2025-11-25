import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../controller/homecontroller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeAppBar({super.key, required this.controller});

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
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Image.asset(
                      Images.logo,
                      height: 80,
                    ),
                  ),
                ),

                Expanded(
                  child: InkWell(
                    onTap: () => controller.refreshLocation(),
                    child: _buildLocationText(),
                  ),
                ),

                SizedBox(
                  width: 80,
                  child: Center(
                    child: _buildIconButton(
                      image: Images.profile,
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            )

          ),
        ),
      ),
    );
  }

  Widget _buildLocationText() {
    return Column(
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
              controller.areaName.isNotEmpty ? controller.areaName : "Fetching...",
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
              controller.fullAddress,
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
  Widget _buildIconButton({
    required String image,
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