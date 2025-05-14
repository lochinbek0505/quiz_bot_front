import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({Key? key}) : super(key: key);

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool isLoading = false;
  String? downloadUrl;
  String selectedLanguage = "Uzbek"; // or "Uzbek", "Russian"

  Future<void> _generateAndUploadPdf(String name, String author) async {
    setState(() {
      isLoading = true;
    });

    final pdf = pw.Document();

    final imageProvider = pw.MemoryImage(
      (await rootBundle.load('assets/background.jpg')).buffer.asUint8List(),
    );

    final date =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
              ),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(50),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        selectedLanguage == "Uzbek"
                            ? ' SERTIFIKAT'
                            : selectedLanguage == "English"
                            ? ' CERTIFICATE'
                            : ' СЕРТИФИКАТ',
                        style: pw.TextStyle(
                          fontSize: 48,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1A1A1A'),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        selectedLanguage == "Uzbek"
                            ? 'Ushbu sertifikat taqdim etiladi'
                            : selectedLanguage == "English"
                            ? 'This certificate is awarded to'
                            : 'Этот сертификат вручается',
                        style: pw.TextStyle(
                          fontSize: 22,
                          color: PdfColor.fromHex('#555555'),
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColor.fromHex('#3498DB'),
                              width: 2,
                            ),
                          ),
                        ),

                        child: pw.Text(
                          name,
                          style: pw.TextStyle(
                            fontSize: 30,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#2C3E50'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        selectedLanguage == "Uzbek"
                            ? "Online testimizda ishtirok etib yuqori natijani ko'rsatgani uchun ushbu sertifikat bilan taqdirlanadi. Kelgusi testlarimizda ham faol bo'lishingizni so'rab qolamiz. Ishtirokingiz uchun tashakkur."
                            : selectedLanguage == "English"
                            ? "This certificate is awarded for achieving a high score in our online test. We look forward to your active participation in our future tests. Thank you for taking part."
                            : "Этот сертификат вручается за высокий результат, показанный в нашем онлайн тесте. Мы надеемся на ваше активное участие в будущих тестах. Спасибо за участие.",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColor.fromHex('#34495E'),
                        ),
                      ),
                      pw.SizedBox(height: 50),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                selectedLanguage == "Uzbek"
                                    ? ' Sana'
                                    : selectedLanguage == "English"
                                    ? ' Date'
                                    : ' Дата',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#7F8C8D'),
                                ),
                              ),
                              pw.Text(
                                date,
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColor.fromHex('#2C3E50'),
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                selectedLanguage == "Uzbek"
                                    ? ' Muallif'
                                    : selectedLanguage == "English"
                                    ? ' Author'
                                    : ' Автор',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#7F8C8D'),
                                ),
                              ),
                              pw.Text(
                                author,
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  color: PdfColor.fromHex('#2C3E50'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    Uint8List bytes = await pdf.save();

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        "certificates/${DateTime.now().millisecondsSinceEpoch}_$name.pdf",
      );

      final uploadTask = await storageRef.putData(bytes);

      final url = await uploadTask.ref.getDownloadURL();

      setState(() {
        downloadUrl = url;
      });
      _showDownloadLinkDialog();
    } catch (e) {
      print("Xatolik: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDownloadLinkDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("PDF Sertifikat yuklandi"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quyidagi havola orqali yuklab olishingiz mumkin:"),
                const SizedBox(height: 8),
                SelectableText(
                  downloadUrl ?? "",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Link nusxalandi!")),
                  );
                },
                child: const Text("📋 Nusxalash"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Yopish"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Test")),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: () {
                    _generateAndUploadPdf("Lochinbek", "Oztech Academy");
                  },
                  child: const Text("Generate PDF"),
                ),
      ),
    );
  }
}
