import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_task_polaris/utils/databasehelper.dart';
import 'package:flutter_task_polaris/viewmodels/dynamic_form_viewmodel.dart';
import 'package:flutter_task_polaris/views/dynamic_form_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

  Future<void> pushDataToCloud(Map<String, dynamic> formData,
      BuildContext context, FormModel formModel) async {
    const pushDataUrl = '$baseUrl/flutter-assignment';
    List<dynamic> requestBodyFormat = [];
    requestBodyFormat.add(formData);
    print(requestBodyFormat);

    final request = {
      'data': requestBodyFormat,
    };

    final response = await http.post(
      Uri.parse('$pushDataUrl/push'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );
    print('Print request:- ');
    print(jsonEncode(request));
    print(">>>>>>>>>>>>>>>");
    print('Print Response:- ');
    print(jsonEncode(response.body));
    if (response.statusCode == 201) {
      // Data pushed successfully
      print('Data pushed to the cloud successfully');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Data uploaded to the server successfully."),
        duration: Durations.extralong1,
      ));
    } else {
      // Error pushing data
      print('Error pushing data to the cloud: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Error pushing data to the cloud: ${response.statusCode}"),
        duration: Durations.extralong1,
      ));

      await saveFormDataToDatabase(formModel, formData, context);
    }
  }

  Future<void> pushDataToCloudWhenDataSavedLocally(
      Map<String, dynamic> formData, BuildContext context) async {
    const pushDataUrl = '$baseUrl/flutter-assignment';
    List<dynamic> requestBodyFormat = [];
    requestBodyFormat.add(formData);
    print(requestBodyFormat);

    final request = {
      'data': requestBodyFormat,
    };

    final response = await http.post(
      Uri.parse('$pushDataUrl/push'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );
    print('Print request:- ');
    print(jsonEncode(request));
    print(">>>>>>>>>>>>>>>");
    print('Print Response:- ');
    print(jsonEncode(response.body));
    if (response.statusCode == 201) {
      // Data pushed successfully
      print('Data pushed to the cloud successfully');
      showDialogBox(context);
    } else {
      // Error pushing data
      print('Error pushing data to the cloud: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("Error pushing data to the cloud: ${response.statusCode}"),
        duration: Durations.extralong1,
      ));
    }
  }

  showDialogBox(BuildContext context) => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Local Data'),
          content: const Text('Saved data uploaded to server!!'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future<void> saveFormDataToDatabase(FormModel form,
      Map<String, dynamic> userInputData, BuildContext context) async {
    Map<String, dynamic> formData = {
      'form_name': form.formName,
      'fields_data': userInputData,
    };

    // Save the data to the database
    await DatabaseHelper.insertFormData(formData, context);
  }
}
