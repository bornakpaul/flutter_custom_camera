import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/camera_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            PermissionStatus status = await Permission.camera.request();
            print("Accessed");
            if (status.isGranted) {
              print("Granted");
              await availableCameras().then(
                (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CameraLayover(cameraDescriptions: value))),
              );
            }else {
              await openAppSettings();
            }
          },
          child: const Text("Take a picture"),
        ),
      ),
    );
  }
}
