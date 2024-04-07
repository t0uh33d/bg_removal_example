part of dx_file_hanlder;

class FileUploaderObject {
  final String fileName;
  final String fileExtension;
  final Uint8List byteArray;
  final int sizeInBytes;

  FileUploaderObject({
    required this.fileName,
    required this.fileExtension,
    required this.byteArray,
    required this.sizeInBytes,
  });

  String? fileUploadKey;

  void setFileUploadKey(String key) {
    fileUploadKey = key;
  }

  factory FileUploaderObject.fromPlatformFile(PlatformFile platformFile) {
    String fileName = platformFile.name;
    return FileUploaderObject(
      fileName: fileName,
      fileExtension: FileUploaderController._getFileExtension(fileName),
      byteArray: platformFile.bytes!,
      sizeInBytes: platformFile.size,
    );
  }

  @override
  bool operator ==(covariant FileUploaderObject other) {
    if (identical(this, other)) return true;

    return other.fileName == fileName &&
        other.fileExtension == fileExtension &&
        other.byteArray == byteArray &&
        other.sizeInBytes == sizeInBytes;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        fileExtension.hashCode ^
        byteArray.hashCode ^
        sizeInBytes.hashCode;
  }
}
