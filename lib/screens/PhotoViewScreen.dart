import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:myapp/models/image.dart';
import 'package:myapp/widget/toastMessage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;

class PhotoViewScreen extends StatefulWidget {
  List<Images> imagePaths;
  int currentIndex;
  PhotoViewScreen(
      {super.key, required this.imagePaths, required this.currentIndex});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewScreen> {
  late PageController _controller;

  void downloadImage(String url) async {
    var status = await Permission.manageExternalStorage.status;

    print(status);

    Dio dio = Dio();

    http.Response response = await http.get(
      Uri.parse(url),
    );

    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    } else {
      try {
        await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.bodyBytes),
          quality: 100,
          name: (DateTime.now().millisecondsSinceEpoch.toString()),
        );

        // var dir = await getApplicationDocumentsDirectory();
        // print(dir.path);
        // await dio.download(
        //   url,
        //   '${dir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg',
        // );

        ToastWidget.showToast("이미지를 다운로드하였습니다.");
      } catch (e) {
        ToastWidget.showToast("이미지를 다운로드에 실패하였습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller = PageController(initialPage: widget.currentIndex);
    return Scaffold(
      body: PageView.builder(
          controller: _controller,
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                PhotoView(
                  imageProvider: NetworkImage(widget.imagePaths[index].image!),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 40, left: 10),
                    child: IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        downloadImage(widget
                            .imagePaths[_controller.page!.round()].image!);
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 45),
                    child: const Text(
                      "사진",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Dongle',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 45, right: 10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      //color: Colors.white24,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      "${index + 1} / ${widget.imagePaths.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Dongle',
                        fontSize: 27,
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
