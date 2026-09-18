class RegistrationData {
  final String aadhaar;
  final String name;
  final String dob;
  final String mobile;
  final String password;
  final String? email;

  const RegistrationData({
    required this.aadhaar,
    required this.name,
    required this.dob,
    required this.mobile,
    required this.password,
    this.email,
  });
}
