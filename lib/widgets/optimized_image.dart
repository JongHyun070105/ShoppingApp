import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 최적화된 이미지 위젯
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 캐시 설정
      cacheManager: null, // 기본 캐시 매니저 사용
      maxWidthDiskCache: 800, // 디스크 캐시 최대 너비
      maxHeightDiskCache: 800, // 디스크 캐시 최대 높이
      // 로딩 플레이스홀더
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),

      // 에러 위젯
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),

      // 메모리 캐시 설정
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    // 둥근 모서리 적용
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.grey, size: 32),
      ),
    );
  }
}

