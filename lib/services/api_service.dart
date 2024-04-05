import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/form_model.dart';

class ApiService {
  static const baseUrl = 'https://chatbot-api.grampower.com';

  Future<FormModel> fetchFormData() async {
    final response = await http.get(Uri.parse('$baseUrl/flutter-assignment'));

    if (response.statusCode == 200) {
      return FormModel.fromJson(jsonDecode(response.body));
    } else {
      print('Response while error:- ');
      print(response.body);
      throw Exception('Failed to fetch form data');
    }
  }

  Future<void> pushDataToCloud(List<FormModel> formDataList) async {
    const pushDataUrl = '$baseUrl/flutter-assignment';

    final request = {
      'data': formDataList,
    };

    final response = await http.post(
      Uri.parse('$pushDataUrl/push'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );
    print('Print request:- ');
    print(jsonEncode(request));

    if (response.statusCode == 200) {
      // Data pushed successfully
      print('Data pushed to the cloud successfully');
    } else {
      // Error pushing data
      print('Error pushing data to the cloud: ${response.statusCode}');
    }
  }



}
