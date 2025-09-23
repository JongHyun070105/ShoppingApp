# 🏗️ 쇼핑 앱 아키텍처 완전 분석

## 📊 전체 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│                        UI Layer (Pages & Widgets)               │
├─────────────────────────────────────────────────────────────────┤
│  MainPage  │  SearchPage  │  FavoritesPage  │  ProfilePage     │
│  CartPage  │  ProductDetail                                   │
├─────────────────────────────────────────────────────────────────┤
│                    Widget Components                            │
│  HomeHeader │ HomeTabBar │ HomeContent │ RankingContent       │
│  ProductCard │ CategoryGrid │ PromoCarousel │ PopularProducts  │
├─────────────────────────────────────────────────────────────────┤
│                      Service Layer                              │
│  OptimizedAppState │ ProductService │ CartService │            │
│  FavoriteService │ SearchService │ RecentProductsService      │
├─────────────────────────────────────────────────────────────────┤
│                      Data Layer                                 │
│              SupabaseService (Database)                        │
├─────────────────────────────────────────────────────────────────┤
│                    External Services                            │
│              Supabase (PostgreSQL Database)                    │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 데이터 흐름

1. **UI → Service → Database**: 사용자 액션 → 서비스 로직 → DB 저장
2. **Database → Service → UI**: DB 변경 → 상태 업데이트 → UI 리렌더링
3. **State Management**: OptimizedAppState가 전체 앱 상태 관리
