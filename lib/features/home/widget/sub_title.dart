import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/colours.dart';

class SubtitleWidget extends StatelessWidget {
  final String title;
  final String highlightWord;
  final VoidCallback? onViewAllTap;
  final Color highlightColor;
  final Color normalColor;

  const SubtitleWidget({
    super.key,
    required this.title,
    required this.highlightWord,
    this.onViewAllTap,
    this.highlightColor = AppColor.primary,
    this.normalColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final words = title.split(" ");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: words.map((word) {
                bool isHighlighted = word.replaceAll(".", "") == highlightWord;

                return TextSpan(
                  text: "$word ",
                  style: TextStyle(
                    color: isHighlighted ? highlightColor : normalColor,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        GestureDetector(
          onTap: onViewAllTap,
          child: const Text(
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
  }
}
