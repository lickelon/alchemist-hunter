import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              detail.materialName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
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
                controller.extractMaterial(
                  detail.materialId,
                  profileId,
                  selectedTraits: _selectedTraits.isEmpty
                      ? null
                      : _selectedTraits.toList(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
