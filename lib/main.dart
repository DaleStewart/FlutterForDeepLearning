import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() => runApp(CameraApp());

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  String? imagePath;
  html.File? webImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (!kIsWeb) {
      cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (kIsWeb) {
      // Web: Open file picker
      final html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      await input.onChange.first;
      if (input.files!.isNotEmpty) {
        final file = input.files![0];
        setState(() {
          webImage = file;
          imagePath = file.name;
        });
      }
    } else {
      // Mobile: Take picture with camera
      if (!_controller!.value.isInitialized) {
        return;
      }

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath = join(dirPath, '${DateTime.now()}.png');

      if (_controller!.value.isTakingPicture) {
        return;
      }

      try {
        await _controller!.takePicture().then((XFile file) {
          if (mounted) {
            setState(() {
              imagePath = file.path;
            });
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _sendPicture() async {
    if (imagePath == null && webImage == null) return;

    var uri = Uri.parse('YOUR_API_ENDPOINT_HERE');
    var request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      // Web: Send uploaded file
      final reader = html.FileReader();
      reader.readAsArrayBuffer(webImage!);
      await reader.onLoad.first;
      final List<int> fileBytes = reader.result as List<int>;
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        fileBytes,
        filename: webImage!.name,
      ));
    } else {
      // Mobile: Send captured image
      request.files.add(await http.MultipartFile.fromPath('image', imagePath!));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Image upload failed');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: kIsWeb
                ? Center(child: Text('Click "Take Picture" to upload an image'))
                : (_controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      )
                    : Container()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                child: Text(kIsWeb ? 'Upload Picture' : 'Take Picture'),
                onPressed: _takePicture,
              ),
              ElevatedButton(
                child: Text('Send Picture'),
                onPressed: (imagePath != null || webImage != null) ? _sendPicture : null,
              ),
            ],
          ),
          if (imagePath != null || webImage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Image ready to send: ${kIsWeb ? webImage!.name : imagePath}'),
            ),
        ],
      ),
    );
  }
}