class MesssageModel {
  final String message;
  final String id;
  MesssageModel({required this.message, required this.id});

  factory MesssageModel.fromJson(json) {
    return MesssageModel(message: json["message"], id: json["id"]);
  }
}
