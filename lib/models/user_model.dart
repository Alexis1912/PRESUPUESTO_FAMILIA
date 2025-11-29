class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final String rol;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "nombre": nombre,
      "email": email,
      "rol": rol,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"],
      nombre: map["nombre"],
      email: map["email"],
      rol: map["rol"],
    );
  }
}
