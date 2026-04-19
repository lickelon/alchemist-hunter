import 'package:flutter/material.dart';

/// UI 전체에서 사용하는 모서리 반경 상수.
///
/// 사용 가이드
/// - [sm] 8pt  : 카드·컨테이너 테두리 (ListCard, 구분선 박스 등)
/// - [md] 12pt : 인터랙티브 요소 탭 영역 (InkWell, 미리보기 섹션 등)
/// - [lg] 16pt : 대형 컨테이너 (향후 확장용)
class AppRadius {
  const AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;

  /// 카드·컨테이너용 BorderRadius
  static const BorderRadius card = BorderRadius.all(Radius.circular(sm));

  /// 인터랙티브 탭 영역용 BorderRadius
  static const BorderRadius interactive = BorderRadius.all(Radius.circular(md));
}
