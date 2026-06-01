import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_equipment_view_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<TownForgeJob>> townForgeQueueProvider =
    Provider<List<TownForgeJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.town.forgeQueue,
        ),
      );
    });

final Provider<int> townForgeInProgressCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townForgeQueueProvider.select(
      (List<TownForgeJob> jobs) => jobs
          .where(
            (TownForgeJob job) => job.status != TownForgeJobStatus.completed,
          )
          .length,
    ),
  );
});

final Provider<int> townForgeCompletedCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townForgeQueueProvider.select(
      (List<TownForgeJob> jobs) => jobs
          .where(
            (TownForgeJob job) => job.status == TownForgeJobStatus.completed,
          )
          .length,
    ),
  );
});

final Provider<List<TownForgeJobView>> townForgeJobViewsProvider =
    Provider<List<TownForgeJobView>>((Ref ref) {
      final List<TownForgeJob> jobs = ref.watch(townForgeQueueProvider);
      final List<TownForgeJob> sorted = <TownForgeJob>[...jobs]
        ..sort((TownForgeJob left, TownForgeJob right) {
          if (left.status == right.status) {
            return left.queuedAt.compareTo(right.queuedAt);
          }
          return left.status == TownForgeJobStatus.completed ? 1 : -1;
        });
      return sorted
          .map((TownForgeJob job) {
            final bool completed = job.status == TownForgeJobStatus.completed;
            return TownForgeJobView(
              id: job.id,
              name: job.name,
              statusLabel: completed
                  ? '완료'
                  : job.status == TownForgeJobStatus.processing
                  ? '제작 중'
                  : '대기 중',
              remainingLabel: completed
                  ? '수령 대기'
                  : '남은 시간 ${job.remaining.inSeconds}s',
              canClaim: completed,
            );
          })
          .toList(growable: false);
    });
