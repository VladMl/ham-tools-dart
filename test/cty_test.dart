import '../cty.dart';
import 'package:test/test.dart';

void main() {
  test('Test single prefix', () {
    var cty = Cty();
    cty.readCsv("test/cty_test.csv");
    var c = cty.getCountry("UT4UKW");
    expect(c?.name, "Ukraine");
  });

  test('Test substitution', () {
    var cty = Cty();
    cty.readCsv("test/cty_test.csv");
    var c = cty.getCountry("AY4Z");
    expect(c?.name, "Antarctica");
    expect(c?.cq, 23);
    expect(c?.itu, 73);
    expect(c?.lat, 10);
    expect(c?.lon, 20);
    expect(c?.timeoffset, 8);
  });
}
