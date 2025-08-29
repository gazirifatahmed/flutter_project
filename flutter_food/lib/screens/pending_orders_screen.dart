import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/shipping_sweet_alert.dart'; // Ship alert widget

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = false;

  int pendingCount = 0;
  int approvedCount = 0;
  int shippedCount = 0;
  int deliveredCount = 0;

  final String baseUrl = "http://192.168.0.107:8080"; // নিজের IPv4

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  /// ===== Fetch Orders =====
  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    final url = Uri.parse('$baseUrl/api/orders');

    try {
      final response = await http.get(url, headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        orders = data
            .where((order) =>
                order['orderStatus'] == 'PENDING' ||
                order['orderStatus'] == 'APPROVED' ||
                order['orderStatus'] == 'SHIPPED' ||
                order['orderStatus'] == 'DELIVERED')
            .toList();

        orders.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a['createdAt'] ?? a['orderDate'] ?? '') ?? DateTime(1970);
          DateTime dateB = DateTime.tryParse(b['createdAt'] ?? b['orderDate'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });

        setState(() {
          pendingCount = orders.where((o) => o['orderStatus'] == 'PENDING').length;
          approvedCount = orders.where((o) => o['orderStatus'] == 'APPROVED').length;
          shippedCount = orders.where((o) => o['orderStatus'] == 'SHIPPED').length;
          deliveredCount = orders.where((o) => o['orderStatus'] == 'DELIVERED').length;
        });
      } else {
        showError("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error fetching orders: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ===== Update Order Status =====
  Future<void> updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('$baseUrl/api/orders/$orderId');
    try {
      final response = await http.patch(
        url,
        headers: {"status": status, "Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        if (status == "SHIPPED") {
          showShippingSweetAlert(context); // Ship alert
        } else if (status == "APPROVED") {
          showApproveSweetAlert(context); // Approve alert
        } else {
          showMessage("✅ Order #$orderId updated to $status");
        }
        fetchOrders();
      } else {
        showError("❌ Failed to update order");
      }
    } catch (e) {
      showError("❌ $e");
    }
  }

  /// ===== Approve Sweet Alert =====
  void showApproveSweetAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/approve.gif',
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Order Approved! ✅",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("OK"),
              )
            ],
          ),
        );
      },
    );
  }

  /// ===== Helper Message =====
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  void showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
      backgroundColor: Colors.red,
    ));
  }

  /// ===== Order Items List =====
  Widget buildOrderItems(List<dynamic> orderItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderItems.map((item) {
        final name = item['menuItem']['name'];
        final quantity = item['quantity'];
        final price = item['menuItem']['price'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            "🛒 $name x$quantity — ৳${(price * quantity).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  /// ===== Status Chip =====
  Widget buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'APPROVED':
        color = Colors.blue;
        break;
      case 'SHIPPED':
        color = Colors.green;
        break;
      case 'DELIVERED':
        color = Colors.teal;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  /// ===== Action Buttons =====
  Widget buildActionButtons(Map<String, dynamic> order) {
    final String status = order['orderStatus'];
    final int orderId = order['id'];

    if (status == 'PENDING') {
      return Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Approve"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => updateOrderStatus(orderId, "APPROVED"),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text("Reject"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => updateOrderStatus(orderId, "REJECTED"),
          ),
        ],
      );
    } else if (status == 'APPROVED') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.local_shipping),
        label: const Text("Ship"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
        onPressed: () => updateOrderStatus(orderId, "SHIPPED"),
      );
    } else if (status == 'SHIPPED') {
      return const Text("⏳ Waiting for Customer", style: TextStyle(color: Colors.grey));
    } else if (status == 'DELIVERED') {
      return const Text("✅ Delivered", style: TextStyle(color: Colors.green));
    } else {
      return const SizedBox.shrink();
    }
  }

  /// ===== Stat Cards =====
  Widget buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard("Pending", pendingCount, Colors.orange),
          _buildStatCard("Approved", approvedCount, Colors.blue),
          _buildStatCard("Shipped", shippedCount, Colors.green),
          _buildStatCard("Delivered", deliveredCount, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📋 Incoming Orders"),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No pending orders!"))
              : Column(
                  children: [
                    buildSummaryCards(),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final orderItems = order['orderItems'] as List<dynamic>;

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Order #${order['id']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      buildStatusChip(order['orderStatus']),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Customer: ${order['customerName']}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text("Address: ${order['customerAddress']}"),
                                  Text("Payment: ${order['paymentMethod']}"),
                                  Text("Total: ৳${order['totalAmount']}"),
                                  const SizedBox(height: 12),
                                  const Text("🛍 Items:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  buildOrderItems(orderItems),
                                  const SizedBox(height: 14),
                                  buildActionButtons(order),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
