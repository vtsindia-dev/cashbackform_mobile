import 'package:cashback_farms/features/about/screens/about_us.dart';
import 'package:cashback_farms/features/contact/screens/contact_us.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../common/images.dart';
import '../../../common/colours.dart';
import '../../../common/widget/imagepicker.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../home/controller/delete_account_controller.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, dynamic>? userData;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await SessionManager.getUserData();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String get _userFullName {
    if (userData == null) return 'User';
    final firstName = userData!['first_name'] ?? '';
    final lastName = userData!['last_name'] ?? '';
    if (firstName.isEmpty && lastName.isEmpty) return 'User';
    return '$firstName $lastName'.trim();
  }

  String get _userEmail {
    return userData?['email'] ?? 'Loading...';
  }

  String get _userProfileImage {
    return userData?['profile_image'] ?? "https://i.pravatar.cc/300?img=12";
  }
  DeleteAccountController deleteAccountController = Get.put(DeleteAccountController());

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
                  _menuOption(context, asset: Images.profile, title: 'Profile', onTap: () => Get.toNamed('/profile')),
                  _menuOption(context, asset: Images.plotMarketplace, title: 'Plot Properties', onTap: () => Get.toNamed('/plotMarket')),
                  _menuOption(context, asset: Images.GiooPlots, title: 'GIOO Plots', onTap: () => Get.toNamed('/gioo')),
                  _menuOption(context, asset: Images.syndicatePlots, title: 'Syndicate Plots', onTap: () => Get.toNamed('/syndicate')),
                  _menuOption(context, asset: Images.materialStore, title: 'Material Store', onTap: () => Get.toNamed('/materialStore')),
                  _menuOption(context, asset: Images.productEnquiry, title: 'My Product Enquiry', onTap: () => Get.toNamed('/myMaterialList')),
                  _menuOption(context, asset: Images.service, title: 'My Service Enquiry', onTap: () => Get.toNamed('/myServiceList')),
                  _menuOption(context, asset: Images.plotRegistered, title: 'My Property', onTap: () => Get.toNamed('/myProperty')),
                  _menuOption(context, asset: Images.plotRegistered, title: 'Buyed Gioo Plots', onTap: () => Get.toNamed('/ownedplotlist')),
                  _menuOption(context, asset: Images.plotRegistered, title: 'Buyed Syndicate Plots', onTap: () => Get.toNamed('/ownedSyndicatePlotList')),
                  _menuOption(context, asset: Images.plotRegistered, title: 'My Residential Plots', onTap: () => Get.toNamed('/myResidential')),
                  _menuOption(context, asset: Images.plotRegistered, title: 'My Residential Enquiry', onTap: () => Get.toNamed('/myResidentialEnquiry')),
                  _menuOption(context, asset: Images.aboutUs, title: 'About Us', onTap: () => Get.to(()=>AboutUs())),
                  _menuOption(context, asset: Images.contactUs, title: 'Contact Us', onTap: () => Get.to(()=>ContactUs())),
                  _menuOption(context, asset: Images.logout, title: 'Logout', onTap: () => _showLogoutConfirmation(context)),
                  _menuOption(context, asset: Images.delete, title: 'Delete Account', delete: true, onTap: () => _showDeleteAccountConfirmation(context),
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
              imageUrl: _userProfileImage,
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
              child: Text(
                 _userFullName,
                style: const TextStyle(
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
                _userEmail,
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
              color: delete ? Colors.red : AppColor.primary,
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
  void _showLogoutConfirmation(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.white,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Image.asset(
                  Images.logout,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                    color: AppColor.black,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: AppColor.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(() {
          final isDeleting = deleteAccountController.isDeleting.value;

          return AlertDialog(
            backgroundColor: AppColor.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Image.asset(Images.delete),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: isDeleting
                            ? null
                            : () async {
                          await deleteAccountController.deleteAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }


  Future<void> _performLogout() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      await SessionManager.clearSession();
      Get.offAllNamed(AppRoutes.login);
      SnackBarHelper.showSuccess("You have been successfully logged out");

    } catch (e) {
      Get.back();
      SnackBarHelper.showError("Failed to logout: $e");

    }
  }
  Future<void> _performDeleteAccount() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      await Future.delayed(const Duration(seconds: 2));
      await SessionManager.clearSession();
      Get.offAllNamed(AppRoutes.login);
      SnackBarHelper.showSuccess("Your account has been permanently deleted");

    } catch (e) {
      Get.back();
      SnackBarHelper.showError("Failed to delete account:  $e");
    }
  }
}