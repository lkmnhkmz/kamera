import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'widget/filter_selector.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController; // Controller untuk kamera
  List<CameraDescription>? _cameras; // Daftar kamera yang tersedia
  Color selectedFilterColor = Colors.transparent; // Warna filter yang dipilih
  XFile? capturedImage; // Menyimpan foto yang diambil

  // Daftar filter warna yang tersedia
  final List<Color> _filters = [
    Colors.transparent,
    Colors.grey.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.red.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Inisialisasi kamera saat widget dimuat
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras(); // Mendapatkan daftar kamera
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize(); // Inisialisasi kamera
      if (mounted) {
        setState(() {}); // Perbarui UI setelah kamera siap
      }
    }
  }

  // Mengubah warna filter berdasarkan pilihan pengguna
  void _onFilterChanged(Color filterColor) {
    setState(() {
      selectedFilterColor = filterColor;
    });
  }

  // Fungsi untuk mengambil foto
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    capturedImage = await _cameraController!.takePicture(); // Ambil foto
    setState(() {}); // Perbarui UI untuk menampilkan hasil foto
  }

  // Fungsi untuk mengambil ulang foto
  Future<void> _retakePicture() async {
    setState(() {
      capturedImage = null; // Reset foto
      selectedFilterColor = Colors.transparent; // Reset filter
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Membersihkan controller kamera
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: capturedImage == null
          ? AppBar(title: const Text("Lukman : 1122140088")) // Menampilkan AppBar sebelum foto diambil
          : null, // Hilangkan AppBar setelah foto diambil
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: capturedImage == null
                ? (_cameraController != null && _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!) // Menampilkan preview kamera
                    : const Center(child: CircularProgressIndicator())) // Loading jika kamera belum siap
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.file(
                          File(capturedImage!.path),
                          fit: BoxFit.cover, // Agar gambar pas di layar
                        ),
                      ),
                      Positioned.fill(
                        child: Container(color: selectedFilterColor), // Overlay filter
                      ),
                    ],
                  ),
          ),

          // Menampilkan filter hanya setelah mengambil foto
          if (capturedImage != null)
            FilterSelector(
              filters: _filters,
              onFilterChanged: _onFilterChanged,
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: capturedImage == null
                ? ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text("Ambil Foto"),
                  )
                : ElevatedButton(
                    onPressed: _retakePicture,
                    child: const Text("Ambil Ulang"),
                  ),
          ),
        ],
      ),
    );
  }
}
