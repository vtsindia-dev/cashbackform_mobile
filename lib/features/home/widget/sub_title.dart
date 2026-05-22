import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';

class SubtitleWidget extends StatelessWidget {
  final String title;
  final String highlightWord;
  final VoidCallback? onViewAllTap;
  final Color highlightColor;
  final Color normalColor;
  final bool showViewAll;
  final Duration delay;
  final Widget? moreButton;

  const SubtitleWidget({
    super.key,
    required this.title,
    this.moreButton,
    required this.highlightWord,
    this.onViewAllTap,
    this.highlightColor = AppColor.primary,
    this.normalColor = Colors.black,
    this.showViewAll = true,
    this.delay = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final highlightWords = highlightWord.split(" ");
    final widgetRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: _buildTextSpans(title, highlightWords),
            ),
          ),
        ),
        if(moreButton != null)
          moreButton!,
        if (showViewAll)
          GestureDetector(
            onTap: onViewAllTap,
            child:  Text(
               "View All",
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
    return widgetRow
        .animate()
        .slideX(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms)
        .scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      duration: 600.ms,
      curve: Curves.easeOutBack,
    )
        .then(delay: delay)
        .shimmer(duration: 800.ms, color: Colors.white.withOpacity(0.3));
  }
  List<TextSpan> _buildTextSpans(String title, List<String> highlightWords) {
    final words = title.split(" ");
    List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      bool isHighlighted = false;

      if (i <= words.length - highlightWords.length) {
        bool sequenceMatches = true;
        for (int j = 0; j < highlightWords.length; j++) {
          if (words[i + j].replaceAll(".", "") != highlightWords[j]) {
            sequenceMatches = false;
            break;
          }
        }
        if (sequenceMatches) {
          isHighlighted = true;
          String highlightedText = words.sublist(i, i + highlightWords.length).join(" ");
          spans.add(TextSpan(
            text: "$highlightedText ",
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.bold,
            ),
          ));
          i += highlightWords.length - 1;
          continue;
        }
      }
      if (!isHighlighted) {
        spans.add(TextSpan(
          text: "${words[i]} ",
          style: TextStyle(
            color: normalColor,
            fontWeight: FontWeight.w400,
          ),
        ));
      }
    }

    return spans;
  }
}