import 'package:flutter/material.dart';


Widget DottedLine({required Color dashColor}) {
  return Container(
    width: double.infinity,
    height: 1,
    child: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(30, (_) => SizedBox(width: 4, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: dashColor)))),
    ),
  );
}