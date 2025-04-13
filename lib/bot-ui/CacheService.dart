import 'dart:html';

class CacheService {
  // SharedPreferences instansiyasi
  // Keshga ma'lumotni saqlash
  Future<void> saveData(String key, String value) async {
    window.localStorage[key] = value;
  }

  // Keshdan ma'lumotni olish
  String? getData(String key) {
    return window.localStorage[key]!;
  }

  // Keshdagi ma'lumotni o'chirish
  Future<void> removeData(String key) async {
    window.localStorage["key"] = "";
  }
}
