import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/services/api_service.dart';
import 'package:flutter_task_polaris/views/components/save_button.dart';
import 'package:flutter_task_polaris/views/components/submit_button.dart';
import 'package:flutter_task_polaris/views/form_data_screen.dart';
import 'package:provider/provider.dart';

import '../models/form_model.dart';
import '../utils/connectivity_utils.dart';
import '../utils/databasehelper.dart';
import '../viewmodels/dynamic_form_viewmodel.dart';
import 'components/edit_text_component.dart';
import 'components/checkboxes_component.dart';
import 'components/dropdown_component.dart';
import 'components/capture_images_component.dart';
import 'components/radio_group_component.dart';

class DynamicFormScreen extends StatefulWidget {
  const DynamicFormScreen({Key? key}) : super(key: key);

  @override
  _DynamicFormScreenState createState() => _DynamicFormScreenState();
  static void addFormFieldData(
      BuildContext context, String label, dynamic value) {
    final formScreen =
        context.findRootAncestorStateOfType<_DynamicFormScreenState>();
    if (formScreen != null) {
      formScreen._addFormFieldData(label, value);
    }
  }
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  late Future<FormModel> _formDataFuture;
  final Map<String, dynamic> _formData = {};
  Map<String, dynamic> userInputData = {};
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  final _textControllerDropdown1 = TextEditingController();
  final _textControllerDropdown2 = TextEditingController();
  String strSavedTableName = '';

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DynamicFormViewModel>();
    // viewModel.handleConnectivityAndDataPush(onConnected: () {  });
    _formDataFuture = viewModel.fetchFormData();

    //handleConnectivityAndDataPush();
  }

  void _addFormFieldData(String label, dynamic value) {
    final viewModel = context.read<DynamicFormViewModel>();
    viewModel.saveFormDataLocally({label: value});
  }

  // Save form data locally when submitting the form
  Future<void> _submitForm() async {
    //TODO
  }

  Future<void> saveFormDataToDatabase(FormModel form,
      Map<String, dynamic> userInputData, BuildContext context) async {
    Map<String, dynamic> formData = {
      'form_name': form.formName,
      'fields_data': userInputData,
    };

    // Save the data to the database
    await DatabaseHelper.insertFormData(formData, context);
  }

  Future<Map<String, dynamic>?> getFormDataFromDatabase(String formName) async {
    // Retrieve data from the database based on the form name
    return await DatabaseHelper.getFormData(formName);
  }

  Future<Map<String, dynamic>> captureUserInputData(
      FormModel form, BuildContext context) async {
    Map<String, dynamic> userInputData = {};

    // Iterate through each field in the form
    for (Field field in form.fields) {
      // Assume the field label is unique within the form
      String label = field.metaInfo.label;
      String strEditTextType = '', strDropdownTextType = '';
      if (label == "Consumer Name") strEditTextType = _textController1.text;
      if (label == "Consumer Mobile Number")
        strEditTextType = _textController2.text;

      if (label == "Meter Status")
        strDropdownTextType = _textControllerDropdown1.text;
      if (label == "Meter Validation Status")
        strDropdownTextType = _textControllerDropdown2.text;
      // Get user input value based on the component type
      dynamic userInputValue;
      switch (field.componentType) {
        case 'EditText':
          print("Print Data:- " +
              _textController1.text +
              "   " +
              strEditTextType.toString());
          userInputValue = strEditTextType;
          break;
        case 'DropDown':
          print("Print Data:- " + "   " + strDropdownTextType);
          userInputValue = strDropdownTextType;
          break;
        case 'CheckBoxes':
          print("Print Data:- " + "   " + label);
          userInputValue = 'OK'; // Default to false if not selected
          break;

        case 'RadioGroup':
          print("Print Data:- " + "   " + label);
          userInputValue =
              userInputData[label]; // Default to false if not selected
          break;

        case 'CaptureImages':
          print("Print Data:- " + "   " + label);
          userInputValue =
              userInputData[label]; // Default to false if not selected
          break;

        // Handle other component types as needed
      }

      // Add the user input value to the userInputData map
      userInputData[label] = userInputValue;
    }
    print("Data to Save:-");
    print(userInputData);
    await saveFormDataToDatabase(form, userInputData, context);

    return userInputData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormDataScreen(formName: strSavedTableName),
                ),
              );
            },
            child: Text('See saved Data'),
          ),
        ],
      ),
      body: FutureBuilder<FormModel>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final formModel = snapshot.data!;
            strSavedTableName = formModel.formName;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formModel.formName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: formModel.fields.length,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (context, index) {
                        final field = formModel.fields[index];
                        switch (field.componentType) {
                          case 'EditText':
                            return EditTextComponent(
                              metaInfo: field.metaInfo,
                              controller:
                                  field.metaInfo.componentInputType == 'INTEGER'
                                      ? _textController2
                                      : _textController1,
                              onTextChanged: (String str) {
                                field.metaInfo.componentInputType == 'INTEGER'
                                    ? _textController2.text = str
                                    : _textController1.text = str;
                              },
                            );
                          case 'CheckBoxes':
                            return CheckBoxesComponent(
                              metaInfo: field.metaInfo,
                            );
                          case 'DropDown':
                            return DropDownComponent(
                              metaInfo: field.metaInfo,
                              controller: field.metaInfo.componentInputType ==
                                      'Meter Status'
                                  ? _textControllerDropdown1
                                  : _textControllerDropdown2,
                              onValueChanged: (String str) {
                                field.metaInfo.componentInputType ==
                                        'Meter Status'
                                    ? _textControllerDropdown1.text = str
                                    : _textControllerDropdown2.text = str;
                              },
                            );
                          case 'CaptureImages':
                            return CaptureImagesComponent(
                              metaInfo: field.metaInfo,
                            );
                          case 'RadioGroup':
                            return RadioGroupComponent(
                              metaInfo: field.metaInfo,
                            );
                          default:
                            return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SaveButton(
                        onPressed: () async {
                          await captureUserInputData(formModel, context);

                          // if (userInputData.isNotEmpty)
                        },
                      ),
                      SizedBox(width: 16),
                      SubmitButton(
                        onPressed: () {
                          //TODO
                          // final viewModel =
                          //     context.read<DynamicFormViewModel>();
                          // viewModel.submitForm();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
