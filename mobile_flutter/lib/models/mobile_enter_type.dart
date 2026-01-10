enum MobileEnterType { vocabulary, grammar, kana, profile }

String mobileEnterTypeParam(MobileEnterType t) {
  switch (t) {
    case MobileEnterType.grammar:
      return 'grammar';
    case MobileEnterType.vocabulary:
      return 'vocabulary';
    case MobileEnterType.kana:
      return 'kana';
    case MobileEnterType.profile:
      return 'profile';
  }
}
