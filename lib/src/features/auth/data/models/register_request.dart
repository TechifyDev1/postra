class RegisterRequest {
  final String username;
  final String password;
  final String fullName;
  final String email;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'fullName': fullName,
    'email': email,
  };
}
