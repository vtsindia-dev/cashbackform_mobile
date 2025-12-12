import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../controller/materialstore_controller.dart';
import '../widget/material_list.dart';
class MaterialStore extends StatefulWidget {
  const MaterialStore({super.key});

  @override
  State<MaterialStore> createState() => _MaterialStoreState();
}
class _MaterialStoreState extends State<MaterialStore> {
  final MaterialController controller = Get.put(MaterialController());

  @override
  void initState() {
    super.initState();
    controller.fetchMaterials();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: "Material Store",
        showBackButton: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: GifLoader(
              message: "Loading...",
              size: 100,
            ),
          );
        }
        if (controller.materials.isEmpty) {
          return const Center(
            child: GifLoader(
              message: "Loading...",
              size: 100,
            ),
          );
        }
        return MaterialListScreen();
      }),
    );
  }
}
