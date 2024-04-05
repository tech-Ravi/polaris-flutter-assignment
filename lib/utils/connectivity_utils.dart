import 'dart:io';
import 'package:flutter_task_polaris/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/form_model.dart';


// Periodically check internet connectivity and handle data push
// void handleConnectivityAndDataPush() async {
//   final subscription =
//       Connectivity().onConnectivityChanged.listen((event) async {
//     if (event == ConnectivityResult.mobile ||
//         event == ConnectivityResult.wifi) {
//       // Internet is available
//       // Fetch local form data
//       final prefs = await SharedPreferences.getInstance();
//       final formDataList = prefs.getStringList('formDataList') ?? [];

//       // Push form data to the cloud
//       final parsedFormDataList = formDataList
//           .map((formDataJson) =>
//               jsonDecode(formDataJson) as Map<String, dynamic>)
//           .toList();
//       if (formDataList.isNotEmpty) await ApiService().pushDataToCloud(parsedFormDataList.map((map) => FormModel.fromJson(map)).toList());

//       // Clear local form data
//       await prefs.remove('formDataList');

//       // Upload captured images to S3
//       // ...
//     }
//   });

// }
