import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopLogCard extends StatelessWidget {
  const WorkshopLogCard({super.key, required this.logCount});

  final int logCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Logs',
      description: logCount == 0 ? '로그 없음' : '최근 로그 $logCount개',
      icon: Icons.notes_outlined,
      onTap: () => _showLogSheet(context),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopLogSheet();
      },
    );
  }
}

class _WorkshopLogSheet extends ConsumerWidget {
  const _WorkshopLogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> logs = ref.watch(recentLogsProvider);

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '로그',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('로그가 없습니다'))
                : ListView(
                    children: logs.map((String entry) {
                      return ListTile(dense: true, title: Text(entry));
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
