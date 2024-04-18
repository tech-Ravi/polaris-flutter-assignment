import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/form_model.dart';
import '../dynamic_form_screen.dart';
import 'package:http/http.dart' as http;

class CaptureImagesComponent extends StatefulWidget {
  final MetaInfo metaInfo;

  const CaptureImagesComponent({Key? key, required this.metaInfo})
      : super(key: key);

  @override
  _CaptureImagesComponentState createState() => _CaptureImagesComponentState();
}

class _CaptureImagesComponentState extends State<CaptureImagesComponent> {
  final List<File> _capturedImages = [];

  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        print('Picked file>>>>>>>>>>>>>>');
        print(pickedFile);
        _capturedImages.add(File(pickedFile.path));
        uploadFileToAWS(pickedFile.path);
      });

      //Add captured image paths to the form data
      DynamicFormScreen.addFormFieldData(
        context,
        widget.metaInfo.label,
        _capturedImages.map((file) => file.path).toList(),
      );
    }
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
        ElevatedButton(
          onPressed: _captureImage,
          child: Text('Capture Image'),
        ),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _capturedImages.length,
          itemBuilder: (context, index) {
            final imageFile = _capturedImages[index];
            return Stack(
              children: [
                Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _capturedImages.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> uploadFileToAWS(String path) async {
    try {
      String url = 'https://s3.ap-south-1.amazonaws.com/assignments-list';
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('file', path));
      request.fields.addAll({
        'key': path.split('/').last,
        'acl': 'public-read',
      });
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        print('File uploaded successfully');
        print(response.body);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text("Failed to upload file. Status code: ${response.body}"),
        // ));
        print('Failed to upload file. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
