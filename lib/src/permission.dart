import "package:app_orm/src/serializable.dart";

class Permission implements Serializable<Permission> {
  late Crud crud;
  late Role role;
  late List<String> resources;

  Permission(this.crud, this.role, {this.resources = const []});

  Permission.fromString(String permission) {
    if (permission.contains("users/")) {
      permission = permission.replaceAll("users", "users:dummy");
    }

    final RegExp pattern = RegExp(r'(\w+)\("(\w+)(?:[:]?(\w+)(?:/(\w+))?)?"\)');

    final Match? match = pattern.firstMatch(permission);

    if (match == null) {
      throw FormatException('Invalid permission string: $permission');
    }

    final String crudString = match.group(1)!;
    String roleString = match.group(2)!;
    final String? resourceString = match.group(3);
    final String? statusString = match.group(4);

    crud = Crud.values.firstWhere(
      (e) => e.toString().split('.')[1] == crudString,
    );

    if (roleString == 'users' && statusString != null) {
      roleString += (statusString == 'verified' ? 'Verified' : 'Unverified');
    }

    role = Role.values.firstWhere(
      (e) => e.toString().split('.')[1] == roleString,
    );

    resources = resourceString != null ? resourceString.split(',') : [];
    resources.remove("dummy");
  }

  @override
  Map<String, dynamic> serialize() {
    return {
      "role": role.name,
      "crud": crud.name,
      "resources": resources,
    };
  }

  @override
  Permission deserialize(Map<String, dynamic> data) {
    role = Role.values.firstWhere((e) => e.toString() == data["role"]);
    crud = Crud.values.firstWhere((e) => e.toString() == data["crud"]);
    resources = data["resources"];
    return this;
  }

  @override
  String toString() {
    //TODO: later
    return super.toString();
  }
}

enum Crud {
  all,
  create,
  read,
  update,
  delete,
}

enum Role {
  any,
  guests,
  user,
  userVerified,
  userUnverified,
  users,
  usersVerified,
  usersUnverified,
  team,
  member,
  label,
}
