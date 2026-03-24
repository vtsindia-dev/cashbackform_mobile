import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cashback_farms/common/widget/full_screen_video_page.dart';
import 'package:cashback_farms/common/widget/gallery_photo_view_wrapper.dart';

class MediaCarouselScreen extends StatefulWidget {
  final List<String> images;
  final double? height;

  const MediaCarouselScreen({
    super.key,
    required this.images,
    this.height,
  });

  @override
  State<MediaCarouselScreen> createState() =>
      _MediaCarouselScreenState();
}

class _MediaCarouselScreenState extends State<MediaCarouselScreen> {
  Map<String, Uint8List?> thumbnailCache = {};
  int current = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    preloadThumbnails();
  }

  Future<void> preloadThumbnails() async {
    try {
      final futures = widget.images.map((url) async {
        if (url.endsWith('.mp4')) {
          final thumb = await VideoThumbnail.thumbnailData(
            video: url,
            maxWidth: 400,
            quality: 75,
          );
          thumbnailCache[url] = thumb;
        }
      });

      await Future.wait(futures);
    } catch (e) {
      debugPrint("Thumbnail error: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: widget.height ?? 200,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColor.primary,
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            final url = widget.images[index];
            if (url.endsWith('.mp4')) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FullScreenVideoPage(videoUrl: url),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    thumbnailCache[url] != null
                        ? Image.memory(
                      thumbnailCache[url]!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.black12,
                    ),

                    const Icon(
                      Icons.play_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                final onlyImages = widget.images
                    .where((e) => !e.endsWith('.mp4'))
                    .toList();

                final imageIndex = onlyImages.indexOf(url);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GalleryPhotoViewWrapper(
                      imageUrls: onlyImages,
                      initialIndex: imageIndex,
                    ),
                  ),
                );
              },
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primary,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            );
          },
          options: CarouselOptions(
            height: widget.height ?? 200,
            viewportFraction: 1,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => current = index);
            },
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: current == entry.key ? 10 : 6,
              height: current == entry.key ? 10 : 6,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current == entry.key
                    ? AppColor.primary
                    : Colors.grey,
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}