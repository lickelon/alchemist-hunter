/// UI 전체에서 사용하는 간격 상수.
///
/// 사용 가이드
/// - [xs]  2pt : 서브레이블 등 극소 간격
/// - [sm]  4pt : 아이콘·칩 간격 등 소형 간격
/// - [md]  8pt : 요소 간 표준 간격 (가장 자주 사용)
/// - [lg] 12pt : 카드·섹션 내부 패딩, 섹션 구분
/// - [xl] 16pt : 상세 시트·폼 상단 여백
/// - [xxl] 24pt : 대형 섹션 구분
class AppSpacing {
  const AppSpacing._();

  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
}
