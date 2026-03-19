import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

import 'workshop_extraction_profile_list.dart';

class WorkshopMaterialExtractionDetail extends ConsumerStatefulWidget {
  const WorkshopMaterialExtractionDetail({super.key, required this.materialId});

  final String materialId;

  @override
  ConsumerState<WorkshopMaterialExtractionDetail> createState() =>
      _WorkshopMaterialExtractionDetailState();
}

class _WorkshopMaterialExtractionDetailState
    extends ConsumerState<WorkshopMaterialExtractionDetail> {
  final Set<String> _selectedTraits = <String>{};
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final MaterialExtractionDetailView? detail = ref.watch(
      materialExtractionDetailViewProvider(widget.materialId),
    );
    final WorkshopExtractionController controller = ref.read(
      workshopExtractionControllerProvider,
    );
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final int selectedQuantity = _quantity > detail.ownedQuantity
        ? detail.ownedQuantity
        : _quantity;
    final List<int> quantityOptions = <int>{
      1,
      if (detail.ownedQuantity >= 5) 5,
      if (detail.ownedQuantity >= 10) 10,
      detail.ownedQuantity,
    }.where((int value) => value > 0).toList()..sort();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (BuildContext sheetContext) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        detail.materialName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('보유 ${detail.ownedQuantity}개'),
                      const SizedBox(height: 8),
                      const Text('추출 수량', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: quantityOptions.map((int quantity) {
                          final bool selected = quantity == selectedQuantity;
                          final String label = quantity == detail.ownedQuantity
                              ? '최대'
                              : 'x$quantity';
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _quantity = quantity;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('분석 결과', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: detail.traits.map((ExtractionTraitOptionView trait) {
                          final bool selected = _selectedTraits.contains(trait.id);
                          return FilterChip(
                            label: Text(
                              '${trait.name} ${trait.amount.toStringAsFixed(2)}',
                            ),
                            selected: selected,
                            onSelected: (bool value) {
                              setState(() {
                                if (value) {
                                  _selectedTraits.add(trait.id);
                                } else {
                                  _selectedTraits.remove(trait.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('추출 프로필', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      WorkshopExtractionProfileList(
                        profiles: detail.profiles,
                        hasSelection: _selectedTraits.isNotEmpty,
                        onExtract: (String profileId) {
                          final WorkshopExtractionSubmitResult result =
                              controller.extractMaterial(
                            detail.materialId,
                            profileId,
                            quantity: selectedQuantity,
                            selectedTraits: _selectedTraits.isEmpty
                                ? null
                                : _selectedTraits.toList(),
                          );
                          if (result == WorkshopExtractionSubmitResult.success) {
                            Navigator.of(sheetContext).pop();
                            return;
                          }
                          final String message =
                              result == WorkshopExtractionSubmitResult.queueFull
                              ? '작업실 큐가 가득 찼습니다'
                              : '추출 등록에 실패했습니다';
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
