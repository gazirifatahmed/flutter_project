import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfferPopup {
  static const _seenKey = 'offer_seen';

  static Future<void> show(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey) ?? false) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _OfferDialog(),
    );

    prefs.setBool(_seenKey, true);
  }
}

class _OfferDialog extends StatelessWidget {
  const _OfferDialog();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.2, // ডায়ালগ চওড়া ছোট
        vertical: 100, // উপরে-নিচে ফাঁকা
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView( // স্ক্রল থাকবে
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/offers/weekend1.jpg',
                      fit: BoxFit.contain, // পুরো ইমেজ দেখাবে
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Order Now',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            top: -6,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
