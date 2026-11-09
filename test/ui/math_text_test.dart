import 'package:flutter_test/flutter_test.dart';
import 'package:lcat_prep/ui/math_text.dart';

String show(String source) => [
  for (final run in splitPowers(source)) run.raised ? '[${run.text}]' : run.text,
].join();

void main() {
  test('raises single-token and bracketed exponents', () {
    expect(show('3^x · 9^y = 81'), '3[x] · 9[y] = 81');
    expect(show('2^(x − 1) + 4^(1/2)'), '2[x − 1] + 4[1/2]');
  });

  test('keeps nested brackets inside one exponent', () {
    expect(show('5^(3 − (−1)) = 625'), '5[3 − (−1)] = 625');
  });

  test('a full stop or question mark after an exponent stays in the text', () {
    expect(show('the value of 2^x.'), 'the value of 2[x].');
    expect(show('What is 3^x?'), 'What is 3[x]?');
  });

  test('leaves text without exponents and stray carets alone', () {
    expect(show('x² + 1'), 'x² + 1');
    expect(show('a ^ b'), 'a ^ b');
    expect(show('end^'), 'end^');
  });
}
