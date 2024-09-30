import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:real_fake_rupiah/main.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = 'Tunggu Sebentar........';
  double confidence = 0.0;
  final AudioPlayer audioPlayer = AudioPlayer();
  var logger = Logger();
  Timer? timer;
  int detectionInterval = 3;
  int timeLeft = 3;
  bool isDetecting = false;
  bool isStreamingImages = false;

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadModel();
    playStartupSound();
  }

  loadCamera() async {
    cameraController =
        CameraController(cameras![0], ResolutionPreset.ultraHigh);
    await cameraController!.initialize();
    if (!mounted) {
      return;
    }

    await cameraController!.setFlashMode(FlashMode.torch);
    setState(() {
      cameraController!.startImageStream((ImageStream) {
        cameraImage = ImageStream;
      });
      isStreamingImages = true;
    });
  }

  startDetectionTimer() {
    if (!isDetecting) {
      timeLeft = detectionInterval;
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            timeLeft = detectionInterval;
            runModel();
          }
        });
        logger.f('Time left until next detection: $timeLeft seconds');
      });
    }
  }

  stopDetectionTimer() {
    timer?.cancel();
    setState(() {
      output = 'Tunggu Sebentar........';
      confidence = 0.0;
      timeLeft = detectionInterval;
    });
    logger.w('Detection stopped.');

    if (isStreamingImages) {
      cameraController?.stopImageStream();
      isStreamingImages = false;
    }
  }

  runModel() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      if (predictions != null && predictions.isNotEmpty) {
        predictions.forEach((element) {
          setState(() {
            output = element['label'];
            confidence = element['confidence'];
            logger.i("Output: $output, Confidence: $confidence");
            playSound(output, confidence);
          });
        });
      } else {
        setState(() {
          output = "Tunggu Sebentar........";
          confidence = 0.0;
          logger.i("Output: $output, Confidence: $confidence");
        });
      }
    }
  }

  Future<void> playSound(String label, double confidence) async {
    String soundPath = '';
    if (label == 'Asli') {
      if (confidence > 0.9) {
        soundPath = 'sounds/real_above_90_percent.mp3';
      } else if (confidence > 0.8) {
        soundPath = 'sounds/real_above_80_percent.mp3';
      } else if (confidence >= 0.7) {
        soundPath = 'sounds/real_above_70_percent.mp3';
      } else if (confidence < 0.1) {
        soundPath = 'sounds/real_below_10_percent.mp3';
      } else if (confidence < 0.2) {
        soundPath = 'sounds/real_below_20_percent.mp3';
      } else if (confidence < 0.3) {
        soundPath = 'sounds/real_below_30_percent.mp3';
      } else if (confidence < 0.4) {
        soundPath = 'sounds/real_below_40_percent.mp3';
      } else if (confidence < 0.5) {
        soundPath = 'sounds/real_below_50_percent.mp3';
      } else if (confidence < 0.6) {
        soundPath = 'sounds/real_below_60_percent.mp3';
      } else if (confidence < 0.7) {
        soundPath = 'sounds/real_below_60_percent.mp3';
      } else {
        soundPath = '';
      }
    } else if (label == 'Palsu') {
      if (confidence > 0.9) {
        soundPath = 'sounds/fake_above_90_percent.mp3';
      } else if (confidence > 0.8) {
        soundPath = 'sounds/fake_above_80_percent.mp3';
      } else if (confidence > 0.7) {
        soundPath = 'sounds/fake_above_70_percent.mp3';
      } else if (confidence > 0.6) {
        soundPath = 'sounds/fake_above_60_percent.mp3';
      } else if (confidence >= 0.5) {
        soundPath = 'sounds/fake_above_50_percent.mp3';
      } else if (confidence < 0.1) {
        soundPath = 'sounds/fake_below_10_percent.mp3';
      } else if (confidence < 0.2) {
        soundPath = 'sounds/fake_below_20_percent.mp3';
      } else if (confidence < 0.3) {
        soundPath = 'sounds/fake_below_30_percent.mp3';
      } else if (confidence < 0.4) {
        soundPath = 'sounds/fake_below_40_percent.mp3';
      } else if (confidence < 0.5) {
        soundPath = 'sounds/fake_below_50_percent.mp3';
      } else {
        soundPath = '';
      }
    }

    if (soundPath.isNotEmpty) {
      logger.w("Suara yang terputar: '$soundPath'");
      await audioPlayer.play(AssetSource(soundPath));
    }
  }

  Future<void> playStartupSound() async {
    const soundPath = 'sounds/start_aplikasi.mp3';
    logger.i("Memutar suara startup: '$soundPath'");
    await audioPlayer.play(AssetSource(soundPath));
  }

  Future<void> playStartDetectionSound() async {
    const soundPath = 'sounds/pendeteksian_dimulai.mp3';
    logger.i("Memutar suara: '$soundPath'");
    await audioPlayer.play(AssetSource(soundPath));
  }

  Future<void> playStopDetectionSound() async {
    const soundPath = 'sounds/pendeteksian_dihentikan.mp3';
    logger.i("Memutar suara: '$soundPath'");
    await audioPlayer.play(AssetSource(soundPath));
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/real_fake_rupiah.tflite", labels: "assets/labels.txt");
  }

  void toggleDetection() async {
    if (isDetecting) {
      stopDetectionTimer();
      await playStopDetectionSound();
      setState(() {
        isDetecting = false;
      });
    } else {
      startDetectionTimer();
      await playStartDetectionSound();
      setState(() {
        isDetecting = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: toggleDetection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Deteksi Keaslian Uang Kertas Rupiah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 255, 54, 54),
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: !cameraController!.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(cameraController!),
                      ),
              ),
            ),
            if (!isDetecting)
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tekan 2x Pada Layar Untuk ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Memulai Pendeteksian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: '\nUlangi Untuk ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Menghentikan Pendeteksian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$output',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: output == 'Asli'
                            ? const Color.fromARGB(255, 0, 131, 4)
                            : const Color.fromARGB(255, 245, 30, 15),
                      ),
                    ),
                    TextSpan(
                      text:
                          '\nKepercayaan: ${(confidence * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '\nPrediksi selanjutnya dalam $timeLeft detik',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color.fromARGB(255, 250, 3, 3),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              'assets/images/telkom-university-logo-13478D5B60-seeklogo.com.png',
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isStreamingImages) {
      cameraController?.stopImageStream();
    }
    cameraController?.setFlashMode(FlashMode.off);
    cameraController?.dispose();
    audioPlayer.dispose();
    timer?.cancel();
    super.dispose();
  }
}
