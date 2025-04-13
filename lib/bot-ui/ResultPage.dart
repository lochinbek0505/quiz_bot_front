import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To copy the link
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quiz_bot/bot-ui/RatePage.dart';

import 'CacheService.dart';

class ResultPage extends StatefulWidget {
  final int score;
  final String examId;
  final String name;

  const ResultPage({
    Key? key,
    required this.score,
    required this.examId,
    required this.name,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String getResultText() {
    if (widget.score >= 90)
      return selectedLanguage == "Uzbek"
          ? "🔥 Ajoyib natija!"
          : selectedLanguage == "English"
          ? "🔥 Excellent result!"
          : "🔥 Отличный результат!";
    if (widget.score >= 75)
      return selectedLanguage == "Uzbek"
          ? "✅ Yaxshi ish!"
          : selectedLanguage == "English"
          ? "✅ Good job!"
          : "✅ Хорошая работа!";
    if (widget.score >= 50)
      return selectedLanguage == "Uzbek"
          ? "💪 Harakat qilish kerak"
          : selectedLanguage == "English"
          ? "💪 Need more effort"
          : "💪 Нужно больше усилий";
    return selectedLanguage == "Uzbek"
        ? "😥 Ko‘proq mashq qil"
        : selectedLanguage == "English"
        ? "😥 Practice more"
        : "😥 Практикуйтесь больше";
  }

  String selectedLanguage = "";

  void _showDownloadLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            selectedLanguage == "Uzbek"
                ? "Yuklab olish linki"
                : selectedLanguage == "English"
                ? "Download link"
                : "Ссылка для скачивания",
          ),
          content: Row(
            children: [
              Expanded(child: SelectableText(downloadUrl)),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: downloadUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selectedLanguage == "Uzbek"
                            ? "Link nusxalandi!"
                            : selectedLanguage == "English"
                            ? "Link copied!"
                            : "Ссылка скопирована!",
                      ),
                    ),
                  );
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

  Color getColor() {
    if (widget.score >= 90) return Colors.greenAccent;
    if (widget.score >= 75) return Colors.blueAccent;
    if (widget.score >= 50) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String downloadUrl = '';
  bool isLoading = false;

  Future<void> _generateAndUploadPdf(name, author) async {
    setState(() {
      isLoading = true;
    });

    final pdf = pw.Document();

    // Load the background image
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
                        selectedLanguage == "Uzbek"
                            ? '🎉 SERTIFIKAT 🎉'
                            : selectedLanguage == "English"
                            ? '🎉 CERTIFICATE 🎉'
                            : '🎉 СЕРТИФИКАТ 🎉',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF3498DB), // Blue
                        ),
                      ),

                      pw.SizedBox(height: 15),
                      pw.Text(
                        selectedLanguage == "Uzbek"
                            ? 'Online testda ishtirok etgani uchun '
                            : selectedLanguage == "English"
                            ? 'For participating in the online test '
                            : 'За участие в онлайн-тесте ',
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
                        selectedLanguage == "Uzbek"
                            ? 'Online testda ishtirok etib natijani ko\'rsatgani uchun ushbu sertifikat bilan taqdirlanadi.'
                            : selectedLanguage == "English"
                            ? 'This certificate is awarded for participating in the online test and showing the result.'
                            : 'Этот сертификат вручается за участие в онлайн-тесте и показ результата.',
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
                                selectedLanguage == "Uzbek"
                                    ? 'Sana'
                                    : selectedLanguage == "English"
                                    ? 'Date'
                                    : 'Дата',
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
                                selectedLanguage == "Uzbek"
                                    ? 'Muallif'
                                    : selectedLanguage == "English"
                                    ? 'Author'
                                    : 'Автор',
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
        _showDownloadLinkDialog(context);
      });
    } catch (e) {
      print("Xatolik: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> load() async {
    CacheService pref = CacheService();

    selectedLanguage = (await pref.getData("lan"))!;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = getColor();
    final resultText = getResultText();

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7), // Light background for daytime
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 100, color: textColor),
              const SizedBox(height: 20),
              Text(
                selectedLanguage == "Uzbek"
                    ? "Natijangiz:"
                    : selectedLanguage == "English"
                    ? "Your Result:"
                    : "Ваш результат:",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Colors.black, // Dark color for text
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "${widget.score}%",
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 22, color: textColor),
              ),
              const SizedBox(height: 40),
              widget.score > 80
                  ? ElevatedButton.icon(
                    onPressed: () {
                      _generateAndUploadPdf(
                        widget.name,
                        "G'ulomjon Abdullayev",
                      );
                    },
                    icon: const Icon(Icons.file_download),
                    label: Text(
                      selectedLanguage == "Uzbek"
                          ? "Sertifikatni yuklab olish"
                          : selectedLanguage == "English"
                          ? "Download Certificate"
                          : "Скачать сертификат",
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                  : SizedBox(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => RatingPage(examId: widget.examId),
                    ),
                  );
                },
                icon: const Icon(Icons.star_rate),
                label: Text(
                  selectedLanguage == "Uzbek"
                      ? "Reyting"
                      : selectedLanguage == "English"
                      ? "Ranking"
                      : "Рейтинг",
                  style: GoogleFonts.poppins(fontSize: 18),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
