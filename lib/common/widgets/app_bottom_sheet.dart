import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

/// 모달 바텀 시트의 표준 래퍼.
///
/// 기존 코드에서 시트마다 하드코딩되던 `SizedBox(height: screenHeight * X)` 패턴을
/// 대체한다. 화면 높이의 90 %를 상한으로 하여 기기·방향에 관계없이 안전하게 동작한다.
///
/// 사용 예
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => AppBottomSheet(child: MySheetContent()),
/// );
/// ```
///
/// [child]는 보통 [Column] + [Expanded] 조합으로 사용한다.
/// 내부 [ListView]의 스크롤은 [Expanded] 안에서 처리한다.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
