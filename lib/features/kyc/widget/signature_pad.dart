// widgets/signature_pad.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/kyc_controller.dart';

class SignaturePadWidget extends StatefulWidget {
  final KYCController controller;

  const SignaturePadWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _SignaturePadWidgetState createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget>
    with SingleTickerProviderStateMixin {
  late final SignatureController _signatureController;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  bool _hasDrawn = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2.5,
      penColor: AppColor.textMain,
      exportBackgroundColor: AppColor.white,
    );
    _signatureController.addListener(() {
      final drawn = _signatureController.isNotEmpty;
      if (drawn != _hasDrawn) {
        setState(() => _hasDrawn = drawn);
      }
    });

    _animController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 350));
    _scaleAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (!_signatureController.isNotEmpty) {
      Get.snackbar(
        'Empty Signature',
        'Please draw your signature before saving',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.warning,
        colorText: AppColor.white,
        margin: EdgeInsets.all(16),
      );
      return;
    }

    try {
      Get.dialog(
        _LoadingDialog(),
        barrierDismissible: false,
      );

      final image = await _signatureController.toImage();
      final byteData = await image?.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        widget.controller.capturedSignature.value = file;
        widget.controller.signDoc.value = file;

        Get.back(); // close loading
        Get.back(); // close pad

        Get.snackbar(
          'Signature Saved',
          'Your signature has been saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.success,
          colorText: AppColor.white,
          margin: EdgeInsets.all(16),
          icon: Icon(Icons.check_circle_rounded, color: AppColor.white),
        );
      } else {
        Get.back();
        _showError('Could not process signature image. Try again.');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showError('Failed to save signature: $e');
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.error,
      colorText: AppColor.white,
      margin: EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        backgroundColor: AppColor.backgroundLight,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              _buildCanvas(),
              SizedBox(height: 16),
              _buildHint(),
              SizedBox(height: 20),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.draw_rounded, color: AppColor.accent, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Draw Signature',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textMain,
                ),
              ),
              Text(
                'Use your finger to sign below',
                style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: AppColor.textSecondary),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildCanvas() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasDrawn
              ? AppColor.accent.withOpacity(0.4)
              : AppColor.lightGrey,
          width: _hasDrawn ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Signature(
              controller: _signatureController,
              height: double.infinity,
              backgroundColor: AppColor.white,
            ),
          ),
          if (!_hasDrawn)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gesture_rounded, size: 36, color: AppColor.lightGrey),
                  SizedBox(height: 8),
                  Text(
                    'Sign here',
                    style: TextStyle(color: AppColor.lightGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
          // Baseline guide
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Container(width: 12, height: 1.5, color: AppColor.grey.withOpacity(0.3)),
                Expanded(
                  child: Container(height: 1, color: AppColor.lightGrey),
                ),
                Container(width: 12, height: 1.5, color: AppColor.grey.withOpacity(0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, size: 13, color: AppColor.grey),
        SizedBox(width: 4),
        Text(
          'Signature will be saved as PNG image',
          style: TextStyle(color: AppColor.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _signatureController.clear();
              setState(() => _hasDrawn = false);
            },
            icon: Icon(Icons.refresh_rounded, size: 18),
            label: Text('Clear'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColor.textSecondary,
              side: BorderSide(color: AppColor.lightGrey),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _hasDrawn ? _saveSignature : null,
            icon: Icon(Icons.check_rounded, size: 18),
            label: Text('Save Signature'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.accent,
              foregroundColor: AppColor.white,
              disabledBackgroundColor: AppColor.lightGrey,
              disabledForegroundColor: AppColor.grey,
              padding: EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────
// Loading Dialog
// ────────────────────────────────────────────
class _LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.accent),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Saving signature...',
              style: TextStyle(
                color: AppColor.textMain,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}