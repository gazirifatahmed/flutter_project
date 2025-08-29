import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_item_provider.dart';
import '../providers/cart_provider.dart';
import '../model/cart_item_model.dart';
import 'cart_screen.dart';
import '../helpers/user_preferences.dart';
import 'my_orders_screen.dart';
import 'login_screen.dart';
import '../widgets/offer_popup.dart';

class MenuItemScreen extends StatefulWidget {
  const MenuItemScreen({super.key});

  @override
  State<MenuItemScreen> createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen>
    with TickerProviderStateMixin {
  String searchQuery = '';
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;

  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<MenuItemProvider>(context, listen: false).loadMenuItems());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OfferPopup.show(context);
    });

    _badgeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _badgeScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _color1 = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: Colors.orange.shade100, end: Colors.deepOrange.shade200), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: Colors.deepOrange.shade200, end: Colors.amber.shade200), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: Colors.amber.shade200, end: Colors.orange.shade100), weight: 1),
    ]).animate(_gradientController);

    _color2 = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: Colors.deepOrange.shade50, end: Colors.orange.shade300), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: Colors.orange.shade300, end: Colors.amber.shade100), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: Colors.amber.shade100, end: Colors.deepOrange.shade50), weight: 1),
    ]).animate(_gradientController);
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _animateBadge() {
    _badgeController.forward().then((_) => _badgeController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuItemProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final filteredItems = provider.items
        .where((item) =>
            item.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_color1.value ?? Colors.white, _color2.value ?? Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    '🍔 Food Menu',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long_outlined, size: 30, color: Colors.black),
                      tooltip: 'My Orders',
                      onPressed: () async {
                        int? userId = await UserPreferences.getUserId();
                        if (userId != null) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => MyOrdersScreen(userId: userId),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("❌ User ID not found")),
                          );
                        }
                      },
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.black),
                          tooltip: 'Cart',
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                          },
                        ),
                        if (cartProvider.totalItems > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: ScaleTransition(
                              scale: _badgeScale,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cartProvider.totalItems}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black),
                      tooltip: 'Logout',
                      onPressed: () async {
                        await UserPreferences.clear();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              child: Row(
                                children: const [
                                  Icon(Icons.location_on, color: Colors.deepOrange, size: 24),
                                  SizedBox(width: 6),
                                  Text("Dhaka, Bangladesh", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search delicious food...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                ),
                                onChanged: (value) => setState(() => searchQuery = value),
                              ),
                            ),
                            Expanded(
                              child: filteredItems.isEmpty
                                  ? const Center(child: Text('😔 No tasty items found!', style: TextStyle(fontSize: 18)))
                                  : ListView.builder(
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                ClipOval(
                                                  child: item.imageUrl.isNotEmpty
                                                      ? Image.network(
                                                          item.imageUrl,
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60, color: Colors.deepOrange),
                                                        )
                                                      : const Icon(Icons.fastfood, size: 60, color: Colors.deepOrange),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 6),
                                                      Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                                      const SizedBox(height: 10),
                                                      // ⭐ Rating + Price + Add Button Row
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          // ⭐ Rating with count
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.star, color: Colors.amber, size: 18),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                "${item.rating.toStringAsFixed(1)} (${item.ratingCount})",
                                                                style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // 💰 Price + Add Button
                                                          Row(
                                                            children: [
                                                              Text('৳${item.price.toStringAsFixed(2)}',
                                                                  style: const TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.deepOrange)),
                                                              const SizedBox(width: 12),
                                                              ElevatedButton.icon(
                                                                onPressed: () {
                                                                  cartProvider.addToCart(CartItem(
                                                                    id: item.id,
                                                                    name: item.name,
                                                                    price: item.price,
                                                                  ));
                                                                  _animateBadge();
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: Colors.deepOrange,
                                                                  foregroundColor: Colors.white,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(10)),
                                                                ),
                                                                icon: const Icon(Icons.add_shopping_cart),
                                                                label: const Text('Add'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}