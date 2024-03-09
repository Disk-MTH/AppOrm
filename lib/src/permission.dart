import "package:app_orm/src/serializable.dart";

import "enums.dart";

class Permission implements Serializable<Permission> {
  late Crud crud;
  late Role role;
  late String? id;
  late String? resource;

  Permission(this.crud, this.role, {this.id, this.resource});

  Permission.empty();

  Permission.fromString(String permission) {
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
    final String? statusString = match.group(4);

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

    resource = statusString;
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "role": role.name,
      "crud": crud.name,
      if (id != null) "id": id,
      if (resource != null) "resource": resource,
    };
  }

  @override
  Permission deserialize(Map<String, dynamic> data) {
    role = Role.values.firstWhere((e) => e.name == data["role"]);
    crud = Crud.values.firstWhere((e) => e.name == data["crud"]);
    id = data["id"];
    resource = data["resource"];
    return this;
  }

  String get string {
    return "${crud.name}(\"${role.name}${id != null ? ":$id" : ""}${resource != null ? "/$resource" : ""}\")";
  }

  Verification? get status {
    if (resource == null) return null;
    return Verification.values
        .where((e) => e.toString() == resource)
        .firstOrNull;
  }
}
