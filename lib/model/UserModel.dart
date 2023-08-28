class User {
  int? id;
  String email;
  String name;

  User({this.id, required this.email, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'name': name};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], email: map['email'], name: map['name']);
  }
}