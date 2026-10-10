import 'package:flutter/material.dart';

/// Two columns on phones; a gently alternating portrait rhythm for visual work.
class GalleryGrid extends StatelessWidget {
  final int count;
  final Widget Function(int index, double aspectRatio) builder;
  const GalleryGrid({super.key, required this.count, required this.builder});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final columns = box.maxWidth >= 1000
          ? 4
          : box.maxWidth >= 650
          ? 3
          : 2;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var column = 0; column < columns; column++) ...[
            if (column > 0) const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  for (var index = column; index < count; index += columns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: builder(
                        index,
                        ((index ~/ columns) + column).isEven ? .78 : .92,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}
