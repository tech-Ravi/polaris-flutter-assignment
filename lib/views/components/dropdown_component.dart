import 'package:flutter/material.dart';

import '../../models/form_model.dart';

class DropDownComponent extends StatefulWidget {
  final MetaInfo metaInfo;
  final TextEditingController controller;
  final Function(String) onValueChanged;
  const DropDownComponent(
      {Key? key,
      required this.metaInfo,
      required this.controller,
      required this.onValueChanged})
      : super(key: key);

  @override
  _DropDownComponentState createState() => _DropDownComponentState();
}

class _DropDownComponentState extends State<DropDownComponent> {
  String? _selectedOption;
  late TextEditingController _controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(widget.metaInfo.label,
            style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _selectedOption,
          onChanged: (value) {
            setState(() {
              print(value);
              _selectedOption = value;
              _controller.text = _selectedOption!;
              widget.onValueChanged(value!);
            });
          },
          items: widget.metaInfo.options!.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}
