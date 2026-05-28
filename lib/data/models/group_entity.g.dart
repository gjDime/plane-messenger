// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGroupEntityCollection on Isar {
  IsarCollection<GroupEntity> get groupEntitys => this.collection();
}

const GroupEntitySchema = CollectionSchema(
  name: r'GroupEntity',
  id: -2259619910335975057,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.long,
    ),
    r'creatorPublicKey': PropertySchema(
      id: 1,
      name: r'creatorPublicKey',
      type: IsarType.string,
    ),
    r'groupId': PropertySchema(
      id: 2,
      name: r'groupId',
      type: IsarType.string,
    ),
    r'isCreator': PropertySchema(
      id: 3,
      name: r'isCreator',
      type: IsarType.bool,
    ),
    r'isMember': PropertySchema(
      id: 4,
      name: r'isMember',
      type: IsarType.bool,
    ),
    r'joinedAt': PropertySchema(
      id: 5,
      name: r'joinedAt',
      type: IsarType.long,
    ),
    r'lastReadTimestamp': PropertySchema(
      id: 6,
      name: r'lastReadTimestamp',
      type: IsarType.long,
    ),
    r'memberPublicKeys': PropertySchema(
      id: 7,
      name: r'memberPublicKeys',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 8,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _groupEntityEstimateSize,
  serialize: _groupEntitySerialize,
  deserialize: _groupEntityDeserialize,
  deserializeProp: _groupEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'groupId': IndexSchema(
      id: -8523216633229774932,
      name: r'groupId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'groupId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _groupEntityGetId,
  getLinks: _groupEntityGetLinks,
  attach: _groupEntityAttach,
  version: '3.1.0+1',
);

int _groupEntityEstimateSize(
  GroupEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.creatorPublicKey.length * 3;
  bytesCount += 3 + object.groupId.length * 3;
  bytesCount += 3 + object.memberPublicKeys.length * 3;
  {
    for (var i = 0; i < object.memberPublicKeys.length; i++) {
      final value = object.memberPublicKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _groupEntitySerialize(
  GroupEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.creatorPublicKey);
  writer.writeString(offsets[2], object.groupId);
  writer.writeBool(offsets[3], object.isCreator);
  writer.writeBool(offsets[4], object.isMember);
  writer.writeLong(offsets[5], object.joinedAt);
  writer.writeLong(offsets[6], object.lastReadTimestamp);
  writer.writeStringList(offsets[7], object.memberPublicKeys);
  writer.writeString(offsets[8], object.name);
}

GroupEntity _groupEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GroupEntity();
  object.createdAt = reader.readLong(offsets[0]);
  object.creatorPublicKey = reader.readString(offsets[1]);
  object.groupId = reader.readString(offsets[2]);
  object.id = id;
  object.isCreator = reader.readBool(offsets[3]);
  object.isMember = reader.readBool(offsets[4]);
  object.joinedAt = reader.readLong(offsets[5]);
  object.lastReadTimestamp = reader.readLong(offsets[6]);
  object.memberPublicKeys = reader.readStringList(offsets[7]) ?? [];
  object.name = reader.readString(offsets[8]);
  return object;
}

P _groupEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _groupEntityGetId(GroupEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _groupEntityGetLinks(GroupEntity object) {
  return [];
}

void _groupEntityAttach(
    IsarCollection<dynamic> col, Id id, GroupEntity object) {
  object.id = id;
}

extension GroupEntityByIndex on IsarCollection<GroupEntity> {
  Future<GroupEntity?> getByGroupId(String groupId) {
    return getByIndex(r'groupId', [groupId]);
  }

  GroupEntity? getByGroupIdSync(String groupId) {
    return getByIndexSync(r'groupId', [groupId]);
  }

  Future<bool> deleteByGroupId(String groupId) {
    return deleteByIndex(r'groupId', [groupId]);
  }

  bool deleteByGroupIdSync(String groupId) {
    return deleteByIndexSync(r'groupId', [groupId]);
  }

  Future<List<GroupEntity?>> getAllByGroupId(List<String> groupIdValues) {
    final values = groupIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'groupId', values);
  }

  List<GroupEntity?> getAllByGroupIdSync(List<String> groupIdValues) {
    final values = groupIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'groupId', values);
  }

  Future<int> deleteAllByGroupId(List<String> groupIdValues) {
    final values = groupIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'groupId', values);
  }

  int deleteAllByGroupIdSync(List<String> groupIdValues) {
    final values = groupIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'groupId', values);
  }

  Future<Id> putByGroupId(GroupEntity object) {
    return putByIndex(r'groupId', object);
  }

  Id putByGroupIdSync(GroupEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'groupId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGroupId(List<GroupEntity> objects) {
    return putAllByIndex(r'groupId', objects);
  }

  List<Id> putAllByGroupIdSync(List<GroupEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'groupId', objects, saveLinks: saveLinks);
  }
}

extension GroupEntityQueryWhereSort
    on QueryBuilder<GroupEntity, GroupEntity, QWhere> {
  QueryBuilder<GroupEntity, GroupEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GroupEntityQueryWhere
    on QueryBuilder<GroupEntity, GroupEntity, QWhereClause> {
  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> groupIdEqualTo(
      String groupId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupId',
        value: [groupId],
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterWhereClause> groupIdNotEqualTo(
      String groupId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [groupId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupId',
              lower: [],
              upper: [groupId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GroupEntityQueryFilter
    on QueryBuilder<GroupEntity, GroupEntity, QFilterCondition> {
  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      createdAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      createdAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      createdAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorPublicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorPublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorPublicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      creatorPublicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorPublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      groupIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      groupIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> groupIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupId',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupId',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      isCreatorEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCreator',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> isMemberEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMember',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> joinedAtEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      joinedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      joinedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'joinedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> joinedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'joinedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      lastReadTimestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      lastReadTimestampGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      lastReadTimestampLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      lastReadTimestampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberPublicKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memberPublicKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memberPublicKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberPublicKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memberPublicKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      memberPublicKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberPublicKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension GroupEntityQueryObject
    on QueryBuilder<GroupEntity, GroupEntity, QFilterCondition> {}

extension GroupEntityQueryLinks
    on QueryBuilder<GroupEntity, GroupEntity, QFilterCondition> {}

extension GroupEntityQuerySortBy
    on QueryBuilder<GroupEntity, GroupEntity, QSortBy> {
  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      sortByCreatorPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorPublicKey', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      sortByCreatorPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorPublicKey', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByIsCreator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreator', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByIsCreatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreator', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByIsMember() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMember', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByIsMemberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMember', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByJoinedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      sortByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      sortByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension GroupEntityQuerySortThenBy
    on QueryBuilder<GroupEntity, GroupEntity, QSortThenBy> {
  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      thenByCreatorPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorPublicKey', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      thenByCreatorPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorPublicKey', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByIsCreator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreator', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByIsCreatorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCreator', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByIsMember() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMember', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByIsMemberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMember', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByJoinedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'joinedAt', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      thenByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy>
      thenByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension GroupEntityQueryWhereDistinct
    on QueryBuilder<GroupEntity, GroupEntity, QDistinct> {
  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByCreatorPublicKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorPublicKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByGroupId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByIsCreator() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCreator');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByIsMember() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMember');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByJoinedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'joinedAt');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct>
      distinctByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTimestamp');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct>
      distinctByMemberPublicKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberPublicKeys');
    });
  }

  QueryBuilder<GroupEntity, GroupEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension GroupEntityQueryProperty
    on QueryBuilder<GroupEntity, GroupEntity, QQueryProperty> {
  QueryBuilder<GroupEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GroupEntity, int, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GroupEntity, String, QQueryOperations>
      creatorPublicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorPublicKey');
    });
  }

  QueryBuilder<GroupEntity, String, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<GroupEntity, bool, QQueryOperations> isCreatorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCreator');
    });
  }

  QueryBuilder<GroupEntity, bool, QQueryOperations> isMemberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMember');
    });
  }

  QueryBuilder<GroupEntity, int, QQueryOperations> joinedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'joinedAt');
    });
  }

  QueryBuilder<GroupEntity, int, QQueryOperations> lastReadTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTimestamp');
    });
  }

  QueryBuilder<GroupEntity, List<String>, QQueryOperations>
      memberPublicKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberPublicKeys');
    });
  }

  QueryBuilder<GroupEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
