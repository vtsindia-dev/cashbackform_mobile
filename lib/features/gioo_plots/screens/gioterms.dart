import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../model/gioo_plot.dart';

class GioPlotTermsScreen extends StatelessWidget {
  final List<GioPlotTermData> terms;
  final String slug;

  const GioPlotTermsScreen({
    super.key,
    required this.terms,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final term = terms.firstWhere(
          (e) => e.slug == slug,
      orElse: () => GioPlotTermData(),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColor.primarylite,
        title: const Text("Terms & Conditions"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(width: 1, color: AppColor.primarylite),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term.title ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Html(
                  data: term.content ?? "",
                  style: {
                    "body": Style(
                      fontSize: FontSize(14),
                      color: Colors.black87,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}