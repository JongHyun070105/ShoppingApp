import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/app_state.dart';
import '../utils/price_formatter.dart';
import '../widgets/product_option_dialog.dart';

class ProductDetail extends StatefulWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      // 실제 구현에서는 SupabaseService.getReviews(widget.product.id!) 호출
      await Future.delayed(const Duration(seconds: 1)); // 임시 지연
      _reviews = _getMockReviews();

      // AppState에 리뷰 개수 업데이트
      if (widget.product.id != null) {
        context.read<AppState>().setReviewCount(
          widget.product.id!,
          _reviews.length,
        );
      }
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  List<Review> _getMockReviews() {
    return [
      Review(
        id: 1,
        productId: widget.product.id ?? 1,
        userName: '김철수',
        rating: 5,
        content: '정말 좋은 제품이에요! 사이즈도 딱 맞고 품질도 만족스럽습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: 2,
        productId: widget.product.id ?? 1,
        userName: '이영희',
        rating: 4,
        content: '가격 대비 품질이 좋네요. 다음에도 구매하고 싶습니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 3,
        productId: widget.product.id ?? 1,
        userName: '박민수',
        rating: 5,
        content: '배송도 빨랐고 상품도 설명과 일치해요. 추천합니다!',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 최근 본 상품에 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().addRecentProduct(widget.product);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              final isFavorite = appState.isFavorite(widget.product.id ?? 0);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (widget.product.id != null) {
                    appState.toggleFavorite(widget.product.id!);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // 상품 이미지
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.product.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 상품 기본 정보
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.productName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.brandName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${widget.product.discount}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₩${PriceFormatter.formatPriceString(widget.product.price)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Consumer<AppState>(
                            builder: (context, appState, child) {
                              final favoriteCount = appState.getFavoriteCount(
                                widget.product.id ?? 0,
                              );
                              final reviewCount = appState.getReviewCount(
                                widget.product.id ?? 0,
                              );
                              return Text(
                                '관심 $favoriteCount 리뷰 $reviewCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: [
                      const Tab(text: '상품정보'),
                      Tab(text: '리뷰 (${_reviews.length})'),
                      const Tab(text: 'Q&A (3)'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [_buildProductInfo(), _buildReviews(), _buildQnA()],
          ),
        ),
      ),
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (widget.product.id != null) {
                        _showOptionDialog(context, appState);
                      }
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('장바구니'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff1957ee),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('구매하기'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상품 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '상품 설명',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '이 상품은 고품질의 소재로 제작되어 오래 사용할 수 있습니다. 세심한 디테일과 편안한 착용감을 제공합니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '상품 상세 정보',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('브랜드', widget.product.brandName),
          _buildDetailRow('상품명', widget.product.productName),
          _buildDetailRow(
            '원가',
            '₩${PriceFormatter.formatPriceString(widget.product.price)}',
          ),
          _buildDetailRow('할인율', '${widget.product.discount}%'),
          _buildDetailRow('재질', '면 100%'),
          _buildDetailRow('색상', '블랙'),
          _buildDetailRow('사이즈', 'S, M, L, XL'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          '아직 리뷰가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.orange,
                  );
                }),
              ),
              const Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildQnA() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQAItem(
          '사이즈 문의',
          'S 사이즈와 M 사이즈 차이가 많이 나나요?',
          '안녕하세요. S 사이즈와 M 사이즈는 가슴둘레 기준으로 약 2cm 정도 차이가 납니다.',
          '김민수',
          '2024.01.15',
        ),
        const SizedBox(height: 16),
        _buildQAItem(
          '배송 문의',
          '주문 후 배송까지 얼마나 걸리나요?',
          null, // 답변이 아직 없는 경우
          '이영희',
          '2024.01.14',
        ),
        const SizedBox(height: 16),
        _buildQAItem(
          '교환/환불',
          '교환이 가능한가요?',
          '네, 7일 이내 교환/환불이 가능합니다. 단, 상품의 상태가 양호해야 합니다.',
          '박철수',
          '2024.01.13',
        ),
      ],
    );
  }

  Widget _buildQAItem(
    String category,
    String question,
    String? answer,
    String userName,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: answer != null ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Q. $userName',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (answer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A. 관리자',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '답변 대기중',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showOptionDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => ProductOptionDialog(
        product: widget.product,
        onAddToCart: (size, color, quantity) async {
          final selectedOptions = '$color $size';
          await appState.addToCart(
            widget.product.id!,
            quantity: quantity,
            selectedOptions: selectedOptions,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('장바구니에 추가되었습니다'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
