import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMetrics {
  double totalIncome;
  double yearlyIncome;
  double monthlyRevenue;
  int customers;
  DateTime lastUpdate;

  FakeMetrics({
    required this.totalIncome,
    required this.yearlyIncome,
    required this.monthlyRevenue,
    required this.customers,
    required this.lastUpdate,
  });
}

class FakeMetricsProvider extends ChangeNotifier {
  static const _kTotalIncome = 'fm_total_income';
  static const _kYearlyIncome = 'fm_yearly_income';
  static const _kMonthlyRevenue = 'fm_monthly_revenue';
  static const _kCustomers = 'fm_customers';
  static const _kLastUpdate = 'fm_last_update';

  /// Customers count is fixed to 28 as per requirement
  static const int fixedCustomers = 28;

  late FakeMetrics _m;
  Timer? _timer;

  // ▶️ গতি নিয়ন্ত্রণ (ইচ্ছে মতো বদলাও)
  final double totalPerSecond   = 3.5;  // ৳/sec
  final double yearlyPerSecond  = 2.0;  // ৳/sec
  final double monthlyPerSecond = 1.1;  // ৳/sec
  // customersPerSec আর ব্যবহার করা হচ্ছে না, তাই মুছে দেওয়া হলো

  FakeMetrics get m => _m;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _m = FakeMetrics(
      totalIncome: sp.getDouble(_kTotalIncome) ?? 0,
      yearlyIncome: sp.getDouble(_kYearlyIncome) ?? 0,
      monthlyRevenue: sp.getDouble(_kMonthlyRevenue) ?? 0,
      customers: fixedCustomers, // ✅ সবসময় 28
      lastUpdate: DateTime.tryParse(sp.getString(_kLastUpdate) ?? '') ?? DateTime.now(),
    );

    // নিশ্চিতভাবে স্টোরেজেও 28 লিখে দিই
    await sp.setInt(_kCustomers, fixedCustomers);

    _start();
  }

  void _start() {
    _tick(immediateCatchUp: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick({bool immediateCatchUp = false}) async {
    final now = DateTime.now();
    final elapsed = now.difference(_m.lastUpdate).inMilliseconds / 1000.0;
    if (elapsed <= 0 && !immediateCatchUp) return;

    _m.totalIncome     += totalPerSecond   * elapsed;
    _m.yearlyIncome    += yearlyPerSecond  * elapsed;
    _m.monthlyRevenue  += monthlyPerSecond * elapsed;
    _m.customers        = fixedCustomers; // ✅ সবসময় 28

    _m.lastUpdate = now;
    notifyListeners();

    if ((now.second % 5) == 0) _persist();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kTotalIncome, _m.totalIncome);
    await sp.setDouble(_kYearlyIncome, _m.yearlyIncome);
    await sp.setDouble(_kMonthlyRevenue, _m.monthlyRevenue);
    await sp.setInt(_kCustomers, fixedCustomers); // ✅ 28 সেভ
    await sp.setString(_kLastUpdate, _m.lastUpdate.toIso8601String());
  }

  Future<void> reset() async {
    _m = FakeMetrics(
      totalIncome: 0,
      yearlyIncome: 0,
      monthlyRevenue: 0,
      customers: fixedCustomers, // ✅ রিসেটেও 28
      lastUpdate: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
