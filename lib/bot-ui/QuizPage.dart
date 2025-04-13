import 'dart:async';

import 'package:flutter/material.dart';

import 'CacheService.dart';
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
  final TextEditingController writtenAnswerController = TextEditingController();

  String userId = "demo_user";
  String username = "Test User";
  String group = "";

  Future<void> load() async {
    CacheService pref = new CacheService();

    username = (await pref.getData("name"))!;
    group = (await pref.getData("group"))!;

    userId = username.toLowerCase();
    await loadTests();
  }

  @override
  void initState() {
    super.initState();

    load();
  }

  void startTimer(int duration) {
    totalTime = duration * 60;
    print(totalTime);
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
    print("TEST TEST TEST ${result["duration"]}");
    final examDuration = result['duration'] ?? 60;

    if (mounted) {
      setState(() {
        tests = List<Map<String, dynamic>>.from(loadedTests);
      });
      startTimer(examDuration);
    }
  }

  void nextQuestion() {
    bool isWritten = tests[current]['isWritten'] == true;

    if (isWritten) {
      // Agar yozma savol bo‘lsa
      final correctWritten =
          tests[current]['writtenAnswer'].toString().trim().toLowerCase();
      final userWritten = writtenAnswerController.text.trim().toLowerCase();

      if (correctWritten == userWritten && correctAnswers < tests.length) {
        correctAnswers++;
      }
    } else {
      // Tanlanadigan savol bo‘lsa
      if (selectedIndex == tests[current]['correctAnswerIndex'] &&
          correctAnswers < tests.length) {
        correctAnswers++;
      }
    }

    if (current < tests.length - 1) {
      setState(() {
        current++;
        selectedIndex = null;
        writtenAnswerController.clear();
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
      group: group,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => ResultPage(
              score: ((correctAnswers / tests.length) * 100).floor(),
              examId: widget.examId,
              name: username,
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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.examTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
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
              "Daraja: ${question['level'].toString().toUpperCase()}",
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

            question['isWritten'].toString() == "false"
                ? Expanded(
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
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextField(
                    controller: writtenAnswerController,
                    maxLines: 3,

                    decoration: InputDecoration(
                      labelText: "Javobingizni yozing",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      question['isWritten'].toString() == "true" ||
                              selectedIndex != null
                          ? nextQuestion
                          : null,
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
