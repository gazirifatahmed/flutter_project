import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../providers/cart_provider.dart';
import '../service/order_service.dart';
import '../helpers/user_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedPaymentMethod; // Cash / Bkash / Rocket

  // ---- Helpers ----
  bool get _needsTransactionId =>
      _selectedPaymentMethod != null &&
      _selectedPaymentMethod!.toLowerCase() != 'cash';

  Future<String?> _askTransactionIdDialog() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          _selectedPaymentMethod == 'Bkash'
              ? 'bKash Transaction ID'
              : 'Rocket Transaction ID',
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter Transaction ID',
              labelText: 'Transaction ID',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Transaction ID required';
              }
              if (v.trim().length < 6) return 'Looks too short';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(CartProvider cart) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and address')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      Fluttertoast.showToast(msg: "Please select a payment method");
      return;
    }

    final int? userId = await UserPreferences.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place an order')),
      );
      return;
    }

    // If Bkash / Rocket → ask for TXN ID
    String? transactionId;
    if (_needsTransactionId) {
      transactionId = await _askTransactionIdDialog();
      if (transactionId == null) {
        // user cancelled dialog
        return;
      }
    }

    try {
      await OrderService.confirmOrder(
        cartItems: cart.items,
        totalAmount: cart.totalPrice,
        userId: userId,
        paymentMethod: _selectedPaymentMethod!, // Cash / Bkash / Rocket
        customerName: name,
        customerAddress: address,
        transactionId: transactionId, // nullable for Cash
      );

      cart.clearCart();
      _nameController.clear();
      _addressController.clear();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        headerAnimationLoop: false,
        title: 'Order Confirmed 🎉',
        desc:
            'Thank you for your order!\nWe will process it shortly.\n\nPayment: $_selectedPaymentMethod'
            '${transactionId != null ? "\nTXN: $transactionId" : ""}',
        btnOkOnPress: () {},
        btnOkColor: Colors.deepOrange,
        width: MediaQuery.of(context).size.width * 0.9,
      ).show();
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Order failed: $e");
    }
  }

  Widget _buildPaymentOption(String method, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == method
                ? Colors.deepOrange
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          color: _selectedPaymentMethod == method
              ? Colors.deepOrange.shade50
              : Colors.white,
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 40, height: 40),
            const SizedBox(width: 12),
            Text(
              method,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (_selectedPaymentMethod == method)
              const Icon(Icons.check_circle, color: Colors.deepOrange)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Your Cart'),
        backgroundColor: Colors.deepOrange,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                '🛍️ Your cart is empty',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items in Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade100,
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Total: ৳${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => cart.removeFromCart(item),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption("Bkash", "assets/images/bkash.png"),
                  _buildPaymentOption("Rocket", "assets/images/rocket.png"),
                  _buildPaymentOption("Cash", "assets/images/cash.png"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _confirmOrder(cart),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Confirm Order',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                border: const Border(
                  top: BorderSide(color: Colors.orangeAccent),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '৳${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
