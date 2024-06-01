class Actualite {
  final int id;
  final String body;
  final String userName;
  final String createdAt;
  final String? avatar;
  final String? filePath; 
  Actualite({
    required this.id,
    required this.body,
    required this.userName,
    required this.createdAt,
    this.avatar,
    this.filePath,
  });

  factory Actualite.fromJson(Map<String, dynamic> json) {
    return Actualite(
      id: json['id'],
      body: json['body'],
      userName: json['userName'],
      avatar: json['avatar'],
      createdAt: json['created_at'],
      filePath: json['file_path'], 
    );
  }
}
