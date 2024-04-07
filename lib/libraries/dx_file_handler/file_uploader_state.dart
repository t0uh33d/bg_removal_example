part of dx_file_hanlder;

sealed class FileUploaderState {}

class FileUploaderInitialState extends FileUploaderState {}

class FileUploaderInvalidFileSelected extends FileUploaderState {
  final String errorMessge;
  FileUploaderInvalidFileSelected({
    required this.errorMessge,
  });
}

class FileUploaderFilesSelectedSuccessfully extends FileUploaderState {}

class FileUploaderUploadingFiles extends FileUploaderState {}
