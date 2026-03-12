import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopExtractionCard extends StatelessWidget {
  const WorkshopExtractionCard({
    super.key,
    required this.materialTypeCount,
    required this.extractedTraitTypeCount,
  });

  final int materialTypeCount;
  final int extractedTraitTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Extraction',
      description:
          '재료 $materialTypeCount종 / 추출 특성 $extractedTraitTypeCount종',
      icon: Icons.biotech_outlined,
      onTap: () => _showExtractionSheet(context),
    );
  }

  void _showExtractionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopExtractionSheet();
      },
    );
  }
}

class _WorkshopExtractionSheet extends ConsumerWidget {
  const _WorkshopExtractionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );
    final List<ExtractedTraitInventoryView> extractedTraits = ref.watch(
      extractedTraitViewsProvider,
    );
    final Map<String, MaterialEntity> materialMap = <String, MaterialEntity>{
      for (final MaterialEntity material in ref.watch(materialsProvider))
        material.id: material,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '추출',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                '보유 추출 특성',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 72,
                child: extractedTraits.isEmpty
                    ? const Center(child: Text('추출된 특성이 없습니다'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          final ExtractedTraitInventoryView entry =
                              extractedTraits[index];
                          return Chip(
                            label: Text(
                              '${entry.name} ${entry.amount.toStringAsFixed(2)}',
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemCount: extractedTraits.length,
                      ),
              ),
              const Divider(),
              const Text(
                '재료 선택',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: materials.isEmpty
                    ? const Center(child: Text('추출 가능한 재료가 없습니다'))
                    : ListView.builder(
                        itemCount: materials.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MaterialInventoryView entry = materials[index];
                          final MaterialEntity? material = materialMap[entry.id];
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text(
                              '${entry.rarity.name} / ${entry.traitSummary}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: material == null
                                  ? null
                                  : () {
                                      _showMaterialExtractionDetail(
                                        context,
                                        ref,
                                        material,
                                      );
                                    },
                              child: const Text('분석/추출'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaterialExtractionDetail(
    BuildContext context,
    WidgetRef ref,
    MaterialEntity material,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _MaterialExtractionDetail(material: material);
      },
    );
  }
}

class _MaterialExtractionDetail extends ConsumerStatefulWidget {
  const _MaterialExtractionDetail({required this.material});

  final MaterialEntity material;

  @override
  ConsumerState<_MaterialExtractionDetail> createState() =>
      _MaterialExtractionDetailState();
}

class _MaterialExtractionDetailState
    extends ConsumerState<_MaterialExtractionDetail> {
  final Set<String> _selectedTraits = <String>{};

  @override
  Widget build(BuildContext context) {
    final WorkshopController controller = ref.read(workshopControllerProvider);
    final List<TraitUnit> analyzed = ref
        .read(alchemyServiceProvider)
        .analyzeMaterial(widget.material);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.material.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              '분석 결과',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: analyzed.map((TraitUnit trait) {
                final bool selected = _selectedTraits.contains(trait.id);
                return FilterChip(
                  label: Text(
                    '${trait.name} ${trait.potency.toStringAsFixed(2)}',
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
            const Text(
              '추출 프로필',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ...DummyData.extractionProfiles.map((ExtractionProfile profile) {
              final bool selectable =
                  profile.mode == ExtractionMode.full ||
                  _selectedTraits.isNotEmpty;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  profile.mode == ExtractionMode.full ? '전체 추출' : '선택 추출',
                ),
                subtitle: Text(
                  '수율 ${profile.yieldRate.toStringAsFixed(2)} / 순도 ${profile.purityRate.toStringAsFixed(2)}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: selectable
                      ? () {
                          controller.extractMaterial(
                            widget.material.id,
                            profile.id,
                            selectedTraits: profile.mode == ExtractionMode.selective
                                ? _selectedTraits.toList()
                                : null,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('추출'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
