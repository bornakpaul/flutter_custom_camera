import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraLayover extends StatefulWidget {
  final List<CameraDescription> cameraDescriptions;

  const CameraLayover({
    Key? key,
    required this.cameraDescriptions,
  }) : super(key: key);

  @override
  State<CameraLayover> createState() => _CameraLayoverState();
}

class _CameraLayoverState extends State<CameraLayover> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String? _selectedImagePath;
  bool _flashOn = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
    initCamera(widget.cameraDescriptions[0]);
    _initializeControllerFuture = _cameraController.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  ///
  /// method to take photo
  ///
  Future<void> _takePhoto() async {
    await _initializeControllerFuture;
    final image = await _cameraController.takePicture();

    setState(() {
      _selectedImagePath = image.path;
    });
  }

  ///
  /// method to turn on flash
  ///
  Future<void> _turnFlashOn() async {
    if (_cameraController.description.lensDirection ==
        CameraLensDirection.front) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Flash not available for front camera"),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_cameraController.value.isInitialized && !_flashOn) {
      await _cameraController.setFlashMode(FlashMode.torch);
    } else if (_cameraController.value.isInitialized && _flashOn) {
      await _cameraController.setFlashMode(FlashMode.off);
    }
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  ///
  /// method to toggle camera
  ///
  Future<void> _toggleCamera() async {
    if (_cameraController.value.isInitialized) {
      final lensDescription = _cameraController.description.lensDirection;
      debugPrint("lensDescription: $lensDescription");
      CameraDescription newCameraDescription;
      if (lensDescription == CameraLensDirection.front) {
        newCameraDescription = widget.cameraDescriptions.firstWhere(
            (element) => element.lensDirection == CameraLensDirection.back);
      } else {
        newCameraDescription = widget.cameraDescriptions.firstWhere(
            (element) => element.lensDirection == CameraLensDirection.front);
      }

      await initCamera(newCameraDescription);

      // int currentCameraIndex = widget.cameraDescriptions.indexOf(_cameraController.description);
      // int newCameraIndex = (currentCameraIndex + 1) % widget.cameraDescriptions.length;
      // //await _cameraController.dispose();
      // _cameraController = CameraController(widget.cameraDescriptions[newCameraIndex], ResolutionPreset.high);
      // try {
      //   await _cameraController.initialize().then((_) {
      //     if (!mounted) return;
      //     setState(() {});
      //   });
      // } on CameraException catch (e) {
      //   debugPrint("camera error $e");
      // }
    }
  }

  ///
  /// initialize camera at the start
  ///
  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: _cameraController.value.isInitialized
          ? LayoutBuilder(builder: (context, constraints) {
              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: _selectedImagePath != null
                        ? Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                          )
                        : CameraPreview(
                            _cameraController,
                          ),
                  ),
                  if (_selectedImagePath == null) ...[
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 8,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 8,
                                child: Container(
                                  height: size.height / 2,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Transform.rotate(
                                  angle: 90 * 3.1415926535,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: size.height / 2,
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        "USE THE GUIDE TO CLICK THE FRONT PROFILE PICTURE",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 50,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _turnFlashOn();
                            },
                            child: Icon(
                              !_flashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          InkWell(
                            onTap: () async {
                              _takePhoto();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  )),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          InkWell(
                            onTap: () {
                              _toggleCamera();
                            },
                            child: const Icon(
                              Icons.cameraswitch_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              );
            })
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
