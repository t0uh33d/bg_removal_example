import 'dart:io';

import 'package:bg_removal_app/libraries/camera_handler/camera_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_cubit/get_cubit.dart';

class BackgroundImageExtractor extends StatefulWidget {
  const BackgroundImageExtractor({super.key});

  @override
  State<BackgroundImageExtractor> createState() =>
      _BackgroundImageExtractorState();
}

class _BackgroundImageExtractorState extends State<BackgroundImageExtractor> {
  final CameraHandler cameraHandler = GetCubit.put(CameraHandler());

  @override
  void initState() {
    cameraHandler.init();
    super.initState();
  }

  @override
  void dispose() {
    cameraHandler.dispose();
    super.dispose();
  }

  final ValueNotifier<bool> capturingImage = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Background image extractor'),
        ),
        body: BlocProvider.value(
          value: cameraHandler,
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: BlocBuilder<CameraHandler, CameraHandlerState>(
              builder: (context, state) {
                if (state is CameraHandlerInitializing) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CameraHandlerError) {
                  return Center(
                    child: MaterialButton(
                      onPressed: () {
                        cameraHandler.init();
                      },
                      child: const Text('Error occred, Retry.'),
                    ),
                  );
                }
                return _render(size, context, state);
              },
            ),
          ),
        ));
  }

  Column _render(Size size, BuildContext context, CameraHandlerState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: size.height * 0.6,
          // width: size.width * 0.6,
          color: Colors.grey,
          child: _cameraPreview(state, size),
        ),
        ValueListenableBuilder<bool>(
            valueListenable: capturingImage,
            builder: (context, val, _) {
              if (val) {
                return const CircularProgressIndicator(strokeWidth: 2);
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: Colors.purple,
                    onPressed: () {
                      if (state is CameraHandlerImageCaptured ||
                          state is CameraHandlerRemovedBackground) {
                        cameraHandler.retakePicture();
                        return;
                      }

                      cameraHandler.takePicture(
                        context,
                        imageCaptureInProgress: capturingImage,
                      );
                    },
                    child: state is CameraHandlerReadyToCapture
                        ? const Text(
                            'Capture Image',
                            style: TextStyle(color: Colors.white),
                          )
                        : const Text(
                            "Retake image",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  if (state is CameraHandlerImageCaptured) ...[
                    const SizedBox(width: 20),
                    MaterialButton(
                        color: Colors.purple,
                        onPressed: () {
                          cameraHandler.removeBackground(capturingImage);
                        },
                        child: const Text(
                          'Remove Background',
                          style: TextStyle(color: Colors.white),
                        )),
                  ]
                ],
              );
            })
      ],
    );
  }

  Widget _cameraPreview(CameraHandlerState state, Size size) {
    if (state is CameraHandlerReadyToCapture) {
      return CameraPreview(cameraHandler.cameraController!);
    }

    return Container(
      height: size.height * 0.6,
      child: Image.file(File(
        state is CameraHandlerRemovedBackground
            ? cameraHandler.removedBackgroundImagePath!
            : cameraHandler.imageFile!.path,
      )),
    );
  }
}
