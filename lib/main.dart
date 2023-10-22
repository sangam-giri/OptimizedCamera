import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MaterialApp(
    home: CameraApp(),
  ));
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController cameraController;
  late VideoPlayerController videoPlayerController;

  XFile? picture;
  XFile? video;

  @override
  void initState() {
    super.initState();
    change(0);
  }

  change(int index) {
    cameraController = CameraController(_cameras[index], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  videoPlayer(XFile filePath) {
    print("File Path: ${filePath.path}");
    videoPlayerController = VideoPlayerController.file(File(filePath.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  cameraFeatures() {
    cameraController.enableAudio;
  }

  takePicture() async {
    picture = await cameraController.takePicture();
    print("Picture: $picture");
    setState(() {});
  }

  play() async {
    await videoPlayerController.play();
  }

  pause() async {
    await videoPlayerController.pause();
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                setState(() {
                  change(1);
                });
              },
              child: const Text("1:Front"),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                setState(() {
                  change(0);
                });
              },
              child: const Text("0:Back"),
            ),
          ],
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
                          Image.file(
                            File(picture!.path),
                            height: 300,
                          ),
                          //Second - > Inverse
                          Transform.flip(
                            flipX: true,
                            child: Image.file(
                              File(picture!.path),
                              height: 300,
                              filterQuality: FilterQuality.high,
                            ),
                          )
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
}
