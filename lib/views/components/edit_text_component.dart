import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/form_model.dart';
import '../../viewmodels/dynamic_form_viewmodel.dart';

class EditTextComponent extends StatefulWidget {
  final MetaInfo metaInfo;
  // final TextEditingController controller;
  // final Function(String) onTextChanged;

  const EditTextComponent(
      {Key? key,
      required this.metaInfo,
      // required this.controller,
      // required this.onTextChanged
      })
      : super(key: key);

  @override
  _EditTextComponentState createState() => _EditTextComponentState();
}

class _EditTextComponentState extends State<EditTextComponent> {
  // late TextEditingController _controller1;
  // late TextEditingController _controller2;

  @override
  void initState() {
    super.initState();
    // _controller1 = TextEditingController();
    // _controller2 = TextEditingController();
  }

  @override
  void dispose() {
    // _controller1.dispose();
    // _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DynamicFormViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          widget.metaInfo.label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Consumer<DynamicFormViewModel>(
          builder: (context, viewModel, child) => TextField(
            keyboardType: widget.metaInfo.componentInputType == 'INTEGER'
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (text) => widget.metaInfo.componentInputType == 'INTEGER'?viewModel.setInputIntData(text):viewModel.setInputTextData(text),
            decoration: InputDecoration(
              hintText: 'Enter ${widget.metaInfo.label}',
              errorText: widget.metaInfo.inputMandatory == 'yes'
                  ? 'This field is required'
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
