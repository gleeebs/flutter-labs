class ApiAdvice {
  final String id;
  final String advice;

  ApiAdvice({required this.id, required this.advice});

  factory ApiAdvice.fromJson(Map<String, dynamic> json) {
    return ApiAdvice(
      id: json['id'].toString(),
      advice: json['advice'] as String,
    );
  }
}
