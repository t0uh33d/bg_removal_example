part of camera_handler;

sealed class CameraHandlerState {}

class CameraHandlerInitializing extends CameraHandlerState {}

class CameraHandlerReadyToCapture extends CameraHandlerState {}

class CameraHandlerImageCaptured extends CameraHandlerState {
  final bool isBase64;
  CameraHandlerImageCaptured({required this.isBase64});
}

class CameraHandlerRemovedBackground extends CameraHandlerState {}

class CameraHandlerError extends CameraHandlerState {}
