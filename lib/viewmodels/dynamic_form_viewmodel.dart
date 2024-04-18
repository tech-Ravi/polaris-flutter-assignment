import 'dart:io';
import 'dart:typed_data';
import 'package:amazon_cognito_upload/amazon_cognito_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../models/form_model.dart';
import '../services/api_service.dart';
import '../utils/connectivity_utils.dart';
import '../utils/databasehelper.dart';

class DynamicFormViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<FormModel> _formDataList = [];
  final List<File> _capturedImages = [];

  Future<FormModel> fetchFormData() async {
    try {
      final formModel = await _apiService.fetchFormData();
      _formDataList.add(formModel);
      notifyListeners();
      return formModel;
    } catch (e) {
      print('Error while fething 1st API:- ' + e.toString());
      rethrow;
    }
  }

  Future<void> saveFormDataLocally(Map<String, dynamic> formData) async {
    await saveFormDataLocally(formData);
  }

//For Edit Text
  String _inputTextData = '';
  String _inputIntData = '';
  String get inputTextData => _inputTextData;
  String get inputIntData => _inputIntData;

  void setInputTextData(String data) {
    _inputTextData = data;
    notifyListeners();
  }

  void setInputIntData(String data) {
    _inputIntData = data;
    notifyListeners();
  }

//For checkbox
  final List<String> _checkBoxData = [];

  String get checkBoxData => _checkBoxData.toString();

  void addDataToList(String value) {
    _checkBoxData.add(value);
    print(_checkBoxData);
    notifyListeners();
  }

  void removeDataToList(String value) {
    _checkBoxData.remove(value);
    print(_checkBoxData);
    notifyListeners();
  }

  //For Dropdown Value
  String _selectedData1 = '';
  String _selectedData2 = '';
  String get selectedData1 => _selectedData1;
  String get selectedData2 => _selectedData2;

  void setSelectedData1(String data) {
    _selectedData1 = data;
    notifyListeners();
  }

  void setSelectedData2(String data) {
    _selectedData2 = data;
    notifyListeners();
  }

  //For RadioButton Value
  String _selectedOpt = '';
  String get selectedOpt => _selectedOpt;

  void setSelectedOpt(String data) {
    _selectedOpt = data;
    notifyListeners();
  }

  
  //For Captured Image

  // Future<void> pushDataToCloudMethod() async {
  //   final formDataList =
  //       _formDataList.map((formModel) => formModel.toJson()).toList();
  //   await ApiService().pushDataToCloud(formDataList.cast<FormModel>());
  //   _formDataList.clear();
  // }

  // Future<void> uploadImagesToS3() async {
  //   final appDir = await getApplicationDocumentsDirectory();
  //   final folderPath = '${appDir.path}/captured_images';
  //   await Directory(folderPath).create(recursive: true);
  //   late Uint8List imageByte;

  //   for (var image in _capturedImages) {
  //     final newPath = '$folderPath/${image.path.split('/').last}';
  //     await image.copy(newPath);

  //     // Upload the image to S3
  //     final file = File(newPath);
  //     ByteData byteData = await rootBundle.load(newPath);
  //     imageByte = byteData.buffer.asUint8List();

  //     final key = image.path.split('/').last;
  //     print('Image uploaded to S3: $key');
  //   }

  //   // _capturedImages.clear();
  // }

  // void addCapturedImage(File image) {
  //   _capturedImages.add(image);
  //   notifyListeners();
  // }

  // void handleConnectivityAndDataPush({required Function onConnected}) {
  //   handleConnectivityAndDataPush(
  //     onConnected: () async {
  //       final formDataList =
  //           _formDataList.map((formModel) => formModel).toList();
  //       print(_formDataList);
  //       await ApiService().pushDataToCloud(formDataList);
  //       await uploadImagesToS3();
  //     },
  //   );
  // }

  // Future<void> submitForm() async {
  //   // Submit the form data to the API or perform any other necessary actions
  //   for (FormModel model in _formDataList) {
  //     print(
  //         'key1: ${model.formName}, key1: ${model.fields.first.metaInfo.componentInputType}');
  //   }
  //   print(_formDataList.single.formName);
  //   if (_formDataList.isNotEmpty) {
  //     await ApiService().pushDataToCloud(_formDataList);
  //     await uploadImagesToS3();
  //   }

  //   // Clear the form data after submission
  //   // _formDataList.clear();
  //   // _capturedImages.clear();
  //   notifyListeners();
  // }
}
