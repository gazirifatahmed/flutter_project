import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/menu_item_model.dart';


class MenuItemService {
final String baseUrl = 'http://192.168.0.107:8080/api/menuItems';


Future<List<MenuItem>> fetchMenuItems() async {
try {
final response = await http.get(Uri.parse(baseUrl));
print('🛰️ GET: $baseUrl');
print('📦 Status Code: ${response.statusCode}');
print('📦 Response Body: ${response.body}');


if (response.statusCode == 200) {
final List<dynamic> jsonData = json.decode(response.body);
return jsonData.map((item) => MenuItem.fromJson(item)).toList();
} else {
throw Exception('❌ Failed to load menu items. Status: ${response.statusCode}');
}
} catch (e) {
print('❗ Error fetching menu items: $e');
rethrow;
}
}
}