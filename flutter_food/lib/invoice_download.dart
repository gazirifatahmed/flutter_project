import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> downloadInvoice(int orderId) async {
  try {
    // ✅ GET method ব্যবহার
    final url = Uri.parse('http://192.168.0.107:8080/api/orders/invoice/$orderId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/invoice_$orderId.pdf';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('✅ Invoice downloaded: $filePath');
      await OpenFilex.open(filePath); // ফাইল ওপেন করো
    } else {
      print('❌ Failed to download invoice: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Error: $e');
  }
}
