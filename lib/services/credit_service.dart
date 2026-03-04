import 'package:shared_preferences/shared_preferences.dart';

class CreditService {
  static const String _creditKey = 'credit_balance_v1';
  static const int _defaultCredits = 1;

  Future<int> getCredits() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? value = prefs.getInt(_creditKey);
    if (value != null) {
      return value;
    }
    await prefs.setInt(_creditKey, _defaultCredits);
    return _defaultCredits;
  }

  Future<int> addCredits(int amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int current = await getCredits();
    final int next = current + amount;
    await prefs.setInt(_creditKey, next);
    return next;
  }

  Future<int> spendOneCredit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int current = await getCredits();
    if (current <= 0) {
      throw StateError('Insufficient credit');
    }
    final int next = current - 1;
    await prefs.setInt(_creditKey, next);
    return next;
  }
}
