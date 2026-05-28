String mercenaryTierLabel(int tierIndex) {
  switch (tierIndex) {
    case 1:
      return 'Rookie';
    case 2:
      return 'Veteran';
    case 3:
      return 'Elite';
    case 4:
      return 'Champion';
    default:
      return 'Legend';
  }
}
