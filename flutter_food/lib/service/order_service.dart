import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../model/cart_item_model.dart';
import '../model/order_model.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class OrderService {
  static const String baseUrl = 'http://192.168.0.107:8080';

  /// ✅ Confirm order
  static Future<void> confirmOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required int userId,
    required String paymentMethod,
    required String customerName,
    required String customerAddress,
    String? transactionId,
  }) async {
    final url = Uri.parse('$baseUrl/api/orders/confirm');

    final orderItems = cartItems
        .map((item) => {
              "quantity": item.quantity,
              "menuItem": {"id": item.id},
            })
        .toList();

    final bodyMap = {
      "user": {"id": userId},
      "totalAmount": totalAmount,
      "paymentMethod": paymentMethod,
      "customerName": customerName,
      "customerAddress": customerAddress,
      "orderStatus": "PENDING",
      "orderItems": orderItems,
      if (transactionId != null && transactionId.isNotEmpty)
        "transactionId": transactionId,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          "Order confirm failed: ${response.statusCode} ${response.body}");
    }
  }

  /// ✅ Update order status
  static Future<void> updateOrderStatus(int orderId, String status) async {
    final url = Uri.parse('$baseUrl/api/orders/$orderId/status');
    final body = jsonEncode({"orderStatus": status});

    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Update status failed: ${response.statusCode} ${response.body}");
    }
  }

  /// ✅ Get orders by userId
  static Future<List<Order>> fetchOrdersByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/api/orders/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception(
          "Failed to load user orders: ${response.statusCode} ${response.body}");
    }
  }

  /// ✅ Download invoice
  static Future<void> downloadInvoice(int orderId) async {
    final url = Uri.parse('$baseUrl/api/orders/invoice/$orderId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (kIsWeb) {
          final blob = html.Blob([response.bodyBytes], 'application/pdf');
          final blobUrl = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: blobUrl)
            ..download = "invoice_$orderId.pdf"
            ..click();
          html.Url.revokeObjectUrl(blobUrl);
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final filePath = "${dir.path}/invoice_$orderId.pdf";
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          await OpenFilex.open(filePath);
        }
      } else {
        throw Exception("Invoice download failed: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Submit Rating (Spring Boot /api/orders/rating endpoint অনুযায়ী)
  static Future<void> submitRating(int orderId, double ratingValue) async {
    final url = Uri.parse('$baseUrl/api/orders/rating');

    final body = jsonEncode({
      "orderId": orderId,
      "rating": ratingValue,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          "Submit rating failed: ${response.statusCode} ${response.body}");
    }
  }
}
