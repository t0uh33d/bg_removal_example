part of dx_file_hanlder;

class FileUploaderController {
  // drop zone view controller
  late DropzoneViewController _dropzoneViewController;

  // supported extensions
  late Set<String> _supportedExtensions;

  // max supported size
  late int _maxSizeInMB;

  // file size error key
  late String _fileSizeErrorKey;

  // file type error key
  late String _fileTypeErrorKey;

  // disable multiple selection
  late bool _disableMultipleSelection;

  // file uploader cubit
  late FileUploaderCubit fileUploaderCubit;

  // selected files
  List<FileUploaderObject>? _selectedFiles;

  void _setFileUploaderCubit(FileUploaderCubit cubit) {
    fileUploaderCubit = cubit;
  }

  void setDropZoneController(DropzoneViewController dropzoneViewController) {
    _dropzoneViewController = dropzoneViewController;
  }

  void _fileDropped(dynamic fileObj) async {
    FileUploaderObject? fileUploaderObject = await _processDroppedFile(fileObj);
    if (fileUploaderObject == null) return;
    _selectedFiles = <FileUploaderObject>[fileUploaderObject];

    fileUploaderCubit._filesAdded();
  }

  void _onMultiDrop(List<dynamic>? fileObjArr) async {
    if (fileObjArr == null) return;
    List<FileUploaderObject> fileUploaderObject = <FileUploaderObject>[];
    for (int idx = 0; idx < fileObjArr.length; idx++) {
      FileUploaderObject? f = await _processDroppedFile(fileObjArr[idx]);
      if (f == null) return;
      fileUploaderObject.add(f);
    }

    _selectedFiles = fileUploaderObject;
    fileUploaderCubit._filesAdded();
  }

  Future<FileUploaderObject?> _processDroppedFile(dynamic fileObj) async {
    Uint8List byteArray = await _dropzoneViewController.getFileData(fileObj);
    int fileSizeInBytes = await _dropzoneViewController.getFileSize(fileObj);
    String fileName = await _dropzoneViewController.getFilename(fileObj);

    FileUploaderObject fileUploaderObject = FileUploaderObject(
      fileName: fileName,
      fileExtension: _getFileExtension(fileName),
      byteArray: byteArray,
      sizeInBytes: fileSizeInBytes,
    );

    String? fileValidity = _validate(fileUploaderObject);

    if (fileValidity != null) {
      fileUploaderCubit.invalidFilesSelected(fileValidity);
      return null;
    }

    return fileUploaderObject;
  }

  void mimicFilePick(List<FileUploaderObject> files) {
    _selectedFiles = files;
    fileUploaderCubit._filesAdded();
  }

  void _pickFiles() async {
    try {
      FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: !_disableMultipleSelection,
      );
      if (filePickerResult == null) return;

      List<FileUploaderObject> files = <FileUploaderObject>[];

      for (int idx = 0; idx < filePickerResult.count; idx++) {
        FileUploaderObject fileUploaderObject;
        if (filePickerResult.files[idx].bytes != null) {
          fileUploaderObject =
              FileUploaderObject.fromPlatformFile(filePickerResult.files[idx]);
        } else {
          if (kIsWeb) return;
          File file = File(filePickerResult.files[idx].path!);
          Uint8List uint8list = await file.readAsBytes();
          PlatformFile platformFile = PlatformFile(
              name: filePickerResult.files[idx].name,
              size: filePickerResult.files[idx].size,
              bytes: uint8list);
          fileUploaderObject =
              FileUploaderObject.fromPlatformFile(platformFile);
        }

        String? fileValidity = _validate(fileUploaderObject);

        if (fileValidity != null) {
          fileUploaderCubit.invalidFilesSelected(fileValidity);
          return;
        }

        files.add(fileUploaderObject);
      }

      _selectedFiles = files;
      fileUploaderCubit._filesAdded();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  String? _validate(FileUploaderObject fileUploaderObject) {
    if (!_isExtensionValid(fileUploaderObject.fileExtension)) {
      return _fileTypeErrorKey;
    }

    if (!_isSizeValid(fileUploaderObject.sizeInBytes)) {
      return _fileSizeErrorKey;
    }

    return null;
  }

  bool _isExtensionValid(String extension) {
    return _supportedExtensions.contains(extension);
  }

  bool _isSizeValid(int sizeInBytes) {
    return _convertToMegaBytes(sizeInBytes) < _maxSizeInMB;
  }

  double _convertToMegaBytes(int bytes) {
    return bytes / pow(10, 6);
  }

  static String _getFileExtension(String name) {
    String ext = '';
    for (int idx = name.length - 1; idx > 0; idx--) {
      if (name[idx] == '.') break;
      ext = name[idx] + ext;
    }

    return ext;
  }
}
