part of dx_file_hanlder;

class FileUploader extends StatefulWidget {
  const FileUploader({super.key});

  @override
  State<FileUploader> createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  final FileUploaderCubit fileUploaderCubit = GetCubit.put(FileUploaderCubit());

  late FileUploaderController _fileUploaderController;

  @override
  void initState() {
    _fileUploaderController = FileUploaderController();
    fileUploaderCubit._setFileUploaderController(_fileUploaderController);
    super.initState();
  }

  @override
  void dispose() {
    fileUploaderCubit.deleteAllInstances();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileUploaderCubit>.value(
      value: fileUploaderCubit,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: DropzoneView(
                  onCreated: _fileUploaderController.setDropZoneController,
                  onDrop: _fileUploaderController._fileDropped,
                  onDropMultiple: _fileUploaderController._onMultiDrop,
                ),
              ),
              const SizedBox(
                height: 100,
                width: 100,
                child: Text(
                  'File dropper/uploader -- find commented sample based on state below',
                ),
              )
              // DottedBorder(
              //   strokeWidth: 1.4,
              //   dashPattern: const <double>[8, 3],
              //   borderType: BorderType.RRect,
              //   radius: const Radius.circular(12),
              //   color: FyColor.blue300,
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: FyColor.blue50,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: <Widget>[
              //         // const FyImage(image: ImagePaths.uploadImg),
              //         const SizedBox(
              //           width: 20,
              //         ),
              //         BlocBuilder<FileUploaderCubit, FileUploaderState>(
              //           builder:
              //               (BuildContext context, FileUploaderState state) {
              //             return Column(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: <Widget>[
              //                 CommonWidgets.text(
              //                   'Drag & drop / Upload document',
              //                   fontWeight: FontWeight.w500,
              //                   fontSize: 15,
              //                   color: FyTheme.black500,
              //                 ),
              //                 const SizedBox(height: 8),
              //                 _fileDetail(state),
              //                 const SizedBox(height: 14),
              //                 InkWell(
              //                   onTap: _fileUploaderController._pickFiles,
              //                   child: CommonWidgets.container(
              //                     padding: 5,
              //                     borderRadius: 4,
              //                     color: Colors.white,
              //                     border: Border.all(
              //                       color: const Color(0xffbfc4ca),
              //                       width: 1,
              //                     ),
              //                     child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.start,
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.center,
              //                       children: <Widget>[
              //                         // const FyImage(
              //                         //   image: ImagePaths.uploadIcon,
              //                         // ),
              //                         const SizedBox(width: 6),
              //                         CommonWidgets.text(
              //                           state is FileUploaderInvalidFileSelected
              //                               ? "Upload again"
              //                               : "Upload",
              //                           fontWeight: FontWeight.w500,
              //                           fontSize: 12,
              //                           color: FyTheme.black500,
              //                           height: 1.5,
              //                         )
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 14),
          BlocBuilder<FileUploaderCubit, FileUploaderState>(
            builder: (BuildContext context, FileUploaderState state) {
              switch (state) {
                case FileUploaderInitialState() ||
                      FileUploaderInvalidFileSelected():
                  return const SizedBox();
                case FileUploaderFilesSelectedSuccessfully() ||
                      FileUploaderUploadingFiles():
                  bool isUploading = state is FileUploaderUploadingFiles;
                  if (fileUploaderCubit.selectedFiles == null) {
                    return const SizedBox();
                  }
                  return SizedBox(
                    height: 300,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 14),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemCount: fileUploaderCubit.selectedFiles!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _file(
                          fileUploaderCubit.selectedFiles![index],
                          isUploading,
                        );
                      },
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _file(FileUploaderObject fileUploaderObject, bool isUploading) {
    return const Text('File widget goes here');
  }

  // ignore: unused_element
  Widget _fileDetail(FileUploaderState uploaderState) {
    String message = 'File format: PDF/JPG  Max: 5 MB';
    bool isInvalid = false;
    if (uploaderState is FileUploaderInvalidFileSelected) {
      message = uploaderState.errorMessge;
      isInvalid = true;
    }
    return Text(
      message,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: isInvalid ? Colors.red : Colors.black,
        height: 1,
      ),
    );
  }
}
