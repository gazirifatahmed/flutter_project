import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../helpers/user_preferences.dart';
import '../service/order_service.dart';
import '../model/order_model.dart';

class MyOrdersScreen extends StatefulWidget {
  final int? userId;
  const MyOrdersScreen({super.key, this.userId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = Future.value([]);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final uid = widget.userId ?? await UserPreferences.getUserId();
    if (uid == null) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Please login to see your orders'),
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
      if (mounted) setState(() => _ordersFuture = Future.value([]));
      return;
    }

    if (mounted) {
      setState(() {
        _ordersFuture = OrderService.fetchOrdersByUserId(uid).then((orders) {
          orders.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return orders;
        });
      });
    }
  }

  Future<void> _confirmReceived(int orderId) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: "Confirm Delivery?",
      desc: "Are you sure you have received your order?",
      btnCancelText: "No",
      btnOkText: "Yes, Confirm",
      btnOkOnPress: () async {
        try {
          await OrderService.updateOrderStatus(orderId, 'DELIVERED');
          if (!mounted) return;

          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: "Delivery Confirmed!",
            desc: "Thank you for confirming. Enjoy your meal! 🍽️",
            btnOkText: "OK",
            btnOkOnPress: () {},
          ).show();

          await _loadOrders();
        } catch (e) {
          if (!mounted) return;
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.scale,
            title: "Oops!",
            desc: "Failed to confirm delivery.\n$e",
            btnOkOnPress: () {},
          ).show();
        }
      },
      btnCancelOnPress: () {},
    ).show();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('yyyy-MM-dd – hh:mm a').format(date);
    } catch (_) {
      return date.toIso8601String();
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'APPROVED':
        color = Colors.blue;
        break;
      case 'SHIPPED':
        color = Colors.purple;
        break;
      case 'DELIVERED':
        color = Colors.green;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ⭐ Rating Dialog
  Future<void> _showRatingDialog(Order order, MenuItem item) async {
    int selected = 5;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Rate \"${item.name}\"",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose stars:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return IconButton(
                      onPressed: () => setState(() => selected = idx),
                      icon: Icon(
                        idx <= selected ? Icons.star : Icons.star_border,
                        size: 36,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  /// ✅ নতুন API কল
                  await OrderService.submitRating(item.id, selected.toDouble());
                  if (!mounted) return;

                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide,
                    title: "Thank You!",
                    desc:
                        "Your rating for\n\n\"${item.name}\"\n\nhas been submitted successfully.",
                    descTextStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    btnOkText: "OK",
                    btnOkOnPress: () {},
                    btnOkColor: Colors.deepOrange,
                    dismissOnBackKeyPress: false,
                    dismissOnTouchOutside: false,
                  ).show();

                  await _loadOrders(); // refresh orders
                } catch (e) {
                  if (!mounted) return;
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.scale,
                    title: "Oops!",
                    desc: "Failed to submit rating for \"${item.name}\".\n$e",
                    btnOkOnPress: () {},
                    btnOkColor: Colors.red,
                  ).show();
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Summary Card (animated counter)
  Widget _buildSummaryCard(String title, int count, Color color) {
    return Container(
      width: 110,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(seconds: 2),
              builder: (context, value, _) {
                return Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📜 My Orders"),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('❌ Failed to load orders.\n${snapshot.error}'),
            );
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                '😴 You have no orders yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final total = orders.length;
          final pending = orders.where((o) => o.orderStatus?.toUpperCase() == 'PENDING').length;
          final approved = orders.where((o) => o.orderStatus?.toUpperCase() == 'APPROVED').length;
          final shipped = orders.where((o) => o.orderStatus?.toUpperCase() == 'SHIPPED').length;
          final delivered = orders.where((o) => o.orderStatus?.toUpperCase() == 'DELIVERED').length;
          final cancelled = orders.where((o) => o.orderStatus?.toUpperCase() == 'CANCELLED').length;

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSummaryCard("Total", total, Colors.deepOrange),
                    _buildSummaryCard("Pending", pending, Colors.orange),
                    _buildSummaryCard("Approved", approved, Colors.blue),
                    _buildSummaryCard("Shipped", shipped, Colors.purple),
                    _buildSummaryCard("Delivered", delivered, Colors.green),
                    _buildSummaryCard("Cancelled", cancelled, Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                ...orders.map((order) {
                  final status = (order.orderStatus ?? '').toUpperCase();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long, color: Colors.deepOrange),
                              const SizedBox(width: 8),
                              Text(
                                "Order ID: ${order.id}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(order.createdAt),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("👤 ${order.customerName ?? 'N/A'}"),
                          Text("🏠 ${order.customerAddress ?? 'N/A'}"),
                          const SizedBox(height: 10),
                          Text("💳 Payment: ${order.paymentMethod ?? 'N/A'}"),
                          Text(
                            "💰 Total: ৳${order.totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 24),
                          const Text(
                            "🛍 Items Ordered:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...order.orderItems.map(
                            (item) => Row(
                              children: [
                                const Text("• "),
                                Expanded(
                                  child: Text(
                                    "${item.menuItem.name} ×${item.quantity} (৳${item.menuItem.price.toStringAsFixed(2)})",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (status == "SHIPPED")
                                ElevatedButton.icon(
                                  onPressed: () => _confirmReceived(order.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text("Confirm Received"),
                                ),
                              if (status == "DELIVERED") ...[
                                if (order.rating == null)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (order.orderItems.isNotEmpty) {
                                        _showRatingDialog(order, order.orderItems[0].menuItem);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("No item to rate"),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.star_border),
                                    label: const Text("Rate"),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber),
                                        const SizedBox(width: 6),
                                        Text(order.rating!.toStringAsFixed(1)),
                                      ],
                                    ),
                                  ),
                              ],
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => OrderService.downloadInvoice(order.id),
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                label: const Text("Invoice"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
