import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isAsset;

  const ServiceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.width = 150,
    this.height = 230,
    this.onTap,
    this.isAsset = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // IMAGE: network or asset
              isAsset
                  ? Image.asset(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
              )
                  : Image.network(
                imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Image.asset(
                    'assets/placeholder.png', // optional placeholder while loading
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/placeholder.png', // fallback if network fails
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  );
                },
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
}
