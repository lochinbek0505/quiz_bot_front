import 'dart:async';

import 'package:flutter/material.dart';

import 'ResultPage.dart';
import 'TestService.dart';

class QuizPage extends StatefulWidget {
  final String examId;
  final String examTitle;

  QuizPage({required this.examId, required this.examTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TestService _testService = TestService();
  List<Map<String, dynamic>> tests = [];
  int current = 0;
  int correctAnswers = 0;
  int totalTime = 60;
  Timer? timer;
  int? selectedIndex;

  String userId = "demo_user"; // Aslida Firebase Auth orqali olinadi
  String username = "Test User";

  Future<String?> showNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();

    // Show the dialog and return the entered name
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Iltimos ismingizni kiriting",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Iltimos ismingizni kiriting",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(); // Close the dialog without returning any value
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Close the dialog and return the name entered
                  Navigator.of(context).pop(name);
                } else {
                  // Show an error message if the name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Iltimos ismingizni kiriting.")),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    showNameDialog(context);

    loadTests();
  }

  void startTimer() {
    totalTime = 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (totalTime > 0) {
          totalTime--;
        } else {
          timer.cancel();
          goToResult();
        }
      });
    });
  }

  Future<void> loadTests() async {
    final loadedTests = await _testService.getTests(widget.examId);
    if (mounted) {
      setState(() {
        tests = loadedTests;
      });
      startTimer();
    }
  }

  void nextQuestion() {
    if (selectedIndex == tests[current]['correctAnswerIndex']) {
      correctAnswers++;
      print(correctAnswers);
    }

    if (current < tests.length - 1) {
      setState(() {
        current++;
        selectedIndex = null;
      });
    } else {
      timer?.cancel();
      goToResult();
    }
  }

  void goToResult() async {
    await _testService.submitResult(
      examId: widget.examId,
      userId: userId,
      username: username,
      correctAnswers: correctAnswers,
      totalQuestions: tests.length,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultPage(
              score: ((correctAnswers / tests.length) * 100) ~/ 1,
              examId: widget.examId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examTitle)),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = tests[current];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.examTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Savol raqami
            Text(
              "Savol ${current + 1} / ${tests.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            /// Vaqt progressi
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalTime / 60,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            SizedBox(height: 24),

            /// Savol matni
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 24),

            /// Variantlar
            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Card(
                      color: isSelected ? Colors.blue : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        child: Text(
                          question['options'][index],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// Keyingi tugma
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedIndex != null ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    current == tests.length - 1 ? "Yakunlash" : "Keyingi",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
