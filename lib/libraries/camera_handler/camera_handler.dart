library camera_handler;

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cw_core/cw_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image/image.dart' as img;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

import '../dx_file_handler/dx_file_handler.dart';

part 'camera_handler_state.dart';

class CameraHandler extends Cubit<CameraHandlerState> {
  CameraHandler() : super(CameraHandlerInitializing());

  CameraController? _cameraController;

  late List<CameraDescription> _cameras;

  CameraController? get cameraController => _cameraController;

  XFile? imageFile;

  String? removedBackgroundImagePath;

  FileUploaderObject? base64FileObject;

  void mimicSelfieCapture(FileUploaderObject file) {
    base64FileObject = file;
    emit(CameraHandlerImageCaptured(isBase64: true));
  }

  Future<void> removeBackground(ValueNotifier<bool> removingBackground) async {
    removingBackground.value = true;

    var uri = Uri.parse('https://sdk.photoroom.com/v1/segment');
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'image/png, application/json',
        'Content-Type': 'multipart/form-data',
        'x-api-key': 'a88ce05d518d59c2555a38b85ba84bb4607bb06f',
      })
      ..fields['format'] = 'jpg'
      ..fields['bg_color'] = '#ffffff'
      ..files.add(await http.MultipartFile.fromPath(
        'image_file',
        File(imageFile!.path).path,
        contentType: MediaType('image', 'jpg'),
      ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        Uint8List bytes = await response.stream.toBytes();
        var directory =
            await getTemporaryDirectory(); // Using path_provider to get a directory
        File outputFile = File('${directory.path}/backgroundRemovedImage.jpg');
        if (outputFile.existsSync()) {
          outputFile.deleteSync();
        }
        await outputFile.writeAsBytes(bytes);
        removedBackgroundImagePath = outputFile.path;
        emit(CameraHandlerRemovedBackground());
      } else {
        print('Failed to remove background');
      }
    } catch (e) {
      print('Exception caught: $e');
    } finally {
      removingBackground.value = false;
    }
  }

  bool get isBase64 {
    if (state is CameraHandlerImageCaptured) {
      return (state as CameraHandlerImageCaptured).isBase64;
    }
    return false;
  }

  Future<void> init() async {
    // if (state is CameraHandlerReadyToCapture) return;
    emit(CameraHandlerInitializing());
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        throw 'No camera available';
      }
      if (kIsWeb) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
      } else {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        _cameraController?.setFlashMode(FlashMode.off);
      }

      await _cameraController?.initialize();

      if (_cameraController?.value.isInitialized ?? false) {
        emit(CameraHandlerReadyToCapture());
        return;
      }
    } catch (e) {
      emit(CameraHandlerError());
    }
  }

  // Future<bool> permissionCheck() async {
  //   PermissionStatus status = await Permission.camera.status;
  //   if (status.isDenied || status.isPermanentlyDenied) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  void takePicture(BuildContext context,
      {required ValueNotifier<bool> imageCaptureInProgress}) async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        imageCaptureInProgress.value) {
      return;
    }
    imageCaptureInProgress.value = true;

    if (_cameraController!.value.isTakingPicture) return;

    try {
      XFile? tmpFile = await _cameraController?.takePicture();
      if (tmpFile == null) {
        throw "Error occured while capturing the pic";
      }

      if (kIsWeb) {
        imageFile = tmpFile;
      } else {
        Uint8List imageBytes = await tmpFile.readAsBytes();

        // img.Image? originalImage = img.decodeImage(imageBytes);
        // img.Image fixedImage = img.flipHorizontal(originalImage!);

        imageFile = XFile.fromData(
          // img.encodeJpg(fixedImage),
          imageBytes,
          path: tmpFile.path,
          mimeType: tmpFile.mimeType,
          name: tmpFile.name,
        );
      }
      _cameraController?.pausePreview();

      emit(CameraHandlerImageCaptured(isBase64: false));
    } on CameraException {
      CodeScout.logError("Error capturing image", error: CameraException);
    } finally {
      imageCaptureInProgress.value = false;
    }
  }

  void retakePicture() async {
    imageFile = null;
    if (_cameraController == null) {
      await init();

      return;
    }
    if (_cameraController?.value.isPreviewPaused == true) {
      await _cameraController?.resumePreview();
    }
    emit(CameraHandlerReadyToCapture());
  }

  void dispose({bool disposeImage = true}) async {
    if (_cameraController?.value.isPreviewPaused == true) {
      await _cameraController?.resumePreview();
    }

    await _cameraController?.dispose();
    _cameraController = null;
    if (disposeImage) {
      imageFile = null;
      emit(CameraHandlerInitializing());
    }
  }
}
