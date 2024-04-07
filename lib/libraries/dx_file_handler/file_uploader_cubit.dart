part of dx_file_hanlder;

class FileUploaderCubit extends Cubit<FileUploaderState> {
  FileUploaderCubit() : super(FileUploaderInitialState());

  late FileUploaderController _fileUploaderController;

  List<FileUploaderObject>? selectedFiles;

  ValueNotifier<double> progress = ValueNotifier<double>(0);

  void _filesAdded() {
    List<FileUploaderObject>? selectedFiles =
        _fileUploaderController._selectedFiles;
    if (selectedFiles == null) return;

    this.selectedFiles = selectedFiles;
    // if (SignaturePadController().containsSignature.value) {
    //   SignaturePadController().clear();
    //   SignaturePadController().containsSignature.value = false;
    // }
    // LiveVerificationController().isSignUploaded.value = true;
    emit(FileUploaderFilesSelectedSuccessfully());
  }

  void _setFileUploaderController(
      FileUploaderController fileUploaderController) {
    _fileUploaderController = fileUploaderController;
  }

  void _removeAllFiles() {
    selectedFiles = null;
    emit(FileUploaderInitialState());
    return;
  }

  void removeFile(FileUploaderObject file) {
    if (selectedFiles == null) return;
    if (selectedFiles!.length == 1) {
      selectedFiles = null;
      emit(FileUploaderInitialState());
      return;
    }

    if (selectedFiles!.contains(file)) {
      selectedFiles!.remove(file);
      emit(FileUploaderFilesSelectedSuccessfully());
    }
  }

  void invalidFilesSelected(String message) {
    emit(FileUploaderInvalidFileSelected(errorMessge: message));
  }
}
