import 'dart:html' as html;
import 'dart:js' as js;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To copy the link
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificateUploader extends StatefulWidget {
  const CertificateUploader({super.key});

  @override
  State<CertificateUploader> createState() => _CertificateUploaderState();
}

class _CertificateUploaderState extends State<CertificateUploader> {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final authorController = TextEditingController();

  String downloadUrl = '';
  bool isLoading = false;

  String getTelegramUserId() {
    final telegram = js.context['Telegram'];
    final userId = telegram?['WebApp']?['initDataUnsafe']?['user']?['id'];
    return userId?.toString() ?? 'unknown';
  }

  var text = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      text = getTelegramUserId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sertifikat PDF (Firebase ${text})")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ism'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Sana'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Muallif'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _generateAndUploadPdf,
              child: Text(isLoading ? "Yuklanmoqda..." : "Yaratish va yuklash"),
            ),
            const SizedBox(height: 20),
            if (downloadUrl.isNotEmpty)
              ElevatedButton(
                onPressed: () => _showDownloadLinkDialog(context),
                child: Text("Yuklab olish linki"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndUploadPdf() async {
    setState(() {
      isLoading = true;
    });

    final pdf = pw.Document();

    // Load the background image
    final imageProvider = pw.MemoryImage(
      (await rootBundle.load('assets/background.jpg')).buffer.asUint8List(),
    );

    final name =
        nameController.text.isEmpty ? "Foydalanuvchi" : nameController.text;
    final date = dateController.text.isEmpty ? "____" : dateController.text;
    final author =
        authorController.text.isEmpty ? "____" : authorController.text;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background image
              pw.Positioned.fill(child: pw.Image(imageProvider)),
              // Content on top of the background
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        ' SERTIFIKAT ',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF3498DB), // Blue
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'Online testda ishtirok etgani uchun ',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.normal,
                          color: PdfColor.fromInt(0xFF2ECC71), // Green
                        ),
                      ),
                      pw.SizedBox(height: 25),
                      pw.Text(
                        name,
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF9B59B6), // Purple
                        ),
                      ),
                      pw.SizedBox(height: 25),
                      pw.Text(
                        'Online testda ishtirok etib natijani ko\'rsatgani uchun ushbu sertifikat bilan taqdirlanadi.',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColor.fromInt(0xFF34495E), // Dark gray
                        ),
                      ),
                      pw.SizedBox(height: 40),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'Sana',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(0xFF34495E),
                                ),
                              ),
                              pw.Text(
                                date,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  color: PdfColor.fromInt(0xFF34495E),
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(
                                'Muallif',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(0xFF34495E),
                                ),
                              ),
                              pw.Text(
                                author,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  color: PdfColor.fromInt(0xFF34495E),
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
    } catch (e) {
      print("Xatolik: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void openLinkInNewTab(String url) {
    html.window.open(url, '_blank');
  }

  // Function to show the download URL in a dialog
  void _showDownloadLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yuklab olish linki'),
          content: Row(
            children: [
              Expanded(child: SelectableText(downloadUrl)),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Link nusxalandi!')));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Yopish'),
            ),
          ],
        );
      },
    );
  }
}
