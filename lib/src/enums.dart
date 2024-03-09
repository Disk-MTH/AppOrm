import "dart:core" as core;

enum Crud { create, read, update, delete }

enum Status { available, processing, deleting, stuck, failed }

enum Role { any, guests, user, users, team, member, label }

// enum Format { email, ip, url, enumeration }

enum Modifier {
  required,
  array,
  // nullable,
  defaultValue,
  size,
  min,
  max,
  elements
}

enum Verification { verified, unverified }

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

/*  core.Type get type {
    switch (this) {
      case AttributeType.string:
        return core.String;
      case AttributeType.integer:
        return core.int;
      case AttributeType.double:
        return core.double;
      case AttributeType.boolean:
        return core.bool;
      case AttributeType.datetime:
        return core.DateTime;
      case AttributeType.email:
        return core.String;
      case AttributeType.ip:
        return core.String;
      case AttributeType.url:
        return core.String;
      case AttributeType.enumeration:
        return core.String;
      case AttributeType.entity:
        return Entity;
      case AttributeType.native:
        return core.Object;
    }
  }*/
}
