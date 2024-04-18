import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/main.dart';
import 'package:flutter_task_polaris/services/api_service.dart';
import 'package:flutter_task_polaris/views/components/submit_button.dart';
import 'package:flutter_task_polaris/views/form_data_screen.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
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
  String strEditTextString = '',
      strEditTextIn = '',
      strDropdownData1 = '',
      strDropdownData2 = '',
      strRadioGroupData = '',
      strCheckboxData = '';
  String strSavedTableName = '';

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DynamicFormViewModel>();
    _formDataFuture = viewModel.fetchFormData();
    getConnectivity(viewModel, _formDataFuture);
  }

  getConnectivity(
      DynamicFormViewModel viewModel, Future<FormModel> formDataFuture) {
    _formDataFuture = viewModel.fetchFormData();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && isAlertSet == false) {
        //showDialogBox();
        setState(() => isAlertSet = true);
      } else {
        pushingLocallySavedDataToServer();
        setState(() => isAlertSet = false);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

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
      //String strEditTextString = '',strEditTextIn='',strDropdownData1='',strDropdownData2='',
      //strRadioGroupData='',strCheckboxData='';
      String strEditTextType = '', strDropdownTextType = '';
      if (label == "Consumer Name") strEditTextType = strEditTextString;
      if (label == "Consumer Mobile Number") strEditTextType = strEditTextIn;

      if (label == "Meter Status") strDropdownTextType = strDropdownData1;
      if (label == "Meter Validation Status")
        strDropdownTextType = strDropdownData2;
      // Get user input value based on the component type
      dynamic userInputValue;
      switch (field.componentType) {
        case 'EditText':
          print("Print Data:- " + strEditTextType.toString());
          userInputValue = strEditTextType;
          break;
        case 'DropDown':
          print("Print Data:- " + "   " + strDropdownTextType);
          userInputValue = strDropdownTextType;
          break;
        case 'CheckBoxes':
          print("Print Data:- " + "   " + label);
          userInputValue = strCheckboxData; // Default to false if not selected
          break;

        case 'RadioGroup':
          print("Print Data:- " + "   " + label);
          userInputValue =
              strRadioGroupData; // Default to false if not selected
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
    //await saveFormDataToDatabase(form, userInputData, context);
    var isDeviceConnected = await InternetConnectionChecker().hasConnection;

    if (isDeviceConnected)
      await ApiService().pushDataToCloud(userInputData, context, form).onError(
          (error, stackTrace) async =>
              {await saveFormDataToDatabase(form, userInputData, context)});
    else {
      await saveFormDataToDatabase(form, userInputData, context);
    }

    return userInputData;
  }

  pushingLocallySavedDataToServer() async {
    var data = await DatabaseHelper.getFormData('Consumer Survey Form') ?? {};
    print("Internet available:- ${data}");

    if (data.isNotEmpty) {
      await ApiService().pushDataToCloudWhenDataSavedLocally(data, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Form'),
        backgroundColor: isDeviceConnected ? Colors.green : Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              (isDeviceConnected) ? Icons.wifi : Icons.wifi_off_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // do something
            },
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FormDataScreen(formName: strSavedTableName),
                ),
              );
            },
            child: Text('See saved data  '),
          ),
        ],
      ),
      body: FutureBuilder<FormModel>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final formModel = snapshot.data!;
            strSavedTableName = formModel.formName;
            return Consumer<DynamicFormViewModel>(
              builder: (context, viewModel, child) => Padding(
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
                    Expanded(child: DynamicItemWidget(formModel)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // SaveButton(
                        //   onPressed: () async {
                        //     //print(field.metaInfo.componentInputType =='INTEGER'?viewModel.inputIntData:viewModel.inputIntData);

                        //     // await captureUserInputData(formModel, context);

                        //   },
                        // ),
                        // SizedBox(width: 16),
                        SubmitButton(
                          onPressed: () {
                            // print(viewModel.inputIntData);
                            // print(viewModel.inputTextData);
                            // print(viewModel.selectedData1);
                            // print(viewModel.selectedData2);
                            // print(viewModel.selectedOpt);
                            // print(viewModel.checkBoxData);
                            //String strEditTextString = '',strEditTextIn='',strDropdownData1='',strDropdownData2='',
                            //strRadioGroupData='',strCheckboxData='';
                            strEditTextString = viewModel.inputTextData;
                            strEditTextIn = viewModel.inputIntData;
                            strDropdownData1 = viewModel.selectedData1;
                            strDropdownData2 = viewModel.selectedData2;
                            strRadioGroupData = viewModel.selectedOpt;
                            strCheckboxData = viewModel.checkBoxData;

                            if (viewModel.inputTextData.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else if (viewModel.inputIntData.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else if (viewModel.selectedData1.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else if (viewModel.selectedData2.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else if (viewModel.selectedOpt.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else if (viewModel.checkBoxData.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Please fill all the fields!!"),
                                duration: Durations.long1,
                              ));
                            } else {
                              captureUserInputData(formModel, context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => MyApp()));
                    },
                    child: Text(
                      'Refresh',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  )
                ],
              ),
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

Widget DynamicItemWidget(FormModel formModel) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < formModel.fields.length; i++)
          fetchItemWidget(formModel.fields[i].componentType, formModel, i)
      ],
    ),
  );
}

Widget fetchItemWidget(String componentType, FormModel formModel, int index) {
  final field = formModel.fields[index];
  switch (componentType) {
    case 'EditText':
      return EditTextComponent(
        metaInfo: field.metaInfo,
      );
    case 'CheckBoxes':
      return CheckBoxesComponent(
        metaInfo: field.metaInfo,
      );
    case 'DropDown':
      return DropDownComponent(
        metaInfo: field.metaInfo,
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
}
