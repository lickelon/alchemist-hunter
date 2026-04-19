import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

/// 기능 카드 목록에서 공통으로 사용하는 카드 위젯.
///
/// 탭 시 상세 시트를 여는 용도와 버튼 액션이 있는 두 가지 형태를 지원한다.
class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.name,
    required this.description,
    this.buttonText,
    this.icon = Icons.shield,
    this.onTap,
    this.onButtonPressed,
  });

  final String name;
  final String description;
  final String? buttonText;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: AppRadius.card,
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon),
          title: Text(name),
          subtitle: Text(description),
          trailing: buttonText == null
              ? const Icon(Icons.chevron_right)
              : ElevatedButton(
                  onPressed: onButtonPressed ?? onTap,
                  child: Text(buttonText!),
                ),
        ),
      ),
    );
  }
}
