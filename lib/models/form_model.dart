class FormModel {
  final String formName;
  final List<Field> fields;

  FormModel({required this.formName, required this.fields});

  factory FormModel.fromJson(Map<String, dynamic> json) {
    final formName = json['form_name'];
    final fields = (json['fields'] as List)
        .map((fieldJson) => Field.fromJson(fieldJson))
        .toList();

    return FormModel(formName: formName, fields: fields);
  }
   Map<String, dynamic> toJson() {
    return {
      'form_name': formName,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}

class Field {
  final String componentType;
  final MetaInfo metaInfo;

  Field({required this.componentType, required this.metaInfo});

  factory Field.fromJson(Map<String, dynamic> json) {
    final componentType = json['component_type'];
    final metaInfo = MetaInfo.fromJson(json['meta_info']);

    return Field(componentType: componentType, metaInfo: metaInfo);
  }

  Map<String, dynamic> toJson() {
    return {
      'component_type': componentType,
      'meta_info': metaInfo.toJson(),
    };
  }
}

class MetaInfo {
  final String label;
  final String? componentInputType;
  final String? inputMandatory;
  final List<String>? options;
  final int? noImagesToCapture;
  final String? savingFolder;

  MetaInfo(
      {required this.label,
      this.componentInputType,
      this.inputMandatory,
      this.options,
      this.noImagesToCapture,
      this.savingFolder});

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      label: json['label'],
      componentInputType: json['component_input_type'],
      inputMandatory: json['input_mandatory'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      noImagesToCapture: json['no_images_to_capture'],
      savingFolder: json['saving_folder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'component_input_type': componentInputType,
      'input_mandatory': inputMandatory,
      'options': options,
      'no_images_to_capture': noImagesToCapture,
      'saving_folder': savingFolder,
    };
  }
}