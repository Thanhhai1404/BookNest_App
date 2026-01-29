// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _monthlyFeeMeta =
      const VerificationMeta('monthlyFee');
  @override
  late final GeneratedColumn<int> monthlyFee = GeneratedColumn<int>(
      'monthly_fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _depositMeta =
      const VerificationMeta('deposit');
  @override
  late final GeneratedColumn<int> deposit = GeneratedColumn<int>(
      'deposit', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxBooksMeta =
      const VerificationMeta('maxBooks');
  @override
  late final GeneratedColumn<int> maxBooks = GeneratedColumn<int>(
      'max_books', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxDaysMeta =
      const VerificationMeta('maxDays');
  @override
  late final GeneratedColumn<int> maxDays = GeneratedColumn<int>(
      'max_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _allowReservationMeta =
      const VerificationMeta('allowReservation');
  @override
  late final GeneratedColumn<bool> allowReservation = GeneratedColumn<bool>(
      'allow_reservation', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_reservation" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _allowRenewalMeta =
      const VerificationMeta('allowRenewal');
  @override
  late final GeneratedColumn<bool> allowRenewal = GeneratedColumn<bool>(
      'allow_renewal', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_renewal" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        monthlyFee,
        deposit,
        maxBooks,
        maxDays,
        description,
        allowReservation,
        allowRenewal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(Insertable<Subscription> instance,
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
    }
    if (data.containsKey('monthly_fee')) {
      context.handle(
          _monthlyFeeMeta,
          monthlyFee.isAcceptableOrUnknown(
              data['monthly_fee']!, _monthlyFeeMeta));
    }
    if (data.containsKey('deposit')) {
      context.handle(_depositMeta,
          deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta));
    }
    if (data.containsKey('max_books')) {
      context.handle(_maxBooksMeta,
          maxBooks.isAcceptableOrUnknown(data['max_books']!, _maxBooksMeta));
    }
    if (data.containsKey('max_days')) {
      context.handle(_maxDaysMeta,
          maxDays.isAcceptableOrUnknown(data['max_days']!, _maxDaysMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('allow_reservation')) {
      context.handle(
          _allowReservationMeta,
          allowReservation.isAcceptableOrUnknown(
              data['allow_reservation']!, _allowReservationMeta));
    }
    if (data.containsKey('allow_renewal')) {
      context.handle(
          _allowRenewalMeta,
          allowRenewal.isAcceptableOrUnknown(
              data['allow_renewal']!, _allowRenewalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      monthlyFee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_fee']),
      deposit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deposit']),
      maxBooks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_books']),
      maxDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_days']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      allowReservation: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}allow_reservation'])!,
      allowRenewal: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}allow_renewal'])!,
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final String id;
  final String? name;

  /// Monthly fee in VND.
  final int? monthlyFee;

  /// Deposit in VND.
  final int? deposit;
  final int? maxBooks;
  final int? maxDays;
  final String? description;
  final bool allowReservation;
  final bool allowRenewal;
  const Subscription(
      {required this.id,
      this.name,
      this.monthlyFee,
      this.deposit,
      this.maxBooks,
      this.maxDays,
      this.description,
      required this.allowReservation,
      required this.allowRenewal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || monthlyFee != null) {
      map['monthly_fee'] = Variable<int>(monthlyFee);
    }
    if (!nullToAbsent || deposit != null) {
      map['deposit'] = Variable<int>(deposit);
    }
    if (!nullToAbsent || maxBooks != null) {
      map['max_books'] = Variable<int>(maxBooks);
    }
    if (!nullToAbsent || maxDays != null) {
      map['max_days'] = Variable<int>(maxDays);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['allow_reservation'] = Variable<bool>(allowReservation);
    map['allow_renewal'] = Variable<bool>(allowRenewal);
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      monthlyFee: monthlyFee == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyFee),
      deposit: deposit == null && nullToAbsent
          ? const Value.absent()
          : Value(deposit),
      maxBooks: maxBooks == null && nullToAbsent
          ? const Value.absent()
          : Value(maxBooks),
      maxDays: maxDays == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDays),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      allowReservation: Value(allowReservation),
      allowRenewal: Value(allowRenewal),
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      monthlyFee: serializer.fromJson<int?>(json['monthlyFee']),
      deposit: serializer.fromJson<int?>(json['deposit']),
      maxBooks: serializer.fromJson<int?>(json['maxBooks']),
      maxDays: serializer.fromJson<int?>(json['maxDays']),
      description: serializer.fromJson<String?>(json['description']),
      allowReservation: serializer.fromJson<bool>(json['allowReservation']),
      allowRenewal: serializer.fromJson<bool>(json['allowRenewal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'monthlyFee': serializer.toJson<int?>(monthlyFee),
      'deposit': serializer.toJson<int?>(deposit),
      'maxBooks': serializer.toJson<int?>(maxBooks),
      'maxDays': serializer.toJson<int?>(maxDays),
      'description': serializer.toJson<String?>(description),
      'allowReservation': serializer.toJson<bool>(allowReservation),
      'allowRenewal': serializer.toJson<bool>(allowRenewal),
    };
  }

  Subscription copyWith(
          {String? id,
          Value<String?> name = const Value.absent(),
          Value<int?> monthlyFee = const Value.absent(),
          Value<int?> deposit = const Value.absent(),
          Value<int?> maxBooks = const Value.absent(),
          Value<int?> maxDays = const Value.absent(),
          Value<String?> description = const Value.absent(),
          bool? allowReservation,
          bool? allowRenewal}) =>
      Subscription(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        monthlyFee: monthlyFee.present ? monthlyFee.value : this.monthlyFee,
        deposit: deposit.present ? deposit.value : this.deposit,
        maxBooks: maxBooks.present ? maxBooks.value : this.maxBooks,
        maxDays: maxDays.present ? maxDays.value : this.maxDays,
        description: description.present ? description.value : this.description,
        allowReservation: allowReservation ?? this.allowReservation,
        allowRenewal: allowRenewal ?? this.allowRenewal,
      );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      monthlyFee:
          data.monthlyFee.present ? data.monthlyFee.value : this.monthlyFee,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      maxBooks: data.maxBooks.present ? data.maxBooks.value : this.maxBooks,
      maxDays: data.maxDays.present ? data.maxDays.value : this.maxDays,
      description:
          data.description.present ? data.description.value : this.description,
      allowReservation: data.allowReservation.present
          ? data.allowReservation.value
          : this.allowReservation,
      allowRenewal: data.allowRenewal.present
          ? data.allowRenewal.value
          : this.allowRenewal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('deposit: $deposit, ')
          ..write('maxBooks: $maxBooks, ')
          ..write('maxDays: $maxDays, ')
          ..write('description: $description, ')
          ..write('allowReservation: $allowReservation, ')
          ..write('allowRenewal: $allowRenewal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, monthlyFee, deposit, maxBooks,
      maxDays, description, allowReservation, allowRenewal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.name == this.name &&
          other.monthlyFee == this.monthlyFee &&
          other.deposit == this.deposit &&
          other.maxBooks == this.maxBooks &&
          other.maxDays == this.maxDays &&
          other.description == this.description &&
          other.allowReservation == this.allowReservation &&
          other.allowRenewal == this.allowRenewal);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<String> id;
  final Value<String?> name;
  final Value<int?> monthlyFee;
  final Value<int?> deposit;
  final Value<int?> maxBooks;
  final Value<int?> maxDays;
  final Value<String?> description;
  final Value<bool> allowReservation;
  final Value<bool> allowRenewal;
  final Value<int> rowid;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.monthlyFee = const Value.absent(),
    this.deposit = const Value.absent(),
    this.maxBooks = const Value.absent(),
    this.maxDays = const Value.absent(),
    this.description = const Value.absent(),
    this.allowReservation = const Value.absent(),
    this.allowRenewal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.monthlyFee = const Value.absent(),
    this.deposit = const Value.absent(),
    this.maxBooks = const Value.absent(),
    this.maxDays = const Value.absent(),
    this.description = const Value.absent(),
    this.allowReservation = const Value.absent(),
    this.allowRenewal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Subscription> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? monthlyFee,
    Expression<int>? deposit,
    Expression<int>? maxBooks,
    Expression<int>? maxDays,
    Expression<String>? description,
    Expression<bool>? allowReservation,
    Expression<bool>? allowRenewal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (monthlyFee != null) 'monthly_fee': monthlyFee,
      if (deposit != null) 'deposit': deposit,
      if (maxBooks != null) 'max_books': maxBooks,
      if (maxDays != null) 'max_days': maxDays,
      if (description != null) 'description': description,
      if (allowReservation != null) 'allow_reservation': allowReservation,
      if (allowRenewal != null) 'allow_renewal': allowRenewal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<int?>? monthlyFee,
      Value<int?>? deposit,
      Value<int?>? maxBooks,
      Value<int?>? maxDays,
      Value<String?>? description,
      Value<bool>? allowReservation,
      Value<bool>? allowRenewal,
      Value<int>? rowid}) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      deposit: deposit ?? this.deposit,
      maxBooks: maxBooks ?? this.maxBooks,
      maxDays: maxDays ?? this.maxDays,
      description: description ?? this.description,
      allowReservation: allowReservation ?? this.allowReservation,
      allowRenewal: allowRenewal ?? this.allowRenewal,
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
    if (monthlyFee.present) {
      map['monthly_fee'] = Variable<int>(monthlyFee.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<int>(deposit.value);
    }
    if (maxBooks.present) {
      map['max_books'] = Variable<int>(maxBooks.value);
    }
    if (maxDays.present) {
      map['max_days'] = Variable<int>(maxDays.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (allowReservation.present) {
      map['allow_reservation'] = Variable<bool>(allowReservation.value);
    }
    if (allowRenewal.present) {
      map['allow_renewal'] = Variable<bool>(allowRenewal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('monthlyFee: $monthlyFee, ')
          ..write('deposit: $deposit, ')
          ..write('maxBooks: $maxBooks, ')
          ..write('maxDays: $maxDays, ')
          ..write('description: $description, ')
          ..write('allowReservation: $allowReservation, ')
          ..write('allowRenewal: $allowRenewal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTable extends Members with TableInfo<$MembersTable, Member> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _middleNameMeta =
      const VerificationMeta('middleName');
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
      'middle_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
      'national_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 12),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _subscriptionExpiryDateMeta =
      const VerificationMeta('subscriptionExpiryDate');
  @override
  late final GeneratedColumn<DateTime> subscriptionExpiryDate =
      GeneratedColumn<DateTime>('subscription_expiry_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _walletBalanceMeta =
      const VerificationMeta('walletBalance');
  @override
  late final GeneratedColumn<int> walletBalance = GeneratedColumn<int>(
      'wallet_balance', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
      'points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  static const VerificationMeta _subscriptionIdMeta =
      const VerificationMeta('subscriptionId');
  @override
  late final GeneratedColumn<String> subscriptionId = GeneratedColumn<String>(
      'subscription_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _avatarPathMeta =
      const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
      'avatar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lastName,
        middleName,
        firstName,
        dateOfBirth,
        phone,
        nationalId,
        email,
        address,
        subscriptionExpiryDate,
        walletBalance,
        points,
        isActive,
        subscriptionId,
        avatarPath,
        password
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members';
  @override
  VerificationContext validateIntegrity(Insertable<Member> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('middle_name')) {
      context.handle(
          _middleNameMeta,
          middleName.isAcceptableOrUnknown(
              data['middle_name']!, _middleNameMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    } else if (isInserting) {
      context.missing(_nationalIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('subscription_expiry_date')) {
      context.handle(
          _subscriptionExpiryDateMeta,
          subscriptionExpiryDate.isAcceptableOrUnknown(
              data['subscription_expiry_date']!, _subscriptionExpiryDateMeta));
    }
    if (data.containsKey('wallet_balance')) {
      context.handle(
          _walletBalanceMeta,
          walletBalance.isAcceptableOrUnknown(
              data['wallet_balance']!, _walletBalanceMeta));
    }
    if (data.containsKey('points')) {
      context.handle(_pointsMeta,
          points.isAcceptableOrUnknown(data['points']!, _pointsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('subscription_id')) {
      context.handle(
          _subscriptionIdMeta,
          subscriptionId.isAcceptableOrUnknown(
              data['subscription_id']!, _subscriptionIdMeta));
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
          _avatarPathMeta,
          avatarPath.isAcceptableOrUnknown(
              data['avatar_path']!, _avatarPathMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Member map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Member(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      middleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}middle_name']),
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}national_id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      subscriptionExpiryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}subscription_expiry_date']),
      walletBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_balance'])!,
      points: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active']),
      subscriptionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subscription_id'])!,
      avatarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_path']),
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
    );
  }

  @override
  $MembersTable createAlias(String alias) {
    return $MembersTable(attachedDatabase, alias);
  }
}

class Member extends DataClass implements Insertable<Member> {
  final String id;

  /// SQL splits name parts (HoDG, TenLotDG, TenDG). Keep parts for fidelity.
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final DateTime? dateOfBirth;
  final String? phone;
  final String nationalId;
  final String email;
  final String? address;
  final DateTime? subscriptionExpiryDate;

  /// Wallet balance in VND. Default is 0.
  final int walletBalance;

  /// Points accumulated. Default is 0.
  final int points;

  /// SQL TrangThai bit (0/1).
  final bool? isActive;
  final String subscriptionId;

  /// Added in roadmap: path to avatar image on device.
  final String? avatarPath;

  /// Added in roadmap: local password for member login (nullable).
  final String? password;
  const Member(
      {required this.id,
      this.lastName,
      this.middleName,
      this.firstName,
      this.dateOfBirth,
      this.phone,
      required this.nationalId,
      required this.email,
      this.address,
      this.subscriptionExpiryDate,
      required this.walletBalance,
      required this.points,
      this.isActive,
      required this.subscriptionId,
      this.avatarPath,
      this.password});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['national_id'] = Variable<String>(nationalId);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || subscriptionExpiryDate != null) {
      map['subscription_expiry_date'] =
          Variable<DateTime>(subscriptionExpiryDate);
    }
    map['wallet_balance'] = Variable<int>(walletBalance);
    map['points'] = Variable<int>(points);
    if (!nullToAbsent || isActive != null) {
      map['is_active'] = Variable<bool>(isActive);
    }
    map['subscription_id'] = Variable<String>(subscriptionId);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    return map;
  }

  MembersCompanion toCompanion(bool nullToAbsent) {
    return MembersCompanion(
      id: Value(id),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      nationalId: Value(nationalId),
      email: Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      subscriptionExpiryDate: subscriptionExpiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionExpiryDate),
      walletBalance: Value(walletBalance),
      points: Value(points),
      isActive: isActive == null && nullToAbsent
          ? const Value.absent()
          : Value(isActive),
      subscriptionId: Value(subscriptionId),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
    );
  }

  factory Member.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Member(
      id: serializer.fromJson<String>(json['id']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      phone: serializer.fromJson<String?>(json['phone']),
      nationalId: serializer.fromJson<String>(json['nationalId']),
      email: serializer.fromJson<String>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      subscriptionExpiryDate:
          serializer.fromJson<DateTime?>(json['subscriptionExpiryDate']),
      walletBalance: serializer.fromJson<int>(json['walletBalance']),
      points: serializer.fromJson<int>(json['points']),
      isActive: serializer.fromJson<bool?>(json['isActive']),
      subscriptionId: serializer.fromJson<String>(json['subscriptionId']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      password: serializer.fromJson<String?>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastName': serializer.toJson<String?>(lastName),
      'middleName': serializer.toJson<String?>(middleName),
      'firstName': serializer.toJson<String?>(firstName),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'phone': serializer.toJson<String?>(phone),
      'nationalId': serializer.toJson<String>(nationalId),
      'email': serializer.toJson<String>(email),
      'address': serializer.toJson<String?>(address),
      'subscriptionExpiryDate':
          serializer.toJson<DateTime?>(subscriptionExpiryDate),
      'walletBalance': serializer.toJson<int>(walletBalance),
      'points': serializer.toJson<int>(points),
      'isActive': serializer.toJson<bool?>(isActive),
      'subscriptionId': serializer.toJson<String>(subscriptionId),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'password': serializer.toJson<String?>(password),
    };
  }

  Member copyWith(
          {String? id,
          Value<String?> lastName = const Value.absent(),
          Value<String?> middleName = const Value.absent(),
          Value<String?> firstName = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          String? nationalId,
          String? email,
          Value<String?> address = const Value.absent(),
          Value<DateTime?> subscriptionExpiryDate = const Value.absent(),
          int? walletBalance,
          int? points,
          Value<bool?> isActive = const Value.absent(),
          String? subscriptionId,
          Value<String?> avatarPath = const Value.absent(),
          Value<String?> password = const Value.absent()}) =>
      Member(
        id: id ?? this.id,
        lastName: lastName.present ? lastName.value : this.lastName,
        middleName: middleName.present ? middleName.value : this.middleName,
        firstName: firstName.present ? firstName.value : this.firstName,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        phone: phone.present ? phone.value : this.phone,
        nationalId: nationalId ?? this.nationalId,
        email: email ?? this.email,
        address: address.present ? address.value : this.address,
        subscriptionExpiryDate: subscriptionExpiryDate.present
            ? subscriptionExpiryDate.value
            : this.subscriptionExpiryDate,
        walletBalance: walletBalance ?? this.walletBalance,
        points: points ?? this.points,
        isActive: isActive.present ? isActive.value : this.isActive,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
        password: password.present ? password.value : this.password,
      );
  Member copyWithCompanion(MembersCompanion data) {
    return Member(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      middleName:
          data.middleName.present ? data.middleName.value : this.middleName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      phone: data.phone.present ? data.phone.value : this.phone,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      subscriptionExpiryDate: data.subscriptionExpiryDate.present
          ? data.subscriptionExpiryDate.value
          : this.subscriptionExpiryDate,
      walletBalance: data.walletBalance.present
          ? data.walletBalance.value
          : this.walletBalance,
      points: data.points.present ? data.points.value : this.points,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Member(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('subscriptionExpiryDate: $subscriptionExpiryDate, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('points: $points, ')
          ..write('isActive: $isActive, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lastName,
      middleName,
      firstName,
      dateOfBirth,
      phone,
      nationalId,
      email,
      address,
      subscriptionExpiryDate,
      walletBalance,
      points,
      isActive,
      subscriptionId,
      avatarPath,
      password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Member &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.middleName == this.middleName &&
          other.firstName == this.firstName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.phone == this.phone &&
          other.nationalId == this.nationalId &&
          other.email == this.email &&
          other.address == this.address &&
          other.subscriptionExpiryDate == this.subscriptionExpiryDate &&
          other.walletBalance == this.walletBalance &&
          other.points == this.points &&
          other.isActive == this.isActive &&
          other.subscriptionId == this.subscriptionId &&
          other.avatarPath == this.avatarPath &&
          other.password == this.password);
}

class MembersCompanion extends UpdateCompanion<Member> {
  final Value<String> id;
  final Value<String?> lastName;
  final Value<String?> middleName;
  final Value<String?> firstName;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> phone;
  final Value<String> nationalId;
  final Value<String> email;
  final Value<String?> address;
  final Value<DateTime?> subscriptionExpiryDate;
  final Value<int> walletBalance;
  final Value<int> points;
  final Value<bool?> isActive;
  final Value<String> subscriptionId;
  final Value<String?> avatarPath;
  final Value<String?> password;
  final Value<int> rowid;
  const MembersCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.subscriptionExpiryDate = const Value.absent(),
    this.walletBalance = const Value.absent(),
    this.points = const Value.absent(),
    this.isActive = const Value.absent(),
    this.subscriptionId = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersCompanion.insert({
    required String id,
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.phone = const Value.absent(),
    required String nationalId,
    required String email,
    this.address = const Value.absent(),
    this.subscriptionExpiryDate = const Value.absent(),
    this.walletBalance = const Value.absent(),
    this.points = const Value.absent(),
    this.isActive = const Value.absent(),
    required String subscriptionId,
    this.avatarPath = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nationalId = Value(nationalId),
        email = Value(email),
        subscriptionId = Value(subscriptionId);
  static Insertable<Member> custom({
    Expression<String>? id,
    Expression<String>? lastName,
    Expression<String>? middleName,
    Expression<String>? firstName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? phone,
    Expression<String>? nationalId,
    Expression<String>? email,
    Expression<String>? address,
    Expression<DateTime>? subscriptionExpiryDate,
    Expression<int>? walletBalance,
    Expression<int>? points,
    Expression<bool>? isActive,
    Expression<String>? subscriptionId,
    Expression<String>? avatarPath,
    Expression<String>? password,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (firstName != null) 'first_name': firstName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'national_id': nationalId,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (subscriptionExpiryDate != null)
        'subscription_expiry_date': subscriptionExpiryDate,
      if (walletBalance != null) 'wallet_balance': walletBalance,
      if (points != null) 'points': points,
      if (isActive != null) 'is_active': isActive,
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (password != null) 'password': password,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersCompanion copyWith(
      {Value<String>? id,
      Value<String?>? lastName,
      Value<String?>? middleName,
      Value<String?>? firstName,
      Value<DateTime?>? dateOfBirth,
      Value<String?>? phone,
      Value<String>? nationalId,
      Value<String>? email,
      Value<String?>? address,
      Value<DateTime?>? subscriptionExpiryDate,
      Value<int>? walletBalance,
      Value<int>? points,
      Value<bool?>? isActive,
      Value<String>? subscriptionId,
      Value<String?>? avatarPath,
      Value<String?>? password,
      Value<int>? rowid}) {
    return MembersCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      firstName: firstName ?? this.firstName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      email: email ?? this.email,
      address: address ?? this.address,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      walletBalance: walletBalance ?? this.walletBalance,
      points: points ?? this.points,
      isActive: isActive ?? this.isActive,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      avatarPath: avatarPath ?? this.avatarPath,
      password: password ?? this.password,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (subscriptionExpiryDate.present) {
      map['subscription_expiry_date'] =
          Variable<DateTime>(subscriptionExpiryDate.value);
    }
    if (walletBalance.present) {
      map['wallet_balance'] = Variable<int>(walletBalance.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<String>(subscriptionId.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('subscriptionExpiryDate: $subscriptionExpiryDate, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('points: $points, ')
          ..write('isActive: $isActive, ')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('password: $password, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffAccountsTable extends StaffAccounts
    with TableInfo<$StaffAccountsTable, StaffAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _middleNameMeta =
      const VerificationMeta('middleName');
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
      'middle_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastName, middleName, firstName, role, username, password];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<StaffAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('middle_name')) {
      context.handle(
          _middleNameMeta,
          middleName.isAcceptableOrUnknown(
              data['middle_name']!, _middleNameMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      middleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}middle_name']),
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
    );
  }

  @override
  $StaffAccountsTable createAlias(String alias) {
    return $StaffAccountsTable(attachedDatabase, alias);
  }
}

class StaffAccount extends DataClass implements Insertable<StaffAccount> {
  final String id;
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final String? role;

  /// Unique username (SQL: TaiKhoan)
  final String username;

  /// Password hash or plaintext (local-only app; you can switch to hashing later)
  final String password;
  const StaffAccount(
      {required this.id,
      this.lastName,
      this.middleName,
      this.firstName,
      this.role,
      required this.username,
      required this.password});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    return map;
  }

  StaffAccountsCompanion toCompanion(bool nullToAbsent) {
    return StaffAccountsCompanion(
      id: Value(id),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      username: Value(username),
      password: Value(password),
    );
  }

  factory StaffAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffAccount(
      id: serializer.fromJson<String>(json['id']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      role: serializer.fromJson<String?>(json['role']),
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lastName': serializer.toJson<String?>(lastName),
      'middleName': serializer.toJson<String?>(middleName),
      'firstName': serializer.toJson<String?>(firstName),
      'role': serializer.toJson<String?>(role),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
    };
  }

  StaffAccount copyWith(
          {String? id,
          Value<String?> lastName = const Value.absent(),
          Value<String?> middleName = const Value.absent(),
          Value<String?> firstName = const Value.absent(),
          Value<String?> role = const Value.absent(),
          String? username,
          String? password}) =>
      StaffAccount(
        id: id ?? this.id,
        lastName: lastName.present ? lastName.value : this.lastName,
        middleName: middleName.present ? middleName.value : this.middleName,
        firstName: firstName.present ? firstName.value : this.firstName,
        role: role.present ? role.value : this.role,
        username: username ?? this.username,
        password: password ?? this.password,
      );
  StaffAccount copyWithCompanion(StaffAccountsCompanion data) {
    return StaffAccount(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      middleName:
          data.middleName.present ? data.middleName.value : this.middleName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      role: data.role.present ? data.role.value : this.role,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffAccount(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('role: $role, ')
          ..write('username: $username, ')
          ..write('password: $password')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, lastName, middleName, firstName, role, username, password);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffAccount &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.middleName == this.middleName &&
          other.firstName == this.firstName &&
          other.role == this.role &&
          other.username == this.username &&
          other.password == this.password);
}

class StaffAccountsCompanion extends UpdateCompanion<StaffAccount> {
  final Value<String> id;
  final Value<String?> lastName;
  final Value<String?> middleName;
  final Value<String?> firstName;
  final Value<String?> role;
  final Value<String> username;
  final Value<String> password;
  final Value<int> rowid;
  const StaffAccountsCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.role = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffAccountsCompanion.insert({
    required String id,
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.role = const Value.absent(),
    required String username,
    required String password,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        username = Value(username),
        password = Value(password);
  static Insertable<StaffAccount> custom({
    Expression<String>? id,
    Expression<String>? lastName,
    Expression<String>? middleName,
    Expression<String>? firstName,
    Expression<String>? role,
    Expression<String>? username,
    Expression<String>? password,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (firstName != null) 'first_name': firstName,
      if (role != null) 'role': role,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? lastName,
      Value<String?>? middleName,
      Value<String?>? firstName,
      Value<String?>? role,
      Value<String>? username,
      Value<String>? password,
      Value<int>? rowid}) {
    return StaffAccountsCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      firstName: firstName ?? this.firstName,
      role: role ?? this.role,
      username: username ?? this.username,
      password: password ?? this.password,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffAccountsCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('role: $role, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String? name;
  const Category({required this.id, this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
    };
  }

  Category copyWith({int? id, Value<String?> name = const Value.absent()}) =>
      Category(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category && other.id == this.id && other.name == this.name);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String?> name;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<String?>? name}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PublishersTable extends Publishers
    with TableInfo<$PublishersTable, Publisher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PublishersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'publishers';
  @override
  VerificationContext validateIntegrity(Insertable<Publisher> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Publisher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Publisher(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
    );
  }

  @override
  $PublishersTable createAlias(String alias) {
    return $PublishersTable(attachedDatabase, alias);
  }
}

class Publisher extends DataClass implements Insertable<Publisher> {
  final int id;
  final String? name;
  final String? address;
  const Publisher({required this.id, this.name, this.address});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  PublishersCompanion toCompanion(bool nullToAbsent) {
    return PublishersCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory Publisher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Publisher(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'address': serializer.toJson<String?>(address),
    };
  }

  Publisher copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<String?> address = const Value.absent()}) =>
      Publisher(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        address: address.present ? address.value : this.address,
      );
  Publisher copyWithCompanion(PublishersCompanion data) {
    return Publisher(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Publisher(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Publisher &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address);
}

class PublishersCompanion extends UpdateCompanion<Publisher> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String?> address;
  const PublishersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
  });
  PublishersCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
  });
  static Insertable<Publisher> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
    });
  }

  PublishersCompanion copyWith(
      {Value<int>? id, Value<String?>? name, Value<String?>? address}) {
    return PublishersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
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
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PublishersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

class $AuthorsTable extends Authors with TableInfo<$AuthorsTable, Author> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _middleNameMeta =
      const VerificationMeta('middleName');
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
      'middle_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _hometownMeta =
      const VerificationMeta('hometown');
  @override
  late final GeneratedColumn<String> hometown = GeneratedColumn<String>(
      'hometown', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastName, middleName, firstName, hometown];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'authors';
  @override
  VerificationContext validateIntegrity(Insertable<Author> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('middle_name')) {
      context.handle(
          _middleNameMeta,
          middleName.isAcceptableOrUnknown(
              data['middle_name']!, _middleNameMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('hometown')) {
      context.handle(_hometownMeta,
          hometown.isAcceptableOrUnknown(data['hometown']!, _hometownMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Author map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Author(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name']),
      middleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}middle_name']),
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      hometown: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hometown']),
    );
  }

  @override
  $AuthorsTable createAlias(String alias) {
    return $AuthorsTable(attachedDatabase, alias);
  }
}

class Author extends DataClass implements Insertable<Author> {
  final int id;
  final String? lastName;
  final String? middleName;
  final String? firstName;
  final String? hometown;
  const Author(
      {required this.id,
      this.lastName,
      this.middleName,
      this.firstName,
      this.hometown});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || hometown != null) {
      map['hometown'] = Variable<String>(hometown);
    }
    return map;
  }

  AuthorsCompanion toCompanion(bool nullToAbsent) {
    return AuthorsCompanion(
      id: Value(id),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      hometown: hometown == null && nullToAbsent
          ? const Value.absent()
          : Value(hometown),
    );
  }

  factory Author.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Author(
      id: serializer.fromJson<int>(json['id']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      hometown: serializer.fromJson<String?>(json['hometown']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastName': serializer.toJson<String?>(lastName),
      'middleName': serializer.toJson<String?>(middleName),
      'firstName': serializer.toJson<String?>(firstName),
      'hometown': serializer.toJson<String?>(hometown),
    };
  }

  Author copyWith(
          {int? id,
          Value<String?> lastName = const Value.absent(),
          Value<String?> middleName = const Value.absent(),
          Value<String?> firstName = const Value.absent(),
          Value<String?> hometown = const Value.absent()}) =>
      Author(
        id: id ?? this.id,
        lastName: lastName.present ? lastName.value : this.lastName,
        middleName: middleName.present ? middleName.value : this.middleName,
        firstName: firstName.present ? firstName.value : this.firstName,
        hometown: hometown.present ? hometown.value : this.hometown,
      );
  Author copyWithCompanion(AuthorsCompanion data) {
    return Author(
      id: data.id.present ? data.id.value : this.id,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      middleName:
          data.middleName.present ? data.middleName.value : this.middleName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      hometown: data.hometown.present ? data.hometown.value : this.hometown,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Author(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('hometown: $hometown')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastName, middleName, firstName, hometown);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Author &&
          other.id == this.id &&
          other.lastName == this.lastName &&
          other.middleName == this.middleName &&
          other.firstName == this.firstName &&
          other.hometown == this.hometown);
}

class AuthorsCompanion extends UpdateCompanion<Author> {
  final Value<int> id;
  final Value<String?> lastName;
  final Value<String?> middleName;
  final Value<String?> firstName;
  final Value<String?> hometown;
  const AuthorsCompanion({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.hometown = const Value.absent(),
  });
  AuthorsCompanion.insert({
    this.id = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.hometown = const Value.absent(),
  });
  static Insertable<Author> custom({
    Expression<int>? id,
    Expression<String>? lastName,
    Expression<String>? middleName,
    Expression<String>? firstName,
    Expression<String>? hometown,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (firstName != null) 'first_name': firstName,
      if (hometown != null) 'hometown': hometown,
    });
  }

  AuthorsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? lastName,
      Value<String?>? middleName,
      Value<String?>? firstName,
      Value<String?>? hometown}) {
    return AuthorsCompanion(
      id: id ?? this.id,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      firstName: firstName ?? this.firstName,
      hometown: hometown ?? this.hometown,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (hometown.present) {
      map['hometown'] = Variable<String>(hometown.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthorsCompanion(')
          ..write('id: $id, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('firstName: $firstName, ')
          ..write('hometown: $hometown')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _publishedYearMeta =
      const VerificationMeta('publishedYear');
  @override
  late final GeneratedColumn<int> publishedYear = GeneratedColumn<int>(
      'published_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _coverPriceMeta =
      const VerificationMeta('coverPrice');
  @override
  late final GeneratedColumn<int> coverPrice = GeneratedColumn<int>(
      'cover_price', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalQuantityMeta =
      const VerificationMeta('totalQuantity');
  @override
  late final GeneratedColumn<int> totalQuantity = GeneratedColumn<int>(
      'total_quantity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _publisherIdMeta =
      const VerificationMeta('publisherId');
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
      'publisher_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES publishers (id)'));
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        publishedYear,
        coverPrice,
        totalQuantity,
        description,
        categoryId,
        publisherId,
        coverPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('published_year')) {
      context.handle(
          _publishedYearMeta,
          publishedYear.isAcceptableOrUnknown(
              data['published_year']!, _publishedYearMeta));
    }
    if (data.containsKey('cover_price')) {
      context.handle(
          _coverPriceMeta,
          coverPrice.isAcceptableOrUnknown(
              data['cover_price']!, _coverPriceMeta));
    }
    if (data.containsKey('total_quantity')) {
      context.handle(
          _totalQuantityMeta,
          totalQuantity.isAcceptableOrUnknown(
              data['total_quantity']!, _totalQuantityMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
          _publisherIdMeta,
          publisherId.isAcceptableOrUnknown(
              data['publisher_id']!, _publisherIdMeta));
    } else if (isInserting) {
      context.missing(_publisherIdMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      publishedYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}published_year']),
      coverPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cover_price']),
      totalQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_quantity']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      publisherId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}publisher_id'])!,
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String? title;

  /// Year of publish.
  final int? publishedYear;

  /// Cover price in VND.
  final int? coverPrice;
  final int? totalQuantity;
  final String? description;

  /// From SQL: THE_LOAI (MaTL).
  final int categoryId;

  /// From SQL: NHA_XUAT_BAN (MaNXB).
  final int publisherId;

  /// Added in roadmap: path to cover image on device.
  final String? coverPath;
  const Book(
      {required this.id,
      this.title,
      this.publishedYear,
      this.coverPrice,
      this.totalQuantity,
      this.description,
      required this.categoryId,
      required this.publisherId,
      this.coverPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || publishedYear != null) {
      map['published_year'] = Variable<int>(publishedYear);
    }
    if (!nullToAbsent || coverPrice != null) {
      map['cover_price'] = Variable<int>(coverPrice);
    }
    if (!nullToAbsent || totalQuantity != null) {
      map['total_quantity'] = Variable<int>(totalQuantity);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category_id'] = Variable<int>(categoryId);
    map['publisher_id'] = Variable<int>(publisherId);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      publishedYear: publishedYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedYear),
      coverPrice: coverPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPrice),
      totalQuantity: totalQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(totalQuantity),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: Value(categoryId),
      publisherId: Value(publisherId),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      publishedYear: serializer.fromJson<int?>(json['publishedYear']),
      coverPrice: serializer.fromJson<int?>(json['coverPrice']),
      totalQuantity: serializer.fromJson<int?>(json['totalQuantity']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      publisherId: serializer.fromJson<int>(json['publisherId']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'publishedYear': serializer.toJson<int?>(publishedYear),
      'coverPrice': serializer.toJson<int?>(coverPrice),
      'totalQuantity': serializer.toJson<int?>(totalQuantity),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<int>(categoryId),
      'publisherId': serializer.toJson<int>(publisherId),
      'coverPath': serializer.toJson<String?>(coverPath),
    };
  }

  Book copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          Value<int?> publishedYear = const Value.absent(),
          Value<int?> coverPrice = const Value.absent(),
          Value<int?> totalQuantity = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? categoryId,
          int? publisherId,
          Value<String?> coverPath = const Value.absent()}) =>
      Book(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        publishedYear:
            publishedYear.present ? publishedYear.value : this.publishedYear,
        coverPrice: coverPrice.present ? coverPrice.value : this.coverPrice,
        totalQuantity:
            totalQuantity.present ? totalQuantity.value : this.totalQuantity,
        description: description.present ? description.value : this.description,
        categoryId: categoryId ?? this.categoryId,
        publisherId: publisherId ?? this.publisherId,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      publishedYear: data.publishedYear.present
          ? data.publishedYear.value
          : this.publishedYear,
      coverPrice:
          data.coverPrice.present ? data.coverPrice.value : this.coverPrice,
      totalQuantity: data.totalQuantity.present
          ? data.totalQuantity.value
          : this.totalQuantity,
      description:
          data.description.present ? data.description.value : this.description,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      publisherId:
          data.publisherId.present ? data.publisherId.value : this.publisherId,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('publishedYear: $publishedYear, ')
          ..write('coverPrice: $coverPrice, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('publisherId: $publisherId, ')
          ..write('coverPath: $coverPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, publishedYear, coverPrice,
      totalQuantity, description, categoryId, publisherId, coverPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.publishedYear == this.publishedYear &&
          other.coverPrice == this.coverPrice &&
          other.totalQuantity == this.totalQuantity &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.publisherId == this.publisherId &&
          other.coverPath == this.coverPath);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String?> title;
  final Value<int?> publishedYear;
  final Value<int?> coverPrice;
  final Value<int?> totalQuantity;
  final Value<String?> description;
  final Value<int> categoryId;
  final Value<int> publisherId;
  final Value<String?> coverPath;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.publishedYear = const Value.absent(),
    this.coverPrice = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.publishedYear = const Value.absent(),
    this.coverPrice = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.description = const Value.absent(),
    required int categoryId,
    required int publisherId,
    this.coverPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        publisherId = Value(publisherId);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? publishedYear,
    Expression<int>? coverPrice,
    Expression<int>? totalQuantity,
    Expression<String>? description,
    Expression<int>? categoryId,
    Expression<int>? publisherId,
    Expression<String>? coverPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (publishedYear != null) 'published_year': publishedYear,
      if (coverPrice != null) 'cover_price': coverPrice,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (publisherId != null) 'publisher_id': publisherId,
      if (coverPath != null) 'cover_path': coverPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<int?>? publishedYear,
      Value<int?>? coverPrice,
      Value<int?>? totalQuantity,
      Value<String?>? description,
      Value<int>? categoryId,
      Value<int>? publisherId,
      Value<String?>? coverPath,
      Value<int>? rowid}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      publishedYear: publishedYear ?? this.publishedYear,
      coverPrice: coverPrice ?? this.coverPrice,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      publisherId: publisherId ?? this.publisherId,
      coverPath: coverPath ?? this.coverPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (publishedYear.present) {
      map['published_year'] = Variable<int>(publishedYear.value);
    }
    if (coverPrice.present) {
      map['cover_price'] = Variable<int>(coverPrice.value);
    }
    if (totalQuantity.present) {
      map['total_quantity'] = Variable<int>(totalQuantity.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('publishedYear: $publishedYear, ')
          ..write('coverPrice: $coverPrice, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('publisherId: $publisherId, ')
          ..write('coverPath: $coverPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookAuthorsTable extends BookAuthors
    with TableInfo<$BookAuthorsTable, BookAuthor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookAuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES books (id)'));
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<int> authorId = GeneratedColumn<int>(
      'author_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES authors (id)'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [bookId, authorId, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_authors';
  @override
  VerificationContext validateIntegrity(Insertable<BookAuthor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(_authorIdMeta,
          authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta));
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, authorId};
  @override
  BookAuthor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookAuthor(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      authorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}author_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
    );
  }

  @override
  $BookAuthorsTable createAlias(String alias) {
    return $BookAuthorsTable(attachedDatabase, alias);
  }
}

class BookAuthor extends DataClass implements Insertable<BookAuthor> {
  final String bookId;
  final int authorId;
  final String? role;
  const BookAuthor({required this.bookId, required this.authorId, this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['author_id'] = Variable<int>(authorId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    return map;
  }

  BookAuthorsCompanion toCompanion(bool nullToAbsent) {
    return BookAuthorsCompanion(
      bookId: Value(bookId),
      authorId: Value(authorId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
    );
  }

  factory BookAuthor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookAuthor(
      bookId: serializer.fromJson<String>(json['bookId']),
      authorId: serializer.fromJson<int>(json['authorId']),
      role: serializer.fromJson<String?>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'authorId': serializer.toJson<int>(authorId),
      'role': serializer.toJson<String?>(role),
    };
  }

  BookAuthor copyWith(
          {String? bookId,
          int? authorId,
          Value<String?> role = const Value.absent()}) =>
      BookAuthor(
        bookId: bookId ?? this.bookId,
        authorId: authorId ?? this.authorId,
        role: role.present ? role.value : this.role,
      );
  BookAuthor copyWithCompanion(BookAuthorsCompanion data) {
    return BookAuthor(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthor(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, authorId, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookAuthor &&
          other.bookId == this.bookId &&
          other.authorId == this.authorId &&
          other.role == this.role);
}

class BookAuthorsCompanion extends UpdateCompanion<BookAuthor> {
  final Value<String> bookId;
  final Value<int> authorId;
  final Value<String?> role;
  final Value<int> rowid;
  const BookAuthorsCompanion({
    this.bookId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookAuthorsCompanion.insert({
    required String bookId,
    required int authorId,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        authorId = Value(authorId);
  static Insertable<BookAuthor> custom({
    Expression<String>? bookId,
    Expression<int>? authorId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (authorId != null) 'author_id': authorId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookAuthorsCompanion copyWith(
      {Value<String>? bookId,
      Value<int>? authorId,
      Value<String?>? role,
      Value<int>? rowid}) {
    return BookAuthorsCompanion(
      bookId: bookId ?? this.bookId,
      authorId: authorId ?? this.authorId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<int>(authorId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthorsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookCopiesTable extends BookCopies
    with TableInfo<$BookCopiesTable, BookCopy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookCopiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES books (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, location, condition, status, bookId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_copies';
  @override
  VerificationContext validateIntegrity(Insertable<BookCopy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookCopy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookCopy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status']),
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
    );
  }

  @override
  $BookCopiesTable createAlias(String alias) {
    return $BookCopiesTable(attachedDatabase, alias);
  }
}

class BookCopy extends DataClass implements Insertable<BookCopy> {
  /// Barcode / MaVach
  final String id;
  final String? location;

  /// Physical condition (TinhTrang)
  final String? condition;

  /// Tinyint status from SQL (TrangThai). Map to enum later.
  final int? status;
  final String bookId;
  const BookCopy(
      {required this.id,
      this.location,
      this.condition,
      this.status,
      required this.bookId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<int>(status);
    }
    map['book_id'] = Variable<String>(bookId);
    return map;
  }

  BookCopiesCompanion toCompanion(bool nullToAbsent) {
    return BookCopiesCompanion(
      id: Value(id),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      bookId: Value(bookId),
    );
  }

  factory BookCopy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookCopy(
      id: serializer.fromJson<String>(json['id']),
      location: serializer.fromJson<String?>(json['location']),
      condition: serializer.fromJson<String?>(json['condition']),
      status: serializer.fromJson<int?>(json['status']),
      bookId: serializer.fromJson<String>(json['bookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'location': serializer.toJson<String?>(location),
      'condition': serializer.toJson<String?>(condition),
      'status': serializer.toJson<int?>(status),
      'bookId': serializer.toJson<String>(bookId),
    };
  }

  BookCopy copyWith(
          {String? id,
          Value<String?> location = const Value.absent(),
          Value<String?> condition = const Value.absent(),
          Value<int?> status = const Value.absent(),
          String? bookId}) =>
      BookCopy(
        id: id ?? this.id,
        location: location.present ? location.value : this.location,
        condition: condition.present ? condition.value : this.condition,
        status: status.present ? status.value : this.status,
        bookId: bookId ?? this.bookId,
      );
  BookCopy copyWithCompanion(BookCopiesCompanion data) {
    return BookCopy(
      id: data.id.present ? data.id.value : this.id,
      location: data.location.present ? data.location.value : this.location,
      condition: data.condition.present ? data.condition.value : this.condition,
      status: data.status.present ? data.status.value : this.status,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookCopy(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('condition: $condition, ')
          ..write('status: $status, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, location, condition, status, bookId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookCopy &&
          other.id == this.id &&
          other.location == this.location &&
          other.condition == this.condition &&
          other.status == this.status &&
          other.bookId == this.bookId);
}

class BookCopiesCompanion extends UpdateCompanion<BookCopy> {
  final Value<String> id;
  final Value<String?> location;
  final Value<String?> condition;
  final Value<int?> status;
  final Value<String> bookId;
  final Value<int> rowid;
  const BookCopiesCompanion({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.condition = const Value.absent(),
    this.status = const Value.absent(),
    this.bookId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookCopiesCompanion.insert({
    required String id,
    this.location = const Value.absent(),
    this.condition = const Value.absent(),
    this.status = const Value.absent(),
    required String bookId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId);
  static Insertable<BookCopy> custom({
    Expression<String>? id,
    Expression<String>? location,
    Expression<String>? condition,
    Expression<int>? status,
    Expression<String>? bookId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (location != null) 'location': location,
      if (condition != null) 'condition': condition,
      if (status != null) 'status': status,
      if (bookId != null) 'book_id': bookId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookCopiesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? location,
      Value<String?>? condition,
      Value<int?>? status,
      Value<String>? bookId,
      Value<int>? rowid}) {
    return BookCopiesCompanion(
      id: id ?? this.id,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      bookId: bookId ?? this.bookId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookCopiesCompanion(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('condition: $condition, ')
          ..write('status: $status, ')
          ..write('bookId: $bookId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES members (id)'));
  static const VerificationMeta _copyIdMeta = const VerificationMeta('copyId');
  @override
  late final GeneratedColumn<String> copyId = GeneratedColumn<String>(
      'copy_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES book_copies (id)'));
  static const VerificationMeta _borrowDateMeta =
      const VerificationMeta('borrowDate');
  @override
  late final GeneratedColumn<DateTime> borrowDate = GeneratedColumn<DateTime>(
      'borrow_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _returnDateMeta =
      const VerificationMeta('returnDate');
  @override
  late final GeneratedColumn<DateTime> returnDate = GeneratedColumn<DateTime>(
      'return_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, memberId, copyId, borrowDate, dueDate, returnDate, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(Insertable<Loan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('copy_id')) {
      context.handle(_copyIdMeta,
          copyId.isAcceptableOrUnknown(data['copy_id']!, _copyIdMeta));
    } else if (isInserting) {
      context.missing(_copyIdMeta);
    }
    if (data.containsKey('borrow_date')) {
      context.handle(
          _borrowDateMeta,
          borrowDate.isAcceptableOrUnknown(
              data['borrow_date']!, _borrowDateMeta));
    } else if (isInserting) {
      context.missing(_borrowDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('return_date')) {
      context.handle(
          _returnDateMeta,
          returnDate.isAcceptableOrUnknown(
              data['return_date']!, _returnDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      copyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}copy_id'])!,
      borrowDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}borrow_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      returnDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}return_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  /// Auto-increment primary key.
  final int id;

  /// Member who borrows the book (FK -> Members.id).
  final String memberId;

  /// The specific book copy being borrowed (FK -> BookCopies.id).
  final String copyId;

  /// Date when the book was borrowed.
  final DateTime borrowDate;

  /// Due date for returning the book.
  final DateTime dueDate;

  /// Actual return date (null if not yet returned).
  final DateTime? returnDate;

  /// Loan status: 0 = Active, 1 = Overdue, 2 = Returned.
  final int status;
  const Loan(
      {required this.id,
      required this.memberId,
      required this.copyId,
      required this.borrowDate,
      required this.dueDate,
      this.returnDate,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['member_id'] = Variable<String>(memberId);
    map['copy_id'] = Variable<String>(copyId);
    map['borrow_date'] = Variable<DateTime>(borrowDate);
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || returnDate != null) {
      map['return_date'] = Variable<DateTime>(returnDate);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      memberId: Value(memberId),
      copyId: Value(copyId),
      borrowDate: Value(borrowDate),
      dueDate: Value(dueDate),
      returnDate: returnDate == null && nullToAbsent
          ? const Value.absent()
          : Value(returnDate),
      status: Value(status),
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      memberId: serializer.fromJson<String>(json['memberId']),
      copyId: serializer.fromJson<String>(json['copyId']),
      borrowDate: serializer.fromJson<DateTime>(json['borrowDate']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      returnDate: serializer.fromJson<DateTime?>(json['returnDate']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memberId': serializer.toJson<String>(memberId),
      'copyId': serializer.toJson<String>(copyId),
      'borrowDate': serializer.toJson<DateTime>(borrowDate),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'returnDate': serializer.toJson<DateTime?>(returnDate),
      'status': serializer.toJson<int>(status),
    };
  }

  Loan copyWith(
          {int? id,
          String? memberId,
          String? copyId,
          DateTime? borrowDate,
          DateTime? dueDate,
          Value<DateTime?> returnDate = const Value.absent(),
          int? status}) =>
      Loan(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        copyId: copyId ?? this.copyId,
        borrowDate: borrowDate ?? this.borrowDate,
        dueDate: dueDate ?? this.dueDate,
        returnDate: returnDate.present ? returnDate.value : this.returnDate,
        status: status ?? this.status,
      );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      copyId: data.copyId.present ? data.copyId.value : this.copyId,
      borrowDate:
          data.borrowDate.present ? data.borrowDate.value : this.borrowDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      returnDate:
          data.returnDate.present ? data.returnDate.value : this.returnDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('copyId: $copyId, ')
          ..write('borrowDate: $borrowDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnDate: $returnDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, memberId, copyId, borrowDate, dueDate, returnDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.copyId == this.copyId &&
          other.borrowDate == this.borrowDate &&
          other.dueDate == this.dueDate &&
          other.returnDate == this.returnDate &&
          other.status == this.status);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<String> memberId;
  final Value<String> copyId;
  final Value<DateTime> borrowDate;
  final Value<DateTime> dueDate;
  final Value<DateTime?> returnDate;
  final Value<int> status;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.copyId = const Value.absent(),
    this.borrowDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.returnDate = const Value.absent(),
    this.status = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required String memberId,
    required String copyId,
    required DateTime borrowDate,
    required DateTime dueDate,
    this.returnDate = const Value.absent(),
    this.status = const Value.absent(),
  })  : memberId = Value(memberId),
        copyId = Value(copyId),
        borrowDate = Value(borrowDate),
        dueDate = Value(dueDate);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<String>? memberId,
    Expression<String>? copyId,
    Expression<DateTime>? borrowDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? returnDate,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (copyId != null) 'copy_id': copyId,
      if (borrowDate != null) 'borrow_date': borrowDate,
      if (dueDate != null) 'due_date': dueDate,
      if (returnDate != null) 'return_date': returnDate,
      if (status != null) 'status': status,
    });
  }

  LoansCompanion copyWith(
      {Value<int>? id,
      Value<String>? memberId,
      Value<String>? copyId,
      Value<DateTime>? borrowDate,
      Value<DateTime>? dueDate,
      Value<DateTime?>? returnDate,
      Value<int>? status}) {
    return LoansCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      copyId: copyId ?? this.copyId,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (copyId.present) {
      map['copy_id'] = Variable<String>(copyId.value);
    }
    if (borrowDate.present) {
      map['borrow_date'] = Variable<DateTime>(borrowDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (returnDate.present) {
      map['return_date'] = Variable<DateTime>(returnDate.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('copyId: $copyId, ')
          ..write('borrowDate: $borrowDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('returnDate: $returnDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $FinesTable extends Fines with TableInfo<$FinesTable, Fine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
      'total_amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
      'is_paid', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paid" IN (0, 1))'));
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
      'loan_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 15),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, totalAmount, reason, isPaid, memberId, loanId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fines';
  @override
  VerificationContext validateIntegrity(Insertable<Fine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('is_paid')) {
      context.handle(_isPaidMeta,
          isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_amount']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      isPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paid']),
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_id'])!,
    );
  }

  @override
  $FinesTable createAlias(String alias) {
    return $FinesTable(attachedDatabase, alias);
  }
}

class Fine extends DataClass implements Insertable<Fine> {
  final int id;
  final DateTime? createdAt;

  /// Total fine amount in VND.
  final int? totalAmount;
  final String? reason;

  /// SQL TrangThai bit.
  final bool? isPaid;
  final String memberId;
  final String loanId;
  const Fine(
      {required this.id,
      this.createdAt,
      this.totalAmount,
      this.reason,
      this.isPaid,
      required this.memberId,
      required this.loanId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || totalAmount != null) {
      map['total_amount'] = Variable<int>(totalAmount);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || isPaid != null) {
      map['is_paid'] = Variable<bool>(isPaid);
    }
    map['member_id'] = Variable<String>(memberId);
    map['loan_id'] = Variable<String>(loanId);
    return map;
  }

  FinesCompanion toCompanion(bool nullToAbsent) {
    return FinesCompanion(
      id: Value(id),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      totalAmount: totalAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalAmount),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      isPaid:
          isPaid == null && nullToAbsent ? const Value.absent() : Value(isPaid),
      memberId: Value(memberId),
      loanId: Value(loanId),
    );
  }

  factory Fine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fine(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      totalAmount: serializer.fromJson<int?>(json['totalAmount']),
      reason: serializer.fromJson<String?>(json['reason']),
      isPaid: serializer.fromJson<bool?>(json['isPaid']),
      memberId: serializer.fromJson<String>(json['memberId']),
      loanId: serializer.fromJson<String>(json['loanId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'totalAmount': serializer.toJson<int?>(totalAmount),
      'reason': serializer.toJson<String?>(reason),
      'isPaid': serializer.toJson<bool?>(isPaid),
      'memberId': serializer.toJson<String>(memberId),
      'loanId': serializer.toJson<String>(loanId),
    };
  }

  Fine copyWith(
          {int? id,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<int?> totalAmount = const Value.absent(),
          Value<String?> reason = const Value.absent(),
          Value<bool?> isPaid = const Value.absent(),
          String? memberId,
          String? loanId}) =>
      Fine(
        id: id ?? this.id,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        totalAmount: totalAmount.present ? totalAmount.value : this.totalAmount,
        reason: reason.present ? reason.value : this.reason,
        isPaid: isPaid.present ? isPaid.value : this.isPaid,
        memberId: memberId ?? this.memberId,
        loanId: loanId ?? this.loanId,
      );
  Fine copyWithCompanion(FinesCompanion data) {
    return Fine(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      reason: data.reason.present ? data.reason.value : this.reason,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fine(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('reason: $reason, ')
          ..write('isPaid: $isPaid, ')
          ..write('memberId: $memberId, ')
          ..write('loanId: $loanId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, totalAmount, reason, isPaid, memberId, loanId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fine &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.totalAmount == this.totalAmount &&
          other.reason == this.reason &&
          other.isPaid == this.isPaid &&
          other.memberId == this.memberId &&
          other.loanId == this.loanId);
}

class FinesCompanion extends UpdateCompanion<Fine> {
  final Value<int> id;
  final Value<DateTime?> createdAt;
  final Value<int?> totalAmount;
  final Value<String?> reason;
  final Value<bool?> isPaid;
  final Value<String> memberId;
  final Value<String> loanId;
  const FinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.reason = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.memberId = const Value.absent(),
    this.loanId = const Value.absent(),
  });
  FinesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.reason = const Value.absent(),
    this.isPaid = const Value.absent(),
    required String memberId,
    required String loanId,
  })  : memberId = Value(memberId),
        loanId = Value(loanId);
  static Insertable<Fine> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? totalAmount,
    Expression<String>? reason,
    Expression<bool>? isPaid,
    Expression<String>? memberId,
    Expression<String>? loanId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (reason != null) 'reason': reason,
      if (isPaid != null) 'is_paid': isPaid,
      if (memberId != null) 'member_id': memberId,
      if (loanId != null) 'loan_id': loanId,
    });
  }

  FinesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? createdAt,
      Value<int?>? totalAmount,
      Value<String?>? reason,
      Value<bool?>? isPaid,
      Value<String>? memberId,
      Value<String>? loanId}) {
    return FinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
      reason: reason ?? this.reason,
      isPaid: isPaid ?? this.isPaid,
      memberId: memberId ?? this.memberId,
      loanId: loanId ?? this.loanId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('reason: $reason, ')
          ..write('isPaid: $isPaid, ')
          ..write('memberId: $memberId, ')
          ..write('loanId: $loanId')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, amount, createdAt, description, memberId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;

  /// SQL: LoaiGiaoDich
  final String? type;

  /// Amount in VND (can be negative in SQL seed data).
  final int? amount;
  final DateTime? createdAt;
  final String? description;
  final String memberId;
  const Transaction(
      {required this.id,
      this.type,
      this.amount,
      this.createdAt,
      this.description,
      required this.memberId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['member_id'] = Variable<String>(memberId);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      amount:
          amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      memberId: Value(memberId),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String?>(json['type']),
      amount: serializer.fromJson<int?>(json['amount']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      description: serializer.fromJson<String?>(json['description']),
      memberId: serializer.fromJson<String>(json['memberId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String?>(type),
      'amount': serializer.toJson<int?>(amount),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'description': serializer.toJson<String?>(description),
      'memberId': serializer.toJson<String>(memberId),
    };
  }

  Transaction copyWith(
          {int? id,
          Value<String?> type = const Value.absent(),
          Value<int?> amount = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? memberId}) =>
      Transaction(
        id: id ?? this.id,
        type: type.present ? type.value : this.type,
        amount: amount.present ? amount.value : this.amount,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        description: description.present ? description.value : this.description,
        memberId: memberId ?? this.memberId,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description:
          data.description.present ? data.description.value : this.description,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('memberId: $memberId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, amount, createdAt, description, memberId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.memberId == this.memberId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String?> type;
  final Value<int?> amount;
  final Value<DateTime?> createdAt;
  final Value<String?> description;
  final Value<String> memberId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.memberId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    required String memberId,
  }) : memberId = Value(memberId);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
    Expression<String>? memberId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (memberId != null) 'member_id': memberId,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? type,
      Value<int?>? amount,
      Value<DateTime?>? createdAt,
      Value<String?>? description,
      Value<String>? memberId}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      memberId: memberId ?? this.memberId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('memberId: $memberId')
          ..write(')'))
        .toString();
  }
}

class $ReservationsTable extends Reservations
    with TableInfo<$ReservationsTable, Reservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, memberId, createdAt, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reservations';
  @override
  VerificationContext validateIntegrity(Insertable<Reservation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reservation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $ReservationsTable createAlias(String alias) {
    return $ReservationsTable(attachedDatabase, alias);
  }
}

class Reservation extends DataClass implements Insertable<Reservation> {
  final int id;
  final String bookId;
  final String memberId;
  final DateTime createdAt;

  /// int status: 0=Active, 1=Fulfilled, 2=Cancelled (suggested)
  final int status;
  const Reservation(
      {required this.id,
      required this.bookId,
      required this.memberId,
      required this.createdAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<String>(bookId);
    map['member_id'] = Variable<String>(memberId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<int>(status);
    return map;
  }

  ReservationsCompanion toCompanion(bool nullToAbsent) {
    return ReservationsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      memberId: Value(memberId),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory Reservation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reservation(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<String>(bookId),
      'memberId': serializer.toJson<String>(memberId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<int>(status),
    };
  }

  Reservation copyWith(
          {int? id,
          String? bookId,
          String? memberId,
          DateTime? createdAt,
          int? status}) =>
      Reservation(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        memberId: memberId ?? this.memberId,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );
  Reservation copyWithCompanion(ReservationsCompanion data) {
    return Reservation(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reservation(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, memberId, createdAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reservation &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.memberId == this.memberId &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class ReservationsCompanion extends UpdateCompanion<Reservation> {
  final Value<int> id;
  final Value<String> bookId;
  final Value<String> memberId;
  final Value<DateTime> createdAt;
  final Value<int> status;
  const ReservationsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  ReservationsCompanion.insert({
    this.id = const Value.absent(),
    required String bookId,
    required String memberId,
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
  })  : bookId = Value(bookId),
        memberId = Value(memberId);
  static Insertable<Reservation> custom({
    Expression<int>? id,
    Expression<String>? bookId,
    Expression<String>? memberId,
    Expression<DateTime>? createdAt,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (memberId != null) 'member_id': memberId,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
    });
  }

  ReservationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? bookId,
      Value<String>? memberId,
      Value<DateTime>? createdAt,
      Value<int>? status}) {
    return ReservationsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      memberId: memberId ?? this.memberId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReservationsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('memberId: $memberId, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RenewalsTable extends Renewals with TableInfo<$RenewalsTable, Renewal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RenewalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
      'loan_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 15),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _renewedAtMeta =
      const VerificationMeta('renewedAt');
  @override
  late final GeneratedColumn<DateTime> renewedAt = GeneratedColumn<DateTime>(
      'renewed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _oldDueDateMeta =
      const VerificationMeta('oldDueDate');
  @override
  late final GeneratedColumn<DateTime> oldDueDate = GeneratedColumn<DateTime>(
      'old_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _newDueDateMeta =
      const VerificationMeta('newDueDate');
  @override
  late final GeneratedColumn<DateTime> newDueDate = GeneratedColumn<DateTime>(
      'new_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, loanId, renewedAt, oldDueDate, newDueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'renewals';
  @override
  VerificationContext validateIntegrity(Insertable<Renewal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    if (data.containsKey('renewed_at')) {
      context.handle(_renewedAtMeta,
          renewedAt.isAcceptableOrUnknown(data['renewed_at']!, _renewedAtMeta));
    }
    if (data.containsKey('old_due_date')) {
      context.handle(
          _oldDueDateMeta,
          oldDueDate.isAcceptableOrUnknown(
              data['old_due_date']!, _oldDueDateMeta));
    } else if (isInserting) {
      context.missing(_oldDueDateMeta);
    }
    if (data.containsKey('new_due_date')) {
      context.handle(
          _newDueDateMeta,
          newDueDate.isAcceptableOrUnknown(
              data['new_due_date']!, _newDueDateMeta));
    } else if (isInserting) {
      context.missing(_newDueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Renewal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Renewal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_id'])!,
      renewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}renewed_at'])!,
      oldDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}old_due_date'])!,
      newDueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}new_due_date'])!,
    );
  }

  @override
  $RenewalsTable createAlias(String alias) {
    return $RenewalsTable(attachedDatabase, alias);
  }
}

class Renewal extends DataClass implements Insertable<Renewal> {
  final int id;
  final String loanId;
  final DateTime renewedAt;
  final DateTime oldDueDate;
  final DateTime newDueDate;
  const Renewal(
      {required this.id,
      required this.loanId,
      required this.renewedAt,
      required this.oldDueDate,
      required this.newDueDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['loan_id'] = Variable<String>(loanId);
    map['renewed_at'] = Variable<DateTime>(renewedAt);
    map['old_due_date'] = Variable<DateTime>(oldDueDate);
    map['new_due_date'] = Variable<DateTime>(newDueDate);
    return map;
  }

  RenewalsCompanion toCompanion(bool nullToAbsent) {
    return RenewalsCompanion(
      id: Value(id),
      loanId: Value(loanId),
      renewedAt: Value(renewedAt),
      oldDueDate: Value(oldDueDate),
      newDueDate: Value(newDueDate),
    );
  }

  factory Renewal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Renewal(
      id: serializer.fromJson<int>(json['id']),
      loanId: serializer.fromJson<String>(json['loanId']),
      renewedAt: serializer.fromJson<DateTime>(json['renewedAt']),
      oldDueDate: serializer.fromJson<DateTime>(json['oldDueDate']),
      newDueDate: serializer.fromJson<DateTime>(json['newDueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'loanId': serializer.toJson<String>(loanId),
      'renewedAt': serializer.toJson<DateTime>(renewedAt),
      'oldDueDate': serializer.toJson<DateTime>(oldDueDate),
      'newDueDate': serializer.toJson<DateTime>(newDueDate),
    };
  }

  Renewal copyWith(
          {int? id,
          String? loanId,
          DateTime? renewedAt,
          DateTime? oldDueDate,
          DateTime? newDueDate}) =>
      Renewal(
        id: id ?? this.id,
        loanId: loanId ?? this.loanId,
        renewedAt: renewedAt ?? this.renewedAt,
        oldDueDate: oldDueDate ?? this.oldDueDate,
        newDueDate: newDueDate ?? this.newDueDate,
      );
  Renewal copyWithCompanion(RenewalsCompanion data) {
    return Renewal(
      id: data.id.present ? data.id.value : this.id,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      renewedAt: data.renewedAt.present ? data.renewedAt.value : this.renewedAt,
      oldDueDate:
          data.oldDueDate.present ? data.oldDueDate.value : this.oldDueDate,
      newDueDate:
          data.newDueDate.present ? data.newDueDate.value : this.newDueDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Renewal(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('renewedAt: $renewedAt, ')
          ..write('oldDueDate: $oldDueDate, ')
          ..write('newDueDate: $newDueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, loanId, renewedAt, oldDueDate, newDueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Renewal &&
          other.id == this.id &&
          other.loanId == this.loanId &&
          other.renewedAt == this.renewedAt &&
          other.oldDueDate == this.oldDueDate &&
          other.newDueDate == this.newDueDate);
}

class RenewalsCompanion extends UpdateCompanion<Renewal> {
  final Value<int> id;
  final Value<String> loanId;
  final Value<DateTime> renewedAt;
  final Value<DateTime> oldDueDate;
  final Value<DateTime> newDueDate;
  const RenewalsCompanion({
    this.id = const Value.absent(),
    this.loanId = const Value.absent(),
    this.renewedAt = const Value.absent(),
    this.oldDueDate = const Value.absent(),
    this.newDueDate = const Value.absent(),
  });
  RenewalsCompanion.insert({
    this.id = const Value.absent(),
    required String loanId,
    this.renewedAt = const Value.absent(),
    required DateTime oldDueDate,
    required DateTime newDueDate,
  })  : loanId = Value(loanId),
        oldDueDate = Value(oldDueDate),
        newDueDate = Value(newDueDate);
  static Insertable<Renewal> custom({
    Expression<int>? id,
    Expression<String>? loanId,
    Expression<DateTime>? renewedAt,
    Expression<DateTime>? oldDueDate,
    Expression<DateTime>? newDueDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loanId != null) 'loan_id': loanId,
      if (renewedAt != null) 'renewed_at': renewedAt,
      if (oldDueDate != null) 'old_due_date': oldDueDate,
      if (newDueDate != null) 'new_due_date': newDueDate,
    });
  }

  RenewalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? loanId,
      Value<DateTime>? renewedAt,
      Value<DateTime>? oldDueDate,
      Value<DateTime>? newDueDate}) {
    return RenewalsCompanion(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      renewedAt: renewedAt ?? this.renewedAt,
      oldDueDate: oldDueDate ?? this.oldDueDate,
      newDueDate: newDueDate ?? this.newDueDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (renewedAt.present) {
      map['renewed_at'] = Variable<DateTime>(renewedAt.value);
    }
    if (oldDueDate.present) {
      map['old_due_date'] = Variable<DateTime>(oldDueDate.value);
    }
    if (newDueDate.present) {
      map['new_due_date'] = Variable<DateTime>(newDueDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RenewalsCompanion(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('renewedAt: $renewedAt, ')
          ..write('oldDueDate: $oldDueDate, ')
          ..write('newDueDate: $newDueDate')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts with TableInfo<$ReceiptsTable, Receipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _memberIdMeta =
      const VerificationMeta('memberId');
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
      'member_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
      'loan_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 0, maxTextLength: 15),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memberId,
        loanId,
        transactionId,
        createdAt,
        type,
        title,
        payloadJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(Insertable<Receipt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('member_id')) {
      context.handle(_memberIdMeta,
          memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta));
    }
    if (data.containsKey('loan_id')) {
      context.handle(_loanIdMeta,
          loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receipt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      memberId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_id']),
      loanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_id']),
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class Receipt extends DataClass implements Insertable<Receipt> {
  final int id;

  /// Optional linkage
  final String? memberId;
  final String? loanId;
  final int? transactionId;
  final DateTime createdAt;

  /// Receipt type: e.g. 'checkout', 'checkin', 'subscription_fee', 'fine'
  final String type;

  /// Human-friendly summary string (for quick lists)
  final String title;

  /// JSON blob for full details (line items, totals, etc.).
  final String payloadJson;
  const Receipt(
      {required this.id,
      this.memberId,
      this.loanId,
      this.transactionId,
      required this.createdAt,
      required this.type,
      required this.title,
      required this.payloadJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || memberId != null) {
      map['member_id'] = Variable<String>(memberId);
    }
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<String>(loanId);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      memberId: memberId == null && nullToAbsent
          ? const Value.absent()
          : Value(memberId),
      loanId:
          loanId == null && nullToAbsent ? const Value.absent() : Value(loanId),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      createdAt: Value(createdAt),
      type: Value(type),
      title: Value(title),
      payloadJson: Value(payloadJson),
    );
  }

  factory Receipt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receipt(
      id: serializer.fromJson<int>(json['id']),
      memberId: serializer.fromJson<String?>(json['memberId']),
      loanId: serializer.fromJson<String?>(json['loanId']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memberId': serializer.toJson<String?>(memberId),
      'loanId': serializer.toJson<String?>(loanId),
      'transactionId': serializer.toJson<int?>(transactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'payloadJson': serializer.toJson<String>(payloadJson),
    };
  }

  Receipt copyWith(
          {int? id,
          Value<String?> memberId = const Value.absent(),
          Value<String?> loanId = const Value.absent(),
          Value<int?> transactionId = const Value.absent(),
          DateTime? createdAt,
          String? type,
          String? title,
          String? payloadJson}) =>
      Receipt(
        id: id ?? this.id,
        memberId: memberId.present ? memberId.value : this.memberId,
        loanId: loanId.present ? loanId.value : this.loanId,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        createdAt: createdAt ?? this.createdAt,
        type: type ?? this.type,
        title: title ?? this.title,
        payloadJson: payloadJson ?? this.payloadJson,
      );
  Receipt copyWithCompanion(ReceiptsCompanion data) {
    return Receipt(
      id: data.id.present ? data.id.value : this.id,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receipt(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('loanId: $loanId, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, memberId, loanId, transactionId, createdAt, type, title, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receipt &&
          other.id == this.id &&
          other.memberId == this.memberId &&
          other.loanId == this.loanId &&
          other.transactionId == this.transactionId &&
          other.createdAt == this.createdAt &&
          other.type == this.type &&
          other.title == this.title &&
          other.payloadJson == this.payloadJson);
}

class ReceiptsCompanion extends UpdateCompanion<Receipt> {
  final Value<int> id;
  final Value<String?> memberId;
  final Value<String?> loanId;
  final Value<int?> transactionId;
  final Value<DateTime> createdAt;
  final Value<String> type;
  final Value<String> title;
  final Value<String> payloadJson;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.payloadJson = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    this.id = const Value.absent(),
    this.memberId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String type,
    required String title,
    required String payloadJson,
  })  : type = Value(type),
        title = Value(title),
        payloadJson = Value(payloadJson);
  static Insertable<Receipt> custom({
    Expression<int>? id,
    Expression<String>? memberId,
    Expression<String>? loanId,
    Expression<int>? transactionId,
    Expression<DateTime>? createdAt,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? payloadJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memberId != null) 'member_id': memberId,
      if (loanId != null) 'loan_id': loanId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (createdAt != null) 'created_at': createdAt,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (payloadJson != null) 'payload_json': payloadJson,
    });
  }

  ReceiptsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? memberId,
      Value<String?>? loanId,
      Value<int?>? transactionId,
      Value<DateTime>? createdAt,
      Value<String>? type,
      Value<String>? title,
      Value<String>? payloadJson}) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      loanId: loanId ?? this.loanId,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      title: title ?? this.title,
      payloadJson: payloadJson ?? this.payloadJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('memberId: $memberId, ')
          ..write('loanId: $loanId, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $MembersTable members = $MembersTable(this);
  late final $StaffAccountsTable staffAccounts = $StaffAccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PublishersTable publishers = $PublishersTable(this);
  late final $AuthorsTable authors = $AuthorsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookAuthorsTable bookAuthors = $BookAuthorsTable(this);
  late final $BookCopiesTable bookCopies = $BookCopiesTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $FinesTable fines = $FinesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ReservationsTable reservations = $ReservationsTable(this);
  late final $RenewalsTable renewals = $RenewalsTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        subscriptions,
        members,
        staffAccounts,
        categories,
        publishers,
        authors,
        books,
        bookAuthors,
        bookCopies,
        loans,
        fines,
        transactions,
        reservations,
        renewals,
        receipts
      ];
}

typedef $$SubscriptionsTableCreateCompanionBuilder = SubscriptionsCompanion
    Function({
  required String id,
  Value<String?> name,
  Value<int?> monthlyFee,
  Value<int?> deposit,
  Value<int?> maxBooks,
  Value<int?> maxDays,
  Value<String?> description,
  Value<bool> allowReservation,
  Value<bool> allowRenewal,
  Value<int> rowid,
});
typedef $$SubscriptionsTableUpdateCompanionBuilder = SubscriptionsCompanion
    Function({
  Value<String> id,
  Value<String?> name,
  Value<int?> monthlyFee,
  Value<int?> deposit,
  Value<int?> maxBooks,
  Value<int?> maxDays,
  Value<String?> description,
  Value<bool> allowReservation,
  Value<bool> allowRenewal,
  Value<int> rowid,
});

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
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

  ColumnFilters<int> get monthlyFee => $composableBuilder(
      column: $table.monthlyFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxBooks => $composableBuilder(
      column: $table.maxBooks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDays => $composableBuilder(
      column: $table.maxDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allowReservation => $composableBuilder(
      column: $table.allowReservation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allowRenewal => $composableBuilder(
      column: $table.allowRenewal, builder: (column) => ColumnFilters(column));
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
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

  ColumnOrderings<int> get monthlyFee => $composableBuilder(
      column: $table.monthlyFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxBooks => $composableBuilder(
      column: $table.maxBooks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDays => $composableBuilder(
      column: $table.maxDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allowReservation => $composableBuilder(
      column: $table.allowReservation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allowRenewal => $composableBuilder(
      column: $table.allowRenewal,
      builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
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

  GeneratedColumn<int> get monthlyFee => $composableBuilder(
      column: $table.monthlyFee, builder: (column) => column);

  GeneratedColumn<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<int> get maxBooks =>
      $composableBuilder(column: $table.maxBooks, builder: (column) => column);

  GeneratedColumn<int> get maxDays =>
      $composableBuilder(column: $table.maxDays, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get allowReservation => $composableBuilder(
      column: $table.allowReservation, builder: (column) => column);

  GeneratedColumn<bool> get allowRenewal => $composableBuilder(
      column: $table.allowRenewal, builder: (column) => column);
}

class $$SubscriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()> {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> monthlyFee = const Value.absent(),
            Value<int?> deposit = const Value.absent(),
            Value<int?> maxBooks = const Value.absent(),
            Value<int?> maxDays = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> allowReservation = const Value.absent(),
            Value<bool> allowRenewal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionsCompanion(
            id: id,
            name: name,
            monthlyFee: monthlyFee,
            deposit: deposit,
            maxBooks: maxBooks,
            maxDays: maxDays,
            description: description,
            allowReservation: allowReservation,
            allowRenewal: allowRenewal,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            Value<int?> monthlyFee = const Value.absent(),
            Value<int?> deposit = const Value.absent(),
            Value<int?> maxBooks = const Value.absent(),
            Value<int?> maxDays = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> allowReservation = const Value.absent(),
            Value<bool> allowRenewal = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionsCompanion.insert(
            id: id,
            name: name,
            monthlyFee: monthlyFee,
            deposit: deposit,
            maxBooks: maxBooks,
            maxDays: maxDays,
            description: description,
            allowReservation: allowReservation,
            allowRenewal: allowRenewal,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubscriptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubscriptionsTable,
    Subscription,
    $$SubscriptionsTableFilterComposer,
    $$SubscriptionsTableOrderingComposer,
    $$SubscriptionsTableAnnotationComposer,
    $$SubscriptionsTableCreateCompanionBuilder,
    $$SubscriptionsTableUpdateCompanionBuilder,
    (
      Subscription,
      BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription>
    ),
    Subscription,
    PrefetchHooks Function()>;
typedef $$MembersTableCreateCompanionBuilder = MembersCompanion Function({
  required String id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<DateTime?> dateOfBirth,
  Value<String?> phone,
  required String nationalId,
  required String email,
  Value<String?> address,
  Value<DateTime?> subscriptionExpiryDate,
  Value<int> walletBalance,
  Value<int> points,
  Value<bool?> isActive,
  required String subscriptionId,
  Value<String?> avatarPath,
  Value<String?> password,
  Value<int> rowid,
});
typedef $$MembersTableUpdateCompanionBuilder = MembersCompanion Function({
  Value<String> id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<DateTime?> dateOfBirth,
  Value<String?> phone,
  Value<String> nationalId,
  Value<String> email,
  Value<String?> address,
  Value<DateTime?> subscriptionExpiryDate,
  Value<int> walletBalance,
  Value<int> points,
  Value<bool?> isActive,
  Value<String> subscriptionId,
  Value<String?> avatarPath,
  Value<String?> password,
  Value<int> rowid,
});

final class $$MembersTableReferences
    extends BaseReferences<_$AppDatabase, $MembersTable, Member> {
  $$MembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName: $_aliasNameGenerator(db.members.id, db.loans.memberId));

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.memberId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MembersTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get subscriptionExpiryDate => $composableBuilder(
      column: $table.subscriptionExpiryDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subscriptionId => $composableBuilder(
      column: $table.subscriptionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  Expression<bool> loansRefs(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.memberId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MembersTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscriptionExpiryDate => $composableBuilder(
      column: $table.subscriptionExpiryDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subscriptionId => $composableBuilder(
      column: $table.subscriptionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));
}

class $$MembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTable> {
  $$MembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get subscriptionExpiryDate => $composableBuilder(
      column: $table.subscriptionExpiryDate, builder: (column) => column);

  GeneratedColumn<int> get walletBalance => $composableBuilder(
      column: $table.walletBalance, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get subscriptionId => $composableBuilder(
      column: $table.subscriptionId, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  Expression<T> loansRefs<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.memberId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, $$MembersTableReferences),
    Member,
    PrefetchHooks Function({bool loansRefs})> {
  $$MembersTableTableManager(_$AppDatabase db, $MembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> nationalId = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<DateTime?> subscriptionExpiryDate = const Value.absent(),
            Value<int> walletBalance = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<bool?> isActive = const Value.absent(),
            Value<String> subscriptionId = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            dateOfBirth: dateOfBirth,
            phone: phone,
            nationalId: nationalId,
            email: email,
            address: address,
            subscriptionExpiryDate: subscriptionExpiryDate,
            walletBalance: walletBalance,
            points: points,
            isActive: isActive,
            subscriptionId: subscriptionId,
            avatarPath: avatarPath,
            password: password,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            required String nationalId,
            required String email,
            Value<String?> address = const Value.absent(),
            Value<DateTime?> subscriptionExpiryDate = const Value.absent(),
            Value<int> walletBalance = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<bool?> isActive = const Value.absent(),
            required String subscriptionId,
            Value<String?> avatarPath = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembersCompanion.insert(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            dateOfBirth: dateOfBirth,
            phone: phone,
            nationalId: nationalId,
            email: email,
            address: address,
            subscriptionExpiryDate: subscriptionExpiryDate,
            walletBalance: walletBalance,
            points: points,
            isActive: isActive,
            subscriptionId: subscriptionId,
            avatarPath: avatarPath,
            password: password,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MembersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansRefs) db.loans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansRefs)
                    await $_getPrefetchedData<Member, $MembersTable, Loan>(
                        currentTable: table,
                        referencedTable:
                            $$MembersTableReferences._loansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MembersTableReferences(db, table, p0).loansRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.memberId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MembersTable,
    Member,
    $$MembersTableFilterComposer,
    $$MembersTableOrderingComposer,
    $$MembersTableAnnotationComposer,
    $$MembersTableCreateCompanionBuilder,
    $$MembersTableUpdateCompanionBuilder,
    (Member, $$MembersTableReferences),
    Member,
    PrefetchHooks Function({bool loansRefs})>;
typedef $$StaffAccountsTableCreateCompanionBuilder = StaffAccountsCompanion
    Function({
  required String id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<String?> role,
  required String username,
  required String password,
  Value<int> rowid,
});
typedef $$StaffAccountsTableUpdateCompanionBuilder = StaffAccountsCompanion
    Function({
  Value<String> id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<String?> role,
  Value<String> username,
  Value<String> password,
  Value<int> rowid,
});

class $$StaffAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));
}

class $$StaffAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));
}

class $$StaffAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffAccountsTable> {
  $$StaffAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);
}

class $$StaffAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StaffAccountsTable,
    StaffAccount,
    $$StaffAccountsTableFilterComposer,
    $$StaffAccountsTableOrderingComposer,
    $$StaffAccountsTableAnnotationComposer,
    $$StaffAccountsTableCreateCompanionBuilder,
    $$StaffAccountsTableUpdateCompanionBuilder,
    (
      StaffAccount,
      BaseReferences<_$AppDatabase, $StaffAccountsTable, StaffAccount>
    ),
    StaffAccount,
    PrefetchHooks Function()> {
  $$StaffAccountsTableTableManager(_$AppDatabase db, $StaffAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffAccountsCompanion(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            role: role,
            username: username,
            password: password,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> role = const Value.absent(),
            required String username,
            required String password,
            Value<int> rowid = const Value.absent(),
          }) =>
              StaffAccountsCompanion.insert(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            role: role,
            username: username,
            password: password,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StaffAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StaffAccountsTable,
    StaffAccount,
    $$StaffAccountsTableFilterComposer,
    $$StaffAccountsTableOrderingComposer,
    $$StaffAccountsTableAnnotationComposer,
    $$StaffAccountsTableCreateCompanionBuilder,
    $$StaffAccountsTableUpdateCompanionBuilder,
    (
      StaffAccount,
      BaseReferences<_$AppDatabase, $StaffAccountsTable, StaffAccount>
    ),
    StaffAccount,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String?> name,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String?> name,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.books,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.books.categoryId));

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  Expression<bool> booksRefs(
      Expression<bool> Function($$BooksTableFilterComposer f) f) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  Expression<T> booksRefs<T extends Object>(
      Expression<T> Function($$BooksTableAnnotationComposer a) f) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool booksRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable, Book>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._booksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .booksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool booksRefs})>;
typedef $$PublishersTableCreateCompanionBuilder = PublishersCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> address,
});
typedef $$PublishersTableUpdateCompanionBuilder = PublishersCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> address,
});

final class $$PublishersTableReferences
    extends BaseReferences<_$AppDatabase, $PublishersTable, Publisher> {
  $$PublishersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.books,
          aliasName:
              $_aliasNameGenerator(db.publishers.id, db.books.publisherId));

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.publisherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PublishersTableFilterComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  Expression<bool> booksRefs(
      Expression<bool> Function($$BooksTableFilterComposer f) f) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.publisherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PublishersTableOrderingComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));
}

class $$PublishersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableAnnotationComposer({
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

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  Expression<T> booksRefs<T extends Object>(
      Expression<T> Function($$BooksTableAnnotationComposer a) f) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.publisherId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PublishersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PublishersTable,
    Publisher,
    $$PublishersTableFilterComposer,
    $$PublishersTableOrderingComposer,
    $$PublishersTableAnnotationComposer,
    $$PublishersTableCreateCompanionBuilder,
    $$PublishersTableUpdateCompanionBuilder,
    (Publisher, $$PublishersTableReferences),
    Publisher,
    PrefetchHooks Function({bool booksRefs})> {
  $$PublishersTableTableManager(_$AppDatabase db, $PublishersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PublishersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PublishersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PublishersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
          }) =>
              PublishersCompanion(
            id: id,
            name: name,
            address: address,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> address = const Value.absent(),
          }) =>
              PublishersCompanion.insert(
            id: id,
            name: name,
            address: address,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PublishersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<Publisher, $PublishersTable,
                            Book>(
                        currentTable: table,
                        referencedTable:
                            $$PublishersTableReferences._booksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PublishersTableReferences(db, table, p0)
                                .booksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.publisherId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PublishersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PublishersTable,
    Publisher,
    $$PublishersTableFilterComposer,
    $$PublishersTableOrderingComposer,
    $$PublishersTableAnnotationComposer,
    $$PublishersTableCreateCompanionBuilder,
    $$PublishersTableUpdateCompanionBuilder,
    (Publisher, $$PublishersTableReferences),
    Publisher,
    PrefetchHooks Function({bool booksRefs})>;
typedef $$AuthorsTableCreateCompanionBuilder = AuthorsCompanion Function({
  Value<int> id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<String?> hometown,
});
typedef $$AuthorsTableUpdateCompanionBuilder = AuthorsCompanion Function({
  Value<int> id,
  Value<String?> lastName,
  Value<String?> middleName,
  Value<String?> firstName,
  Value<String?> hometown,
});

final class $$AuthorsTableReferences
    extends BaseReferences<_$AppDatabase, $AuthorsTable, Author> {
  $$AuthorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookAuthorsTable, List<BookAuthor>>
      _bookAuthorsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookAuthors,
              aliasName:
                  $_aliasNameGenerator(db.authors.id, db.bookAuthors.authorId));

  $$BookAuthorsTableProcessedTableManager get bookAuthorsRefs {
    final manager = $$BookAuthorsTableTableManager($_db, $_db.bookAuthors)
        .filter((f) => f.authorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookAuthorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AuthorsTableFilterComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hometown => $composableBuilder(
      column: $table.hometown, builder: (column) => ColumnFilters(column));

  Expression<bool> bookAuthorsRefs(
      Expression<bool> Function($$BookAuthorsTableFilterComposer f) f) {
    final $$BookAuthorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookAuthors,
        getReferencedColumn: (t) => t.authorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookAuthorsTableFilterComposer(
              $db: $db,
              $table: $db.bookAuthors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AuthorsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hometown => $composableBuilder(
      column: $table.hometown, builder: (column) => ColumnOrderings(column));
}

class $$AuthorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get hometown =>
      $composableBuilder(column: $table.hometown, builder: (column) => column);

  Expression<T> bookAuthorsRefs<T extends Object>(
      Expression<T> Function($$BookAuthorsTableAnnotationComposer a) f) {
    final $$BookAuthorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookAuthors,
        getReferencedColumn: (t) => t.authorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookAuthorsTableAnnotationComposer(
              $db: $db,
              $table: $db.bookAuthors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AuthorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuthorsTable,
    Author,
    $$AuthorsTableFilterComposer,
    $$AuthorsTableOrderingComposer,
    $$AuthorsTableAnnotationComposer,
    $$AuthorsTableCreateCompanionBuilder,
    $$AuthorsTableUpdateCompanionBuilder,
    (Author, $$AuthorsTableReferences),
    Author,
    PrefetchHooks Function({bool bookAuthorsRefs})> {
  $$AuthorsTableTableManager(_$AppDatabase db, $AuthorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> hometown = const Value.absent(),
          }) =>
              AuthorsCompanion(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            hometown: hometown,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> hometown = const Value.absent(),
          }) =>
              AuthorsCompanion.insert(
            id: id,
            lastName: lastName,
            middleName: middleName,
            firstName: firstName,
            hometown: hometown,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AuthorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({bookAuthorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookAuthorsRefs) db.bookAuthors],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookAuthorsRefs)
                    await $_getPrefetchedData<Author, $AuthorsTable,
                            BookAuthor>(
                        currentTable: table,
                        referencedTable:
                            $$AuthorsTableReferences._bookAuthorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AuthorsTableReferences(db, table, p0)
                                .bookAuthorsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.authorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AuthorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuthorsTable,
    Author,
    $$AuthorsTableFilterComposer,
    $$AuthorsTableOrderingComposer,
    $$AuthorsTableAnnotationComposer,
    $$AuthorsTableCreateCompanionBuilder,
    $$AuthorsTableUpdateCompanionBuilder,
    (Author, $$AuthorsTableReferences),
    Author,
    PrefetchHooks Function({bool bookAuthorsRefs})>;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  required String id,
  Value<String?> title,
  Value<int?> publishedYear,
  Value<int?> coverPrice,
  Value<int?> totalQuantity,
  Value<String?> description,
  required int categoryId,
  required int publisherId,
  Value<String?> coverPath,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<String?> title,
  Value<int?> publishedYear,
  Value<int?> coverPrice,
  Value<int?> totalQuantity,
  Value<String?> description,
  Value<int> categoryId,
  Value<int> publisherId,
  Value<String?> coverPath,
  Value<int> rowid,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.books.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PublishersTable _publisherIdTable(_$AppDatabase db) =>
      db.publishers.createAlias(
          $_aliasNameGenerator(db.books.publisherId, db.publishers.id));

  $$PublishersTableProcessedTableManager get publisherId {
    final $_column = $_itemColumn<int>('publisher_id')!;

    final manager = $$PublishersTableTableManager($_db, $_db.publishers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_publisherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$BookAuthorsTable, List<BookAuthor>>
      _bookAuthorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.bookAuthors,
          aliasName: $_aliasNameGenerator(db.books.id, db.bookAuthors.bookId));

  $$BookAuthorsTableProcessedTableManager get bookAuthorsRefs {
    final manager = $$BookAuthorsTableTableManager($_db, $_db.bookAuthors)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookAuthorsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookCopiesTable, List<BookCopy>>
      _bookCopiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.bookCopies,
          aliasName: $_aliasNameGenerator(db.books.id, db.bookCopies.bookId));

  $$BookCopiesTableProcessedTableManager get bookCopiesRefs {
    final manager = $$BookCopiesTableTableManager($_db, $_db.bookCopies)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookCopiesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get publishedYear => $composableBuilder(
      column: $table.publishedYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coverPrice => $composableBuilder(
      column: $table.coverPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PublishersTableFilterComposer get publisherId {
    final $$PublishersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.publisherId,
        referencedTable: $db.publishers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PublishersTableFilterComposer(
              $db: $db,
              $table: $db.publishers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> bookAuthorsRefs(
      Expression<bool> Function($$BookAuthorsTableFilterComposer f) f) {
    final $$BookAuthorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookAuthors,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookAuthorsTableFilterComposer(
              $db: $db,
              $table: $db.bookAuthors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookCopiesRefs(
      Expression<bool> Function($$BookCopiesTableFilterComposer f) f) {
    final $$BookCopiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookCopies,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookCopiesTableFilterComposer(
              $db: $db,
              $table: $db.bookCopies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get publishedYear => $composableBuilder(
      column: $table.publishedYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coverPrice => $composableBuilder(
      column: $table.coverPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PublishersTableOrderingComposer get publisherId {
    final $$PublishersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.publisherId,
        referencedTable: $db.publishers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PublishersTableOrderingComposer(
              $db: $db,
              $table: $db.publishers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get publishedYear => $composableBuilder(
      column: $table.publishedYear, builder: (column) => column);

  GeneratedColumn<int> get coverPrice => $composableBuilder(
      column: $table.coverPrice, builder: (column) => column);

  GeneratedColumn<int> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PublishersTableAnnotationComposer get publisherId {
    final $$PublishersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.publisherId,
        referencedTable: $db.publishers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PublishersTableAnnotationComposer(
              $db: $db,
              $table: $db.publishers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> bookAuthorsRefs<T extends Object>(
      Expression<T> Function($$BookAuthorsTableAnnotationComposer a) f) {
    final $$BookAuthorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookAuthors,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookAuthorsTableAnnotationComposer(
              $db: $db,
              $table: $db.bookAuthors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bookCopiesRefs<T extends Object>(
      Expression<T> Function($$BookCopiesTableAnnotationComposer a) f) {
    final $$BookCopiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookCopies,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookCopiesTableAnnotationComposer(
              $db: $db,
              $table: $db.bookCopies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function(
        {bool categoryId,
        bool publisherId,
        bool bookAuthorsRefs,
        bool bookCopiesRefs})> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<int?> publishedYear = const Value.absent(),
            Value<int?> coverPrice = const Value.absent(),
            Value<int?> totalQuantity = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> publisherId = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            publishedYear: publishedYear,
            coverPrice: coverPrice,
            totalQuantity: totalQuantity,
            description: description,
            categoryId: categoryId,
            publisherId: publisherId,
            coverPath: coverPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            Value<int?> publishedYear = const Value.absent(),
            Value<int?> coverPrice = const Value.absent(),
            Value<int?> totalQuantity = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required int categoryId,
            required int publisherId,
            Value<String?> coverPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            publishedYear: publishedYear,
            coverPrice: coverPrice,
            totalQuantity: totalQuantity,
            description: description,
            categoryId: categoryId,
            publisherId: publisherId,
            coverPath: coverPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BooksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false,
              publisherId = false,
              bookAuthorsRefs = false,
              bookCopiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookAuthorsRefs) db.bookAuthors,
                if (bookCopiesRefs) db.bookCopies
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BooksTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BooksTableReferences._categoryIdTable(db).id,
                  ) as T;
                }
                if (publisherId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.publisherId,
                    referencedTable:
                        $$BooksTableReferences._publisherIdTable(db),
                    referencedColumn:
                        $$BooksTableReferences._publisherIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookAuthorsRefs)
                    await $_getPrefetchedData<Book, $BooksTable, BookAuthor>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._bookAuthorsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .bookAuthorsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (bookCopiesRefs)
                    await $_getPrefetchedData<Book, $BooksTable, BookCopy>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._bookCopiesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .bookCopiesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, $$BooksTableReferences),
    Book,
    PrefetchHooks Function(
        {bool categoryId,
        bool publisherId,
        bool bookAuthorsRefs,
        bool bookCopiesRefs})>;
typedef $$BookAuthorsTableCreateCompanionBuilder = BookAuthorsCompanion
    Function({
  required String bookId,
  required int authorId,
  Value<String?> role,
  Value<int> rowid,
});
typedef $$BookAuthorsTableUpdateCompanionBuilder = BookAuthorsCompanion
    Function({
  Value<String> bookId,
  Value<int> authorId,
  Value<String?> role,
  Value<int> rowid,
});

final class $$BookAuthorsTableReferences
    extends BaseReferences<_$AppDatabase, $BookAuthorsTable, BookAuthor> {
  $$BookAuthorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books
      .createAlias($_aliasNameGenerator(db.bookAuthors.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AuthorsTable _authorIdTable(_$AppDatabase db) =>
      db.authors.createAlias(
          $_aliasNameGenerator(db.bookAuthors.authorId, db.authors.id));

  $$AuthorsTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<int>('author_id')!;

    final manager = $$AuthorsTableTableManager($_db, $_db.authors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookAuthorsTableFilterComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AuthorsTableFilterComposer get authorId {
    final $$AuthorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.authors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuthorsTableFilterComposer(
              $db: $db,
              $table: $db.authors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookAuthorsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AuthorsTableOrderingComposer get authorId {
    final $$AuthorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.authors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuthorsTableOrderingComposer(
              $db: $db,
              $table: $db.authors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookAuthorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AuthorsTableAnnotationComposer get authorId {
    final $$AuthorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.authorId,
        referencedTable: $db.authors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AuthorsTableAnnotationComposer(
              $db: $db,
              $table: $db.authors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookAuthorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookAuthorsTable,
    BookAuthor,
    $$BookAuthorsTableFilterComposer,
    $$BookAuthorsTableOrderingComposer,
    $$BookAuthorsTableAnnotationComposer,
    $$BookAuthorsTableCreateCompanionBuilder,
    $$BookAuthorsTableUpdateCompanionBuilder,
    (BookAuthor, $$BookAuthorsTableReferences),
    BookAuthor,
    PrefetchHooks Function({bool bookId, bool authorId})> {
  $$BookAuthorsTableTableManager(_$AppDatabase db, $BookAuthorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookAuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookAuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookAuthorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookId = const Value.absent(),
            Value<int> authorId = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookAuthorsCompanion(
            bookId: bookId,
            authorId: authorId,
            role: role,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookId,
            required int authorId,
            Value<String?> role = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookAuthorsCompanion.insert(
            bookId: bookId,
            authorId: authorId,
            role: role,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookAuthorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$BookAuthorsTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$BookAuthorsTableReferences._bookIdTable(db).id,
                  ) as T;
                }
                if (authorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.authorId,
                    referencedTable:
                        $$BookAuthorsTableReferences._authorIdTable(db),
                    referencedColumn:
                        $$BookAuthorsTableReferences._authorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookAuthorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookAuthorsTable,
    BookAuthor,
    $$BookAuthorsTableFilterComposer,
    $$BookAuthorsTableOrderingComposer,
    $$BookAuthorsTableAnnotationComposer,
    $$BookAuthorsTableCreateCompanionBuilder,
    $$BookAuthorsTableUpdateCompanionBuilder,
    (BookAuthor, $$BookAuthorsTableReferences),
    BookAuthor,
    PrefetchHooks Function({bool bookId, bool authorId})>;
typedef $$BookCopiesTableCreateCompanionBuilder = BookCopiesCompanion Function({
  required String id,
  Value<String?> location,
  Value<String?> condition,
  Value<int?> status,
  required String bookId,
  Value<int> rowid,
});
typedef $$BookCopiesTableUpdateCompanionBuilder = BookCopiesCompanion Function({
  Value<String> id,
  Value<String?> location,
  Value<String?> condition,
  Value<int?> status,
  Value<String> bookId,
  Value<int> rowid,
});

final class $$BookCopiesTableReferences
    extends BaseReferences<_$AppDatabase, $BookCopiesTable, BookCopy> {
  $$BookCopiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) => db.books
      .createAlias($_aliasNameGenerator(db.bookCopies.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.loans,
          aliasName: $_aliasNameGenerator(db.bookCopies.id, db.loans.copyId));

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager($_db, $_db.loans)
        .filter((f) => f.copyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BookCopiesTableFilterComposer
    extends Composer<_$AppDatabase, $BookCopiesTable> {
  $$BookCopiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> loansRefs(
      Expression<bool> Function($$LoansTableFilterComposer f) f) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.copyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableFilterComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BookCopiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookCopiesTable> {
  $$BookCopiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookCopiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookCopiesTable> {
  $$BookCopiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> loansRefs<T extends Object>(
      Expression<T> Function($$LoansTableAnnotationComposer a) f) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.loans,
        getReferencedColumn: (t) => t.copyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LoansTableAnnotationComposer(
              $db: $db,
              $table: $db.loans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BookCopiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookCopiesTable,
    BookCopy,
    $$BookCopiesTableFilterComposer,
    $$BookCopiesTableOrderingComposer,
    $$BookCopiesTableAnnotationComposer,
    $$BookCopiesTableCreateCompanionBuilder,
    $$BookCopiesTableUpdateCompanionBuilder,
    (BookCopy, $$BookCopiesTableReferences),
    BookCopy,
    PrefetchHooks Function({bool bookId, bool loansRefs})> {
  $$BookCopiesTableTableManager(_$AppDatabase db, $BookCopiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookCopiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookCopiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookCopiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<int?> status = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookCopiesCompanion(
            id: id,
            location: location,
            condition: condition,
            status: status,
            bookId: bookId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> location = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<int?> status = const Value.absent(),
            required String bookId,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookCopiesCompanion.insert(
            id: id,
            location: location,
            condition: condition,
            status: status,
            bookId: bookId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BookCopiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false, loansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loansRefs) db.loans],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$BookCopiesTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$BookCopiesTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loansRefs)
                    await $_getPrefetchedData<BookCopy, $BookCopiesTable, Loan>(
                        currentTable: table,
                        referencedTable:
                            $$BookCopiesTableReferences._loansRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BookCopiesTableReferences(db, table, p0)
                                .loansRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.copyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BookCopiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookCopiesTable,
    BookCopy,
    $$BookCopiesTableFilterComposer,
    $$BookCopiesTableOrderingComposer,
    $$BookCopiesTableAnnotationComposer,
    $$BookCopiesTableCreateCompanionBuilder,
    $$BookCopiesTableUpdateCompanionBuilder,
    (BookCopy, $$BookCopiesTableReferences),
    BookCopy,
    PrefetchHooks Function({bool bookId, bool loansRefs})>;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  required String memberId,
  required String copyId,
  required DateTime borrowDate,
  required DateTime dueDate,
  Value<DateTime?> returnDate,
  Value<int> status,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  Value<String> memberId,
  Value<String> copyId,
  Value<DateTime> borrowDate,
  Value<DateTime> dueDate,
  Value<DateTime?> returnDate,
  Value<int> status,
});

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MembersTable _memberIdTable(_$AppDatabase db) => db.members
      .createAlias($_aliasNameGenerator(db.loans.memberId, db.members.id));

  $$MembersTableProcessedTableManager get memberId {
    final $_column = $_itemColumn<String>('member_id')!;

    final manager = $$MembersTableTableManager($_db, $_db.members)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BookCopiesTable _copyIdTable(_$AppDatabase db) => db.bookCopies
      .createAlias($_aliasNameGenerator(db.loans.copyId, db.bookCopies.id));

  $$BookCopiesTableProcessedTableManager get copyId {
    final $_column = $_itemColumn<String>('copy_id')!;

    final manager = $$BookCopiesTableTableManager($_db, $_db.bookCopies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_copyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get borrowDate => $composableBuilder(
      column: $table.borrowDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$MembersTableFilterComposer get memberId {
    final $$MembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableFilterComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BookCopiesTableFilterComposer get copyId {
    final $$BookCopiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.copyId,
        referencedTable: $db.bookCopies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookCopiesTableFilterComposer(
              $db: $db,
              $table: $db.bookCopies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get borrowDate => $composableBuilder(
      column: $table.borrowDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$MembersTableOrderingComposer get memberId {
    final $$MembersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableOrderingComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BookCopiesTableOrderingComposer get copyId {
    final $$BookCopiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.copyId,
        referencedTable: $db.bookCopies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookCopiesTableOrderingComposer(
              $db: $db,
              $table: $db.bookCopies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get borrowDate => $composableBuilder(
      column: $table.borrowDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get returnDate => $composableBuilder(
      column: $table.returnDate, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$MembersTableAnnotationComposer get memberId {
    final $$MembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.memberId,
        referencedTable: $db.members,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MembersTableAnnotationComposer(
              $db: $db,
              $table: $db.members,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BookCopiesTableAnnotationComposer get copyId {
    final $$BookCopiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.copyId,
        referencedTable: $db.bookCopies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookCopiesTableAnnotationComposer(
              $db: $db,
              $table: $db.bookCopies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LoansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, $$LoansTableReferences),
    Loan,
    PrefetchHooks Function({bool memberId, bool copyId})> {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> copyId = const Value.absent(),
            Value<DateTime> borrowDate = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<DateTime?> returnDate = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              LoansCompanion(
            id: id,
            memberId: memberId,
            copyId: copyId,
            borrowDate: borrowDate,
            dueDate: dueDate,
            returnDate: returnDate,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String memberId,
            required String copyId,
            required DateTime borrowDate,
            required DateTime dueDate,
            Value<DateTime?> returnDate = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              LoansCompanion.insert(
            id: id,
            memberId: memberId,
            copyId: copyId,
            borrowDate: borrowDate,
            dueDate: dueDate,
            returnDate: returnDate,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LoansTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({memberId = false, copyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (memberId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.memberId,
                    referencedTable: $$LoansTableReferences._memberIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._memberIdTable(db).id,
                  ) as T;
                }
                if (copyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.copyId,
                    referencedTable: $$LoansTableReferences._copyIdTable(db),
                    referencedColumn:
                        $$LoansTableReferences._copyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LoansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, $$LoansTableReferences),
    Loan,
    PrefetchHooks Function({bool memberId, bool copyId})>;
typedef $$FinesTableCreateCompanionBuilder = FinesCompanion Function({
  Value<int> id,
  Value<DateTime?> createdAt,
  Value<int?> totalAmount,
  Value<String?> reason,
  Value<bool?> isPaid,
  required String memberId,
  required String loanId,
});
typedef $$FinesTableUpdateCompanionBuilder = FinesCompanion Function({
  Value<int> id,
  Value<DateTime?> createdAt,
  Value<int?> totalAmount,
  Value<String?> reason,
  Value<bool?> isPaid,
  Value<String> memberId,
  Value<String> loanId,
});

class $$FinesTableFilterComposer extends Composer<_$AppDatabase, $FinesTable> {
  $$FinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnFilters(column));
}

class $$FinesTableOrderingComposer
    extends Composer<_$AppDatabase, $FinesTable> {
  $$FinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnOrderings(column));
}

class $$FinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinesTable> {
  $$FinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);
}

class $$FinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FinesTable,
    Fine,
    $$FinesTableFilterComposer,
    $$FinesTableOrderingComposer,
    $$FinesTableAnnotationComposer,
    $$FinesTableCreateCompanionBuilder,
    $$FinesTableUpdateCompanionBuilder,
    (Fine, BaseReferences<_$AppDatabase, $FinesTable, Fine>),
    Fine,
    PrefetchHooks Function()> {
  $$FinesTableTableManager(_$AppDatabase db, $FinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int?> totalAmount = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<bool?> isPaid = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<String> loanId = const Value.absent(),
          }) =>
              FinesCompanion(
            id: id,
            createdAt: createdAt,
            totalAmount: totalAmount,
            reason: reason,
            isPaid: isPaid,
            memberId: memberId,
            loanId: loanId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int?> totalAmount = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<bool?> isPaid = const Value.absent(),
            required String memberId,
            required String loanId,
          }) =>
              FinesCompanion.insert(
            id: id,
            createdAt: createdAt,
            totalAmount: totalAmount,
            reason: reason,
            isPaid: isPaid,
            memberId: memberId,
            loanId: loanId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FinesTable,
    Fine,
    $$FinesTableFilterComposer,
    $$FinesTableOrderingComposer,
    $$FinesTableAnnotationComposer,
    $$FinesTableCreateCompanionBuilder,
    $$FinesTableUpdateCompanionBuilder,
    (Fine, BaseReferences<_$AppDatabase, $FinesTable, Fine>),
    Fine,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<String?> type,
  Value<int?> amount,
  Value<DateTime?> createdAt,
  Value<String?> description,
  required String memberId,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<String?> type,
  Value<int?> amount,
  Value<DateTime?> createdAt,
  Value<String?> description,
  Value<String> memberId,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<int?> amount = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> memberId = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            createdAt: createdAt,
            description: description,
            memberId: memberId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<int?> amount = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required String memberId,
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            createdAt: createdAt,
            description: description,
            memberId: memberId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$ReservationsTableCreateCompanionBuilder = ReservationsCompanion
    Function({
  Value<int> id,
  required String bookId,
  required String memberId,
  Value<DateTime> createdAt,
  Value<int> status,
});
typedef $$ReservationsTableUpdateCompanionBuilder = ReservationsCompanion
    Function({
  Value<int> id,
  Value<String> bookId,
  Value<String> memberId,
  Value<DateTime> createdAt,
  Value<int> status,
});

class $$ReservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$ReservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$ReservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ReservationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReservationsTable,
    Reservation,
    $$ReservationsTableFilterComposer,
    $$ReservationsTableOrderingComposer,
    $$ReservationsTableAnnotationComposer,
    $$ReservationsTableCreateCompanionBuilder,
    $$ReservationsTableUpdateCompanionBuilder,
    (
      Reservation,
      BaseReferences<_$AppDatabase, $ReservationsTable, Reservation>
    ),
    Reservation,
    PrefetchHooks Function()> {
  $$ReservationsTableTableManager(_$AppDatabase db, $ReservationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> memberId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              ReservationsCompanion(
            id: id,
            bookId: bookId,
            memberId: memberId,
            createdAt: createdAt,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String bookId,
            required String memberId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              ReservationsCompanion.insert(
            id: id,
            bookId: bookId,
            memberId: memberId,
            createdAt: createdAt,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReservationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReservationsTable,
    Reservation,
    $$ReservationsTableFilterComposer,
    $$ReservationsTableOrderingComposer,
    $$ReservationsTableAnnotationComposer,
    $$ReservationsTableCreateCompanionBuilder,
    $$ReservationsTableUpdateCompanionBuilder,
    (
      Reservation,
      BaseReferences<_$AppDatabase, $ReservationsTable, Reservation>
    ),
    Reservation,
    PrefetchHooks Function()>;
typedef $$RenewalsTableCreateCompanionBuilder = RenewalsCompanion Function({
  Value<int> id,
  required String loanId,
  Value<DateTime> renewedAt,
  required DateTime oldDueDate,
  required DateTime newDueDate,
});
typedef $$RenewalsTableUpdateCompanionBuilder = RenewalsCompanion Function({
  Value<int> id,
  Value<String> loanId,
  Value<DateTime> renewedAt,
  Value<DateTime> oldDueDate,
  Value<DateTime> newDueDate,
});

class $$RenewalsTableFilterComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get renewedAt => $composableBuilder(
      column: $table.renewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => ColumnFilters(column));
}

class $$RenewalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get renewedAt => $composableBuilder(
      column: $table.renewedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => ColumnOrderings(column));
}

class $$RenewalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RenewalsTable> {
  $$RenewalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<DateTime> get renewedAt =>
      $composableBuilder(column: $table.renewedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get oldDueDate => $composableBuilder(
      column: $table.oldDueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get newDueDate => $composableBuilder(
      column: $table.newDueDate, builder: (column) => column);
}

class $$RenewalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RenewalsTable,
    Renewal,
    $$RenewalsTableFilterComposer,
    $$RenewalsTableOrderingComposer,
    $$RenewalsTableAnnotationComposer,
    $$RenewalsTableCreateCompanionBuilder,
    $$RenewalsTableUpdateCompanionBuilder,
    (Renewal, BaseReferences<_$AppDatabase, $RenewalsTable, Renewal>),
    Renewal,
    PrefetchHooks Function()> {
  $$RenewalsTableTableManager(_$AppDatabase db, $RenewalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RenewalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RenewalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RenewalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> loanId = const Value.absent(),
            Value<DateTime> renewedAt = const Value.absent(),
            Value<DateTime> oldDueDate = const Value.absent(),
            Value<DateTime> newDueDate = const Value.absent(),
          }) =>
              RenewalsCompanion(
            id: id,
            loanId: loanId,
            renewedAt: renewedAt,
            oldDueDate: oldDueDate,
            newDueDate: newDueDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String loanId,
            Value<DateTime> renewedAt = const Value.absent(),
            required DateTime oldDueDate,
            required DateTime newDueDate,
          }) =>
              RenewalsCompanion.insert(
            id: id,
            loanId: loanId,
            renewedAt: renewedAt,
            oldDueDate: oldDueDate,
            newDueDate: newDueDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RenewalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RenewalsTable,
    Renewal,
    $$RenewalsTableFilterComposer,
    $$RenewalsTableOrderingComposer,
    $$RenewalsTableAnnotationComposer,
    $$RenewalsTableCreateCompanionBuilder,
    $$RenewalsTableUpdateCompanionBuilder,
    (Renewal, BaseReferences<_$AppDatabase, $RenewalsTable, Renewal>),
    Renewal,
    PrefetchHooks Function()>;
typedef $$ReceiptsTableCreateCompanionBuilder = ReceiptsCompanion Function({
  Value<int> id,
  Value<String?> memberId,
  Value<String?> loanId,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
  required String type,
  required String title,
  required String payloadJson,
});
typedef $$ReceiptsTableUpdateCompanionBuilder = ReceiptsCompanion Function({
  Value<int> id,
  Value<String?> memberId,
  Value<String?> loanId,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
  Value<String> type,
  Value<String> title,
  Value<String> payloadJson,
});

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memberId => $composableBuilder(
      column: $table.memberId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loanId => $composableBuilder(
      column: $table.loanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get loanId =>
      $composableBuilder(column: $table.loanId, builder: (column) => column);

  GeneratedColumn<int> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);
}

class $$ReceiptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()> {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> memberId = const Value.absent(),
            Value<String?> loanId = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
          }) =>
              ReceiptsCompanion(
            id: id,
            memberId: memberId,
            loanId: loanId,
            transactionId: transactionId,
            createdAt: createdAt,
            type: type,
            title: title,
            payloadJson: payloadJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> memberId = const Value.absent(),
            Value<String?> loanId = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            required String type,
            required String title,
            required String payloadJson,
          }) =>
              ReceiptsCompanion.insert(
            id: id,
            memberId: memberId,
            loanId: loanId,
            transactionId: transactionId,
            createdAt: createdAt,
            type: type,
            title: title,
            payloadJson: payloadJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReceiptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$MembersTableTableManager get members =>
      $$MembersTableTableManager(_db, _db.members);
  $$StaffAccountsTableTableManager get staffAccounts =>
      $$StaffAccountsTableTableManager(_db, _db.staffAccounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PublishersTableTableManager get publishers =>
      $$PublishersTableTableManager(_db, _db.publishers);
  $$AuthorsTableTableManager get authors =>
      $$AuthorsTableTableManager(_db, _db.authors);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookAuthorsTableTableManager get bookAuthors =>
      $$BookAuthorsTableTableManager(_db, _db.bookAuthors);
  $$BookCopiesTableTableManager get bookCopies =>
      $$BookCopiesTableTableManager(_db, _db.bookCopies);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$FinesTableTableManager get fines =>
      $$FinesTableTableManager(_db, _db.fines);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ReservationsTableTableManager get reservations =>
      $$ReservationsTableTableManager(_db, _db.reservations);
  $$RenewalsTableTableManager get renewals =>
      $$RenewalsTableTableManager(_db, _db.renewals);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
}
