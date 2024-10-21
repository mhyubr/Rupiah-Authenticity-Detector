# Rupiah-Authenticity-Detector

![Screenshot](real_fake_rupiah/assets/images/Mockup%20Start%20App.png)

Rupiah-Authenticity-Detector adalah proyek yang menggabungkan pembelajaran mesin dengan aplikasi mobile untuk mendeteksi keaslian uang Rupiah. Proyek ini menggunakan model deteksi gambar berbasis TensorFlow untuk menentukan apakah uang tersebut asli atau palsu, dengan antarmuka pengguna yang dibangun menggunakan Flutter.

## Spesifikasi Lingkungan Pengembangan

### 1. Lingkungan Model
- **Python Version**: 3.10.13
- **Numpy**: 1.26.4
- **Pandas**: 2.2.2
- **TensorFlow**: 2.15.0
- **Matplotlib**: 3.7.5
- **Seaborn**: 0.12.2
- **Scikit-learn**: 1.2.2
- **Optuna**: 3.6.1

### 2. Spesifikasi Notebook
- **Nama Akselerator**: Tesla P100-PCIE-16GB
- **Versi CUDA**: 12.2
- **Kapasitas Tenaga**: 250 W
- **RAM Sistem**: 62.8 GB
- **RAM GPU**: 16,384 MiB
- **Kapasitas Penyimpanan**: 201.2 GB

## Aplikasi Mobile (Flutter)

### Deskripsi Proyek
Aplikasi Flutter ini berfungsi sebagai antarmuka untuk mendeteksi keaslian uang Rupiah menggunakan model TensorFlow yang telah dilatih. Dengan memanfaatkan kamera perangkat, aplikasi dapat mengambil gambar uang Rupiah dan memberikan hasil deteksi mengenai keasliannya.

### Struktur Proyek Flutter
- **Nama Proyek**: `real_fake_rupiah`

### Flutter Dependencies
Proyek ini menggunakan beberapa dependencies Flutter untuk menangani fungsionalitas kamera, model TensorFlow Lite, serta audio dan logging:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.11.0
  tflite_v2: ^1.0.0
  audioplayers: ^6.0.0
  logger: ^2.3.0
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
