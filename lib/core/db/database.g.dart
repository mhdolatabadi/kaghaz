// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF5C7CFA),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;

  /// Null for folders at the library root.
  final int? parentId;
  final int color;
  final DateTime createdAt;
  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<int?>(parentId),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Folder copyWith({
    int? id,
    String? name,
    Value<int?> parentId = const Value.absent(),
    int? color,
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> parentId;
  final Value<int> color;
  final Value<DateTime> createdAt;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.parentId = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? parentId,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? parentId,
    Value<int>? color,
    Value<DateTime>? createdAt,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotebooksTable extends Notebooks
    with TableInfo<$NotebooksTable, Notebook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotebooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF3D5A80),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PageBackground, String>
  defaultBackground = GeneratedColumn<String>(
    'default_background',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lined'),
  ).withConverter<PageBackground>($NotebooksTable.$converterdefaultBackground);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    color,
    folderId,
    favorite,
    defaultBackground,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notebooks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notebook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notebook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notebook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      ),
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      defaultBackground: $NotebooksTable.$converterdefaultBackground.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_background'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotebooksTable createAlias(String alias) {
    return $NotebooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PageBackground, String, String>
  $converterdefaultBackground = const EnumNameConverter<PageBackground>(
    PageBackground.values,
  );
}

class Notebook extends DataClass implements Insertable<Notebook> {
  final int id;
  final String title;
  final int color;

  /// Null for notebooks at the library root.
  final int? folderId;
  final bool favorite;

  /// Paper used for new pages added to this notebook.
  final PageBackground defaultBackground;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Notebook({
    required this.id,
    required this.title,
    required this.color,
    this.folderId,
    required this.favorite,
    required this.defaultBackground,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['favorite'] = Variable<bool>(favorite);
    {
      map['default_background'] = Variable<String>(
        $NotebooksTable.$converterdefaultBackground.toSql(defaultBackground),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotebooksCompanion toCompanion(bool nullToAbsent) {
    return NotebooksCompanion(
      id: Value(id),
      title: Value(title),
      color: Value(color),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      favorite: Value(favorite),
      defaultBackground: Value(defaultBackground),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Notebook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notebook(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      color: serializer.fromJson<int>(json['color']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      defaultBackground: $NotebooksTable.$converterdefaultBackground.fromJson(
        serializer.fromJson<String>(json['defaultBackground']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'color': serializer.toJson<int>(color),
      'folderId': serializer.toJson<int?>(folderId),
      'favorite': serializer.toJson<bool>(favorite),
      'defaultBackground': serializer.toJson<String>(
        $NotebooksTable.$converterdefaultBackground.toJson(defaultBackground),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Notebook copyWith({
    int? id,
    String? title,
    int? color,
    Value<int?> folderId = const Value.absent(),
    bool? favorite,
    PageBackground? defaultBackground,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Notebook(
    id: id ?? this.id,
    title: title ?? this.title,
    color: color ?? this.color,
    folderId: folderId.present ? folderId.value : this.folderId,
    favorite: favorite ?? this.favorite,
    defaultBackground: defaultBackground ?? this.defaultBackground,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Notebook copyWithCompanion(NotebooksCompanion data) {
    return Notebook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      color: data.color.present ? data.color.value : this.color,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      defaultBackground: data.defaultBackground.present
          ? data.defaultBackground.value
          : this.defaultBackground,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notebook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('folderId: $folderId, ')
          ..write('favorite: $favorite, ')
          ..write('defaultBackground: $defaultBackground, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    color,
    folderId,
    favorite,
    defaultBackground,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notebook &&
          other.id == this.id &&
          other.title == this.title &&
          other.color == this.color &&
          other.folderId == this.folderId &&
          other.favorite == this.favorite &&
          other.defaultBackground == this.defaultBackground &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotebooksCompanion extends UpdateCompanion<Notebook> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> color;
  final Value<int?> folderId;
  final Value<bool> favorite;
  final Value<PageBackground> defaultBackground;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotebooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.color = const Value.absent(),
    this.folderId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.defaultBackground = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotebooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.color = const Value.absent(),
    this.folderId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.defaultBackground = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Notebook> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? color,
    Expression<int>? folderId,
    Expression<bool>? favorite,
    Expression<String>? defaultBackground,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (color != null) 'color': color,
      if (folderId != null) 'folder_id': folderId,
      if (favorite != null) 'favorite': favorite,
      if (defaultBackground != null) 'default_background': defaultBackground,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotebooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int>? color,
    Value<int?>? folderId,
    Value<bool>? favorite,
    Value<PageBackground>? defaultBackground,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotebooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      folderId: folderId ?? this.folderId,
      favorite: favorite ?? this.favorite,
      defaultBackground: defaultBackground ?? this.defaultBackground,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (defaultBackground.present) {
      map['default_background'] = Variable<String>(
        $NotebooksTable.$converterdefaultBackground.toSql(
          defaultBackground.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotebooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('color: $color, ')
          ..write('folderId: $folderId, ')
          ..write('favorite: $favorite, ')
          ..write('defaultBackground: $defaultBackground, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PdfFilesTable extends PdfFiles with TableInfo<$PdfFilesTable, PdfFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PdfFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, bytes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pdf_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PdfFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PdfFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PdfFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PdfFilesTable createAlias(String alias) {
    return $PdfFilesTable(attachedDatabase, alias);
  }
}

class PdfFile extends DataClass implements Insertable<PdfFile> {
  final int id;
  final String name;
  final Uint8List bytes;
  final DateTime createdAt;
  const PdfFile({
    required this.id,
    required this.name,
    required this.bytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PdfFilesCompanion toCompanion(bool nullToAbsent) {
    return PdfFilesCompanion(
      id: Value(id),
      name: Value(name),
      bytes: Value(bytes),
      createdAt: Value(createdAt),
    );
  }

  factory PdfFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PdfFile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PdfFile copyWith({
    int? id,
    String? name,
    Uint8List? bytes,
    DateTime? createdAt,
  }) => PdfFile(
    id: id ?? this.id,
    name: name ?? this.name,
    bytes: bytes ?? this.bytes,
    createdAt: createdAt ?? this.createdAt,
  );
  PdfFile copyWithCompanion(PdfFilesCompanion data) {
    return PdfFile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PdfFile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, $driftBlobEquality.hash(bytes), createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PdfFile &&
          other.id == this.id &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.createdAt == this.createdAt);
}

class PdfFilesCompanion extends UpdateCompanion<PdfFile> {
  final Value<int> id;
  final Value<String> name;
  final Value<Uint8List> bytes;
  final Value<DateTime> createdAt;
  const PdfFilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bytes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PdfFilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required Uint8List bytes,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       bytes = Value(bytes);
  static Insertable<PdfFile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<Uint8List>? bytes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bytes != null) 'bytes': bytes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PdfFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<Uint8List>? bytes,
    Value<DateTime>? createdAt,
  }) {
    return PdfFilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PdfFilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotePagesTable extends NotePages
    with TableInfo<$NotePagesTable, NotePage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotePagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<int> notebookId = GeneratedColumn<int>(
    'notebook_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notebooks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PageKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PageKind>($NotePagesTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<PageBackground, String>
  background = GeneratedColumn<String>(
    'background',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lined'),
  ).withConverter<PageBackground>($NotePagesTable.$converterbackground);
  static const VerificationMeta _inkMeta = const VerificationMeta('ink');
  @override
  late final GeneratedColumn<String> ink = GeneratedColumn<String>(
    'ink',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultPageWidth),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultPageHeight),
  );
  static const VerificationMeta _pdfIdMeta = const VerificationMeta('pdfId');
  @override
  late final GeneratedColumn<int> pdfId = GeneratedColumn<int>(
    'pdf_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pdf_files (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _pdfPageMeta = const VerificationMeta(
    'pdfPage',
  );
  @override
  late final GeneratedColumn<int> pdfPage = GeneratedColumn<int>(
    'pdf_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notebookId,
    position,
    kind,
    background,
    ink,
    body,
    width,
    height,
    pdfId,
    pdfPage,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotePage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notebookIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('ink')) {
      context.handle(
        _inkMeta,
        ink.isAcceptableOrUnknown(data['ink']!, _inkMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('pdf_id')) {
      context.handle(
        _pdfIdMeta,
        pdfId.isAcceptableOrUnknown(data['pdf_id']!, _pdfIdMeta),
      );
    }
    if (data.containsKey('pdf_page')) {
      context.handle(
        _pdfPageMeta,
        pdfPage.isAcceptableOrUnknown(data['pdf_page']!, _pdfPageMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotePage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotePage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notebook_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: $NotePagesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      background: $NotePagesTable.$converterbackground.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}background'],
        )!,
      ),
      ink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ink'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      pdfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pdf_id'],
      ),
      pdfPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pdf_page'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotePagesTable createAlias(String alias) {
    return $NotePagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PageKind, String, String> $converterkind =
      const EnumNameConverter<PageKind>(PageKind.values);
  static JsonTypeConverter2<PageBackground, String, String>
  $converterbackground = const EnumNameConverter<PageBackground>(
    PageBackground.values,
  );
}

class NotePage extends DataClass implements Insertable<NotePage> {
  final int id;
  final int notebookId;
  final int position;
  final PageKind kind;
  final PageBackground background;

  /// Strokes serialized by `InkDocument.encode`.
  final String ink;

  /// Typed content for text pages.
  final String body;

  /// Page size in logical units; PDF pages keep their own aspect ratio.
  final double width;
  final double height;

  /// The PDF drawn behind the ink, and which of its pages (0-based).
  final int? pdfId;
  final int? pdfPage;
  final DateTime updatedAt;
  const NotePage({
    required this.id,
    required this.notebookId,
    required this.position,
    required this.kind,
    required this.background,
    required this.ink,
    required this.body,
    required this.width,
    required this.height,
    this.pdfId,
    this.pdfPage,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notebook_id'] = Variable<int>(notebookId);
    map['position'] = Variable<int>(position);
    {
      map['kind'] = Variable<String>(
        $NotePagesTable.$converterkind.toSql(kind),
      );
    }
    {
      map['background'] = Variable<String>(
        $NotePagesTable.$converterbackground.toSql(background),
      );
    }
    map['ink'] = Variable<String>(ink);
    map['body'] = Variable<String>(body);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    if (!nullToAbsent || pdfId != null) {
      map['pdf_id'] = Variable<int>(pdfId);
    }
    if (!nullToAbsent || pdfPage != null) {
      map['pdf_page'] = Variable<int>(pdfPage);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotePagesCompanion toCompanion(bool nullToAbsent) {
    return NotePagesCompanion(
      id: Value(id),
      notebookId: Value(notebookId),
      position: Value(position),
      kind: Value(kind),
      background: Value(background),
      ink: Value(ink),
      body: Value(body),
      width: Value(width),
      height: Value(height),
      pdfId: pdfId == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfId),
      pdfPage: pdfPage == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPage),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotePage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotePage(
      id: serializer.fromJson<int>(json['id']),
      notebookId: serializer.fromJson<int>(json['notebookId']),
      position: serializer.fromJson<int>(json['position']),
      kind: $NotePagesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      background: $NotePagesTable.$converterbackground.fromJson(
        serializer.fromJson<String>(json['background']),
      ),
      ink: serializer.fromJson<String>(json['ink']),
      body: serializer.fromJson<String>(json['body']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      pdfId: serializer.fromJson<int?>(json['pdfId']),
      pdfPage: serializer.fromJson<int?>(json['pdfPage']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notebookId': serializer.toJson<int>(notebookId),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<String>(
        $NotePagesTable.$converterkind.toJson(kind),
      ),
      'background': serializer.toJson<String>(
        $NotePagesTable.$converterbackground.toJson(background),
      ),
      'ink': serializer.toJson<String>(ink),
      'body': serializer.toJson<String>(body),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'pdfId': serializer.toJson<int?>(pdfId),
      'pdfPage': serializer.toJson<int?>(pdfPage),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotePage copyWith({
    int? id,
    int? notebookId,
    int? position,
    PageKind? kind,
    PageBackground? background,
    String? ink,
    String? body,
    double? width,
    double? height,
    Value<int?> pdfId = const Value.absent(),
    Value<int?> pdfPage = const Value.absent(),
    DateTime? updatedAt,
  }) => NotePage(
    id: id ?? this.id,
    notebookId: notebookId ?? this.notebookId,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    background: background ?? this.background,
    ink: ink ?? this.ink,
    body: body ?? this.body,
    width: width ?? this.width,
    height: height ?? this.height,
    pdfId: pdfId.present ? pdfId.value : this.pdfId,
    pdfPage: pdfPage.present ? pdfPage.value : this.pdfPage,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NotePage copyWithCompanion(NotePagesCompanion data) {
    return NotePage(
      id: data.id.present ? data.id.value : this.id,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      background: data.background.present
          ? data.background.value
          : this.background,
      ink: data.ink.present ? data.ink.value : this.ink,
      body: data.body.present ? data.body.value : this.body,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      pdfId: data.pdfId.present ? data.pdfId.value : this.pdfId,
      pdfPage: data.pdfPage.present ? data.pdfPage.value : this.pdfPage,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotePage(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('background: $background, ')
          ..write('ink: $ink, ')
          ..write('body: $body, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pdfId: $pdfId, ')
          ..write('pdfPage: $pdfPage, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notebookId,
    position,
    kind,
    background,
    ink,
    body,
    width,
    height,
    pdfId,
    pdfPage,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotePage &&
          other.id == this.id &&
          other.notebookId == this.notebookId &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.background == this.background &&
          other.ink == this.ink &&
          other.body == this.body &&
          other.width == this.width &&
          other.height == this.height &&
          other.pdfId == this.pdfId &&
          other.pdfPage == this.pdfPage &&
          other.updatedAt == this.updatedAt);
}

class NotePagesCompanion extends UpdateCompanion<NotePage> {
  final Value<int> id;
  final Value<int> notebookId;
  final Value<int> position;
  final Value<PageKind> kind;
  final Value<PageBackground> background;
  final Value<String> ink;
  final Value<String> body;
  final Value<double> width;
  final Value<double> height;
  final Value<int?> pdfId;
  final Value<int?> pdfPage;
  final Value<DateTime> updatedAt;
  const NotePagesCompanion({
    this.id = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.background = const Value.absent(),
    this.ink = const Value.absent(),
    this.body = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.pdfId = const Value.absent(),
    this.pdfPage = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotePagesCompanion.insert({
    this.id = const Value.absent(),
    required int notebookId,
    required int position,
    required PageKind kind,
    this.background = const Value.absent(),
    this.ink = const Value.absent(),
    this.body = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.pdfId = const Value.absent(),
    this.pdfPage = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : notebookId = Value(notebookId),
       position = Value(position),
       kind = Value(kind);
  static Insertable<NotePage> custom({
    Expression<int>? id,
    Expression<int>? notebookId,
    Expression<int>? position,
    Expression<String>? kind,
    Expression<String>? background,
    Expression<String>? ink,
    Expression<String>? body,
    Expression<double>? width,
    Expression<double>? height,
    Expression<int>? pdfId,
    Expression<int>? pdfPage,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notebookId != null) 'notebook_id': notebookId,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (background != null) 'background': background,
      if (ink != null) 'ink': ink,
      if (body != null) 'body': body,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pdfId != null) 'pdf_id': pdfId,
      if (pdfPage != null) 'pdf_page': pdfPage,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotePagesCompanion copyWith({
    Value<int>? id,
    Value<int>? notebookId,
    Value<int>? position,
    Value<PageKind>? kind,
    Value<PageBackground>? background,
    Value<String>? ink,
    Value<String>? body,
    Value<double>? width,
    Value<double>? height,
    Value<int?>? pdfId,
    Value<int?>? pdfPage,
    Value<DateTime>? updatedAt,
  }) {
    return NotePagesCompanion(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      background: background ?? this.background,
      ink: ink ?? this.ink,
      body: body ?? this.body,
      width: width ?? this.width,
      height: height ?? this.height,
      pdfId: pdfId ?? this.pdfId,
      pdfPage: pdfPage ?? this.pdfPage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<int>(notebookId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $NotePagesTable.$converterkind.toSql(kind.value),
      );
    }
    if (background.present) {
      map['background'] = Variable<String>(
        $NotePagesTable.$converterbackground.toSql(background.value),
      );
    }
    if (ink.present) {
      map['ink'] = Variable<String>(ink.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (pdfId.present) {
      map['pdf_id'] = Variable<int>(pdfId.value);
    }
    if (pdfPage.present) {
      map['pdf_page'] = Variable<int>(pdfPage.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotePagesCompanion(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('background: $background, ')
          ..write('ink: $ink, ')
          ..write('body: $body, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pdfId: $pdfId, ')
          ..write('pdfPage: $pdfPage, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $NotebooksTable notebooks = $NotebooksTable(this);
  late final $PdfFilesTable pdfFiles = $PdfFilesTable(this);
  late final $NotePagesTable notePages = $NotePagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    notebooks,
    pdfFiles,
    notePages,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notebooks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notebooks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pdf_files',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_pages', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> parentId,
  Value<int> color,
  Value<DateTime> createdAt,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> parentId,
  Value<int> color,
  Value<DateTime> createdAt,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _parentIdTable(_$AppDatabase db) =>
      db.folders.createAlias('folders__parent_id__folders__id');

  $$FoldersTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NotebooksTable, List<Notebook>>
  _notebooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notebooks,
    aliasName: 'folders__id__notebooks__folder_id',
  );

  $$NotebooksTableProcessedTableManager get notebooksRefs {
    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notebooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get parentId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> notebooksRefs(
    Expression<bool> Function($$NotebooksTableFilterComposer f) f,
  ) {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get parentId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get parentId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> notebooksRefs<T extends Object>(
    Expression<T> Function($$NotebooksTableAnnotationComposer a) f,
  ) {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool parentId, bool notebooksRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                parentId: parentId,
                color: color,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> parentId = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                color: color,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoldersTable, Folder>(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, notebooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notebooksRefs) db.notebooks],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.parentId,
                        referencedTable: $$FoldersTableReferences
                            ._parentIdTable(db),
                        referencedColumn: $$FoldersTableReferences
                            ._parentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notebooksRefs)
                    await $_getPrefetchedDataByColumns<
                      Folder,
                      $FoldersTable,
                      Notebook,
                      $NotebooksTable
                    >(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._notebooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).notebooksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'folder_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool parentId, bool notebooksRefs})
    >;
typedef $$NotebooksTableCreateCompanionBuilder = NotebooksCompanion Function({
  Value<int> id,
  required String title,
  Value<int> color,
  Value<int?> folderId,
  Value<bool> favorite,
  Value<PageBackground> defaultBackground,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$NotebooksTableUpdateCompanionBuilder = NotebooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int> color,
  Value<int?> folderId,
  Value<bool> favorite,
  Value<PageBackground> defaultBackground,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$NotebooksTableReferences
    extends BaseReferences<_$AppDatabase, $NotebooksTable, Notebook> {
  $$NotebooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias('notebooks__folder_id__folders__id');

  $$FoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NotePagesTable, List<NotePage>>
  _notePagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notePages,
    aliasName: 'notebooks__id__note_pages__notebook_id',
  );

  $$NotePagesTableProcessedTableManager get notePagesRefs {
    final manager = $$NotePagesTableTableManager(
      $_db,
      $_db.notePages,
    ).filter((f) => f.notebookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notePagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotebooksTableFilterComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PageBackground, PageBackground, String>
  get defaultBackground => $composableBuilder(
    column: $table.defaultBackground,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> notePagesRefs(
    Expression<bool> Function($$NotePagesTableFilterComposer f) f,
  ) {
    final $$NotePagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePages,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePagesTableFilterComposer(
            $db: $db,
            $table: $db.notePages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableOrderingComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultBackground => $composableBuilder(
    column: $table.defaultBackground,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotebooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotebooksTable> {
  $$NotebooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PageBackground, String>
  get defaultBackground => $composableBuilder(
    column: $table.defaultBackground,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> notePagesRefs<T extends Object>(
    Expression<T> Function($$NotePagesTableAnnotationComposer a) f,
  ) {
    final $$NotePagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePages,
      getReferencedColumn: (t) => t.notebookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePagesTableAnnotationComposer(
            $db: $db,
            $table: $db.notePages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotebooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotebooksTable,
          Notebook,
          $$NotebooksTableFilterComposer,
          $$NotebooksTableOrderingComposer,
          $$NotebooksTableAnnotationComposer,
          $$NotebooksTableCreateCompanionBuilder,
          $$NotebooksTableUpdateCompanionBuilder,
          (Notebook, $$NotebooksTableReferences),
          Notebook,
          PrefetchHooks Function({bool folderId, bool notePagesRefs})
        > {
  $$NotebooksTableTableManager(_$AppDatabase db, $NotebooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotebooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotebooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotebooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<PageBackground> defaultBackground = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotebooksCompanion(
                id: id,
                title: title,
                color: color,
                folderId: folderId,
                favorite: favorite,
                defaultBackground: defaultBackground,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<int> color = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<PageBackground> defaultBackground = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotebooksCompanion.insert(
                id: id,
                title: title,
                color: color,
                folderId: folderId,
                favorite: favorite,
                defaultBackground: defaultBackground,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotebooksTable, Notebook>(table),
                  $$NotebooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, notePagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notePagesRefs) db.notePages],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$NotebooksTableReferences
                            ._folderIdTable(db),
                        referencedColumn: $$NotebooksTableReferences
                            ._folderIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notePagesRefs)
                    await $_getPrefetchedDataByColumns<
                      Notebook,
                      $NotebooksTable,
                      NotePage,
                      $NotePagesTable
                    >(
                      currentTable: table,
                      referencedTable: $$NotebooksTableReferences
                          ._notePagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NotebooksTableReferences(
                            db,
                            table,
                            p0,
                          ).notePagesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'notebook_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotebooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotebooksTable,
      Notebook,
      $$NotebooksTableFilterComposer,
      $$NotebooksTableOrderingComposer,
      $$NotebooksTableAnnotationComposer,
      $$NotebooksTableCreateCompanionBuilder,
      $$NotebooksTableUpdateCompanionBuilder,
      (Notebook, $$NotebooksTableReferences),
      Notebook,
      PrefetchHooks Function({bool folderId, bool notePagesRefs})
    >;
typedef $$PdfFilesTableCreateCompanionBuilder = PdfFilesCompanion Function({
  Value<int> id,
  required String name,
  required Uint8List bytes,
  Value<DateTime> createdAt,
});
typedef $$PdfFilesTableUpdateCompanionBuilder = PdfFilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<Uint8List> bytes,
  Value<DateTime> createdAt,
});

final class $$PdfFilesTableReferences
    extends BaseReferences<_$AppDatabase, $PdfFilesTable, PdfFile> {
  $$PdfFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotePagesTable, List<NotePage>>
  _notePagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.notePages,
    aliasName: 'pdf_files__id__note_pages__pdf_id',
  );

  $$NotePagesTableProcessedTableManager get notePagesRefs {
    final manager = $$NotePagesTableTableManager(
      $_db,
      $_db.notePages,
    ).filter((f) => f.pdfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notePagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PdfFilesTableFilterComposer
    extends Composer<_$AppDatabase, $PdfFilesTable> {
  $$PdfFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notePagesRefs(
    Expression<bool> Function($$NotePagesTableFilterComposer f) f,
  ) {
    final $$NotePagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePages,
      getReferencedColumn: (t) => t.pdfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePagesTableFilterComposer(
            $db: $db,
            $table: $db.notePages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PdfFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PdfFilesTable> {
  $$PdfFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PdfFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PdfFilesTable> {
  $$PdfFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> notePagesRefs<T extends Object>(
    Expression<T> Function($$NotePagesTableAnnotationComposer a) f,
  ) {
    final $$NotePagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notePages,
      getReferencedColumn: (t) => t.pdfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotePagesTableAnnotationComposer(
            $db: $db,
            $table: $db.notePages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PdfFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PdfFilesTable,
          PdfFile,
          $$PdfFilesTableFilterComposer,
          $$PdfFilesTableOrderingComposer,
          $$PdfFilesTableAnnotationComposer,
          $$PdfFilesTableCreateCompanionBuilder,
          $$PdfFilesTableUpdateCompanionBuilder,
          (PdfFile, $$PdfFilesTableReferences),
          PdfFile,
          PrefetchHooks Function({bool notePagesRefs})
        > {
  $$PdfFilesTableTableManager(_$AppDatabase db, $PdfFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PdfFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PdfFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PdfFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PdfFilesCompanion(
                id: id,
                name: name,
                bytes: bytes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required Uint8List bytes,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PdfFilesCompanion.insert(
                id: id,
                name: name,
                bytes: bytes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PdfFilesTable, PdfFile>(table),
                  $$PdfFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notePagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notePagesRefs) db.notePages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notePagesRefs)
                    await $_getPrefetchedDataByColumns<
                      PdfFile,
                      $PdfFilesTable,
                      NotePage,
                      $NotePagesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PdfFilesTableReferences
                          ._notePagesRefsTable(db),
                      managerFromTypedResult: (p0) => $$PdfFilesTableReferences(
                        db,
                        table,
                        p0,
                      ).notePagesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'pdf_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PdfFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PdfFilesTable,
      PdfFile,
      $$PdfFilesTableFilterComposer,
      $$PdfFilesTableOrderingComposer,
      $$PdfFilesTableAnnotationComposer,
      $$PdfFilesTableCreateCompanionBuilder,
      $$PdfFilesTableUpdateCompanionBuilder,
      (PdfFile, $$PdfFilesTableReferences),
      PdfFile,
      PrefetchHooks Function({bool notePagesRefs})
    >;
typedef $$NotePagesTableCreateCompanionBuilder = NotePagesCompanion Function({
  Value<int> id,
  required int notebookId,
  required int position,
  required PageKind kind,
  Value<PageBackground> background,
  Value<String> ink,
  Value<String> body,
  Value<double> width,
  Value<double> height,
  Value<int?> pdfId,
  Value<int?> pdfPage,
  Value<DateTime> updatedAt,
});
typedef $$NotePagesTableUpdateCompanionBuilder = NotePagesCompanion Function({
  Value<int> id,
  Value<int> notebookId,
  Value<int> position,
  Value<PageKind> kind,
  Value<PageBackground> background,
  Value<String> ink,
  Value<String> body,
  Value<double> width,
  Value<double> height,
  Value<int?> pdfId,
  Value<int?> pdfPage,
  Value<DateTime> updatedAt,
});

final class $$NotePagesTableReferences
    extends BaseReferences<_$AppDatabase, $NotePagesTable, NotePage> {
  $$NotePagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotebooksTable _notebookIdTable(_$AppDatabase db) =>
      db.notebooks.createAlias('note_pages__notebook_id__notebooks__id');

  $$NotebooksTableProcessedTableManager get notebookId {
    final $_column = $_itemColumn<int>('notebook_id')!;

    final manager = $$NotebooksTableTableManager(
      $_db,
      $_db.notebooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_notebookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PdfFilesTable _pdfIdTable(_$AppDatabase db) =>
      db.pdfFiles.createAlias('note_pages__pdf_id__pdf_files__id');

  $$PdfFilesTableProcessedTableManager? get pdfId {
    final $_column = $_itemColumn<int>('pdf_id');
    if ($_column == null) return null;
    final manager = $$PdfFilesTableTableManager(
      $_db,
      $_db.pdfFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pdfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotePagesTableFilterComposer
    extends Composer<_$AppDatabase, $NotePagesTable> {
  $$NotePagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PageKind, PageKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PageBackground, PageBackground, String>
  get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get ink => $composableBuilder(
    column: $table.ink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pdfPage => $composableBuilder(
    column: $table.pdfPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NotebooksTableFilterComposer get notebookId {
    final $$NotebooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableFilterComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableFilterComposer get pdfId {
    final $$PdfFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableFilterComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePagesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotePagesTable> {
  $$NotePagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ink => $composableBuilder(
    column: $table.ink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pdfPage => $composableBuilder(
    column: $table.pdfPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotebooksTableOrderingComposer get notebookId {
    final $$NotebooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableOrderingComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableOrderingComposer get pdfId {
    final $$PdfFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableOrderingComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotePagesTable> {
  $$NotePagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PageKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PageBackground, String> get background =>
      $composableBuilder(
        column: $table.background,
        builder: (column) => column,
      );

  GeneratedColumn<String> get ink =>
      $composableBuilder(column: $table.ink, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get pdfPage =>
      $composableBuilder(column: $table.pdfPage, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$NotebooksTableAnnotationComposer get notebookId {
    final $$NotebooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.notebookId,
      referencedTable: $db.notebooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotebooksTableAnnotationComposer(
            $db: $db,
            $table: $db.notebooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PdfFilesTableAnnotationComposer get pdfId {
    final $$PdfFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pdfId,
      referencedTable: $db.pdfFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PdfFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.pdfFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotePagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotePagesTable,
          NotePage,
          $$NotePagesTableFilterComposer,
          $$NotePagesTableOrderingComposer,
          $$NotePagesTableAnnotationComposer,
          $$NotePagesTableCreateCompanionBuilder,
          $$NotePagesTableUpdateCompanionBuilder,
          (NotePage, $$NotePagesTableReferences),
          NotePage,
          PrefetchHooks Function({bool notebookId, bool pdfId})
        > {
  $$NotePagesTableTableManager(_$AppDatabase db, $NotePagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotePagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotePagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotePagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> notebookId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<PageKind> kind = const Value.absent(),
                Value<PageBackground> background = const Value.absent(),
                Value<String> ink = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<int?> pdfId = const Value.absent(),
                Value<int?> pdfPage = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotePagesCompanion(
                id: id,
                notebookId: notebookId,
                position: position,
                kind: kind,
                background: background,
                ink: ink,
                body: body,
                width: width,
                height: height,
                pdfId: pdfId,
                pdfPage: pdfPage,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int notebookId,
                required int position,
                required PageKind kind,
                Value<PageBackground> background = const Value.absent(),
                Value<String> ink = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<int?> pdfId = const Value.absent(),
                Value<int?> pdfPage = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotePagesCompanion.insert(
                id: id,
                notebookId: notebookId,
                position: position,
                kind: kind,
                background: background,
                ink: ink,
                body: body,
                width: width,
                height: height,
                pdfId: pdfId,
                pdfPage: pdfPage,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotePagesTable, NotePage>(table),
                  $$NotePagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notebookId = false, pdfId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (notebookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.notebookId,
                        referencedTable: $$NotePagesTableReferences
                            ._notebookIdTable(db),
                        referencedColumn: $$NotePagesTableReferences
                            ._notebookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (pdfId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.pdfId,
                        referencedTable: $$NotePagesTableReferences._pdfIdTable(
                          db,
                        ),
                        referencedColumn: $$NotePagesTableReferences
                            ._pdfIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotePagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotePagesTable,
      NotePage,
      $$NotePagesTableFilterComposer,
      $$NotePagesTableOrderingComposer,
      $$NotePagesTableAnnotationComposer,
      $$NotePagesTableCreateCompanionBuilder,
      $$NotePagesTableUpdateCompanionBuilder,
      (NotePage, $$NotePagesTableReferences),
      NotePage,
      PrefetchHooks Function({bool notebookId, bool pdfId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$NotebooksTableTableManager get notebooks =>
      $$NotebooksTableTableManager(_db, _db.notebooks);
  $$PdfFilesTableTableManager get pdfFiles =>
      $$PdfFilesTableTableManager(_db, _db.pdfFiles);
  $$NotePagesTableTableManager get notePages =>
      $$NotePagesTableTableManager(_db, _db.notePages);
}
