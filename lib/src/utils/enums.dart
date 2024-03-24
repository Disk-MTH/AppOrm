import "dart:core" as core;

enum Crud { create, read, update, delete }

enum Status { available, processing, deleting, stuck, failed }

enum Role { any, guests, user, users, team, member, label }

enum Modifier { required, array, defaultValue, size, min, max, elements }

enum SortOrder { asc, desc }

enum IndexType { key, unique, fulltext }

enum AttributeType {
  native,
  entity,
  string,
  integer,
  double,
  boolean,
  datetime,
  email,
  ip,
  url,
  enumeration;

  core.Type get type {
    switch (this) {
      case AttributeType.integer:
        return core.int;
      case AttributeType.double:
        return core.double;
      case AttributeType.boolean:
        return core.bool;
      case AttributeType.datetime:
        return core.DateTime;
      default:
        return core.String;
    }
  }
}
