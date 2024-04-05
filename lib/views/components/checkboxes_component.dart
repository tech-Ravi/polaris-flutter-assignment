import 'package:flutter/material.dart';
import '../../models/form_model.dart';

class CheckBoxesComponent extends StatefulWidget {
  final MetaInfo metaInfo;

  const CheckBoxesComponent({Key? key, required this.metaInfo}) : super(key: key);

  @override
  _CheckBoxesComponentState createState() => _CheckBoxesComponentState();
}

class _CheckBoxesComponentState extends State<CheckBoxesComponent> {
  final List<bool> _isSelected = [];

  @override
  void initState() {
    super.initState();
    _isSelected.addAll(List.filled(widget.metaInfo.options!.length, false));
  }

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
        ...widget.metaInfo.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return CheckboxListTile(
            title: Text(option),
            value: _isSelected[index],
            onChanged: (value) {
              setState(() {
                _isSelected[index] = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}
