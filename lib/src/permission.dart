import "package:app_orm/src/utils/serializable.dart";

import "utils/enums.dart";

class Permission with Serializable {
  static const String verified = "verified";
  static const String unverified = "unverified";

  late Crud crud;
  late Role role;
  late String? id;
  late String? resource;

  Permission(this.crud, this.role, {this.id, this.resource}) {
    _checkValidity();
  }

  Permission.fromModel(String permission) {
    if (permission.contains("users/")) {
      permission = permission.replaceAll("users", "users:dummy");
    }

    final RegExp pattern = RegExp(r'(\w+)\("(\w+)(?:[:]?(\w+)(?:/(\w+))?)?"\)');
    final Match? match = pattern.firstMatch(permission);

    if (match == null) {
      throw FormatException("Invalid permission string: $permission");
    }

    final String crudString = match.group(1)!;
    final String roleString = match.group(2)!;
    final String? idString = match.group(3)?.replaceAll("dummy", "");
    final String? resourceString = match.group(4);

    crud = Crud.values.firstWhere(
      (e) => e.toString().split(".")[1] == crudString,
    );

    role = Role.values.firstWhere(
      (e) => e.toString().split(".")[1] == roleString,
    );

    id = idString != null
        ? idString.isEmpty
            ? null
            : idString
        : null;

    resource = resourceString;

    _checkValidity();
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "role": role.name,
      "crud": crud.name,
      if (id != null) "id": id,
      if (resource != null) "resource": resource.toString(),
    };
  }

  @override
  Permission deserialize(Map<String, dynamic> data) {
    role = Role.values.firstWhere((e) => e.name == data["role"]);
    crud = Crud.values.firstWhere((e) => e.name == data["crud"]);
    id = data["id"];
    resource = data["resource"];
    _checkValidity();
    return this;
  }

  String get string {
    return "${crud.name}(\"${role.name}${id != null ? ":$id" : ""}${resource != null ? "/$resource" : ""}\")";
  }

  void _checkValidity() {
    if (role == Role.any && (id != null || resource != null)) {
      throw "\"$role\" role can't have an id or resource";
    }

    if (role == Role.user &&
        (id == null ||
            (resource != null &&
                (resource != verified && resource != unverified)))) {
      throw "\"$role\" role must have an id and his resource must be a Verification (or null)";
    }

    if (role == Role.users &&
        (id != null ||
            (resource != null &&
                (resource != verified && resource != unverified)))) {
      throw "\"$role\" role can't have an id and his resource must be a Verification (or null)";
    }

    if (role == Role.guests && (id != null || resource != null)) {
      throw "\"$role\" role can't have an id or resource";
    }

    if (role == Role.team && id == null) {
      throw "\"$role\" role must have an id";
    }

    if (role == Role.member && (id == null || resource != null)) {
      throw "\"$role\" role must have an id and can't have a resource";
    }

    if (role == Role.label && (id == null || resource != null)) {
      throw "\"$role\" role must have an id and can't have a resource";
    }
  }
}
