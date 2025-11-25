import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/images.dart';
import '../../../common/colours.dart';
import '../../../common/widget/imagepicker.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.72,
      child: Drawer(
        backgroundColor: AppColor.white,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuOption(context, asset: Images.profile, title: 'Profile', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.plotMarketplace, title: 'Plot Properties', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.GiooPlots, title: 'GIOO Plots', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.syndicatePlots, title: 'Syndicate Plots', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.materialStore, title: 'Material Store', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.productEnquiry, title: 'My Product Enquiry', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.service, title: 'My Service Enquiry', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.aboutUs, title: 'About Us', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.contactUs, title: 'Contact Us', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.logout, title: 'Logout', onTap: () => Navigator.pop(context)),
                  _menuOption(context, asset: Images.delete, title: 'Delete Account', delete: true, onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primary,
            AppColor.primary.withOpacity(0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            ImagePickerWidget(
              isPicker: false,
              imageUrl: "https://i.pravatar.cc/300?img=12",
            )
                .animate()
                .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 600.ms)
                .then()
                .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.4)),
            const SizedBox(height: 12),

            Animate(
              effects: [
                FadeEffect(duration: 600.ms),
                MoveEffect(begin: Offset(-20, 0), duration: 600.ms),
              ],
              child: const Text(
                'Tobi Jr',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 4),
            Animate(
              effects: [
                FadeEffect(duration: 600.ms, delay: 150.ms),
                MoveEffect(begin: Offset(-20, 0), duration: 600.ms, delay: 150.ms),
              ],
              child: Text(
                'tobijr.@example.com',
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _menuOption(
      BuildContext context, {
        required String asset,
        required String title,
        required VoidCallback onTap,
        bool delete = false,
      }) {
    return Column(
      children: [
        Animate(
          effects: [
            FadeEffect(duration: 450.ms),
            MoveEffect(begin: Offset(-14, 0), duration: 450.ms),
          ],
          child: ListTile(
            leading: Image.asset(
              asset,
              width: 20,
              height: 20,
              color: delete ? Colors.red : AppColor.primary, // RED only for delete
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: delete ? Colors.red : Colors.black,
                fontWeight: delete ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: onTap,
          ),
        ),
        Animate(
          effects: [
            FadeEffect(duration: 450.ms, delay: 100.ms),
            MoveEffect(begin: Offset(-10, 0), duration: 450.ms, delay: 100.ms),
          ],
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: List.generate(26, (index) {
                return Container(
                  width: 4,
                  height: 2,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 4),
      ],
    );
  }
}
