// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGameSessionEntityCollection on Isar {
  IsarCollection<GameSessionEntity> get gameSessionEntitys => this.collection();
}

const GameSessionEntitySchema = CollectionSchema(
  name: r'GameSessionEntity',
  id: -7553089661117924583,
  properties: {
    r'board': PropertySchema(
      id: 0,
      name: r'board',
      type: IsarType.longList,
    ),
    r'colorGameData': PropertySchema(
      id: 1,
      name: r'colorGameData',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.long,
    ),
    r'currentTurnKey': PropertySchema(
      id: 3,
      name: r'currentTurnKey',
      type: IsarType.string,
    ),
    r'gameId': PropertySchema(
      id: 4,
      name: r'gameId',
      type: IsarType.string,
    ),
    r'gameType': PropertySchema(
      id: 5,
      name: r'gameType',
      type: IsarType.string,
    ),
    r'lastMoveAt': PropertySchema(
      id: 6,
      name: r'lastMoveAt',
      type: IsarType.long,
    ),
    r'moveCount': PropertySchema(
      id: 7,
      name: r'moveCount',
      type: IsarType.long,
    ),
    r'playerOKey': PropertySchema(
      id: 8,
      name: r'playerOKey',
      type: IsarType.string,
    ),
    r'playerONickname': PropertySchema(
      id: 9,
      name: r'playerONickname',
      type: IsarType.string,
    ),
    r'playerXKey': PropertySchema(
      id: 10,
      name: r'playerXKey',
      type: IsarType.string,
    ),
    r'playerXNickname': PropertySchema(
      id: 11,
      name: r'playerXNickname',
      type: IsarType.string,
    ),
    r'result': PropertySchema(
      id: 12,
      name: r'result',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 13,
      name: r'status',
      type: IsarType.long,
    ),
    r'winnerKey': PropertySchema(
      id: 14,
      name: r'winnerKey',
      type: IsarType.string,
    )
  },
  estimateSize: _gameSessionEntityEstimateSize,
  serialize: _gameSessionEntitySerialize,
  deserialize: _gameSessionEntityDeserialize,
  deserializeProp: _gameSessionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'gameId': IndexSchema(
      id: -1012023815008531514,
      name: r'gameId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'gameId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _gameSessionEntityGetId,
  getLinks: _gameSessionEntityGetLinks,
  attach: _gameSessionEntityAttach,
  version: '3.1.0+1',
);

int _gameSessionEntityEstimateSize(
  GameSessionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.board.length * 8;
  bytesCount += 3 + object.colorGameData.length * 3;
  bytesCount += 3 + object.currentTurnKey.length * 3;
  bytesCount += 3 + object.gameId.length * 3;
  bytesCount += 3 + object.gameType.length * 3;
  bytesCount += 3 + object.playerOKey.length * 3;
  {
    final value = object.playerONickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.playerXKey.length * 3;
  {
    final value = object.playerXNickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.result.length * 3;
  {
    final value = object.winnerKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _gameSessionEntitySerialize(
  GameSessionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.board);
  writer.writeString(offsets[1], object.colorGameData);
  writer.writeLong(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.currentTurnKey);
  writer.writeString(offsets[4], object.gameId);
  writer.writeString(offsets[5], object.gameType);
  writer.writeLong(offsets[6], object.lastMoveAt);
  writer.writeLong(offsets[7], object.moveCount);
  writer.writeString(offsets[8], object.playerOKey);
  writer.writeString(offsets[9], object.playerONickname);
  writer.writeString(offsets[10], object.playerXKey);
  writer.writeString(offsets[11], object.playerXNickname);
  writer.writeString(offsets[12], object.result);
  writer.writeLong(offsets[13], object.status);
  writer.writeString(offsets[14], object.winnerKey);
}

GameSessionEntity _gameSessionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GameSessionEntity();
  object.board = reader.readLongList(offsets[0]) ?? [];
  object.colorGameData = reader.readString(offsets[1]);
  object.createdAt = reader.readLong(offsets[2]);
  object.currentTurnKey = reader.readString(offsets[3]);
  object.gameId = reader.readString(offsets[4]);
  object.gameType = reader.readString(offsets[5]);
  object.id = id;
  object.lastMoveAt = reader.readLong(offsets[6]);
  object.moveCount = reader.readLong(offsets[7]);
  object.playerOKey = reader.readString(offsets[8]);
  object.playerONickname = reader.readStringOrNull(offsets[9]);
  object.playerXKey = reader.readString(offsets[10]);
  object.playerXNickname = reader.readStringOrNull(offsets[11]);
  object.result = reader.readString(offsets[12]);
  object.status = reader.readLong(offsets[13]);
  object.winnerKey = reader.readStringOrNull(offsets[14]);
  return object;
}

P _gameSessionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gameSessionEntityGetId(GameSessionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gameSessionEntityGetLinks(
    GameSessionEntity object) {
  return [];
}

void _gameSessionEntityAttach(
    IsarCollection<dynamic> col, Id id, GameSessionEntity object) {
  object.id = id;
}

extension GameSessionEntityByIndex on IsarCollection<GameSessionEntity> {
  Future<GameSessionEntity?> getByGameId(String gameId) {
    return getByIndex(r'gameId', [gameId]);
  }

  GameSessionEntity? getByGameIdSync(String gameId) {
    return getByIndexSync(r'gameId', [gameId]);
  }

  Future<bool> deleteByGameId(String gameId) {
    return deleteByIndex(r'gameId', [gameId]);
  }

  bool deleteByGameIdSync(String gameId) {
    return deleteByIndexSync(r'gameId', [gameId]);
  }

  Future<List<GameSessionEntity?>> getAllByGameId(List<String> gameIdValues) {
    final values = gameIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'gameId', values);
  }

  List<GameSessionEntity?> getAllByGameIdSync(List<String> gameIdValues) {
    final values = gameIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'gameId', values);
  }

  Future<int> deleteAllByGameId(List<String> gameIdValues) {
    final values = gameIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'gameId', values);
  }

  int deleteAllByGameIdSync(List<String> gameIdValues) {
    final values = gameIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'gameId', values);
  }

  Future<Id> putByGameId(GameSessionEntity object) {
    return putByIndex(r'gameId', object);
  }

  Id putByGameIdSync(GameSessionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'gameId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGameId(List<GameSessionEntity> objects) {
    return putAllByIndex(r'gameId', objects);
  }

  List<Id> putAllByGameIdSync(List<GameSessionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'gameId', objects, saveLinks: saveLinks);
  }
}

extension GameSessionEntityQueryWhereSort
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QWhere> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GameSessionEntityQueryWhere
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QWhereClause> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      gameIdEqualTo(String gameId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gameId',
        value: [gameId],
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterWhereClause>
      gameIdNotEqualTo(String gameId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gameId',
              lower: [],
              upper: [gameId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gameId',
              lower: [gameId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gameId',
              lower: [gameId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gameId',
              lower: [],
              upper: [gameId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GameSessionEntityQueryFilter
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QFilterCondition> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'board',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'board',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'board',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'board',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      boardLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'board',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorGameData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorGameData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorGameData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorGameData',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      colorGameDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorGameData',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      createdAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentTurnKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentTurnKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentTurnKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentTurnKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      currentTurnKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentTurnKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gameId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gameId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gameId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gameId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gameType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gameType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gameType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gameType',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      gameTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gameType',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      lastMoveAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMoveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      lastMoveAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMoveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      lastMoveAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMoveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      lastMoveAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMoveAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      moveCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveCount',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      moveCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moveCount',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      moveCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moveCount',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      moveCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moveCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerOKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerOKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerOKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerOKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerOKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerOKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playerONickname',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playerONickname',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerONickname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerONickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerONickname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerONickname',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerONicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerONickname',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerXKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerXKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerXKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerXKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerXKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playerXNickname',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playerXNickname',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerXNickname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerXNickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerXNickname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerXNickname',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      playerXNicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerXNickname',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'result',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'result',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'result',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'result',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      resultIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'result',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      statusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      statusGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      statusLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      statusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'winnerKey',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'winnerKey',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'winnerKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'winnerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'winnerKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'winnerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterFilterCondition>
      winnerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'winnerKey',
        value: '',
      ));
    });
  }
}

extension GameSessionEntityQueryObject
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QFilterCondition> {}

extension GameSessionEntityQueryLinks
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QFilterCondition> {}

extension GameSessionEntityQuerySortBy
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QSortBy> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByColorGameData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorGameData', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByColorGameDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorGameData', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByCurrentTurnKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTurnKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByCurrentTurnKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTurnKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByGameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByGameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByGameType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameType', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByGameTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameType', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByLastMoveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMoveAt', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByLastMoveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMoveAt', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByMoveCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveCount', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByMoveCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveCount', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerOKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerOKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerOKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerOKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerONickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerONickname', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerONicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerONickname', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerXKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerXKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerXNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXNickname', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByPlayerXNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXNickname', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'result', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'result', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByWinnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      sortByWinnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerKey', Sort.desc);
    });
  }
}

extension GameSessionEntityQuerySortThenBy
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QSortThenBy> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByColorGameData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorGameData', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByColorGameDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorGameData', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByCurrentTurnKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTurnKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByCurrentTurnKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentTurnKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByGameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByGameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByGameType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameType', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByGameTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameType', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByLastMoveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMoveAt', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByLastMoveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMoveAt', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByMoveCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveCount', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByMoveCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveCount', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerOKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerOKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerOKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerOKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerONickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerONickname', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerONicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerONickname', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerXKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerXKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXKey', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerXNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXNickname', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByPlayerXNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerXNickname', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByResult() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'result', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByResultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'result', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByWinnerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerKey', Sort.asc);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QAfterSortBy>
      thenByWinnerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'winnerKey', Sort.desc);
    });
  }
}

extension GameSessionEntityQueryWhereDistinct
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct> {
  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByBoard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'board');
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByColorGameData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorGameData',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByCurrentTurnKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentTurnKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByGameId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gameId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByGameType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gameType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByLastMoveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMoveAt');
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByMoveCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moveCount');
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByPlayerOKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerOKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByPlayerONickname({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerONickname',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByPlayerXKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerXKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByPlayerXNickname({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerXNickname',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByResult({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'result', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<GameSessionEntity, GameSessionEntity, QDistinct>
      distinctByWinnerKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'winnerKey', caseSensitive: caseSensitive);
    });
  }
}

extension GameSessionEntityQueryProperty
    on QueryBuilder<GameSessionEntity, GameSessionEntity, QQueryProperty> {
  QueryBuilder<GameSessionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GameSessionEntity, List<int>, QQueryOperations> boardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'board');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations>
      colorGameDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorGameData');
    });
  }

  QueryBuilder<GameSessionEntity, int, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations>
      currentTurnKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentTurnKey');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations> gameIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gameId');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations> gameTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gameType');
    });
  }

  QueryBuilder<GameSessionEntity, int, QQueryOperations> lastMoveAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMoveAt');
    });
  }

  QueryBuilder<GameSessionEntity, int, QQueryOperations> moveCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moveCount');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations>
      playerOKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerOKey');
    });
  }

  QueryBuilder<GameSessionEntity, String?, QQueryOperations>
      playerONicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerONickname');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations>
      playerXKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerXKey');
    });
  }

  QueryBuilder<GameSessionEntity, String?, QQueryOperations>
      playerXNicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerXNickname');
    });
  }

  QueryBuilder<GameSessionEntity, String, QQueryOperations> resultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'result');
    });
  }

  QueryBuilder<GameSessionEntity, int, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<GameSessionEntity, String?, QQueryOperations>
      winnerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'winnerKey');
    });
  }
}
