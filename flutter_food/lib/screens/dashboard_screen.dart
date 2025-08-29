import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'pending_orders_screen.dart';
import 'my_orders_screen.dart';
import '../helpers/user_preferences.dart';
import 'login_screen.dart';
import '../providers/f_metrics_provider.dart';

class DashboardScreen extends StatelessWidget {
  final String role;
  const DashboardScreen({super.key, this.role = 'manager'});

  Future<void> _logout(BuildContext context) async {
    await UserPreferences.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _money(num v) {
    final n = NumberFormat.decimalPattern();
    return '৳ ${n.format(v.floor())}';
  }

  @override
  Widget build(BuildContext context) {
    final isManager = role == 'manager';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F2),
      appBar: AppBar(
        title: Text(
          isManager ? "🍽 Manager Dashboard" : "👤 Customer Dashboard",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          if (isManager)
            IconButton(
              tooltip: 'Reset counters',
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<FakeMetricsProvider>().reset(),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: isManager
          ? Column(
              children: [
                Consumer<FakeMetricsProvider>(
                  builder: (_, fm, __) {
                    final m = fm.m;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatCard(
                            title: "Total Income",
                            value: _money(m.totalIncome),
                            icon: Icons.monetization_on,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            title: "Customers",
                            value: m.customers.toString(), // ✅ এখন সবসময় 28
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            title: "Yearly Income",
                            value: _money(m.yearlyIncome),
                            icon: Icons.bar_chart,
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            title: "Monthly Revenue",
                            value: _money(m.monthlyRevenue),
                            icon: Icons.trending_up,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                const Expanded(child: PendingOrdersScreen()),
              ],
            )
          : _buildCustomerUI(context),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(1, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.restaurant_menu, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome, Food Lover!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You are logged in as a $role',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text("🧾 View My Orders"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final userId = await UserPreferences.getUserId();
                if (userId != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrdersScreen(userId: userId)),
                  );
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ User ID not found')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/food_banner.png', height: 160, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
