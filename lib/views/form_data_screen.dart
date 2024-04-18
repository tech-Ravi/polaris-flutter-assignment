import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/utils/databasehelper.dart';

class FormDataScreen extends StatefulWidget {
  final String formName;

  const FormDataScreen({Key? key, required this.formName}) : super(key: key);

  @override
  _FormDataScreenState createState() => _FormDataScreenState();
}

class _FormDataScreenState extends State<FormDataScreen> {
  Map<String, dynamic>? formData;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch form data from the database
    fetchFormData();
  }

  Future<void> fetchFormData() async {
    // Call the getFormData function with the form name
    formData = await DatabaseHelper.getFormData(widget.formName);
    print(formData.toString());
    setState(() {}); // Update the UI after fetching data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formName),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: formData != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Form Name: ${widget.formName}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Display fetched data
                    // Adjust the UI as per your data structure
                    for (var entry in formData!.entries)
                      Text('${entry.key}: ${entry.value}'),

                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        await DatabaseHelper.deleteFormData(
                                'Consumer Survey Form') ??
                            {};
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Saved data deleted from local DB!"),
                        ));
                      },
                      child: Text(
                        'Clear Local DB',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ],
                )
              : CircularProgressIndicator(), // Show loading indicator while fetching data
        ),
      ),
    );
  }
}
