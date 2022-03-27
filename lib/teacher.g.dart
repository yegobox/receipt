// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast

extension GetTeacherCollection on Isar {
  IsarCollection<Teacher> get teachers {
    return getCollection('Teacher');
  }
}

final TeacherSchema = CollectionSchema(
  name: 'Teacher',
  schema:
      '{"name":"Teacher","idName":"id","properties":[{"name":"subject","type":"String"}],"indexes":[],"links":[]}',
  nativeAdapter: const _TeacherNativeAdapter(),
  webAdapter: const _TeacherWebAdapter(),
  idName: 'id',
  propertyIds: {'subject': 0},
  listProperties: {},
  indexIds: {},
  indexTypes: {},
  linkIds: {},
  backlinkIds: {},
  linkedCollections: [],
  getId: (obj) {
    if (obj.id == Isar.autoIncrement) {
      return null;
    } else {
      return obj.id;
    }
  },
  setId: (obj, id) => obj.id = id,
  getLinks: (obj) => [],
  version: 2,
);

class _TeacherWebAdapter extends IsarWebTypeAdapter<Teacher> {
  const _TeacherWebAdapter();

  @override
  Object serialize(IsarCollection<Teacher> collection, Teacher object) {
    final jsObj = IsarNative.newJsObject();
    IsarNative.jsObjectSet(jsObj, 'id', object.id);
    IsarNative.jsObjectSet(jsObj, 'subject', object.subject);
    return jsObj;
  }

  @override
  Teacher deserialize(IsarCollection<Teacher> collection, dynamic jsObj) {
    final object = Teacher();
    object.id = IsarNative.jsObjectGet(jsObj, 'id');
    object.subject = IsarNative.jsObjectGet(jsObj, 'subject') ?? '';
    return object;
  }

  @override
  P deserializeProperty<P>(Object jsObj, String propertyName) {
    switch (propertyName) {
      case 'id':
        return (IsarNative.jsObjectGet(jsObj, 'id')) as P;
      case 'subject':
        return (IsarNative.jsObjectGet(jsObj, 'subject') ?? '') as P;
      default:
        throw 'Illegal propertyName';
    }
  }

  @override
  void attachLinks(Isar isar, int id, Teacher object) {}
}

class _TeacherNativeAdapter extends IsarNativeTypeAdapter<Teacher> {
  const _TeacherNativeAdapter();

  @override
  void serialize(IsarCollection<Teacher> collection, IsarRawObject rawObj,
      Teacher object, int staticSize, List<int> offsets, AdapterAlloc alloc) {
    var dynamicSize = 0;
    final value0 = object.subject;
    final _subject = IsarBinaryWriter.utf8Encoder.convert(value0);
    dynamicSize += (_subject.length) as int;
    final size = staticSize + dynamicSize;

    rawObj.buffer = alloc(size);
    rawObj.buffer_length = size;
    final buffer = IsarNative.bufAsBytes(rawObj.buffer, size);
    final writer = IsarBinaryWriter(buffer, staticSize);
    writer.writeBytes(offsets[0], _subject);
  }

  @override
  Teacher deserialize(IsarCollection<Teacher> collection, int id,
      IsarBinaryReader reader, List<int> offsets) {
    final object = Teacher();
    object.id = id;
    object.subject = reader.readString(offsets[0]);
    return object;
  }

  @override
  P deserializeProperty<P>(
      int id, IsarBinaryReader reader, int propertyIndex, int offset) {
    switch (propertyIndex) {
      case -1:
        return id as P;
      case 0:
        return (reader.readString(offset)) as P;
      default:
        throw 'Illegal propertyIndex';
    }
  }

  @override
  void attachLinks(Isar isar, int id, Teacher object) {}
}

extension TeacherQueryWhereSort on QueryBuilder<Teacher, Teacher, QWhere> {
  QueryBuilder<Teacher, Teacher, QAfterWhere> anyId() {
    return addWhereClauseInternal(const WhereClause(indexName: null));
  }
}

extension TeacherQueryWhere on QueryBuilder<Teacher, Teacher, QWhereClause> {
  QueryBuilder<Teacher, Teacher, QAfterWhereClause> idEqualTo(int? id) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: true,
      upper: [id],
      includeUpper: true,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterWhereClause> idNotEqualTo(int? id) {
    if (whereSortInternal == Sort.asc) {
      return addWhereClauseInternal(WhereClause(
        indexName: null,
        upper: [id],
        includeUpper: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: null,
        lower: [id],
        includeLower: false,
      ));
    } else {
      return addWhereClauseInternal(WhereClause(
        indexName: null,
        lower: [id],
        includeLower: false,
      )).addWhereClauseInternal(WhereClause(
        indexName: null,
        upper: [id],
        includeUpper: false,
      ));
    }
  }

  QueryBuilder<Teacher, Teacher, QAfterWhereClause> idGreaterThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [id],
      includeLower: include,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterWhereClause> idLessThan(
    int? id, {
    bool include = false,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      upper: [id],
      includeUpper: include,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterWhereClause> idBetween(
    int? lowerId,
    int? upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addWhereClauseInternal(WhereClause(
      indexName: null,
      lower: [lowerId],
      includeLower: includeLower,
      upper: [upperId],
      includeUpper: includeUpper,
    ));
  }
}

extension TeacherQueryFilter
    on QueryBuilder<Teacher, Teacher, QFilterCondition> {
  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> idIsNull() {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.isNull,
      property: 'id',
      value: null,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> idEqualTo(int? value) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> idGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> idLessThan(
    int? value, {
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'id',
      value: value,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> idBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'id',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.eq,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectGreaterThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.gt,
      include: include,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectLessThan(
    String value, {
    bool caseSensitive = true,
    bool include = false,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.lt,
      include: include,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return addFilterConditionInternal(FilterCondition.between(
      property: 'subject',
      lower: lower,
      includeLower: includeLower,
      upper: upper,
      includeUpper: includeUpper,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.startsWith,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.endsWith,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectContains(
      String value,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.contains,
      property: 'subject',
      value: value,
      caseSensitive: caseSensitive,
    ));
  }

  QueryBuilder<Teacher, Teacher, QAfterFilterCondition> subjectMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return addFilterConditionInternal(FilterCondition(
      type: ConditionType.matches,
      property: 'subject',
      value: pattern,
      caseSensitive: caseSensitive,
    ));
  }
}

extension TeacherQueryLinks
    on QueryBuilder<Teacher, Teacher, QFilterCondition> {}

extension TeacherQueryWhereSortBy on QueryBuilder<Teacher, Teacher, QSortBy> {
  QueryBuilder<Teacher, Teacher, QAfterSortBy> sortById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> sortByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> sortBySubject() {
    return addSortByInternal('subject', Sort.asc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> sortBySubjectDesc() {
    return addSortByInternal('subject', Sort.desc);
  }
}

extension TeacherQueryWhereSortThenBy
    on QueryBuilder<Teacher, Teacher, QSortThenBy> {
  QueryBuilder<Teacher, Teacher, QAfterSortBy> thenById() {
    return addSortByInternal('id', Sort.asc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> thenByIdDesc() {
    return addSortByInternal('id', Sort.desc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> thenBySubject() {
    return addSortByInternal('subject', Sort.asc);
  }

  QueryBuilder<Teacher, Teacher, QAfterSortBy> thenBySubjectDesc() {
    return addSortByInternal('subject', Sort.desc);
  }
}

extension TeacherQueryWhereDistinct
    on QueryBuilder<Teacher, Teacher, QDistinct> {
  QueryBuilder<Teacher, Teacher, QDistinct> distinctById() {
    return addDistinctByInternal('id');
  }

  QueryBuilder<Teacher, Teacher, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return addDistinctByInternal('subject', caseSensitive: caseSensitive);
  }
}

extension TeacherQueryProperty
    on QueryBuilder<Teacher, Teacher, QQueryProperty> {
  QueryBuilder<Teacher, int?, QQueryOperations> idProperty() {
    return addPropertyNameInternal('id');
  }

  QueryBuilder<Teacher, String, QQueryOperations> subjectProperty() {
    return addPropertyNameInternal('subject');
  }
}
