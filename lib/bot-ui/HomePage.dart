import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/quiz_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentQuestion = 0;
  int score = 0;
  int totalTime = 60;
  Timer? timer;
  late QuizModel quizModel;

  @override
  void initState() {
    super.initState();
    startTimer();

    String jsonData = '''[
    {"question": "Flutter nima?", "options": ["Framework", "Dasturlash tili", "Ma'lumotlar bazasi", "Operatsion tizim"], "answer": 0},
    {"question": "Dartda asosiy funksiya qaysi?", "options": ["start()", "run()", "main()", "execute()"], "answer": 2},
    {"question": "StatefulWidget nima uchun ishlatiladi?", "options": ["O'zgaruvchan UI yaratish", "Statik UI yaratish", "Backend yozish", "Ma'lumot saqlash"], "answer": 0},
    {"question": "Dartda String qanday e'lon qilinadi?", "options": ["string name", "String name", "var name = string", "define name = String"], "answer": 1},
    {"question": "Flutter-da UI yaratish uchun qaysi til ishlatiladi?", "options": ["Java", "Kotlin", "Swift", "Dart"], "answer": 3},
    {"question": "Flutter-da asosiy UI elementi nima?", "options": ["View", "Widget", "Component", "Element"], "answer": 1},
    {"question": "setState() metodi qachon chaqiriladi?", "options": ["Ma'lumot o'zgarganda UI yangilash uchun", "Barcha widgetlarni yaratishda", "StatelessWidget ichida", "Ma'lumotni serverga jo'natishda"], "answer": 0}
    ]''';
    List<dynamic> jsonList = jsonDecode(jsonData);
    quizModel = QuizModel.fromJson(jsonList);
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (totalTime > 0) {
          totalTime--;
        } else {
          timer.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                  ResultPage(
                    score: score,
                    total: quizModel.dataListList!.length,
                  ),
            ),
          );
        }
      });
    });
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == quizModel.dataListList![currentQuestion].answer) {
      score++;
    }
    setState(() {
      if (currentQuestion < quizModel.dataListList!.length - 1) {
        currentQuestion++;
      } else {
        timer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                ResultPage(
                  score: score,
                  total: quizModel.dataListList!.length,
                ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Savol ${currentQuestion + 1} / ${quizModel.dataListList!
                  .length}",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            Text(
              "Vaqt: $totalTime s",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: totalTime / 60,
          backgroundColor: Colors.white,
          color: Colors.red,
          minHeight: 8,
        ),
        SizedBox(height: 40),
        Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                quizModel.dataListList![currentQuestion].question!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => checkAnswer(index),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        quizModel
                            .dataListList![currentQuestion]
                            .optionsList![index],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
              itemCount:
              quizModel
                  .dataListList![currentQuestion]
                  .optionsList!
                  .length,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {

          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                "Keyingisi",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        )

        ],
      ),
    ),);
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final int total;

  ResultPage({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sizning natijangiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                width: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: score.toDouble(),
                        title: "$score",
                        color: Colors.green,
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: (total - score).toDouble(),
                        title: "${total - score}",
                        color: Colors.red,
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  child: Text("Qayta boshlash", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
