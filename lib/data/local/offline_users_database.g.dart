// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_users_database.dart';

// ignore_for_file: type=lint
class $CachedUsersTable extends CachedUsers
    with TableInfo<$CachedUsersTable, CachedUserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailNormalizedMeta =
      const VerificationMeta('emailNormalized');
  @override
  late final GeneratedColumn<String> emailNormalized = GeneratedColumn<String>(
      'email_normalized', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courtMeta = const VerificationMeta('court');
  @override
  late final GeneratedColumn<String> court = GeneratedColumn<String>(
      'court', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactInfoMeta =
      const VerificationMeta('contactInfo');
  @override
  late final GeneratedColumn<String> contactInfo = GeneratedColumn<String>(
      'contact_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _provinceMeta =
      const VerificationMeta('province');
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
      'province', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _districtMeta =
      const VerificationMeta('district');
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
      'district', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<String> dateCreated = GeneratedColumn<String>(
      'date_created', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        emailNormalized,
        role,
        court,
        contactInfo,
        province,
        region,
        district,
        dateCreated,
        passwordHash
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_users';
  @override
  VerificationContext validateIntegrity(Insertable<CachedUserRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email_normalized')) {
      context.handle(
          _emailNormalizedMeta,
          emailNormalized.isAcceptableOrUnknown(
              data['email_normalized']!, _emailNormalizedMeta));
    } else if (isInserting) {
      context.missing(_emailNormalizedMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('court')) {
      context.handle(
          _courtMeta, court.isAcceptableOrUnknown(data['court']!, _courtMeta));
    }
    if (data.containsKey('contact_info')) {
      context.handle(
          _contactInfoMeta,
          contactInfo.isAcceptableOrUnknown(
              data['contact_info']!, _contactInfoMeta));
    }
    if (data.containsKey('province')) {
      context.handle(_provinceMeta,
          province.isAcceptableOrUnknown(data['province']!, _provinceMeta));
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    }
    if (data.containsKey('district')) {
      context.handle(_districtMeta,
          district.isAcceptableOrUnknown(data['district']!, _districtMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUserRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emailNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}email_normalized'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      court: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}court']),
      contactInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_info']),
      province: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province']),
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region']),
      district: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}district']),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_created']),
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
    );
  }

  @override
  $CachedUsersTable createAlias(String alias) {
    return $CachedUsersTable(attachedDatabase, alias);
  }
}

class CachedUserRow extends DataClass implements Insertable<CachedUserRow> {
  final String id;
  final String name;

  /// Normalized email (trim + lowercase) for lookups; unique.
  final String emailNormalized;
  final String role;
  final String? court;
  final String? contactInfo;
  final String? province;
  final String? region;
  final String? district;
  final String? dateCreated;

  /// Bcrypt modular crypt string from server — never log this field.
  final String passwordHash;
  const CachedUserRow(
      {required this.id,
      required this.name,
      required this.emailNormalized,
      required this.role,
      this.court,
      this.contactInfo,
      this.province,
      this.region,
      this.district,
      this.dateCreated,
      required this.passwordHash});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email_normalized'] = Variable<String>(emailNormalized);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || court != null) {
      map['court'] = Variable<String>(court);
    }
    if (!nullToAbsent || contactInfo != null) {
      map['contact_info'] = Variable<String>(contactInfo);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || dateCreated != null) {
      map['date_created'] = Variable<String>(dateCreated);
    }
    map['password_hash'] = Variable<String>(passwordHash);
    return map;
  }

  CachedUsersCompanion toCompanion(bool nullToAbsent) {
    return CachedUsersCompanion(
      id: Value(id),
      name: Value(name),
      emailNormalized: Value(emailNormalized),
      role: Value(role),
      court:
          court == null && nullToAbsent ? const Value.absent() : Value(court),
      contactInfo: contactInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(contactInfo),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      region:
          region == null && nullToAbsent ? const Value.absent() : Value(region),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      dateCreated: dateCreated == null && nullToAbsent
          ? const Value.absent()
          : Value(dateCreated),
      passwordHash: Value(passwordHash),
    );
  }

  factory CachedUserRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUserRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emailNormalized: serializer.fromJson<String>(json['emailNormalized']),
      role: serializer.fromJson<String>(json['role']),
      court: serializer.fromJson<String?>(json['court']),
      contactInfo: serializer.fromJson<String?>(json['contactInfo']),
      province: serializer.fromJson<String?>(json['province']),
      region: serializer.fromJson<String?>(json['region']),
      district: serializer.fromJson<String?>(json['district']),
      dateCreated: serializer.fromJson<String?>(json['dateCreated']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'emailNormalized': serializer.toJson<String>(emailNormalized),
      'role': serializer.toJson<String>(role),
      'court': serializer.toJson<String?>(court),
      'contactInfo': serializer.toJson<String?>(contactInfo),
      'province': serializer.toJson<String?>(province),
      'region': serializer.toJson<String?>(region),
      'district': serializer.toJson<String?>(district),
      'dateCreated': serializer.toJson<String?>(dateCreated),
      'passwordHash': serializer.toJson<String>(passwordHash),
    };
  }

  CachedUserRow copyWith(
          {String? id,
          String? name,
          String? emailNormalized,
          String? role,
          Value<String?> court = const Value.absent(),
          Value<String?> contactInfo = const Value.absent(),
          Value<String?> province = const Value.absent(),
          Value<String?> region = const Value.absent(),
          Value<String?> district = const Value.absent(),
          Value<String?> dateCreated = const Value.absent(),
          String? passwordHash}) =>
      CachedUserRow(
        id: id ?? this.id,
        name: name ?? this.name,
        emailNormalized: emailNormalized ?? this.emailNormalized,
        role: role ?? this.role,
        court: court.present ? court.value : this.court,
        contactInfo: contactInfo.present ? contactInfo.value : this.contactInfo,
        province: province.present ? province.value : this.province,
        region: region.present ? region.value : this.region,
        district: district.present ? district.value : this.district,
        dateCreated: dateCreated.present ? dateCreated.value : this.dateCreated,
        passwordHash: passwordHash ?? this.passwordHash,
      );
  CachedUserRow copyWithCompanion(CachedUsersCompanion data) {
    return CachedUserRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emailNormalized: data.emailNormalized.present
          ? data.emailNormalized.value
          : this.emailNormalized,
      role: data.role.present ? data.role.value : this.role,
      court: data.court.present ? data.court.value : this.court,
      contactInfo:
          data.contactInfo.present ? data.contactInfo.value : this.contactInfo,
      province: data.province.present ? data.province.value : this.province,
      region: data.region.present ? data.region.value : this.region,
      district: data.district.present ? data.district.value : this.district,
      dateCreated:
          data.dateCreated.present ? data.dateCreated.value : this.dateCreated,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUserRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emailNormalized: $emailNormalized, ')
          ..write('role: $role, ')
          ..write('court: $court, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('district: $district, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('passwordHash: $passwordHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emailNormalized, role, court,
      contactInfo, province, region, district, dateCreated, passwordHash);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUserRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.emailNormalized == this.emailNormalized &&
          other.role == this.role &&
          other.court == this.court &&
          other.contactInfo == this.contactInfo &&
          other.province == this.province &&
          other.region == this.region &&
          other.district == this.district &&
          other.dateCreated == this.dateCreated &&
          other.passwordHash == this.passwordHash);
}

class CachedUsersCompanion extends UpdateCompanion<CachedUserRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> emailNormalized;
  final Value<String> role;
  final Value<String?> court;
  final Value<String?> contactInfo;
  final Value<String?> province;
  final Value<String?> region;
  final Value<String?> district;
  final Value<String?> dateCreated;
  final Value<String> passwordHash;
  final Value<int> rowid;
  const CachedUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emailNormalized = const Value.absent(),
    this.role = const Value.absent(),
    this.court = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.province = const Value.absent(),
    this.region = const Value.absent(),
    this.district = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUsersCompanion.insert({
    required String id,
    required String name,
    required String emailNormalized,
    required String role,
    this.court = const Value.absent(),
    this.contactInfo = const Value.absent(),
    this.province = const Value.absent(),
    this.region = const Value.absent(),
    this.district = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required String passwordHash,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        emailNormalized = Value(emailNormalized),
        role = Value(role),
        passwordHash = Value(passwordHash);
  static Insertable<CachedUserRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emailNormalized,
    Expression<String>? role,
    Expression<String>? court,
    Expression<String>? contactInfo,
    Expression<String>? province,
    Expression<String>? region,
    Expression<String>? district,
    Expression<String>? dateCreated,
    Expression<String>? passwordHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emailNormalized != null) 'email_normalized': emailNormalized,
      if (role != null) 'role': role,
      if (court != null) 'court': court,
      if (contactInfo != null) 'contact_info': contactInfo,
      if (province != null) 'province': province,
      if (region != null) 'region': region,
      if (district != null) 'district': district,
      if (dateCreated != null) 'date_created': dateCreated,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? emailNormalized,
      Value<String>? role,
      Value<String?>? court,
      Value<String?>? contactInfo,
      Value<String?>? province,
      Value<String?>? region,
      Value<String?>? district,
      Value<String?>? dateCreated,
      Value<String>? passwordHash,
      Value<int>? rowid}) {
    return CachedUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emailNormalized: emailNormalized ?? this.emailNormalized,
      role: role ?? this.role,
      court: court ?? this.court,
      contactInfo: contactInfo ?? this.contactInfo,
      province: province ?? this.province,
      region: region ?? this.region,
      district: district ?? this.district,
      dateCreated: dateCreated ?? this.dateCreated,
      passwordHash: passwordHash ?? this.passwordHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emailNormalized.present) {
      map['email_normalized'] = Variable<String>(emailNormalized.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (court.present) {
      map['court'] = Variable<String>(court.value);
    }
    if (contactInfo.present) {
      map['contact_info'] = Variable<String>(contactInfo.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<String>(dateCreated.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emailNormalized: $emailNormalized, ')
          ..write('role: $role, ')
          ..write('court: $court, ')
          ..write('contactInfo: $contactInfo, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('district: $district, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMyListRecordingsTable extends CachedMyListRecordings
    with TableInfo<$CachedMyListRecordingsTable, CachedMyListRecordingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMyListRecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordingIdMeta =
      const VerificationMeta('recordingId');
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
      'recording_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listDateMillisMeta =
      const VerificationMeta('listDateMillis');
  @override
  late final GeneratedColumn<int> listDateMillis = GeneratedColumn<int>(
      'list_date_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMillisMeta =
      const VerificationMeta('syncedAtMillis');
  @override
  late final GeneratedColumn<int> syncedAtMillis = GeneratedColumn<int>(
      'synced_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [ownerUserId, recordingId, payloadJson, listDateMillis, syncedAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_my_list_recordings';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedMyListRecordingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
          _recordingIdMeta,
          recordingId.isAcceptableOrUnknown(
              data['recording_id']!, _recordingIdMeta));
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('list_date_millis')) {
      context.handle(
          _listDateMillisMeta,
          listDateMillis.isAcceptableOrUnknown(
              data['list_date_millis']!, _listDateMillisMeta));
    } else if (isInserting) {
      context.missing(_listDateMillisMeta);
    }
    if (data.containsKey('synced_at_millis')) {
      context.handle(
          _syncedAtMillisMeta,
          syncedAtMillis.isAcceptableOrUnknown(
              data['synced_at_millis']!, _syncedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_syncedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerUserId, recordingId};
  @override
  CachedMyListRecordingRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMyListRecordingRow(
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id'])!,
      recordingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recording_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      listDateMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_date_millis'])!,
      syncedAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced_at_millis'])!,
    );
  }

  @override
  $CachedMyListRecordingsTable createAlias(String alias) {
    return $CachedMyListRecordingsTable(attachedDatabase, alias);
  }
}

class CachedMyListRecordingRow extends DataClass
    implements Insertable<CachedMyListRecordingRow> {
  final String ownerUserId;
  final String recordingId;
  final String payloadJson;

  /// From API `date_stamp` / `date` for ordering and prune.
  final int listDateMillis;
  final int syncedAtMillis;
  const CachedMyListRecordingRow(
      {required this.ownerUserId,
      required this.recordingId,
      required this.payloadJson,
      required this.listDateMillis,
      required this.syncedAtMillis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['recording_id'] = Variable<String>(recordingId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['list_date_millis'] = Variable<int>(listDateMillis);
    map['synced_at_millis'] = Variable<int>(syncedAtMillis);
    return map;
  }

  CachedMyListRecordingsCompanion toCompanion(bool nullToAbsent) {
    return CachedMyListRecordingsCompanion(
      ownerUserId: Value(ownerUserId),
      recordingId: Value(recordingId),
      payloadJson: Value(payloadJson),
      listDateMillis: Value(listDateMillis),
      syncedAtMillis: Value(syncedAtMillis),
    );
  }

  factory CachedMyListRecordingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMyListRecordingRow(
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      listDateMillis: serializer.fromJson<int>(json['listDateMillis']),
      syncedAtMillis: serializer.fromJson<int>(json['syncedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'recordingId': serializer.toJson<String>(recordingId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'listDateMillis': serializer.toJson<int>(listDateMillis),
      'syncedAtMillis': serializer.toJson<int>(syncedAtMillis),
    };
  }

  CachedMyListRecordingRow copyWith(
          {String? ownerUserId,
          String? recordingId,
          String? payloadJson,
          int? listDateMillis,
          int? syncedAtMillis}) =>
      CachedMyListRecordingRow(
        ownerUserId: ownerUserId ?? this.ownerUserId,
        recordingId: recordingId ?? this.recordingId,
        payloadJson: payloadJson ?? this.payloadJson,
        listDateMillis: listDateMillis ?? this.listDateMillis,
        syncedAtMillis: syncedAtMillis ?? this.syncedAtMillis,
      );
  CachedMyListRecordingRow copyWithCompanion(
      CachedMyListRecordingsCompanion data) {
    return CachedMyListRecordingRow(
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      recordingId:
          data.recordingId.present ? data.recordingId.value : this.recordingId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      listDateMillis: data.listDateMillis.present
          ? data.listDateMillis.value
          : this.listDateMillis,
      syncedAtMillis: data.syncedAtMillis.present
          ? data.syncedAtMillis.value
          : this.syncedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMyListRecordingRow(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('listDateMillis: $listDateMillis, ')
          ..write('syncedAtMillis: $syncedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      ownerUserId, recordingId, payloadJson, listDateMillis, syncedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMyListRecordingRow &&
          other.ownerUserId == this.ownerUserId &&
          other.recordingId == this.recordingId &&
          other.payloadJson == this.payloadJson &&
          other.listDateMillis == this.listDateMillis &&
          other.syncedAtMillis == this.syncedAtMillis);
}

class CachedMyListRecordingsCompanion
    extends UpdateCompanion<CachedMyListRecordingRow> {
  final Value<String> ownerUserId;
  final Value<String> recordingId;
  final Value<String> payloadJson;
  final Value<int> listDateMillis;
  final Value<int> syncedAtMillis;
  final Value<int> rowid;
  const CachedMyListRecordingsCompanion({
    this.ownerUserId = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.listDateMillis = const Value.absent(),
    this.syncedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMyListRecordingsCompanion.insert({
    required String ownerUserId,
    required String recordingId,
    required String payloadJson,
    required int listDateMillis,
    required int syncedAtMillis,
    this.rowid = const Value.absent(),
  })  : ownerUserId = Value(ownerUserId),
        recordingId = Value(recordingId),
        payloadJson = Value(payloadJson),
        listDateMillis = Value(listDateMillis),
        syncedAtMillis = Value(syncedAtMillis);
  static Insertable<CachedMyListRecordingRow> custom({
    Expression<String>? ownerUserId,
    Expression<String>? recordingId,
    Expression<String>? payloadJson,
    Expression<int>? listDateMillis,
    Expression<int>? syncedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (recordingId != null) 'recording_id': recordingId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (listDateMillis != null) 'list_date_millis': listDateMillis,
      if (syncedAtMillis != null) 'synced_at_millis': syncedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMyListRecordingsCompanion copyWith(
      {Value<String>? ownerUserId,
      Value<String>? recordingId,
      Value<String>? payloadJson,
      Value<int>? listDateMillis,
      Value<int>? syncedAtMillis,
      Value<int>? rowid}) {
    return CachedMyListRecordingsCompanion(
      ownerUserId: ownerUserId ?? this.ownerUserId,
      recordingId: recordingId ?? this.recordingId,
      payloadJson: payloadJson ?? this.payloadJson,
      listDateMillis: listDateMillis ?? this.listDateMillis,
      syncedAtMillis: syncedAtMillis ?? this.syncedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (listDateMillis.present) {
      map['list_date_millis'] = Variable<int>(listDateMillis.value);
    }
    if (syncedAtMillis.present) {
      map['synced_at_millis'] = Variable<int>(syncedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMyListRecordingsCompanion(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('listDateMillis: $listDateMillis, ')
          ..write('syncedAtMillis: $syncedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecordingAudiosTable extends CachedRecordingAudios
    with TableInfo<$CachedRecordingAudiosTable, CachedRecordingAudioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecordingAudiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordingIdMeta =
      const VerificationMeta('recordingId');
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
      'recording_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
      'bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _downloadedAtMillisMeta =
      const VerificationMeta('downloadedAtMillis');
  @override
  late final GeneratedColumn<int> downloadedAtMillis = GeneratedColumn<int>(
      'downloaded_at_millis', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        ownerUserId,
        recordingId,
        audioPath,
        localPath,
        status,
        bytes,
        downloadedAtMillis,
        error
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recording_audios';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedRecordingAudioRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
          _recordingIdMeta,
          recordingId.isAcceptableOrUnknown(
              data['recording_id']!, _recordingIdMeta));
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
          _bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    }
    if (data.containsKey('downloaded_at_millis')) {
      context.handle(
          _downloadedAtMillisMeta,
          downloadedAtMillis.isAcceptableOrUnknown(
              data['downloaded_at_millis']!, _downloadedAtMillisMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerUserId, recordingId};
  @override
  CachedRecordingAudioRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecordingAudioRow(
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id'])!,
      recordingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recording_id'])!,
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      bytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes']),
      downloadedAtMillis: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}downloaded_at_millis']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
    );
  }

  @override
  $CachedRecordingAudiosTable createAlias(String alias) {
    return $CachedRecordingAudiosTable(attachedDatabase, alias);
  }
}

class CachedRecordingAudioRow extends DataClass
    implements Insertable<CachedRecordingAudioRow> {
  final String ownerUserId;
  final String recordingId;
  final String audioPath;
  final String? localPath;

  /// queued|downloading|downloaded|failed
  final String status;
  final int? bytes;
  final int? downloadedAtMillis;
  final String? error;
  const CachedRecordingAudioRow(
      {required this.ownerUserId,
      required this.recordingId,
      required this.audioPath,
      this.localPath,
      required this.status,
      this.bytes,
      this.downloadedAtMillis,
      this.error});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['recording_id'] = Variable<String>(recordingId);
    map['audio_path'] = Variable<String>(audioPath);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || bytes != null) {
      map['bytes'] = Variable<int>(bytes);
    }
    if (!nullToAbsent || downloadedAtMillis != null) {
      map['downloaded_at_millis'] = Variable<int>(downloadedAtMillis);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    return map;
  }

  CachedRecordingAudiosCompanion toCompanion(bool nullToAbsent) {
    return CachedRecordingAudiosCompanion(
      ownerUserId: Value(ownerUserId),
      recordingId: Value(recordingId),
      audioPath: Value(audioPath),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      status: Value(status),
      bytes:
          bytes == null && nullToAbsent ? const Value.absent() : Value(bytes),
      downloadedAtMillis: downloadedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAtMillis),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
    );
  }

  factory CachedRecordingAudioRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecordingAudioRow(
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      status: serializer.fromJson<String>(json['status']),
      bytes: serializer.fromJson<int?>(json['bytes']),
      downloadedAtMillis: serializer.fromJson<int?>(json['downloadedAtMillis']),
      error: serializer.fromJson<String?>(json['error']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'recordingId': serializer.toJson<String>(recordingId),
      'audioPath': serializer.toJson<String>(audioPath),
      'localPath': serializer.toJson<String?>(localPath),
      'status': serializer.toJson<String>(status),
      'bytes': serializer.toJson<int?>(bytes),
      'downloadedAtMillis': serializer.toJson<int?>(downloadedAtMillis),
      'error': serializer.toJson<String?>(error),
    };
  }

  CachedRecordingAudioRow copyWith(
          {String? ownerUserId,
          String? recordingId,
          String? audioPath,
          Value<String?> localPath = const Value.absent(),
          String? status,
          Value<int?> bytes = const Value.absent(),
          Value<int?> downloadedAtMillis = const Value.absent(),
          Value<String?> error = const Value.absent()}) =>
      CachedRecordingAudioRow(
        ownerUserId: ownerUserId ?? this.ownerUserId,
        recordingId: recordingId ?? this.recordingId,
        audioPath: audioPath ?? this.audioPath,
        localPath: localPath.present ? localPath.value : this.localPath,
        status: status ?? this.status,
        bytes: bytes.present ? bytes.value : this.bytes,
        downloadedAtMillis: downloadedAtMillis.present
            ? downloadedAtMillis.value
            : this.downloadedAtMillis,
        error: error.present ? error.value : this.error,
      );
  CachedRecordingAudioRow copyWithCompanion(
      CachedRecordingAudiosCompanion data) {
    return CachedRecordingAudioRow(
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      recordingId:
          data.recordingId.present ? data.recordingId.value : this.recordingId,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      status: data.status.present ? data.status.value : this.status,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      downloadedAtMillis: data.downloadedAtMillis.present
          ? data.downloadedAtMillis.value
          : this.downloadedAtMillis,
      error: data.error.present ? data.error.value : this.error,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecordingAudioRow(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('audioPath: $audioPath, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAtMillis: $downloadedAtMillis, ')
          ..write('error: $error')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerUserId, recordingId, audioPath,
      localPath, status, bytes, downloadedAtMillis, error);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecordingAudioRow &&
          other.ownerUserId == this.ownerUserId &&
          other.recordingId == this.recordingId &&
          other.audioPath == this.audioPath &&
          other.localPath == this.localPath &&
          other.status == this.status &&
          other.bytes == this.bytes &&
          other.downloadedAtMillis == this.downloadedAtMillis &&
          other.error == this.error);
}

class CachedRecordingAudiosCompanion
    extends UpdateCompanion<CachedRecordingAudioRow> {
  final Value<String> ownerUserId;
  final Value<String> recordingId;
  final Value<String> audioPath;
  final Value<String?> localPath;
  final Value<String> status;
  final Value<int?> bytes;
  final Value<int?> downloadedAtMillis;
  final Value<String?> error;
  final Value<int> rowid;
  const CachedRecordingAudiosCompanion({
    this.ownerUserId = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.localPath = const Value.absent(),
    this.status = const Value.absent(),
    this.bytes = const Value.absent(),
    this.downloadedAtMillis = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecordingAudiosCompanion.insert({
    required String ownerUserId,
    required String recordingId,
    required String audioPath,
    this.localPath = const Value.absent(),
    required String status,
    this.bytes = const Value.absent(),
    this.downloadedAtMillis = const Value.absent(),
    this.error = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : ownerUserId = Value(ownerUserId),
        recordingId = Value(recordingId),
        audioPath = Value(audioPath),
        status = Value(status);
  static Insertable<CachedRecordingAudioRow> custom({
    Expression<String>? ownerUserId,
    Expression<String>? recordingId,
    Expression<String>? audioPath,
    Expression<String>? localPath,
    Expression<String>? status,
    Expression<int>? bytes,
    Expression<int>? downloadedAtMillis,
    Expression<String>? error,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (recordingId != null) 'recording_id': recordingId,
      if (audioPath != null) 'audio_path': audioPath,
      if (localPath != null) 'local_path': localPath,
      if (status != null) 'status': status,
      if (bytes != null) 'bytes': bytes,
      if (downloadedAtMillis != null)
        'downloaded_at_millis': downloadedAtMillis,
      if (error != null) 'error': error,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecordingAudiosCompanion copyWith(
      {Value<String>? ownerUserId,
      Value<String>? recordingId,
      Value<String>? audioPath,
      Value<String?>? localPath,
      Value<String>? status,
      Value<int?>? bytes,
      Value<int?>? downloadedAtMillis,
      Value<String?>? error,
      Value<int>? rowid}) {
    return CachedRecordingAudiosCompanion(
      ownerUserId: ownerUserId ?? this.ownerUserId,
      recordingId: recordingId ?? this.recordingId,
      audioPath: audioPath ?? this.audioPath,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      bytes: bytes ?? this.bytes,
      downloadedAtMillis: downloadedAtMillis ?? this.downloadedAtMillis,
      error: error ?? this.error,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (downloadedAtMillis.present) {
      map['downloaded_at_millis'] = Variable<int>(downloadedAtMillis.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecordingAudiosCompanion(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('audioPath: $audioPath, ')
          ..write('localPath: $localPath, ')
          ..write('status: $status, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAtMillis: $downloadedAtMillis, ')
          ..write('error: $error, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRecordingTranscriptsTable extends CachedRecordingTranscripts
    with
        TableInfo<$CachedRecordingTranscriptsTable,
            CachedRecordingTranscriptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRecordingTranscriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordingIdMeta =
      const VerificationMeta('recordingId');
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
      'recording_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _htmlMeta = const VerificationMeta('html');
  @override
  late final GeneratedColumn<String> html = GeneratedColumn<String>(
      'html', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMillisMeta =
      const VerificationMeta('updatedAtMillis');
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
      'updated_at_millis', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [ownerUserId, recordingId, html, updatedAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_recording_transcripts';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedRecordingTranscriptRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
          _recordingIdMeta,
          recordingId.isAcceptableOrUnknown(
              data['recording_id']!, _recordingIdMeta));
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('html')) {
      context.handle(
          _htmlMeta, html.isAcceptableOrUnknown(data['html']!, _htmlMeta));
    } else if (isInserting) {
      context.missing(_htmlMeta);
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
          _updatedAtMillisMeta,
          updatedAtMillis.isAcceptableOrUnknown(
              data['updated_at_millis']!, _updatedAtMillisMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerUserId, recordingId};
  @override
  CachedRecordingTranscriptRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRecordingTranscriptRow(
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id'])!,
      recordingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recording_id'])!,
      html: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html'])!,
      updatedAtMillis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at_millis'])!,
    );
  }

  @override
  $CachedRecordingTranscriptsTable createAlias(String alias) {
    return $CachedRecordingTranscriptsTable(attachedDatabase, alias);
  }
}

class CachedRecordingTranscriptRow extends DataClass
    implements Insertable<CachedRecordingTranscriptRow> {
  final String ownerUserId;
  final String recordingId;
  final String html;
  final int updatedAtMillis;
  const CachedRecordingTranscriptRow(
      {required this.ownerUserId,
      required this.recordingId,
      required this.html,
      required this.updatedAtMillis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['recording_id'] = Variable<String>(recordingId);
    map['html'] = Variable<String>(html);
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  CachedRecordingTranscriptsCompanion toCompanion(bool nullToAbsent) {
    return CachedRecordingTranscriptsCompanion(
      ownerUserId: Value(ownerUserId),
      recordingId: Value(recordingId),
      html: Value(html),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory CachedRecordingTranscriptRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRecordingTranscriptRow(
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      html: serializer.fromJson<String>(json['html']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'recordingId': serializer.toJson<String>(recordingId),
      'html': serializer.toJson<String>(html),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  CachedRecordingTranscriptRow copyWith(
          {String? ownerUserId,
          String? recordingId,
          String? html,
          int? updatedAtMillis}) =>
      CachedRecordingTranscriptRow(
        ownerUserId: ownerUserId ?? this.ownerUserId,
        recordingId: recordingId ?? this.recordingId,
        html: html ?? this.html,
        updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      );
  CachedRecordingTranscriptRow copyWithCompanion(
      CachedRecordingTranscriptsCompanion data) {
    return CachedRecordingTranscriptRow(
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      recordingId:
          data.recordingId.present ? data.recordingId.value : this.recordingId,
      html: data.html.present ? data.html.value : this.html,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecordingTranscriptRow(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('html: $html, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ownerUserId, recordingId, html, updatedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRecordingTranscriptRow &&
          other.ownerUserId == this.ownerUserId &&
          other.recordingId == this.recordingId &&
          other.html == this.html &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class CachedRecordingTranscriptsCompanion
    extends UpdateCompanion<CachedRecordingTranscriptRow> {
  final Value<String> ownerUserId;
  final Value<String> recordingId;
  final Value<String> html;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const CachedRecordingTranscriptsCompanion({
    this.ownerUserId = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.html = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRecordingTranscriptsCompanion.insert({
    required String ownerUserId,
    required String recordingId,
    required String html,
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  })  : ownerUserId = Value(ownerUserId),
        recordingId = Value(recordingId),
        html = Value(html),
        updatedAtMillis = Value(updatedAtMillis);
  static Insertable<CachedRecordingTranscriptRow> custom({
    Expression<String>? ownerUserId,
    Expression<String>? recordingId,
    Expression<String>? html,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (recordingId != null) 'recording_id': recordingId,
      if (html != null) 'html': html,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRecordingTranscriptsCompanion copyWith(
      {Value<String>? ownerUserId,
      Value<String>? recordingId,
      Value<String>? html,
      Value<int>? updatedAtMillis,
      Value<int>? rowid}) {
    return CachedRecordingTranscriptsCompanion(
      ownerUserId: ownerUserId ?? this.ownerUserId,
      recordingId: recordingId ?? this.recordingId,
      html: html ?? this.html,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (html.present) {
      map['html'] = Variable<String>(html.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRecordingTranscriptsCompanion(')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('recordingId: $recordingId, ')
          ..write('html: $html, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineUsersDatabase extends GeneratedDatabase {
  _$OfflineUsersDatabase(QueryExecutor e) : super(e);
  $OfflineUsersDatabaseManager get managers =>
      $OfflineUsersDatabaseManager(this);
  late final $CachedUsersTable cachedUsers = $CachedUsersTable(this);
  late final $CachedMyListRecordingsTable cachedMyListRecordings =
      $CachedMyListRecordingsTable(this);
  late final $CachedRecordingAudiosTable cachedRecordingAudios =
      $CachedRecordingAudiosTable(this);
  late final $CachedRecordingTranscriptsTable cachedRecordingTranscripts =
      $CachedRecordingTranscriptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedUsers,
        cachedMyListRecordings,
        cachedRecordingAudios,
        cachedRecordingTranscripts
      ];
}

typedef $$CachedUsersTableCreateCompanionBuilder = CachedUsersCompanion
    Function({
  required String id,
  required String name,
  required String emailNormalized,
  required String role,
  Value<String?> court,
  Value<String?> contactInfo,
  Value<String?> province,
  Value<String?> region,
  Value<String?> district,
  Value<String?> dateCreated,
  required String passwordHash,
  Value<int> rowid,
});
typedef $$CachedUsersTableUpdateCompanionBuilder = CachedUsersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> emailNormalized,
  Value<String> role,
  Value<String?> court,
  Value<String?> contactInfo,
  Value<String?> province,
  Value<String?> region,
  Value<String?> district,
  Value<String?> dateCreated,
  Value<String> passwordHash,
  Value<int> rowid,
});

class $$CachedUsersTableFilterComposer
    extends Composer<_$OfflineUsersDatabase, $CachedUsersTable> {
  $$CachedUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get court => $composableBuilder(
      column: $table.court, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactInfo => $composableBuilder(
      column: $table.contactInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));
}

class $$CachedUsersTableOrderingComposer
    extends Composer<_$OfflineUsersDatabase, $CachedUsersTable> {
  $$CachedUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get court => $composableBuilder(
      column: $table.court, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactInfo => $composableBuilder(
      column: $table.contactInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedUsersTableAnnotationComposer
    extends Composer<_$OfflineUsersDatabase, $CachedUsersTable> {
  $$CachedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emailNormalized => $composableBuilder(
      column: $table.emailNormalized, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get court =>
      $composableBuilder(column: $table.court, builder: (column) => column);

  GeneratedColumn<String> get contactInfo => $composableBuilder(
      column: $table.contactInfo, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get dateCreated => $composableBuilder(
      column: $table.dateCreated, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);
}

class $$CachedUsersTableTableManager extends RootTableManager<
    _$OfflineUsersDatabase,
    $CachedUsersTable,
    CachedUserRow,
    $$CachedUsersTableFilterComposer,
    $$CachedUsersTableOrderingComposer,
    $$CachedUsersTableAnnotationComposer,
    $$CachedUsersTableCreateCompanionBuilder,
    $$CachedUsersTableUpdateCompanionBuilder,
    (
      CachedUserRow,
      BaseReferences<_$OfflineUsersDatabase, $CachedUsersTable, CachedUserRow>
    ),
    CachedUserRow,
    PrefetchHooks Function()> {
  $$CachedUsersTableTableManager(
      _$OfflineUsersDatabase db, $CachedUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emailNormalized = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> court = const Value.absent(),
            Value<String?> contactInfo = const Value.absent(),
            Value<String?> province = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> district = const Value.absent(),
            Value<String?> dateCreated = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUsersCompanion(
            id: id,
            name: name,
            emailNormalized: emailNormalized,
            role: role,
            court: court,
            contactInfo: contactInfo,
            province: province,
            region: region,
            district: district,
            dateCreated: dateCreated,
            passwordHash: passwordHash,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String emailNormalized,
            required String role,
            Value<String?> court = const Value.absent(),
            Value<String?> contactInfo = const Value.absent(),
            Value<String?> province = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> district = const Value.absent(),
            Value<String?> dateCreated = const Value.absent(),
            required String passwordHash,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUsersCompanion.insert(
            id: id,
            name: name,
            emailNormalized: emailNormalized,
            role: role,
            court: court,
            contactInfo: contactInfo,
            province: province,
            region: region,
            district: district,
            dateCreated: dateCreated,
            passwordHash: passwordHash,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedUsersTableProcessedTableManager = ProcessedTableManager<
    _$OfflineUsersDatabase,
    $CachedUsersTable,
    CachedUserRow,
    $$CachedUsersTableFilterComposer,
    $$CachedUsersTableOrderingComposer,
    $$CachedUsersTableAnnotationComposer,
    $$CachedUsersTableCreateCompanionBuilder,
    $$CachedUsersTableUpdateCompanionBuilder,
    (
      CachedUserRow,
      BaseReferences<_$OfflineUsersDatabase, $CachedUsersTable, CachedUserRow>
    ),
    CachedUserRow,
    PrefetchHooks Function()>;
typedef $$CachedMyListRecordingsTableCreateCompanionBuilder
    = CachedMyListRecordingsCompanion Function({
  required String ownerUserId,
  required String recordingId,
  required String payloadJson,
  required int listDateMillis,
  required int syncedAtMillis,
  Value<int> rowid,
});
typedef $$CachedMyListRecordingsTableUpdateCompanionBuilder
    = CachedMyListRecordingsCompanion Function({
  Value<String> ownerUserId,
  Value<String> recordingId,
  Value<String> payloadJson,
  Value<int> listDateMillis,
  Value<int> syncedAtMillis,
  Value<int> rowid,
});

class $$CachedMyListRecordingsTableFilterComposer
    extends Composer<_$OfflineUsersDatabase, $CachedMyListRecordingsTable> {
  $$CachedMyListRecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get listDateMillis => $composableBuilder(
      column: $table.listDateMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncedAtMillis => $composableBuilder(
      column: $table.syncedAtMillis,
      builder: (column) => ColumnFilters(column));
}

class $$CachedMyListRecordingsTableOrderingComposer
    extends Composer<_$OfflineUsersDatabase, $CachedMyListRecordingsTable> {
  $$CachedMyListRecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get listDateMillis => $composableBuilder(
      column: $table.listDateMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncedAtMillis => $composableBuilder(
      column: $table.syncedAtMillis,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedMyListRecordingsTableAnnotationComposer
    extends Composer<_$OfflineUsersDatabase, $CachedMyListRecordingsTable> {
  $$CachedMyListRecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<int> get listDateMillis => $composableBuilder(
      column: $table.listDateMillis, builder: (column) => column);

  GeneratedColumn<int> get syncedAtMillis => $composableBuilder(
      column: $table.syncedAtMillis, builder: (column) => column);
}

class $$CachedMyListRecordingsTableTableManager extends RootTableManager<
    _$OfflineUsersDatabase,
    $CachedMyListRecordingsTable,
    CachedMyListRecordingRow,
    $$CachedMyListRecordingsTableFilterComposer,
    $$CachedMyListRecordingsTableOrderingComposer,
    $$CachedMyListRecordingsTableAnnotationComposer,
    $$CachedMyListRecordingsTableCreateCompanionBuilder,
    $$CachedMyListRecordingsTableUpdateCompanionBuilder,
    (
      CachedMyListRecordingRow,
      BaseReferences<_$OfflineUsersDatabase, $CachedMyListRecordingsTable,
          CachedMyListRecordingRow>
    ),
    CachedMyListRecordingRow,
    PrefetchHooks Function()> {
  $$CachedMyListRecordingsTableTableManager(
      _$OfflineUsersDatabase db, $CachedMyListRecordingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMyListRecordingsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMyListRecordingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMyListRecordingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ownerUserId = const Value.absent(),
            Value<String> recordingId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<int> listDateMillis = const Value.absent(),
            Value<int> syncedAtMillis = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMyListRecordingsCompanion(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            payloadJson: payloadJson,
            listDateMillis: listDateMillis,
            syncedAtMillis: syncedAtMillis,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ownerUserId,
            required String recordingId,
            required String payloadJson,
            required int listDateMillis,
            required int syncedAtMillis,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMyListRecordingsCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            payloadJson: payloadJson,
            listDateMillis: listDateMillis,
            syncedAtMillis: syncedAtMillis,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedMyListRecordingsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineUsersDatabase,
        $CachedMyListRecordingsTable,
        CachedMyListRecordingRow,
        $$CachedMyListRecordingsTableFilterComposer,
        $$CachedMyListRecordingsTableOrderingComposer,
        $$CachedMyListRecordingsTableAnnotationComposer,
        $$CachedMyListRecordingsTableCreateCompanionBuilder,
        $$CachedMyListRecordingsTableUpdateCompanionBuilder,
        (
          CachedMyListRecordingRow,
          BaseReferences<_$OfflineUsersDatabase, $CachedMyListRecordingsTable,
              CachedMyListRecordingRow>
        ),
        CachedMyListRecordingRow,
        PrefetchHooks Function()>;
typedef $$CachedRecordingAudiosTableCreateCompanionBuilder
    = CachedRecordingAudiosCompanion Function({
  required String ownerUserId,
  required String recordingId,
  required String audioPath,
  Value<String?> localPath,
  required String status,
  Value<int?> bytes,
  Value<int?> downloadedAtMillis,
  Value<String?> error,
  Value<int> rowid,
});
typedef $$CachedRecordingAudiosTableUpdateCompanionBuilder
    = CachedRecordingAudiosCompanion Function({
  Value<String> ownerUserId,
  Value<String> recordingId,
  Value<String> audioPath,
  Value<String?> localPath,
  Value<String> status,
  Value<int?> bytes,
  Value<int?> downloadedAtMillis,
  Value<String?> error,
  Value<int> rowid,
});

class $$CachedRecordingAudiosTableFilterComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingAudiosTable> {
  $$CachedRecordingAudiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downloadedAtMillis => $composableBuilder(
      column: $table.downloadedAtMillis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));
}

class $$CachedRecordingAudiosTableOrderingComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingAudiosTable> {
  $$CachedRecordingAudiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytes => $composableBuilder(
      column: $table.bytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedAtMillis => $composableBuilder(
      column: $table.downloadedAtMillis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));
}

class $$CachedRecordingAudiosTableAnnotationComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingAudiosTable> {
  $$CachedRecordingAudiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get downloadedAtMillis => $composableBuilder(
      column: $table.downloadedAtMillis, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);
}

class $$CachedRecordingAudiosTableTableManager extends RootTableManager<
    _$OfflineUsersDatabase,
    $CachedRecordingAudiosTable,
    CachedRecordingAudioRow,
    $$CachedRecordingAudiosTableFilterComposer,
    $$CachedRecordingAudiosTableOrderingComposer,
    $$CachedRecordingAudiosTableAnnotationComposer,
    $$CachedRecordingAudiosTableCreateCompanionBuilder,
    $$CachedRecordingAudiosTableUpdateCompanionBuilder,
    (
      CachedRecordingAudioRow,
      BaseReferences<_$OfflineUsersDatabase, $CachedRecordingAudiosTable,
          CachedRecordingAudioRow>
    ),
    CachedRecordingAudioRow,
    PrefetchHooks Function()> {
  $$CachedRecordingAudiosTableTableManager(
      _$OfflineUsersDatabase db, $CachedRecordingAudiosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecordingAudiosTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecordingAudiosTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecordingAudiosTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ownerUserId = const Value.absent(),
            Value<String> recordingId = const Value.absent(),
            Value<String> audioPath = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> bytes = const Value.absent(),
            Value<int?> downloadedAtMillis = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecordingAudiosCompanion(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            audioPath: audioPath,
            localPath: localPath,
            status: status,
            bytes: bytes,
            downloadedAtMillis: downloadedAtMillis,
            error: error,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ownerUserId,
            required String recordingId,
            required String audioPath,
            Value<String?> localPath = const Value.absent(),
            required String status,
            Value<int?> bytes = const Value.absent(),
            Value<int?> downloadedAtMillis = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecordingAudiosCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            audioPath: audioPath,
            localPath: localPath,
            status: status,
            bytes: bytes,
            downloadedAtMillis: downloadedAtMillis,
            error: error,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecordingAudiosTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineUsersDatabase,
        $CachedRecordingAudiosTable,
        CachedRecordingAudioRow,
        $$CachedRecordingAudiosTableFilterComposer,
        $$CachedRecordingAudiosTableOrderingComposer,
        $$CachedRecordingAudiosTableAnnotationComposer,
        $$CachedRecordingAudiosTableCreateCompanionBuilder,
        $$CachedRecordingAudiosTableUpdateCompanionBuilder,
        (
          CachedRecordingAudioRow,
          BaseReferences<_$OfflineUsersDatabase, $CachedRecordingAudiosTable,
              CachedRecordingAudioRow>
        ),
        CachedRecordingAudioRow,
        PrefetchHooks Function()>;
typedef $$CachedRecordingTranscriptsTableCreateCompanionBuilder
    = CachedRecordingTranscriptsCompanion Function({
  required String ownerUserId,
  required String recordingId,
  required String html,
  required int updatedAtMillis,
  Value<int> rowid,
});
typedef $$CachedRecordingTranscriptsTableUpdateCompanionBuilder
    = CachedRecordingTranscriptsCompanion Function({
  Value<String> ownerUserId,
  Value<String> recordingId,
  Value<String> html,
  Value<int> updatedAtMillis,
  Value<int> rowid,
});

class $$CachedRecordingTranscriptsTableFilterComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingTranscriptsTable> {
  $$CachedRecordingTranscriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get html => $composableBuilder(
      column: $table.html, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnFilters(column));
}

class $$CachedRecordingTranscriptsTableOrderingComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingTranscriptsTable> {
  $$CachedRecordingTranscriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get html => $composableBuilder(
      column: $table.html, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedRecordingTranscriptsTableAnnotationComposer
    extends Composer<_$OfflineUsersDatabase, $CachedRecordingTranscriptsTable> {
  $$CachedRecordingTranscriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get recordingId => $composableBuilder(
      column: $table.recordingId, builder: (column) => column);

  GeneratedColumn<String> get html =>
      $composableBuilder(column: $table.html, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
      column: $table.updatedAtMillis, builder: (column) => column);
}

class $$CachedRecordingTranscriptsTableTableManager extends RootTableManager<
    _$OfflineUsersDatabase,
    $CachedRecordingTranscriptsTable,
    CachedRecordingTranscriptRow,
    $$CachedRecordingTranscriptsTableFilterComposer,
    $$CachedRecordingTranscriptsTableOrderingComposer,
    $$CachedRecordingTranscriptsTableAnnotationComposer,
    $$CachedRecordingTranscriptsTableCreateCompanionBuilder,
    $$CachedRecordingTranscriptsTableUpdateCompanionBuilder,
    (
      CachedRecordingTranscriptRow,
      BaseReferences<_$OfflineUsersDatabase, $CachedRecordingTranscriptsTable,
          CachedRecordingTranscriptRow>
    ),
    CachedRecordingTranscriptRow,
    PrefetchHooks Function()> {
  $$CachedRecordingTranscriptsTableTableManager(
      _$OfflineUsersDatabase db, $CachedRecordingTranscriptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRecordingTranscriptsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRecordingTranscriptsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRecordingTranscriptsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ownerUserId = const Value.absent(),
            Value<String> recordingId = const Value.absent(),
            Value<String> html = const Value.absent(),
            Value<int> updatedAtMillis = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecordingTranscriptsCompanion(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            html: html,
            updatedAtMillis: updatedAtMillis,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ownerUserId,
            required String recordingId,
            required String html,
            required int updatedAtMillis,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRecordingTranscriptsCompanion.insert(
            ownerUserId: ownerUserId,
            recordingId: recordingId,
            html: html,
            updatedAtMillis: updatedAtMillis,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRecordingTranscriptsTableProcessedTableManager
    = ProcessedTableManager<
        _$OfflineUsersDatabase,
        $CachedRecordingTranscriptsTable,
        CachedRecordingTranscriptRow,
        $$CachedRecordingTranscriptsTableFilterComposer,
        $$CachedRecordingTranscriptsTableOrderingComposer,
        $$CachedRecordingTranscriptsTableAnnotationComposer,
        $$CachedRecordingTranscriptsTableCreateCompanionBuilder,
        $$CachedRecordingTranscriptsTableUpdateCompanionBuilder,
        (
          CachedRecordingTranscriptRow,
          BaseReferences<_$OfflineUsersDatabase,
              $CachedRecordingTranscriptsTable, CachedRecordingTranscriptRow>
        ),
        CachedRecordingTranscriptRow,
        PrefetchHooks Function()>;

class $OfflineUsersDatabaseManager {
  final _$OfflineUsersDatabase _db;
  $OfflineUsersDatabaseManager(this._db);
  $$CachedUsersTableTableManager get cachedUsers =>
      $$CachedUsersTableTableManager(_db, _db.cachedUsers);
  $$CachedMyListRecordingsTableTableManager get cachedMyListRecordings =>
      $$CachedMyListRecordingsTableTableManager(
          _db, _db.cachedMyListRecordings);
  $$CachedRecordingAudiosTableTableManager get cachedRecordingAudios =>
      $$CachedRecordingAudiosTableTableManager(_db, _db.cachedRecordingAudios);
  $$CachedRecordingTranscriptsTableTableManager
      get cachedRecordingTranscripts =>
          $$CachedRecordingTranscriptsTableTableManager(
              _db, _db.cachedRecordingTranscripts);
}
