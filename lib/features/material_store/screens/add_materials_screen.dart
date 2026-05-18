import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:cashback_farms/features/material_store/model/added_materials_list_model.dart'
as added_materials_list_model;
import 'package:cashback_farms/features/material_store/model/materials_type_list_model.dart'
as materials_type_list_model;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddMaterialsScreen extends StatefulWidget {
  const AddMaterialsScreen({super.key});

  @override
  State<AddMaterialsScreen> createState() => _AddMaterialsScreenState();
}

class _AddMaterialsScreenState extends State<AddMaterialsScreen> {
  final MaterialController controller = Get.put(MaterialController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAddedMaterialsList();
    });
  }


  void _openAddMaterialSheet() {
    controller.fetchMaterialsTypeList();

    materials_type_list_model.MaterialsTypeListModel? selectedMaterial;
    List<materials_type_list_model.Brand> selectedBrands = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return GetBuilder<MaterialController>(
              builder: (ctrl) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Material',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GetBuilder<MaterialController>(
                          builder: (ctrl) {
                            if (ctrl.isMaterialsTypeLoading) {
                              return Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6B8E23),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return _buildDropdown<
                                materials_type_list_model
                                    .MaterialsTypeListModel>(
                              hint: 'Select Material',
                              value: selectedMaterial,
                              items: ctrl.materialsTypeListModel,
                              itemLabel: (item) =>
                              item.materialName ?? '',
                              onChanged: (val) {
                                setSheetState(() {
                                  selectedMaterial = val;
                                  selectedBrands.clear();
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (selectedMaterial != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Brands',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if ((selectedMaterial?.brand ?? [])
                                    .isEmpty)
                                  Text(
                                    'No brands available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ...(selectedMaterial?.brand ?? [])
                                    .map((brand) {
                                  final isSelected =
                                  selectedBrands.any(
                                          (e) => e.id == brand.id);
                                  return CheckboxListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                    ListTileControlAffinity.leading,
                                    activeColor:
                                    const Color(0xFF6B8E23),
                                    value: isSelected,
                                    title: Text(
                                      brand.name ?? '',
                                      style: const TextStyle(
                                          fontSize: 14),
                                    ),
                                    onChanged: (value) {
                                      setSheetState(() {
                                        if (value == true) {
                                          final alreadyExists =
                                          selectedBrands.any(
                                                  (e) =>
                                              e.id ==
                                                  brand.id);
                                          if (!alreadyExists) {
                                            selectedBrands
                                                .add(brand);
                                          }
                                        } else {
                                          selectedBrands
                                              .removeWhere((e) =>
                                          e.id == brand.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                            ctrl.isVendorMaterialsRequestLoading ==
                                true
                                ? null
                                : () async {
                              if (selectedMaterial == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please select a material'),
                                    backgroundColor:
                                    Colors.red,
                                  ),
                                );
                                return;
                              }
                              ctrl.clearMaterialSelection();
                              ctrl.setMaterialId(
                                  selectedMaterial!.id
                                      ?.toString() ??
                                      '');
                              ctrl.setBrandIds(
                                selectedBrands
                                    .map((e) =>
                                    e.id.toString())
                                    .toList(),
                              );
                              final success = await ctrl
                                  .vendorMaterialsRequest();
                              if (success) {
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF6B8E23),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child:
                            ctrl.isVendorMaterialsRequestLoading ==
                                true
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMaterialDetailSheet(
      added_materials_list_model.AddedMaterialsListModel material,
      MaterialController ctrl,
      ) {
    final brands = material.material?.brand ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        material.material?.materialName ?? '-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(child: _buildDetailImage(material)),
                const SizedBox(height: 24),
                _sectionLabel('Material Info'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.grey.shade100),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _detailRow(
                        icon: Icons.tag_rounded,
                        label: 'Material ID',
                        value: '#000${material.id ?? '-'}',
                      ),
                      _detailDivider(),
                      _detailRow(
                        icon: Icons.category_outlined,
                        label: 'Material Name',
                        value: material
                            .material?.materialName ??
                            '-',
                      ),
                      _detailDivider(),
                      _detailRow(
                        icon: Icons.verified_outlined,
                        label: 'Status',
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B8E23)
                                .withValues(alpha: 0.12),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A6315),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _sectionLabel('All Brands'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${brands.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                brands.isEmpty
                    ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text(
                        'No brands available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
                    : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brands.map((b) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E23)
                            .withValues(alpha: 0.10),
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6B8E23)
                              .withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        b.name ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A6315),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDeleteDialog(material, ctrl, 0);
                    },
                    icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 18),
                    label: const Text(
                      'Remove this material',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.red
                              .withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _detailDivider() =>
      Divider(height: 1, color: Colors.grey.shade100);

  Widget _detailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF6B8E23).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF6B8E23),
            ),
          ),

          const SizedBox(width: 12),

          /// Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                valueWidget ??
                    Text(
                      value ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildDetailImage(
      added_materials_list_model.AddedMaterialsListModel material) {
    final images = (material.material?.image ?? [])
        .where((e) =>
    e.toString().toLowerCase().endsWith('.jpg') ||
        e.toString().toLowerCase().endsWith('.jpeg') ||
        e.toString().toLowerCase().endsWith('.png') ||
        e.toString().toLowerCase().endsWith('.webp'))
        .toList();

    if (images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          images.first,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackDetailImage(),
        ),
      );
    }
    return _fallbackDetailImage();
  }

  Widget _fallbackDetailImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(Icons.image_outlined,
          color: Colors.grey.shade400, size: 36),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding:
      const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade600),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }


  void _showDeleteDialog(
      added_materials_list_model.AddedMaterialsListModel material,
      MaterialController ctrl,
      int index,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.only(
            bottom: 16, right: 16, left: 16),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete Material',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove '
              '"${material.material?.materialName}"?',
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ctrl.deleteVendorMaterial(
                        material.id.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Delete',
                      style: TextStyle(
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Material Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Brand',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'Image',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      added_materials_list_model.AddedMaterialsListModel material,
      MaterialController ctrl,
      int index,
      ) {
    final brands = material.material?.brand ?? [];
    final visibleBrands = brands.take(2).toList();
    final remainingCount = brands.length - visibleBrands.length;

    return InkWell(
      onTap: () => _showMaterialDetailSheet(material, ctrl),
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.material?.materialName ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: brands.isEmpty
                  ? Text(
                'No brand',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              )
                  : Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ...visibleBrands.map(
                        (b) => Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E23)
                            .withValues(alpha: 0.10),
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color:
                          const Color(0xFF6B8E23)
                              .withValues(
                              alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        b.name ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A6315),
                        ),
                      ),
                    ),
                  ),
                  if (remainingCount > 0)
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                            color:
                            Colors.grey.shade300),
                      ),
                      child: Text(
                        '+$remainingCount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 50,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Center(
                  child: (() {
                    final images =
                    (material.material?.image ?? [])
                        .where((e) =>
                    e
                        .toString()
                        .toLowerCase()
                        .endsWith('.jpg') ||
                        e
                            .toString()
                            .toLowerCase()
                            .endsWith('.jpeg') ||
                        e
                            .toString()
                            .toLowerCase()
                            .endsWith('.png') ||
                        e
                            .toString()
                            .toLowerCase()
                            .endsWith('.webp'))
                        .toList();
                    if (images.isNotEmpty) {
                      return ClipRRect(
                        borderRadius:
                        BorderRadius.circular(8),
                        child: Image.network(
                          images.first,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildFallbackImage(),
                        ),
                      );
                    }
                    return _buildFallbackImage();
                  })(),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Center(
                  child: InkWell(
                    onTap: ctrl.isDeleteMaterialLoading &&
                        ctrl.deletingMaterialId ==
                            material.id.toString()
                        ? null
                        : () => _showDeleteDialog(
                        material, ctrl, index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.red
                            .withValues(alpha: 0.06),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: ctrl.isDeleteMaterialLoading &&
                          ctrl.deletingMaterialId ==
                              material.id.toString()
                          ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                          : Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(Icons.image_outlined,
          color: Colors.grey.shade400, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: DynamicAppBar(
        title: 'Add Material List',
        showBackButton: true,
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _openAddMaterialSheet,
            icon: const Icon(Icons.add, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E23),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF6B8E23)
                  .withValues(alpha: 0.3),
            ),
            label: const Text(
              'Add Material',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<MaterialController>(
        builder: (ctrl) {
          if (ctrl.isAddedMaterialsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B8E23),
                strokeWidth: 3,
              ),
            );
          }

          if (ctrl.addedMaterialsListModel.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No materials added yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add Material" to get started.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 80),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: ctrl
                          .addedMaterialsListModel.length,
                      separatorBuilder: (_, __) =>
                          Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                      itemBuilder: (context, index) {
                        final material = ctrl
                            .addedMaterialsListModel[index];
                        return _buildTableRow(
                            material, ctrl, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}