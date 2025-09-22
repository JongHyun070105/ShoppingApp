class PriceFormatter {
  /// 가격을 천 단위 구분자가 있는 문자열로 변환
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  /// 문자열 가격을 천 단위 구분자가 있는 문자열로 변환
  static String formatPriceString(String price) {
    final priceInt = int.tryParse(price) ?? 0;
    return formatPrice(priceInt);
  }
}
