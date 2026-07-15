class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String subjectName;
  final int order;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectName,
    this.order = 0,
  });

  factory ModuleModel.fromMap(String id, Map<String, dynamic> data) {
    return ModuleModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subjectName: data['subjectName'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subjectName': subjectName,
      'order': order,
    };
  }
}
