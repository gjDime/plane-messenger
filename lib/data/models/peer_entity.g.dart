// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPeerEntityCollection on Isar {
  IsarCollection<PeerEntity> get peerEntitys => this.collection();
}

const PeerEntitySchema = CollectionSchema(
  name: r'PeerEntity',
  id: 1313106226027583312,
  properties: {
    r'deviceId': PropertySchema(
      id: 0,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'isConnected': PropertySchema(
      id: 1,
      name: r'isConnected',
      type: IsarType.bool,
    ),
    r'lastReadTimestamp': PropertySchema(
      id: 2,
      name: r'lastReadTimestamp',
      type: IsarType.long,
    ),
    r'lastSeen': PropertySchema(
      id: 3,
      name: r'lastSeen',
      type: IsarType.long,
    ),
    r'nickname': PropertySchema(
      id: 4,
      name: r'nickname',
      type: IsarType.string,
    ),
    r'publicKey': PropertySchema(
      id: 5,
      name: r'publicKey',
      type: IsarType.string,
    ),
    r'x25519PublicKey': PropertySchema(
      id: 6,
      name: r'x25519PublicKey',
      type: IsarType.string,
    )
  },
  estimateSize: _peerEntityEstimateSize,
  serialize: _peerEntitySerialize,
  deserialize: _peerEntityDeserialize,
  deserializeProp: _peerEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'deviceId': IndexSchema(
      id: 4442814072367132509,
      name: r'deviceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'deviceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _peerEntityGetId,
  getLinks: _peerEntityGetLinks,
  attach: _peerEntityAttach,
  version: '3.1.0+1',
);

int _peerEntityEstimateSize(
  PeerEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.nickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.publicKey.length * 3;
  bytesCount += 3 + object.x25519PublicKey.length * 3;
  return bytesCount;
}

void _peerEntitySerialize(
  PeerEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deviceId);
  writer.writeBool(offsets[1], object.isConnected);
  writer.writeLong(offsets[2], object.lastReadTimestamp);
  writer.writeLong(offsets[3], object.lastSeen);
  writer.writeString(offsets[4], object.nickname);
  writer.writeString(offsets[5], object.publicKey);
  writer.writeString(offsets[6], object.x25519PublicKey);
}

PeerEntity _peerEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PeerEntity();
  object.deviceId = reader.readString(offsets[0]);
  object.id = id;
  object.isConnected = reader.readBool(offsets[1]);
  object.lastReadTimestamp = reader.readLong(offsets[2]);
  object.lastSeen = reader.readLong(offsets[3]);
  object.nickname = reader.readStringOrNull(offsets[4]);
  object.publicKey = reader.readString(offsets[5]);
  object.x25519PublicKey = reader.readString(offsets[6]);
  return object;
}

P _peerEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _peerEntityGetId(PeerEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _peerEntityGetLinks(PeerEntity object) {
  return [];
}

void _peerEntityAttach(IsarCollection<dynamic> col, Id id, PeerEntity object) {
  object.id = id;
}

extension PeerEntityByIndex on IsarCollection<PeerEntity> {
  Future<PeerEntity?> getByDeviceId(String deviceId) {
    return getByIndex(r'deviceId', [deviceId]);
  }

  PeerEntity? getByDeviceIdSync(String deviceId) {
    return getByIndexSync(r'deviceId', [deviceId]);
  }

  Future<bool> deleteByDeviceId(String deviceId) {
    return deleteByIndex(r'deviceId', [deviceId]);
  }

  bool deleteByDeviceIdSync(String deviceId) {
    return deleteByIndexSync(r'deviceId', [deviceId]);
  }

  Future<List<PeerEntity?>> getAllByDeviceId(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'deviceId', values);
  }

  List<PeerEntity?> getAllByDeviceIdSync(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'deviceId', values);
  }

  Future<int> deleteAllByDeviceId(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'deviceId', values);
  }

  int deleteAllByDeviceIdSync(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'deviceId', values);
  }

  Future<Id> putByDeviceId(PeerEntity object) {
    return putByIndex(r'deviceId', object);
  }

  Id putByDeviceIdSync(PeerEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'deviceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDeviceId(List<PeerEntity> objects) {
    return putAllByIndex(r'deviceId', objects);
  }

  List<Id> putAllByDeviceIdSync(List<PeerEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'deviceId', objects, saveLinks: saveLinks);
  }
}

extension PeerEntityQueryWhereSort
    on QueryBuilder<PeerEntity, PeerEntity, QWhere> {
  QueryBuilder<PeerEntity, PeerEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PeerEntityQueryWhere
    on QueryBuilder<PeerEntity, PeerEntity, QWhereClause> {
  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> deviceIdEqualTo(
      String deviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deviceId',
        value: [deviceId],
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterWhereClause> deviceIdNotEqualTo(
      String deviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [],
              upper: [deviceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [deviceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [deviceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deviceId',
              lower: [],
              upper: [deviceId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PeerEntityQueryFilter
    on QueryBuilder<PeerEntity, PeerEntity, QFilterCondition> {
  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      isConnectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isConnected',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      lastReadTimestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
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

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> lastSeenEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      lastSeenGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> lastSeenLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> lastSeenBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      nicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      nicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nickname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      nicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> nicknameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nickname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      nicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      nicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      publicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      publicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'publicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition> publicKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'publicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      publicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      publicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'publicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'x25519PublicKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'x25519PublicKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'x25519PublicKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'x25519PublicKey',
        value: '',
      ));
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterFilterCondition>
      x25519PublicKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'x25519PublicKey',
        value: '',
      ));
    });
  }
}

extension PeerEntityQueryObject
    on QueryBuilder<PeerEntity, PeerEntity, QFilterCondition> {}

extension PeerEntityQueryLinks
    on QueryBuilder<PeerEntity, PeerEntity, QFilterCondition> {}

extension PeerEntityQuerySortBy
    on QueryBuilder<PeerEntity, PeerEntity, QSortBy> {
  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByIsConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy>
      sortByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKey', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKey', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> sortByX25519PublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x25519PublicKey', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy>
      sortByX25519PublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x25519PublicKey', Sort.desc);
    });
  }
}

extension PeerEntityQuerySortThenBy
    on QueryBuilder<PeerEntity, PeerEntity, QSortThenBy> {
  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByIsConnectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isConnected', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy>
      thenByLastReadTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadTimestamp', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByLastSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeen', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByPublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKey', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByPublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publicKey', Sort.desc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy> thenByX25519PublicKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x25519PublicKey', Sort.asc);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QAfterSortBy>
      thenByX25519PublicKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'x25519PublicKey', Sort.desc);
    });
  }
}

extension PeerEntityQueryWhereDistinct
    on QueryBuilder<PeerEntity, PeerEntity, QDistinct> {
  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByIsConnected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isConnected');
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct>
      distinctByLastReadTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadTimestamp');
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByLastSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeen');
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByNickname(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickname', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByPublicKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publicKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeerEntity, PeerEntity, QDistinct> distinctByX25519PublicKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'x25519PublicKey',
          caseSensitive: caseSensitive);
    });
  }
}

extension PeerEntityQueryProperty
    on QueryBuilder<PeerEntity, PeerEntity, QQueryProperty> {
  QueryBuilder<PeerEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PeerEntity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<PeerEntity, bool, QQueryOperations> isConnectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isConnected');
    });
  }

  QueryBuilder<PeerEntity, int, QQueryOperations> lastReadTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadTimestamp');
    });
  }

  QueryBuilder<PeerEntity, int, QQueryOperations> lastSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeen');
    });
  }

  QueryBuilder<PeerEntity, String?, QQueryOperations> nicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickname');
    });
  }

  QueryBuilder<PeerEntity, String, QQueryOperations> publicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publicKey');
    });
  }

  QueryBuilder<PeerEntity, String, QQueryOperations> x25519PublicKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'x25519PublicKey');
    });
  }
}
