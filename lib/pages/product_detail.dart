import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_application/models/qa.dart';
import 'package:shopping_application/services/supabase_service.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/optimized_app_state.dart';
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
  List<Qa> _qas = [];
  bool _isLoadingReviews = false;
  bool _isLoadingQAs = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReviews();
    _loadQAs();
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
      // 실제 DB에서 리뷰 데이터 로드
      if (widget.product.id != null) {
        _reviews = await SupabaseService.getReviews(widget.product.id!);

        // OptimizedAppState에 리뷰 개수 업데이트
        if (mounted) {
          context.read<OptimizedAppState>().setReviewCount(
            widget.product.id!,
            _reviews.length,
          );
        }
      }
    } catch (e) {
      logger.e('Error loading reviews: $e');
      _reviews = []; // 에러 시 빈 리스트
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _loadQAs() async {
    setState(() {
      _isLoadingQAs = true;
    });

    try {
      // 실제 DB에서 Q&A 데이터 로드
      if (widget.product.id != null) {
        _qas = await SupabaseService.getQAs(widget.product.id!);
      }
    } catch (e) {
      logger.e('Error loading Q&As: $e');
      _qas = []; // 에러 시 빈 리스트
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQAs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 최근 본 상품에 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OptimizedAppState>().addRecentProduct(widget.product);
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
          Consumer<OptimizedAppState>(
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
                          Consumer<OptimizedAppState>(
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
                      Tab(text: '리뷰'),
                      const Tab(text: 'Q&A'),
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
      bottomNavigationBar: Consumer<OptimizedAppState>(
        builder: (context, appState, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
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
                    onPressed: () {
                      if (widget.product.id != null) {
                        _showBuyNowDialog(context, appState);
                      }
                    },
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
    if (_isLoadingQAs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_qas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 질문이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '첫 번째 질문을 남겨보세요!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _qas.length,
      itemBuilder: (context, index) {
        final qa = _qas[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index < _qas.length - 1 ? 16 : 0),
          child: _buildQAItem(
            _getQACategory(qa.question),
            qa.question,
            qa.answer,
            qa.userName,
            _formatDate(qa.createdAt),
          ),
        );
      },
    );
  }

  String _getQACategory(String question) {
    if (question.contains('사이즈') || question.contains('크기')) {
      return '사이즈 문의';
    } else if (question.contains('배송') || question.contains('발송')) {
      return '배송 문의';
    } else if (question.contains('교환') || question.contains('환불')) {
      return '교환/환불';
    } else if (question.contains('재고') || question.contains('품절')) {
      return '재고 문의';
    } else {
      return '기타 문의';
    }
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

  void _showOptionDialog(BuildContext context, OptimizedAppState appState) {
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

  void _showBuyNowDialog(BuildContext context, OptimizedAppState appState) {
    showDialog(
      context: context,
      builder: (context) => ProductOptionDialog(
        product: widget.product,
        buttonText: '구매하기',
        shouldCloseDialog: false,
        onAddToCart: (size, color, quantity) async {
          // 구매 완료 다이얼로그 표시 (장바구니에 담지 않음)
          if (context.mounted) {
            Navigator.pop(context); // 옵션 선택 다이얼로그 닫기
            // ✅ mounted 체크로 Widget이 여전히 활성화되어 있는지 확인
            if (mounted) {
              _showPurchaseCompleteDialog(context, size, color, quantity);
            }
          }
        },
      ),
    );
  }

  void _showPurchaseCompleteDialog(
    BuildContext context,
    String size,
    String color,
    int quantity,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 성공 아이콘 영역
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green[400]!, Colors.green[600]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.green[600],
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '구매가 완료되었습니다!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '빠른 시일 내에 배송될 예정입니다',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // 상품 정보 영역
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이미지와 정보
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(widget.product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.brandName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.product.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 주문 정보
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildOrderInfoRow('옵션', '$color $size'),
                          const SizedBox(height: 8),
                          _buildOrderInfoRow('수량', '$quantity개'),
                          const SizedBox(height: 8),
                          _buildOrderInfoRow(
                            '결제금액',
                            '₩${PriceFormatter.formatPrice((int.tryParse(widget.product.price) ?? 0) * quantity)}',
                            isPrice: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 버튼 영역
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1957ee),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoRow(
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            color: isPrice ? Colors.black : Colors.grey[800],
          ),
        ),
      ],
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
