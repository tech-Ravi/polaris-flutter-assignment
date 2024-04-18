import 'package:flutter/material.dart';
import 'package:flutter_task_polaris/viewmodels/dynamic_form_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/form_model.dart';

class RadioGroupComponent extends StatefulWidget {
  final MetaInfo metaInfo;

  const RadioGroupComponent({Key? key, required this.metaInfo})
      : super(key: key);

  @override
  _RadioGroupComponentState createState() => _RadioGroupComponentState();
}

class _RadioGroupComponentState extends State<RadioGroupComponent> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Consumer<DynamicFormViewModel>(builder: (context, viewModel, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Text(widget.metaInfo.label,
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...widget.metaInfo.options!.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value;
                  print(_selectedOption.toString());
                  viewModel.setSelectedOpt(_selectedOption.toString());
                });
              },
            );
          }).toList(),
        ],
      );
    });
  }
}
