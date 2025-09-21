import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PromoCarousel extends StatelessWidget {
  final CarouselSliderController carouselController;
  final List<String> images;
  final Function(int, CarouselPageChangedReason) onPageChanged;

  const PromoCarousel({
    super.key,
    required this.carouselController,
    required this.images,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CarouselSlider(
        carouselController: carouselController,
        items: images.map((imageUrl) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 250,
          viewportFraction: 1.0,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }
}
