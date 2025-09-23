/// 앱 전체에서 사용하는 상수들을 정의
library;

class AppConstants {
  // 앱 정보
  static const String appName = 'My Best Fit';
  static const String appVersion = '1.0.0';

  // API 관련
  static const int currentUserId = 1; // 임시 사용자 ID

  // UI 관련
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;

  // 그리드 설정
  static const int productGridCrossAxisCount = 2;
  static const double productGridChildAspectRatio = 0.6;
  static const double productGridSpacing = 12.0;

  // 애니메이션
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 최대값
  static const int maxRecentSearches = 10;
  static const int maxRecentProducts = 20;
  static const int maxCartQuantity = 99;

  // 색상
  static const int primaryColorValue = 0xff1957ee;
  static const int errorColorValue = 0xffe74c3c;
  static const int successColorValue = 0xff27ae60;
  static const int warningColorValue = 0xfff39c12;
}

class CategoryConstants {
  // 카테고리 목록
  static const List<String> categories = [
    '전체',
    '티셔츠',
    '셔츠',
    '후드',
    '아우터',
    '바람막이',
    '청바지',
    '반바지',
    '바지',
    '신발',
    '액세서리',
  ];

  // 카테고리별 키워드 매핑
  static const Map<String, List<String>> categoryKeywords = {
    '티셔츠': ['티셔츠', '반팔', '긴팔', '맨투맨', '스웨터', '니트'],
    '셔츠': ['셔츠', '블라우스', '폴로', '데님셔츠'],
    '후드': ['후드', '후드티', '후드집업'],
    '아우터': ['자켓', '코트', '아우터', '블레이저', '베스트'],
    '바람막이': ['바람막이', '윈드브레이커'],
    '청바지': ['청바지', '진', '데님'],
    '반바지': ['반바지', '숏', '쇼츠'],
    '바지': ['바지', '팬츠', '슬랙스', '트레이닝복'],
    '신발': ['신발', '운동화', '스니커', '부츠', '샌들', '구두'],
    '액세서리': ['가방', '백팩', '시계', '향수', '오드퍼퓸', '벨트', '모자'],
  };
}

class ImageConstants {
  // 기본 이미지 URL
  static const String defaultProductImage =
      'https://via.placeholder.com/400x400/cccccc/666666?text=No+Image';

  // 프로모션 이미지
  static const List<String> promoImages = [
    "https://img.freepik.com/free-psd/fashion-clothes-banner-template_23-2148578502.jpg",
    "https://images.jkn.co.kr/data/images/full/904120/g-_-600-jpg.jpg?w=600",
    "https://cdn.news2day.co.kr/data2/content/image/2019/09/23/20190923306831.jpg",
  ];

  // 카테고리 이미지
  static const Map<String, String> categoryImages = {
    '티셔츠':
        'https://img.pikbest.com/photo/20250722/black-plain-t-shirt-on-white-background_11801689.jpg!w700wp',
    '셔츠': 'https://gdimg.gmarket.co.kr/3547131014/still/280?ver=1720253379',
    '후드':
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200&h=200&fit=crop&crop=center',
    '아우터':
        'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=200&h=200&fit=crop&crop=center',
    '바람막이':
        'https://common.image.cf.marpple.co/files/u_3928552/2024/4/original/044ad8664c9b94b7a4aa099c94efbe7581e018271.png?w=200&h=200&fit=crop&crop=center',
    '청바지':
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop&crop=center',
    '반바지':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQp7GGg_MgotkuMGdIhRD0PFgg2czdfRwjPBQ&s',
    '바지':
        'https://us.123rf.com/450wm/vitalily73/vitalily732003/vitalily73200300794/143245173-black-pants-isolated-on-white-background-fashion-men-s-trousers-top-view.jpg?ver=6',
    '신발':
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop&crop=center',
    '액세서리':
        'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=200&h=200&fit=crop&crop=center',
  };
}

class TextConstants {
  // 공통 텍스트
  static const String loading = '로딩 중...';
  static const String error = '오류가 발생했습니다';
  static const String retry = '다시 시도';
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String save = '저장';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String add = '추가';
  static const String search = '검색';
  static const String clear = '초기화';

  // 상품 관련
  static const String productAddedToCart = '장바구니에 추가되었습니다';
  static const String productAddedToFavorites = '관심상품에 추가되었습니다';
  static const String productRemovedFromFavorites = '관심상품에서 제거되었습니다';
  static const String noProductsFound = '상품을 찾을 수 없습니다';
  static const String noSearchResults = '검색 결과가 없습니다';

  // 카테고리 관련
  static const String allCategories = '전체';
  static const String popularProducts = '인기 상품';
  static const String recentProducts = '최근 본 상품';

  // 검색 관련
  static const String searchHint = '상품을 검색해보세요';
  static const String recentSearches = '최근 검색어';
  static const String popularSearches = '인기 검색어';
  static const String clearAllSearches = '전체 삭제';
}
