import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
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
      summary: logCount == 0 ? '로그 없음' : '최근 로그 $logCount개',
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
      child: AppSheetLayout(
        title: '로그',
        body: logs.isEmpty
            ? const Center(child: Text('로그가 없습니다'))
            : ListView(
                children: logs.map((String entry) {
                  return ListTile(dense: true, title: Text(entry));
                }).toList(),
              ),
      ),
    );
  }
}
