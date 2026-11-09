import 'package:flutter/material.dart';

/// One run of question text: normal, or an exponent to raise.
typedef TextRun = ({String text, bool raised});

/// Splits `3^x · 9^(2y − 1)` into runs so exponents can be drawn raised.
/// An exponent is `^(...)` with balanced brackets, or `^` followed by letters, digits and dots.
/// Pure, so it is tested without widgets.
List<TextRun> splitPowers(String source) {
  final runs = <TextRun>[];
  final plain = StringBuffer();
  var i = 0;
  while (i < source.length) {
    final caret = source.indexOf('^', i);
    if (caret < 0 || caret == source.length - 1) {
      plain.write(source.substring(i));
      break;
    }
    plain.write(source.substring(i, caret));
    var end = caret + 1;
    String? exponent;
    if (source[end] == '(') {
      var depth = 0;
      for (; end < source.length; end++) {
        if (source[end] == '(') depth++;
        if (source[end] == ')' && --depth == 0) break;
      }
      if (end < source.length) {
        exponent = source.substring(caret + 2, end);
        end++;
      }
    } else {
      while (end < source.length && RegExp('[A-Za-z0-9.]').hasMatch(source[end])) {
        end++;
      }
      // A trailing full stop ends the sentence, not the exponent.
      if (end > caret + 1 && source[end - 1] == '.') end--;
      if (end > caret + 1) exponent = source.substring(caret + 1, end);
    }
    if (exponent == null) {
      plain.write('^');
      i = caret + 1;
      continue;
    }
    if (plain.isNotEmpty) {
      runs.add((text: plain.toString(), raised: false));
      plain.clear();
    }
    runs.add((text: exponent, raised: true));
    i = end;
  }
  if (plain.isNotEmpty) runs.add((text: plain.toString(), raised: false));
  return runs;
}

/// Text that draws `^` exponents as raised, smaller text.
class MathText extends StatelessWidget {
  const MathText(this.data, {this.style, this.selectable = false, super.key});

  final String data;
  final TextStyle? style;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    if (!data.contains('^')) {
      return selectable ? SelectableText(data, style: style) : Text(data, style: style);
    }
    final base = DefaultTextStyle.of(context).style.merge(style);
    final size = base.fontSize ?? 14;
    final span = TextSpan(
      style: style,
      children: [
        for (final run in splitPowers(data))
          if (run.raised)
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Text(
                run.text,
                style: base.copyWith(fontSize: size * 0.72),
              ),
            )
          else
            TextSpan(text: run.text),
      ],
    );
    return selectable ? SelectableText.rich(span) : Text.rich(span);
  }
}
