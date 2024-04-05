import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/utils/databasehelper.dart';
import 'package:provider/provider.dart';

import 'viewmodels/dynamic_form_viewmodel.dart';
import 'views/dynamic_form_screen.dart';

void main() {
  initDB();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

initDB() async {
  await DatabaseHelper.initDatabase();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DynamicFormViewModel(),
      child: MaterialApp(
        title: 'Dynamic Form',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DynamicFormScreen(),
      ),
    );
  }
}
