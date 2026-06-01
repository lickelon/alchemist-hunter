import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/craft_queue_submit_results.dart';
import 'package:alchemist_hunter/features/workshop/craft_queue/presentation/viewmodels/workshop_craft_queue_controller_provider.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/use_cases/workshop_brew_experiment_use_case.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_result_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopBrewExperimentResultDialog extends ConsumerWidget {
  const WorkshopBrewExperimentResultDialog({
    super.key,
    required this.result,
    required this.potionId,
    required this.potionName,
  });

  final WorkshopBrewExperimentSubmitResult result;
  final String? potionId;
  final String? potionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = switch (result.status) {
      WorkshopBrewExperimentStatus.success => '실험 결과',
      WorkshopBrewExperimentStatus.elementMissing => '원소 부족',
      WorkshopBrewExperimentStatus.unknownReaction => '알 수 없는 반응',
      WorkshopBrewExperimentStatus.failed => '실험 실패',
    };
    final bool canPinRecipe =
        result.status == WorkshopBrewExperimentStatus.success &&
        !result.isNewDiscovery &&
        result.potionId != null &&
        result.discoveredTraits != null &&
        result.qualityGrade != null;

    return AppDialogLayout(
      title: title,
      body: WorkshopBrewExperimentResultBody(
        result: result,
        potionId: potionId,
        potionName: potionName,
        onPinRecipe: canPinRecipe
            ? () {
                ref
                    .read(workshopCraftQueueControllerProvider)
                    .pinBrewExperimentRecipe(
                      potionId: result.potionId!,
                      discoveredTraits: result.discoveredTraits!,
                      grade: result.qualityGrade!,
                    );
                AppToast.show(context, '레시피 비율을 고정했습니다');
                Navigator.of(context).pop();
              }
            : null,
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          label: const Text('닫기'),
        ),
      ],
    );
  }
}
