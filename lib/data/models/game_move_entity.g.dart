// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_move_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGameMoveEntityCollection on Isar {
  IsarCollection<GameMoveEntity> get gameMoveEntitys => this.collection();
}

const GameMoveEntitySchema = CollectionSchema(
  name: r'GameMoveEntity',
  id: -463838703737148534,
  properties: {
    r'acked': PropertySchema(
      id: 0,
      name: r'acked',
      type: IsarType.bool,
    ),
    r'gameId': PropertySchema(
      id: 1,
      name: r'gameId',
      type: IsarType.string,
    ),
    r'moveId': PropertySchema(
      id: 2,
      name: r'moveId',
      type: IsarType.string,
    ),
    r'moveNumber': PropertySchema(
      id: 3,
      name: r'moveNumber',
      type: IsarType.long,
    ),
    r'playerKey': PropertySchema(
      id: 4,
      name: r'playerKey',
      type: IsarType.string,
    ),
    r'position': PropertySchema(
      id: 5,
      name: r'position',
      type: IsarType.long,
    ),
    r'signature': PropertySchema(
      id: 6,
      name: r'signature',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 7,
      name: r'timestamp',
      type: IsarType.long,
    )
  },
  estimateSize: _gameMoveEntityEstimateSize,
  serialize: _gameMoveEntitySerialize,
  deserialize: _gameMoveEntityDeserialize,
  deserializeProp: _gameMoveEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'gameId': IndexSchema(
      id: -1012023815008531514,
      name: r'gameId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'gameId',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'moveId': IndexSchema(
      id: 7633310754490106230,
      name: r'moveId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'moveId',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _gameMoveEntityGetId,
  getLinks: _gameMoveEntityGetLinks,
  attach: _gameMoveEntityAttach,
  version: '3.1.0+1',
);

int _gameMoveEntityEstimateSize(
  GameMoveEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.gameId.length * 3;
  bytesCount += 3 + object.moveId.length * 3;
  bytesCount += 3 + object.playerKey.length * 3;
  bytesCount += 3 + object.signature.length * 3;
  return bytesCount;
}

void _gameMoveEntitySerialize(
  GameMoveEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.acked);
  writer.writeString(offsets[1], object.gameId);
  writer.writeString(offsets[2], object.moveId);
  writer.writeLong(offsets[3], object.moveNumber);
  writer.writeString(offsets[4], object.playerKey);
  writer.writeLong(offsets[5], object.position);
  writer.writeString(offsets[6], object.signature);
  writer.writeLong(offsets[7], object.timestamp);
}

GameMoveEntity _gameMoveEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GameMoveEntity();
  object.acked = reader.readBool(offsets[0]);
  object.gameId = reader.readString(offsets[1]);
  object.id = id;
  object.moveId = reader.readString(offsets[2]);
  object.moveNumber = reader.readLong(offsets[3]);
  object.playerKey = reader.readString(offsets[4]);
  object.position = reader.readLong(offsets[5]);
  object.signature = reader.readString(offsets[6]);
  object.timestamp = reader.readLong(offsets[7]);
  return object;
}

P _gameMoveEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gameMoveEntityGetId(GameMoveEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gameMoveEntityGetLinks(GameMoveEntity object) {
  return [];
}

void _gameMoveEntityAttach(
    IsarCollection<dynamic> col, Id id, GameMoveEntity object) {
  object.id = id;
}

extension GameMoveEntityQueryWhereSort
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QWhere> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhere> anyGameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'gameId'),
      );
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhere> anyMoveId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'moveId'),
      );
    });
  }
}

extension GameMoveEntityQueryWhere
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QWhereClause> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> gameIdEqualTo(
      String gameId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gameId',
        value: [gameId],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      gameIdGreaterThan(
    String gameId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gameId',
        lower: [gameId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      gameIdLessThan(
    String gameId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gameId',
        lower: [],
        upper: [gameId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> gameIdBetween(
    String lowerGameId,
    String upperGameId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gameId',
        lower: [lowerGameId],
        includeLower: includeLower,
        upper: [upperGameId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      gameIdStartsWith(String GameIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'gameId',
        lower: [GameIdPrefix],
        upper: ['$GameIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      gameIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gameId',
        value: [''],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      gameIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'gameId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'gameId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'gameId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'gameId',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> moveIdEqualTo(
      String moveId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moveId',
        value: [moveId],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdNotEqualTo(String moveId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moveId',
              lower: [],
              upper: [moveId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moveId',
              lower: [moveId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moveId',
              lower: [moveId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'moveId',
              lower: [],
              upper: [moveId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdGreaterThan(
    String moveId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'moveId',
        lower: [moveId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdLessThan(
    String moveId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'moveId',
        lower: [],
        upper: [moveId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause> moveIdBetween(
    String lowerMoveId,
    String upperMoveId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'moveId',
        lower: [lowerMoveId],
        includeLower: includeLower,
        upper: [upperMoveId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdStartsWith(String MoveIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'moveId',
        lower: [MoveIdPrefix],
        upper: ['$MoveIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'moveId',
        value: [''],
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterWhereClause>
      moveIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'moveId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'moveId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'moveId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'moveId',
              upper: [''],
            ));
      }
    });
  }
}

extension GameMoveEntityQueryFilter
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QFilterCondition> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      ackedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acked',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      gameIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gameId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      gameIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gameId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      gameIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gameId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      gameIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gameId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moveId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moveId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moveId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moveId',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moveNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moveNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moveNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      moveNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moveNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      playerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      positionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      positionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signature',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signature',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      signatureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signature',
        value: '',
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      timestampEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      timestampGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      timestampLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterFilterCondition>
      timestampBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GameMoveEntityQueryObject
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QFilterCondition> {}

extension GameMoveEntityQueryLinks
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QFilterCondition> {}

extension GameMoveEntityQuerySortBy
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QSortBy> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByAcked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acked', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByAckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acked', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByGameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByGameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByMoveId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveId', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByMoveIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveId', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByMoveNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveNumber', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByMoveNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveNumber', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByPlayerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerKey', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByPlayerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerKey', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GameMoveEntityQuerySortThenBy
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QSortThenBy> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByAcked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acked', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByAckedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acked', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByGameId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByGameIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gameId', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByMoveId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveId', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByMoveIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveId', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByMoveNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveNumber', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByMoveNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moveNumber', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByPlayerKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerKey', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByPlayerKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playerKey', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenBySignature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenBySignatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signature', Sort.desc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension GameMoveEntityQueryWhereDistinct
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> {
  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctByAcked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acked');
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctByGameId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gameId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctByMoveId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moveId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct>
      distinctByMoveNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moveNumber');
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctByPlayerKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct> distinctBySignature(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signature', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GameMoveEntity, GameMoveEntity, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension GameMoveEntityQueryProperty
    on QueryBuilder<GameMoveEntity, GameMoveEntity, QQueryProperty> {
  QueryBuilder<GameMoveEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GameMoveEntity, bool, QQueryOperations> ackedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acked');
    });
  }

  QueryBuilder<GameMoveEntity, String, QQueryOperations> gameIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gameId');
    });
  }

  QueryBuilder<GameMoveEntity, String, QQueryOperations> moveIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moveId');
    });
  }

  QueryBuilder<GameMoveEntity, int, QQueryOperations> moveNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moveNumber');
    });
  }

  QueryBuilder<GameMoveEntity, String, QQueryOperations> playerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerKey');
    });
  }

  QueryBuilder<GameMoveEntity, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<GameMoveEntity, String, QQueryOperations> signatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signature');
    });
  }

  QueryBuilder<GameMoveEntity, int, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
