library dx_file_hanlder;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cw_core/cw_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get_cubit/get_cubit.dart';
import 'package:http/http.dart' as http;

part 'controller.dart';
part 'data.dart';
part 'file_uploader.dart';
part 'file_uploader_cubit.dart';
part 'file_uploader_state.dart';
part 'network.dart';

class DxFileHandler {
  DxFileHandler({
    Set<String> supportedExtensions = const <String>{'jpg', 'jpeg', 'png'},
    int maxFileSize = 5,
    String fileSizeErrorKey =
        'File size limit is exceeded, please upload below 5 MB',
    String fileTypeErrorKey = 'Invalid file format',
    bool disableMutipleSelection = false,
  }) {
    _createCubitForView();
    _fileUploaderController._maxSizeInMB = maxFileSize;
    _fileUploaderController._supportedExtensions = supportedExtensions;
    _fileUploaderController._fileSizeErrorKey = fileSizeErrorKey;
    _fileUploaderController._fileTypeErrorKey = fileTypeErrorKey;
    _fileUploaderController._disableMultipleSelection = disableMutipleSelection;
  }

  /// file uploader controller which controls the files
  final FileUploaderController _fileUploaderController =
      FileUploaderController();

  /// handles the state of the file uplaoder
  late FileUploaderCubit _fileUploaderCubit;

  /// creates [FileUploaderCubit] on demand for View
  void _createCubitForView() {
    _fileUploaderCubit = FileUploaderCubit();
    _fileUploaderController._setFileUploaderCubit(_fileUploaderCubit);
    _fileUploaderCubit._setFileUploaderController(_fileUploaderController);
  }

  /// ``` dart
  /// generate a cubit to attach to UI to receive state updates
  /// the states of the FileUploaderCubit are as follows
  ///
  /// - FileUploaderInitialState : yet to select any files
  /// - FileUploaderInvalidFileSelected : invalid files selected
  /// - FileUploaderFilesSelectedSuccessfully : files have been selected successfully
  /// - FileUploaderUploadingFiles : Files being uploaded to the server
  /// ```
  FileUploaderCubit generateCubit() {
    return _fileUploaderCubit;
  }

  // dispose the handler
  void dispose() {
    _fileUploaderCubit.close();
  }

  // this will stack the child widget above the drop zone view
  Widget attachDropZoneView({required Widget child}) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DropzoneView(
            onCreated: _fileUploaderController.setDropZoneController,
            onDrop: _fileUploaderController._fileDropped,
            onDropMultiple: _fileUploaderController._onMultiDrop,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  void openFilePicker() {
    _fileUploaderController._pickFiles();
  }

  void mimicFilePick(List<FileUploaderObject> files) {
    _fileUploaderController.mimicFilePick(files);
  }

  // start uplaoding
  Future<void> upload() async {}

  // remove file
  void removeFile(FileUploaderObject fileUploaderObject) {
    _fileUploaderCubit.removeFile(fileUploaderObject);
  }

  void removeAllFiles() {
    _fileUploaderCubit._removeAllFiles();
  }
}
