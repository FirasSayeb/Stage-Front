class User {
  late String email;
  late String userName;
  late String password;
  late String role;
  late String phone;
  late String address;
  late String filePath; 

  User(); 

  User.par(this.email, this.password, this.role,this.userName);

  factory User.fromJson(Map<String, dynamic> json) { 
    return User.par(json['email'], json['password'], json['role'],json['userName'])
      ..filePath = json['filePath'];
  }
}
