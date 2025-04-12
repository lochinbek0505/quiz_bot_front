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

  String userId = "demo_user";
  String username = "Test User";

  Future<String?> showNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Iltimos ismingizni kiriting"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Ismingizni kiriting",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Bekor qilish"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Iltimos ismingizni kiriting."),
                    ),
                  );
                }
              },
              child: const Text("Kiritish"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final name = await showNameDialog(context);
      if (name != null && mounted) {
        setState(() {
          username = name;
        });
        await loadTests();
      }
    });
  }

  void startTimer(int duration) {
    totalTime = duration * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final result = await _testService.getExamWithTests(widget.examId);
    final loadedTests = result['tests'] ?? [];
    final examDuration = result['duration'] ?? 60;

    if (mounted) {
      setState(() {
        tests = List<Map<String, dynamic>>.from(loadedTests);
      });
      startTimer(examDuration);
    }
  }

  void nextQuestion() {
    if (selectedIndex == tests[current]['correctAnswerIndex']) {
      correctAnswers++;
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
              score: ((correctAnswers / tests.length) * 100).floor(),
              examId: widget.examId,
            ),
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = tests[current];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.examTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Savol ${current + 1} / ${tests.length} - "
              "Daraja: ${question['difficulty'].toString().toUpperCase()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: totalTime / 60,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatTime(totalTime),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

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

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedIndex != null ? nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
