class Validators {
  static bool isEmail(String email) {
    return email.contains("@") && email.contains(".");
  }
}
