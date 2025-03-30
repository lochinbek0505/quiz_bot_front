class DataList {
  String? question;
  List<String>? optionsList;
  num? answer;

  DataList({this.question, this.optionsList, this.answer});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["question"] = question;
    map["options"] = optionsList;
    map["answer"] = answer;
    return map;
  }

  DataList.fromJson(dynamic json){
    question = json["question"];
    optionsList = json["options"] != null ? json["options"].cast<String>() : [];
    answer = json["answer"];
  }
}

class QuizModel {
  List<DataList>? dataListList;

  QuizModel({this.dataListList});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (dataListList != null) {
      map["dataList"] = dataListList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  QuizModel.fromJson(dynamic json){
    if (json != null) {
      dataListList = [];
      json.forEach((v) {
        dataListList?.add(DataList.fromJson(v));
      });
    }
  }
}