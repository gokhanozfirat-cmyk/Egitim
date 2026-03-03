import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathTextBlock extends StatelessWidget {
  const MathTextBlock({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final List<_Chunk> chunks = _parse(text);
    final TextStyle fallbackStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chunks.map((chunk) {
        if (chunk.value.trim().isEmpty) {
          return const SizedBox.shrink();
        }

        if (chunk.isLatex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                chunk.value,
                textStyle: fallbackStyle.copyWith(fontSize: 18),
                onErrorFallback: (error) =>
                    Text(chunk.value, style: fallbackStyle),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(chunk.value, style: fallbackStyle),
        );
      }).toList(),
    );
  }

  List<_Chunk> _parse(String input) {
    if (!input.contains(r'$')) {
      return <_Chunk>[_Chunk(value: input, isLatex: false)];
    }

    final RegExp regex = RegExp(r'\$([^$]+)\$');
    final List<_Chunk> chunks = <_Chunk>[];
    int cursor = 0;

    for (final Match match in regex.allMatches(input)) {
      if (match.start > cursor) {
        chunks.add(
          _Chunk(value: input.substring(cursor, match.start), isLatex: false),
        );
      }
      chunks.add(_Chunk(value: match.group(1) ?? '', isLatex: true));
      cursor = match.end;
    }

    if (cursor < input.length) {
      chunks.add(_Chunk(value: input.substring(cursor), isLatex: false));
    }

    return chunks;
  }
}

class _Chunk {
  const _Chunk({required this.value, required this.isLatex});

  final String value;
  final bool isLatex;
}
