part of dx_file_hanlder;

class FileUploaderNetwork {
  static Future<dynamic> uploadFiles({
    required List<FileUploaderObject>? fileUploaderObjects,
    required Uri uri,
    Map<String, String>? fields,
    Map<String, String>? headers,
    ValueNotifier<double>? progressNotifier,
  }) async {
    http.MultipartRequest multipartRequest = http.MultipartRequest(
      'POST',
      uri,
      // onProgress: (int bytes, int totalBytes) {
      //   DxLogger.debugLogInfo(totalBytes);
      //   if (fileUploaderObjects != null && progressNotifier != null) {
      //     progressNotifier.value = bytes / totalBytes;
      //   }
      // },
    );
    if (fields != null) {
      multipartRequest.fields.addAll(fields);
    }

    if (headers != null) {
      multipartRequest.headers.addAll(headers);
    }

    if (fileUploaderObjects != null) {
      for (int idx = 0; idx < fileUploaderObjects.length; idx++) {
        FileUploaderObject uploaderObject = fileUploaderObjects[idx];
        http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          uploaderObject.fileUploadKey ?? '',
          uploaderObject.byteArray,
          filename: uploaderObject.fileName,
        );
        multipartRequest.files.add(multipartFile);
      }
    }

    http.StreamedResponse response = await multipartRequest.send();
    try {
      return json.decode(await response.stream.bytesToString());
    } catch (e) {
      CodeScout.logError('Uploading failed', error: e);
    }
  }
}
