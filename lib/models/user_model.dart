class UserModel {
  final String uid;
  final String nombre;
  final String rol;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "nombre": nombre,
      "rol": rol,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data["uid"],
      nombre: data["nombre"],
      rol: data["rol"],
    );
  }
}
