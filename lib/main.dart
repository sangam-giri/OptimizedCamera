import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  _cameras = await availableCameras();
  runApp(const MaterialApp(
    home: CameraApp(),
  ));
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController cameraController;
  late VideoPlayerController videoPlayerController;
  bool back = true;
  XFile? picture;
  XFile? video;

  @override
  void initState() {
    super.initState();
    change();
  }

  change() {
    cameraController = CameraController(
      _cameras[back ? 0 : 1],
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  takePicture() async {
    picture = await cameraController.takePicture();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          onPressed: () {
            setState(() {
              back = !back;
              change();
            });
          },
          child: const Text("1:Front"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 200, child: CameraPreview(cameraController)),
                (picture == null)
                    ? const Text("Image")
                    : Row(
                        children: [
                          autoAdjust(picture!),
                          const Spacer(),
                          Transform.flip(
                            flipX: !back,
                            child: Image.file(
                              File(picture!.path),
                              height: 300,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ],
                      ),
                ElevatedButton(
                    onPressed: () {
                      takePicture();
                    },
                    child: const Text("Take Picture")),
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget autoAdjust(XFile picture) {
    return Transform.flip(
      flipX: !back,
      child: Image.file(
        File(picture.path),
        height: 300,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
