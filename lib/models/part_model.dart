class PartModel {
  final String id;
  final String moduleId;
  final String title;
  final String content;
  final int order;

  PartModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.content,
    this.order = 0,
  });

  factory PartModel.fromMap(String id, Map<String, dynamic> data) {
    return PartModel(
      id: id,
      moduleId: data['moduleId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'title': title,
      'content': content,
      'order': order,
    };
  }
}
