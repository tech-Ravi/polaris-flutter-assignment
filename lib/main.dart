import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/utils/databasehelper.dart';
import 'package:provider/provider.dart';

import 'viewmodels/dynamic_form_viewmodel.dart';
import 'views/dynamic_form_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDB();
  runApp(MyApp());
}

initDB() async {
  await DatabaseHelper.initDatabase();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => DynamicFormViewModel(),
          ),
        ],
        child: DynamicFormScreen(),
      ),
    );
  }
}
