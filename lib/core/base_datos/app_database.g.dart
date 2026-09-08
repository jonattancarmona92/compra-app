// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CiclosOperativosTable extends CiclosOperativos
    with TableInfo<$CiclosOperativosTable, DBCicloOperativo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CiclosOperativosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fechaAperturaMeta = const VerificationMeta(
    'fechaApertura',
  );
  @override
  late final GeneratedColumn<int> fechaApertura = GeneratedColumn<int>(
    'fecha_apertura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<int> fechaCierre = GeneratedColumn<int>(
    'fecha_cierre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estado IN (\'ACTIVO\',\'CERRADO\'))',
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fechaApertura,
    fechaCierre,
    estado,
    observaciones,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ciclos_operativos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBCicloOperativo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
        _fechaAperturaMeta,
        fechaApertura.isAcceptableOrUnknown(
          data['fecha_apertura']!,
          _fechaAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaAperturaMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBCicloOperativo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCicloOperativo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fechaApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_apertura'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_cierre'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
    );
  }

  @override
  $CiclosOperativosTable createAlias(String alias) {
    return $CiclosOperativosTable(attachedDatabase, alias);
  }
}

class DBCicloOperativo extends DataClass
    implements Insertable<DBCicloOperativo> {
  final int id;
  final int fechaApertura;
  final int? fechaCierre;
  final String estado;
  final String? observaciones;
  const DBCicloOperativo({
    required this.id,
    required this.fechaApertura,
    this.fechaCierre,
    required this.estado,
    this.observaciones,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha_apertura'] = Variable<int>(fechaApertura);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<int>(fechaCierre);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    return map;
  }

  CiclosOperativosCompanion toCompanion(bool nullToAbsent) {
    return CiclosOperativosCompanion(
      id: Value(id),
      fechaApertura: Value(fechaApertura),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      estado: Value(estado),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
    );
  }

  factory DBCicloOperativo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBCicloOperativo(
      id: serializer.fromJson<int>(json['id']),
      fechaApertura: serializer.fromJson<int>(json['fechaApertura']),
      fechaCierre: serializer.fromJson<int?>(json['fechaCierre']),
      estado: serializer.fromJson<String>(json['estado']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fechaApertura': serializer.toJson<int>(fechaApertura),
      'fechaCierre': serializer.toJson<int?>(fechaCierre),
      'estado': serializer.toJson<String>(estado),
      'observaciones': serializer.toJson<String?>(observaciones),
    };
  }

  DBCicloOperativo copyWith({
    int? id,
    int? fechaApertura,
    Value<int?> fechaCierre = const Value.absent(),
    String? estado,
    Value<String?> observaciones = const Value.absent(),
  }) => DBCicloOperativo(
    id: id ?? this.id,
    fechaApertura: fechaApertura ?? this.fechaApertura,
    fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
    estado: estado ?? this.estado,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
  );
  DBCicloOperativo copyWithCompanion(CiclosOperativosCompanion data) {
    return DBCicloOperativo(
      id: data.id.present ? data.id.value : this.id,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      estado: data.estado.present ? data.estado.value : this.estado,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBCicloOperativo(')
          ..write('id: $id, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fechaApertura, fechaCierre, estado, observaciones);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBCicloOperativo &&
          other.id == this.id &&
          other.fechaApertura == this.fechaApertura &&
          other.fechaCierre == this.fechaCierre &&
          other.estado == this.estado &&
          other.observaciones == this.observaciones);
}

class CiclosOperativosCompanion extends UpdateCompanion<DBCicloOperativo> {
  final Value<int> id;
  final Value<int> fechaApertura;
  final Value<int?> fechaCierre;
  final Value<String> estado;
  final Value<String?> observaciones;
  const CiclosOperativosCompanion({
    this.id = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
  });
  CiclosOperativosCompanion.insert({
    this.id = const Value.absent(),
    required int fechaApertura,
    this.fechaCierre = const Value.absent(),
    required String estado,
    this.observaciones = const Value.absent(),
  }) : fechaApertura = Value(fechaApertura),
       estado = Value(estado);
  static Insertable<DBCicloOperativo> custom({
    Expression<int>? id,
    Expression<int>? fechaApertura,
    Expression<int>? fechaCierre,
    Expression<String>? estado,
    Expression<String>? observaciones,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
    });
  }

  CiclosOperativosCompanion copyWith({
    Value<int>? id,
    Value<int>? fechaApertura,
    Value<int?>? fechaCierre,
    Value<String>? estado,
    Value<String?>? observaciones,
  }) {
    return CiclosOperativosCompanion(
      id: id ?? this.id,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<int>(fechaApertura.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<int>(fechaCierre.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CiclosOperativosCompanion(')
          ..write('id: $id, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones')
          ..write(')'))
        .toString();
  }
}

class $CajasTable extends Cajas with TableInfo<$CajasTable, DBCaja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cicloOperativoIdMeta = const VerificationMeta(
    'cicloOperativoId',
  );
  @override
  late final GeneratedColumn<int> cicloOperativoId = GeneratedColumn<int>(
    'ciclo_operativo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaAperturaMeta = const VerificationMeta(
    'fechaApertura',
  );
  @override
  late final GeneratedColumn<int> fechaApertura = GeneratedColumn<int>(
    'fecha_apertura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<int> fechaCierre = GeneratedColumn<int>(
    'fecha_cierre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saldoInicialMeta = const VerificationMeta(
    'saldoInicial',
  );
  @override
  late final GeneratedColumn<double> saldoInicial = GeneratedColumn<double>(
    'saldo_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (saldo_inicial >= 0)',
  );
  static const VerificationMeta _saldoFinalTeoricoMeta = const VerificationMeta(
    'saldoFinalTeorico',
  );
  @override
  late final GeneratedColumn<double> saldoFinalTeorico =
      GeneratedColumn<double>(
        'saldo_final_teorico',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estado IN (\'ABIERTA\',\'CERRADA\'))',
  );
  static const VerificationMeta _abiertaPorMeta = const VerificationMeta(
    'abiertaPor',
  );
  @override
  late final GeneratedColumn<String> abiertaPor = GeneratedColumn<String>(
    'abierta_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cicloOperativoId,
    fechaApertura,
    fechaCierre,
    saldoInicial,
    saldoFinalTeorico,
    estado,
    abiertaPor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cajas';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBCaja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ciclo_operativo_id')) {
      context.handle(
        _cicloOperativoIdMeta,
        cicloOperativoId.isAcceptableOrUnknown(
          data['ciclo_operativo_id']!,
          _cicloOperativoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cicloOperativoIdMeta);
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
        _fechaAperturaMeta,
        fechaApertura.isAcceptableOrUnknown(
          data['fecha_apertura']!,
          _fechaAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaAperturaMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    }
    if (data.containsKey('saldo_inicial')) {
      context.handle(
        _saldoInicialMeta,
        saldoInicial.isAcceptableOrUnknown(
          data['saldo_inicial']!,
          _saldoInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saldoInicialMeta);
    }
    if (data.containsKey('saldo_final_teorico')) {
      context.handle(
        _saldoFinalTeoricoMeta,
        saldoFinalTeorico.isAcceptableOrUnknown(
          data['saldo_final_teorico']!,
          _saldoFinalTeoricoMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('abierta_por')) {
      context.handle(
        _abiertaPorMeta,
        abiertaPor.isAcceptableOrUnknown(data['abierta_por']!, _abiertaPorMeta),
      );
    } else if (isInserting) {
      context.missing(_abiertaPorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBCaja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCaja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cicloOperativoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_operativo_id'],
      )!,
      fechaApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_apertura'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_cierre'],
      ),
      saldoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_inicial'],
      )!,
      saldoFinalTeorico: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_final_teorico'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      abiertaPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abierta_por'],
      )!,
    );
  }

  @override
  $CajasTable createAlias(String alias) {
    return $CajasTable(attachedDatabase, alias);
  }
}

class DBCaja extends DataClass implements Insertable<DBCaja> {
  final int id;
  final int cicloOperativoId;
  final int fechaApertura;
  final int? fechaCierre;
  final double saldoInicial;
  final double? saldoFinalTeorico;
  final String estado;
  final String abiertaPor;
  const DBCaja({
    required this.id,
    required this.cicloOperativoId,
    required this.fechaApertura,
    this.fechaCierre,
    required this.saldoInicial,
    this.saldoFinalTeorico,
    required this.estado,
    required this.abiertaPor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId);
    map['fecha_apertura'] = Variable<int>(fechaApertura);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<int>(fechaCierre);
    }
    map['saldo_inicial'] = Variable<double>(saldoInicial);
    if (!nullToAbsent || saldoFinalTeorico != null) {
      map['saldo_final_teorico'] = Variable<double>(saldoFinalTeorico);
    }
    map['estado'] = Variable<String>(estado);
    map['abierta_por'] = Variable<String>(abiertaPor);
    return map;
  }

  CajasCompanion toCompanion(bool nullToAbsent) {
    return CajasCompanion(
      id: Value(id),
      cicloOperativoId: Value(cicloOperativoId),
      fechaApertura: Value(fechaApertura),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      saldoInicial: Value(saldoInicial),
      saldoFinalTeorico: saldoFinalTeorico == null && nullToAbsent
          ? const Value.absent()
          : Value(saldoFinalTeorico),
      estado: Value(estado),
      abiertaPor: Value(abiertaPor),
    );
  }

  factory DBCaja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBCaja(
      id: serializer.fromJson<int>(json['id']),
      cicloOperativoId: serializer.fromJson<int>(json['cicloOperativoId']),
      fechaApertura: serializer.fromJson<int>(json['fechaApertura']),
      fechaCierre: serializer.fromJson<int?>(json['fechaCierre']),
      saldoInicial: serializer.fromJson<double>(json['saldoInicial']),
      saldoFinalTeorico: serializer.fromJson<double?>(
        json['saldoFinalTeorico'],
      ),
      estado: serializer.fromJson<String>(json['estado']),
      abiertaPor: serializer.fromJson<String>(json['abiertaPor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cicloOperativoId': serializer.toJson<int>(cicloOperativoId),
      'fechaApertura': serializer.toJson<int>(fechaApertura),
      'fechaCierre': serializer.toJson<int?>(fechaCierre),
      'saldoInicial': serializer.toJson<double>(saldoInicial),
      'saldoFinalTeorico': serializer.toJson<double?>(saldoFinalTeorico),
      'estado': serializer.toJson<String>(estado),
      'abiertaPor': serializer.toJson<String>(abiertaPor),
    };
  }

  DBCaja copyWith({
    int? id,
    int? cicloOperativoId,
    int? fechaApertura,
    Value<int?> fechaCierre = const Value.absent(),
    double? saldoInicial,
    Value<double?> saldoFinalTeorico = const Value.absent(),
    String? estado,
    String? abiertaPor,
  }) => DBCaja(
    id: id ?? this.id,
    cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
    fechaApertura: fechaApertura ?? this.fechaApertura,
    fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
    saldoInicial: saldoInicial ?? this.saldoInicial,
    saldoFinalTeorico: saldoFinalTeorico.present
        ? saldoFinalTeorico.value
        : this.saldoFinalTeorico,
    estado: estado ?? this.estado,
    abiertaPor: abiertaPor ?? this.abiertaPor,
  );
  DBCaja copyWithCompanion(CajasCompanion data) {
    return DBCaja(
      id: data.id.present ? data.id.value : this.id,
      cicloOperativoId: data.cicloOperativoId.present
          ? data.cicloOperativoId.value
          : this.cicloOperativoId,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      saldoInicial: data.saldoInicial.present
          ? data.saldoInicial.value
          : this.saldoInicial,
      saldoFinalTeorico: data.saldoFinalTeorico.present
          ? data.saldoFinalTeorico.value
          : this.saldoFinalTeorico,
      estado: data.estado.present ? data.estado.value : this.estado,
      abiertaPor: data.abiertaPor.present
          ? data.abiertaPor.value
          : this.abiertaPor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBCaja(')
          ..write('id: $id, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('saldoFinalTeorico: $saldoFinalTeorico, ')
          ..write('estado: $estado, ')
          ..write('abiertaPor: $abiertaPor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cicloOperativoId,
    fechaApertura,
    fechaCierre,
    saldoInicial,
    saldoFinalTeorico,
    estado,
    abiertaPor,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBCaja &&
          other.id == this.id &&
          other.cicloOperativoId == this.cicloOperativoId &&
          other.fechaApertura == this.fechaApertura &&
          other.fechaCierre == this.fechaCierre &&
          other.saldoInicial == this.saldoInicial &&
          other.saldoFinalTeorico == this.saldoFinalTeorico &&
          other.estado == this.estado &&
          other.abiertaPor == this.abiertaPor);
}

class CajasCompanion extends UpdateCompanion<DBCaja> {
  final Value<int> id;
  final Value<int> cicloOperativoId;
  final Value<int> fechaApertura;
  final Value<int?> fechaCierre;
  final Value<double> saldoInicial;
  final Value<double?> saldoFinalTeorico;
  final Value<String> estado;
  final Value<String> abiertaPor;
  const CajasCompanion({
    this.id = const Value.absent(),
    this.cicloOperativoId = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.saldoInicial = const Value.absent(),
    this.saldoFinalTeorico = const Value.absent(),
    this.estado = const Value.absent(),
    this.abiertaPor = const Value.absent(),
  });
  CajasCompanion.insert({
    this.id = const Value.absent(),
    required int cicloOperativoId,
    required int fechaApertura,
    this.fechaCierre = const Value.absent(),
    required double saldoInicial,
    this.saldoFinalTeorico = const Value.absent(),
    required String estado,
    required String abiertaPor,
  }) : cicloOperativoId = Value(cicloOperativoId),
       fechaApertura = Value(fechaApertura),
       saldoInicial = Value(saldoInicial),
       estado = Value(estado),
       abiertaPor = Value(abiertaPor);
  static Insertable<DBCaja> custom({
    Expression<int>? id,
    Expression<int>? cicloOperativoId,
    Expression<int>? fechaApertura,
    Expression<int>? fechaCierre,
    Expression<double>? saldoInicial,
    Expression<double>? saldoFinalTeorico,
    Expression<String>? estado,
    Expression<String>? abiertaPor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cicloOperativoId != null) 'ciclo_operativo_id': cicloOperativoId,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (saldoInicial != null) 'saldo_inicial': saldoInicial,
      if (saldoFinalTeorico != null) 'saldo_final_teorico': saldoFinalTeorico,
      if (estado != null) 'estado': estado,
      if (abiertaPor != null) 'abierta_por': abiertaPor,
    });
  }

  CajasCompanion copyWith({
    Value<int>? id,
    Value<int>? cicloOperativoId,
    Value<int>? fechaApertura,
    Value<int?>? fechaCierre,
    Value<double>? saldoInicial,
    Value<double?>? saldoFinalTeorico,
    Value<String>? estado,
    Value<String>? abiertaPor,
  }) {
    return CajasCompanion(
      id: id ?? this.id,
      cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      saldoFinalTeorico: saldoFinalTeorico ?? this.saldoFinalTeorico,
      estado: estado ?? this.estado,
      abiertaPor: abiertaPor ?? this.abiertaPor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cicloOperativoId.present) {
      map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<int>(fechaApertura.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<int>(fechaCierre.value);
    }
    if (saldoInicial.present) {
      map['saldo_inicial'] = Variable<double>(saldoInicial.value);
    }
    if (saldoFinalTeorico.present) {
      map['saldo_final_teorico'] = Variable<double>(saldoFinalTeorico.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (abiertaPor.present) {
      map['abierta_por'] = Variable<String>(abiertaPor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajasCompanion(')
          ..write('id: $id, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('saldoFinalTeorico: $saldoFinalTeorico, ')
          ..write('estado: $estado, ')
          ..write('abiertaPor: $abiertaPor')
          ..write(')'))
        .toString();
  }
}

class $CierresCajaTable extends CierresCaja
    with TableInfo<$CierresCajaTable, DBCierreCaja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CierresCajaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
    'caja_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _dineroFisicoContadoMeta =
      const VerificationMeta('dineroFisicoContado');
  @override
  late final GeneratedColumn<double> dineroFisicoContado =
      GeneratedColumn<double>(
        'dinero_fisico_contado',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL CHECK (dinero_fisico_contado >= 0)',
      );
  static const VerificationMeta _saldoTeoricoMeta = const VerificationMeta(
    'saldoTeorico',
  );
  @override
  late final GeneratedColumn<double> saldoTeorico = GeneratedColumn<double>(
    'saldo_teorico',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diferenciaMeta = const VerificationMeta(
    'diferencia',
  );
  @override
  late final GeneratedColumn<double> diferencia = GeneratedColumn<double>(
    'diferencia',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validadoPorMeta = const VerificationMeta(
    'validadoPor',
  );
  @override
  late final GeneratedColumn<String> validadoPor = GeneratedColumn<String>(
    'validado_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<int> fechaCierre = GeneratedColumn<int>(
    'fecha_cierre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _comprobantePdfMeta = const VerificationMeta(
    'comprobantePdf',
  );
  @override
  late final GeneratedColumn<String> comprobantePdf = GeneratedColumn<String>(
    'comprobante_pdf',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estado IN (\'VALIDADO\',\'ANULADO\'))',
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoCierreMeta = const VerificationMeta(
    'tipoCierre',
  );
  @override
  late final GeneratedColumn<String> tipoCierre = GeneratedColumn<String>(
    'tipo_cierre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_cierre IN (\'MANUAL\',\'AUTOMATICO_SISTEMA\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cajaId,
    dineroFisicoContado,
    saldoTeorico,
    diferencia,
    validadoPor,
    fechaCierre,
    comprobantePdf,
    estado,
    observaciones,
    tipoCierre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cierres_caja';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBCierreCaja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('caja_id')) {
      context.handle(
        _cajaIdMeta,
        cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('dinero_fisico_contado')) {
      context.handle(
        _dineroFisicoContadoMeta,
        dineroFisicoContado.isAcceptableOrUnknown(
          data['dinero_fisico_contado']!,
          _dineroFisicoContadoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dineroFisicoContadoMeta);
    }
    if (data.containsKey('saldo_teorico')) {
      context.handle(
        _saldoTeoricoMeta,
        saldoTeorico.isAcceptableOrUnknown(
          data['saldo_teorico']!,
          _saldoTeoricoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saldoTeoricoMeta);
    }
    if (data.containsKey('diferencia')) {
      context.handle(
        _diferenciaMeta,
        diferencia.isAcceptableOrUnknown(data['diferencia']!, _diferenciaMeta),
      );
    } else if (isInserting) {
      context.missing(_diferenciaMeta);
    }
    if (data.containsKey('validado_por')) {
      context.handle(
        _validadoPorMeta,
        validadoPor.isAcceptableOrUnknown(
          data['validado_por']!,
          _validadoPorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_validadoPorMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaCierreMeta);
    }
    if (data.containsKey('comprobante_pdf')) {
      context.handle(
        _comprobantePdfMeta,
        comprobantePdf.isAcceptableOrUnknown(
          data['comprobante_pdf']!,
          _comprobantePdfMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_comprobantePdfMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('tipo_cierre')) {
      context.handle(
        _tipoCierreMeta,
        tipoCierre.isAcceptableOrUnknown(data['tipo_cierre']!, _tipoCierreMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoCierreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBCierreCaja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCierreCaja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caja_id'],
      )!,
      dineroFisicoContado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dinero_fisico_contado'],
      )!,
      saldoTeorico: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_teorico'],
      )!,
      diferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}diferencia'],
      )!,
      validadoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validado_por'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_cierre'],
      )!,
      comprobantePdf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comprobante_pdf'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      tipoCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cierre'],
      )!,
    );
  }

  @override
  $CierresCajaTable createAlias(String alias) {
    return $CierresCajaTable(attachedDatabase, alias);
  }
}

class DBCierreCaja extends DataClass implements Insertable<DBCierreCaja> {
  final int id;
  final int cajaId;
  final double dineroFisicoContado;
  final double saldoTeorico;
  final double diferencia;
  final String validadoPor;
  final int fechaCierre;
  final String comprobantePdf;
  final String estado;
  final String? observaciones;
  final String tipoCierre;
  const DBCierreCaja({
    required this.id,
    required this.cajaId,
    required this.dineroFisicoContado,
    required this.saldoTeorico,
    required this.diferencia,
    required this.validadoPor,
    required this.fechaCierre,
    required this.comprobantePdf,
    required this.estado,
    this.observaciones,
    required this.tipoCierre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['caja_id'] = Variable<int>(cajaId);
    map['dinero_fisico_contado'] = Variable<double>(dineroFisicoContado);
    map['saldo_teorico'] = Variable<double>(saldoTeorico);
    map['diferencia'] = Variable<double>(diferencia);
    map['validado_por'] = Variable<String>(validadoPor);
    map['fecha_cierre'] = Variable<int>(fechaCierre);
    map['comprobante_pdf'] = Variable<String>(comprobantePdf);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['tipo_cierre'] = Variable<String>(tipoCierre);
    return map;
  }

  CierresCajaCompanion toCompanion(bool nullToAbsent) {
    return CierresCajaCompanion(
      id: Value(id),
      cajaId: Value(cajaId),
      dineroFisicoContado: Value(dineroFisicoContado),
      saldoTeorico: Value(saldoTeorico),
      diferencia: Value(diferencia),
      validadoPor: Value(validadoPor),
      fechaCierre: Value(fechaCierre),
      comprobantePdf: Value(comprobantePdf),
      estado: Value(estado),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      tipoCierre: Value(tipoCierre),
    );
  }

  factory DBCierreCaja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBCierreCaja(
      id: serializer.fromJson<int>(json['id']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      dineroFisicoContado: serializer.fromJson<double>(
        json['dineroFisicoContado'],
      ),
      saldoTeorico: serializer.fromJson<double>(json['saldoTeorico']),
      diferencia: serializer.fromJson<double>(json['diferencia']),
      validadoPor: serializer.fromJson<String>(json['validadoPor']),
      fechaCierre: serializer.fromJson<int>(json['fechaCierre']),
      comprobantePdf: serializer.fromJson<String>(json['comprobantePdf']),
      estado: serializer.fromJson<String>(json['estado']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      tipoCierre: serializer.fromJson<String>(json['tipoCierre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cajaId': serializer.toJson<int>(cajaId),
      'dineroFisicoContado': serializer.toJson<double>(dineroFisicoContado),
      'saldoTeorico': serializer.toJson<double>(saldoTeorico),
      'diferencia': serializer.toJson<double>(diferencia),
      'validadoPor': serializer.toJson<String>(validadoPor),
      'fechaCierre': serializer.toJson<int>(fechaCierre),
      'comprobantePdf': serializer.toJson<String>(comprobantePdf),
      'estado': serializer.toJson<String>(estado),
      'observaciones': serializer.toJson<String?>(observaciones),
      'tipoCierre': serializer.toJson<String>(tipoCierre),
    };
  }

  DBCierreCaja copyWith({
    int? id,
    int? cajaId,
    double? dineroFisicoContado,
    double? saldoTeorico,
    double? diferencia,
    String? validadoPor,
    int? fechaCierre,
    String? comprobantePdf,
    String? estado,
    Value<String?> observaciones = const Value.absent(),
    String? tipoCierre,
  }) => DBCierreCaja(
    id: id ?? this.id,
    cajaId: cajaId ?? this.cajaId,
    dineroFisicoContado: dineroFisicoContado ?? this.dineroFisicoContado,
    saldoTeorico: saldoTeorico ?? this.saldoTeorico,
    diferencia: diferencia ?? this.diferencia,
    validadoPor: validadoPor ?? this.validadoPor,
    fechaCierre: fechaCierre ?? this.fechaCierre,
    comprobantePdf: comprobantePdf ?? this.comprobantePdf,
    estado: estado ?? this.estado,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    tipoCierre: tipoCierre ?? this.tipoCierre,
  );
  DBCierreCaja copyWithCompanion(CierresCajaCompanion data) {
    return DBCierreCaja(
      id: data.id.present ? data.id.value : this.id,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      dineroFisicoContado: data.dineroFisicoContado.present
          ? data.dineroFisicoContado.value
          : this.dineroFisicoContado,
      saldoTeorico: data.saldoTeorico.present
          ? data.saldoTeorico.value
          : this.saldoTeorico,
      diferencia: data.diferencia.present
          ? data.diferencia.value
          : this.diferencia,
      validadoPor: data.validadoPor.present
          ? data.validadoPor.value
          : this.validadoPor,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      comprobantePdf: data.comprobantePdf.present
          ? data.comprobantePdf.value
          : this.comprobantePdf,
      estado: data.estado.present ? data.estado.value : this.estado,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      tipoCierre: data.tipoCierre.present
          ? data.tipoCierre.value
          : this.tipoCierre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBCierreCaja(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('dineroFisicoContado: $dineroFisicoContado, ')
          ..write('saldoTeorico: $saldoTeorico, ')
          ..write('diferencia: $diferencia, ')
          ..write('validadoPor: $validadoPor, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('comprobantePdf: $comprobantePdf, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoCierre: $tipoCierre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cajaId,
    dineroFisicoContado,
    saldoTeorico,
    diferencia,
    validadoPor,
    fechaCierre,
    comprobantePdf,
    estado,
    observaciones,
    tipoCierre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBCierreCaja &&
          other.id == this.id &&
          other.cajaId == this.cajaId &&
          other.dineroFisicoContado == this.dineroFisicoContado &&
          other.saldoTeorico == this.saldoTeorico &&
          other.diferencia == this.diferencia &&
          other.validadoPor == this.validadoPor &&
          other.fechaCierre == this.fechaCierre &&
          other.comprobantePdf == this.comprobantePdf &&
          other.estado == this.estado &&
          other.observaciones == this.observaciones &&
          other.tipoCierre == this.tipoCierre);
}

class CierresCajaCompanion extends UpdateCompanion<DBCierreCaja> {
  final Value<int> id;
  final Value<int> cajaId;
  final Value<double> dineroFisicoContado;
  final Value<double> saldoTeorico;
  final Value<double> diferencia;
  final Value<String> validadoPor;
  final Value<int> fechaCierre;
  final Value<String> comprobantePdf;
  final Value<String> estado;
  final Value<String?> observaciones;
  final Value<String> tipoCierre;
  const CierresCajaCompanion({
    this.id = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.dineroFisicoContado = const Value.absent(),
    this.saldoTeorico = const Value.absent(),
    this.diferencia = const Value.absent(),
    this.validadoPor = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.comprobantePdf = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.tipoCierre = const Value.absent(),
  });
  CierresCajaCompanion.insert({
    this.id = const Value.absent(),
    required int cajaId,
    required double dineroFisicoContado,
    required double saldoTeorico,
    required double diferencia,
    required String validadoPor,
    required int fechaCierre,
    required String comprobantePdf,
    required String estado,
    this.observaciones = const Value.absent(),
    required String tipoCierre,
  }) : cajaId = Value(cajaId),
       dineroFisicoContado = Value(dineroFisicoContado),
       saldoTeorico = Value(saldoTeorico),
       diferencia = Value(diferencia),
       validadoPor = Value(validadoPor),
       fechaCierre = Value(fechaCierre),
       comprobantePdf = Value(comprobantePdf),
       estado = Value(estado),
       tipoCierre = Value(tipoCierre);
  static Insertable<DBCierreCaja> custom({
    Expression<int>? id,
    Expression<int>? cajaId,
    Expression<double>? dineroFisicoContado,
    Expression<double>? saldoTeorico,
    Expression<double>? diferencia,
    Expression<String>? validadoPor,
    Expression<int>? fechaCierre,
    Expression<String>? comprobantePdf,
    Expression<String>? estado,
    Expression<String>? observaciones,
    Expression<String>? tipoCierre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cajaId != null) 'caja_id': cajaId,
      if (dineroFisicoContado != null)
        'dinero_fisico_contado': dineroFisicoContado,
      if (saldoTeorico != null) 'saldo_teorico': saldoTeorico,
      if (diferencia != null) 'diferencia': diferencia,
      if (validadoPor != null) 'validado_por': validadoPor,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (comprobantePdf != null) 'comprobante_pdf': comprobantePdf,
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
      if (tipoCierre != null) 'tipo_cierre': tipoCierre,
    });
  }

  CierresCajaCompanion copyWith({
    Value<int>? id,
    Value<int>? cajaId,
    Value<double>? dineroFisicoContado,
    Value<double>? saldoTeorico,
    Value<double>? diferencia,
    Value<String>? validadoPor,
    Value<int>? fechaCierre,
    Value<String>? comprobantePdf,
    Value<String>? estado,
    Value<String?>? observaciones,
    Value<String>? tipoCierre,
  }) {
    return CierresCajaCompanion(
      id: id ?? this.id,
      cajaId: cajaId ?? this.cajaId,
      dineroFisicoContado: dineroFisicoContado ?? this.dineroFisicoContado,
      saldoTeorico: saldoTeorico ?? this.saldoTeorico,
      diferencia: diferencia ?? this.diferencia,
      validadoPor: validadoPor ?? this.validadoPor,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      comprobantePdf: comprobantePdf ?? this.comprobantePdf,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      tipoCierre: tipoCierre ?? this.tipoCierre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (dineroFisicoContado.present) {
      map['dinero_fisico_contado'] = Variable<double>(
        dineroFisicoContado.value,
      );
    }
    if (saldoTeorico.present) {
      map['saldo_teorico'] = Variable<double>(saldoTeorico.value);
    }
    if (diferencia.present) {
      map['diferencia'] = Variable<double>(diferencia.value);
    }
    if (validadoPor.present) {
      map['validado_por'] = Variable<String>(validadoPor.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<int>(fechaCierre.value);
    }
    if (comprobantePdf.present) {
      map['comprobante_pdf'] = Variable<String>(comprobantePdf.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (tipoCierre.present) {
      map['tipo_cierre'] = Variable<String>(tipoCierre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CierresCajaCompanion(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('dineroFisicoContado: $dineroFisicoContado, ')
          ..write('saldoTeorico: $saldoTeorico, ')
          ..write('diferencia: $diferencia, ')
          ..write('validadoPor: $validadoPor, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('comprobantePdf: $comprobantePdf, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('tipoCierre: $tipoCierre')
          ..write(')'))
        .toString();
  }
}

class $MovimientosCajaTable extends MovimientosCaja
    with TableInfo<$MovimientosCajaTable, DBMovimientoCaja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosCajaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
    'caja_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMovimientoMeta = const VerificationMeta(
    'tipoMovimiento',
  );
  @override
  late final GeneratedColumn<String> tipoMovimiento = GeneratedColumn<String>(
    'tipo_movimiento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_movimiento IN (\'ENTRADA\',\'SALIDA\'))',
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monto > 0)',
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenTablaMeta = const VerificationMeta(
    'origenTabla',
  );
  @override
  late final GeneratedColumn<String> origenTabla = GeneratedColumn<String>(
    'origen_tabla',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origenIdMeta = const VerificationMeta(
    'origenId',
  );
  @override
  late final GeneratedColumn<int> origenId = GeneratedColumn<int>(
    'origen_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaRegistroMeta = const VerificationMeta(
    'fechaRegistro',
  );
  @override
  late final GeneratedColumn<int> fechaRegistro = GeneratedColumn<int>(
    'fecha_registro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anuladoMeta = const VerificationMeta(
    'anulado',
  );
  @override
  late final GeneratedColumn<int> anulado = GeneratedColumn<int>(
    'anulado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cajaId,
    tipoMovimiento,
    monto,
    concepto,
    categoria,
    origenTabla,
    origenId,
    fechaRegistro,
    anulado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_caja';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBMovimientoCaja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('caja_id')) {
      context.handle(
        _cajaIdMeta,
        cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('tipo_movimiento')) {
      context.handle(
        _tipoMovimientoMeta,
        tipoMovimiento.isAcceptableOrUnknown(
          data['tipo_movimiento']!,
          _tipoMovimientoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoMovimientoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('origen_tabla')) {
      context.handle(
        _origenTablaMeta,
        origenTabla.isAcceptableOrUnknown(
          data['origen_tabla']!,
          _origenTablaMeta,
        ),
      );
    }
    if (data.containsKey('origen_id')) {
      context.handle(
        _origenIdMeta,
        origenId.isAcceptableOrUnknown(data['origen_id']!, _origenIdMeta),
      );
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
        _fechaRegistroMeta,
        fechaRegistro.isAcceptableOrUnknown(
          data['fecha_registro']!,
          _fechaRegistroMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaRegistroMeta);
    }
    if (data.containsKey('anulado')) {
      context.handle(
        _anuladoMeta,
        anulado.isAcceptableOrUnknown(data['anulado']!, _anuladoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBMovimientoCaja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBMovimientoCaja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caja_id'],
      )!,
      tipoMovimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_movimiento'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      origenTabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen_tabla'],
      ),
      origenId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origen_id'],
      ),
      fechaRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_registro'],
      )!,
      anulado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anulado'],
      )!,
    );
  }

  @override
  $MovimientosCajaTable createAlias(String alias) {
    return $MovimientosCajaTable(attachedDatabase, alias);
  }
}

class DBMovimientoCaja extends DataClass
    implements Insertable<DBMovimientoCaja> {
  final int id;
  final int cajaId;
  final String tipoMovimiento;
  final double monto;
  final String concepto;
  final String categoria;
  final String? origenTabla;
  final int? origenId;
  final int fechaRegistro;
  final int anulado;
  const DBMovimientoCaja({
    required this.id,
    required this.cajaId,
    required this.tipoMovimiento,
    required this.monto,
    required this.concepto,
    required this.categoria,
    this.origenTabla,
    this.origenId,
    required this.fechaRegistro,
    required this.anulado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['caja_id'] = Variable<int>(cajaId);
    map['tipo_movimiento'] = Variable<String>(tipoMovimiento);
    map['monto'] = Variable<double>(monto);
    map['concepto'] = Variable<String>(concepto);
    map['categoria'] = Variable<String>(categoria);
    if (!nullToAbsent || origenTabla != null) {
      map['origen_tabla'] = Variable<String>(origenTabla);
    }
    if (!nullToAbsent || origenId != null) {
      map['origen_id'] = Variable<int>(origenId);
    }
    map['fecha_registro'] = Variable<int>(fechaRegistro);
    map['anulado'] = Variable<int>(anulado);
    return map;
  }

  MovimientosCajaCompanion toCompanion(bool nullToAbsent) {
    return MovimientosCajaCompanion(
      id: Value(id),
      cajaId: Value(cajaId),
      tipoMovimiento: Value(tipoMovimiento),
      monto: Value(monto),
      concepto: Value(concepto),
      categoria: Value(categoria),
      origenTabla: origenTabla == null && nullToAbsent
          ? const Value.absent()
          : Value(origenTabla),
      origenId: origenId == null && nullToAbsent
          ? const Value.absent()
          : Value(origenId),
      fechaRegistro: Value(fechaRegistro),
      anulado: Value(anulado),
    );
  }

  factory DBMovimientoCaja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBMovimientoCaja(
      id: serializer.fromJson<int>(json['id']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      tipoMovimiento: serializer.fromJson<String>(json['tipoMovimiento']),
      monto: serializer.fromJson<double>(json['monto']),
      concepto: serializer.fromJson<String>(json['concepto']),
      categoria: serializer.fromJson<String>(json['categoria']),
      origenTabla: serializer.fromJson<String?>(json['origenTabla']),
      origenId: serializer.fromJson<int?>(json['origenId']),
      fechaRegistro: serializer.fromJson<int>(json['fechaRegistro']),
      anulado: serializer.fromJson<int>(json['anulado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cajaId': serializer.toJson<int>(cajaId),
      'tipoMovimiento': serializer.toJson<String>(tipoMovimiento),
      'monto': serializer.toJson<double>(monto),
      'concepto': serializer.toJson<String>(concepto),
      'categoria': serializer.toJson<String>(categoria),
      'origenTabla': serializer.toJson<String?>(origenTabla),
      'origenId': serializer.toJson<int?>(origenId),
      'fechaRegistro': serializer.toJson<int>(fechaRegistro),
      'anulado': serializer.toJson<int>(anulado),
    };
  }

  DBMovimientoCaja copyWith({
    int? id,
    int? cajaId,
    String? tipoMovimiento,
    double? monto,
    String? concepto,
    String? categoria,
    Value<String?> origenTabla = const Value.absent(),
    Value<int?> origenId = const Value.absent(),
    int? fechaRegistro,
    int? anulado,
  }) => DBMovimientoCaja(
    id: id ?? this.id,
    cajaId: cajaId ?? this.cajaId,
    tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
    monto: monto ?? this.monto,
    concepto: concepto ?? this.concepto,
    categoria: categoria ?? this.categoria,
    origenTabla: origenTabla.present ? origenTabla.value : this.origenTabla,
    origenId: origenId.present ? origenId.value : this.origenId,
    fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    anulado: anulado ?? this.anulado,
  );
  DBMovimientoCaja copyWithCompanion(MovimientosCajaCompanion data) {
    return DBMovimientoCaja(
      id: data.id.present ? data.id.value : this.id,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      tipoMovimiento: data.tipoMovimiento.present
          ? data.tipoMovimiento.value
          : this.tipoMovimiento,
      monto: data.monto.present ? data.monto.value : this.monto,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      origenTabla: data.origenTabla.present
          ? data.origenTabla.value
          : this.origenTabla,
      origenId: data.origenId.present ? data.origenId.value : this.origenId,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      anulado: data.anulado.present ? data.anulado.value : this.anulado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBMovimientoCaja(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('tipoMovimiento: $tipoMovimiento, ')
          ..write('monto: $monto, ')
          ..write('concepto: $concepto, ')
          ..write('categoria: $categoria, ')
          ..write('origenTabla: $origenTabla, ')
          ..write('origenId: $origenId, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('anulado: $anulado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cajaId,
    tipoMovimiento,
    monto,
    concepto,
    categoria,
    origenTabla,
    origenId,
    fechaRegistro,
    anulado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBMovimientoCaja &&
          other.id == this.id &&
          other.cajaId == this.cajaId &&
          other.tipoMovimiento == this.tipoMovimiento &&
          other.monto == this.monto &&
          other.concepto == this.concepto &&
          other.categoria == this.categoria &&
          other.origenTabla == this.origenTabla &&
          other.origenId == this.origenId &&
          other.fechaRegistro == this.fechaRegistro &&
          other.anulado == this.anulado);
}

class MovimientosCajaCompanion extends UpdateCompanion<DBMovimientoCaja> {
  final Value<int> id;
  final Value<int> cajaId;
  final Value<String> tipoMovimiento;
  final Value<double> monto;
  final Value<String> concepto;
  final Value<String> categoria;
  final Value<String?> origenTabla;
  final Value<int?> origenId;
  final Value<int> fechaRegistro;
  final Value<int> anulado;
  const MovimientosCajaCompanion({
    this.id = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.tipoMovimiento = const Value.absent(),
    this.monto = const Value.absent(),
    this.concepto = const Value.absent(),
    this.categoria = const Value.absent(),
    this.origenTabla = const Value.absent(),
    this.origenId = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.anulado = const Value.absent(),
  });
  MovimientosCajaCompanion.insert({
    this.id = const Value.absent(),
    required int cajaId,
    required String tipoMovimiento,
    required double monto,
    required String concepto,
    required String categoria,
    this.origenTabla = const Value.absent(),
    this.origenId = const Value.absent(),
    required int fechaRegistro,
    this.anulado = const Value.absent(),
  }) : cajaId = Value(cajaId),
       tipoMovimiento = Value(tipoMovimiento),
       monto = Value(monto),
       concepto = Value(concepto),
       categoria = Value(categoria),
       fechaRegistro = Value(fechaRegistro);
  static Insertable<DBMovimientoCaja> custom({
    Expression<int>? id,
    Expression<int>? cajaId,
    Expression<String>? tipoMovimiento,
    Expression<double>? monto,
    Expression<String>? concepto,
    Expression<String>? categoria,
    Expression<String>? origenTabla,
    Expression<int>? origenId,
    Expression<int>? fechaRegistro,
    Expression<int>? anulado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cajaId != null) 'caja_id': cajaId,
      if (tipoMovimiento != null) 'tipo_movimiento': tipoMovimiento,
      if (monto != null) 'monto': monto,
      if (concepto != null) 'concepto': concepto,
      if (categoria != null) 'categoria': categoria,
      if (origenTabla != null) 'origen_tabla': origenTabla,
      if (origenId != null) 'origen_id': origenId,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (anulado != null) 'anulado': anulado,
    });
  }

  MovimientosCajaCompanion copyWith({
    Value<int>? id,
    Value<int>? cajaId,
    Value<String>? tipoMovimiento,
    Value<double>? monto,
    Value<String>? concepto,
    Value<String>? categoria,
    Value<String?>? origenTabla,
    Value<int?>? origenId,
    Value<int>? fechaRegistro,
    Value<int>? anulado,
  }) {
    return MovimientosCajaCompanion(
      id: id ?? this.id,
      cajaId: cajaId ?? this.cajaId,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      monto: monto ?? this.monto,
      concepto: concepto ?? this.concepto,
      categoria: categoria ?? this.categoria,
      origenTabla: origenTabla ?? this.origenTabla,
      origenId: origenId ?? this.origenId,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      anulado: anulado ?? this.anulado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (tipoMovimiento.present) {
      map['tipo_movimiento'] = Variable<String>(tipoMovimiento.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (origenTabla.present) {
      map['origen_tabla'] = Variable<String>(origenTabla.value);
    }
    if (origenId.present) {
      map['origen_id'] = Variable<int>(origenId.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<int>(fechaRegistro.value);
    }
    if (anulado.present) {
      map['anulado'] = Variable<int>(anulado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCajaCompanion(')
          ..write('id: $id, ')
          ..write('cajaId: $cajaId, ')
          ..write('tipoMovimiento: $tipoMovimiento, ')
          ..write('monto: $monto, ')
          ..write('concepto: $concepto, ')
          ..write('categoria: $categoria, ')
          ..write('origenTabla: $origenTabla, ')
          ..write('origenId: $origenId, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('anulado: $anulado')
          ..write(')'))
        .toString();
  }
}

class $ClientesTable extends Clientes
    with TableInfo<$ClientesTable, DBCliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nombreCompletoMeta = const VerificationMeta(
    'nombreCompleto',
  );
  @override
  late final GeneratedColumn<String> nombreCompleto = GeneratedColumn<String>(
    'nombre_completo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentoMeta = const VerificationMeta(
    'documento',
  );
  @override
  late final GeneratedColumn<String> documento = GeneratedColumn<String>(
    'documento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditoAutorizadoMeta = const VerificationMeta(
    'creditoAutorizado',
  );
  @override
  late final GeneratedColumn<int> creditoAutorizado = GeneratedColumn<int>(
    'credito_autorizado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cupoMaximoMeta = const VerificationMeta(
    'cupoMaximo',
  );
  @override
  late final GeneratedColumn<double> cupoMaximo = GeneratedColumn<double>(
    'cupo_maximo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<int> activo = GeneratedColumn<int>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombreCompleto,
    documento,
    telefono,
    direccion,
    creditoAutorizado,
    cupoMaximo,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBCliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_completo')) {
      context.handle(
        _nombreCompletoMeta,
        nombreCompleto.isAcceptableOrUnknown(
          data['nombre_completo']!,
          _nombreCompletoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreCompletoMeta);
    }
    if (data.containsKey('documento')) {
      context.handle(
        _documentoMeta,
        documento.isAcceptableOrUnknown(data['documento']!, _documentoMeta),
      );
    } else if (isInserting) {
      context.missing(_documentoMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('credito_autorizado')) {
      context.handle(
        _creditoAutorizadoMeta,
        creditoAutorizado.isAcceptableOrUnknown(
          data['credito_autorizado']!,
          _creditoAutorizadoMeta,
        ),
      );
    }
    if (data.containsKey('cupo_maximo')) {
      context.handle(
        _cupoMaximoMeta,
        cupoMaximo.isAcceptableOrUnknown(data['cupo_maximo']!, _cupoMaximoMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBCliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreCompleto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_completo'],
      )!,
      documento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      creditoAutorizado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credito_autorizado'],
      )!,
      cupoMaximo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cupo_maximo'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class DBCliente extends DataClass implements Insertable<DBCliente> {
  final int id;
  final String nombreCompleto;
  final String documento;
  final String? telefono;
  final String? direccion;
  final int creditoAutorizado;
  final double cupoMaximo;
  final int activo;
  const DBCliente({
    required this.id,
    required this.nombreCompleto,
    required this.documento,
    this.telefono,
    this.direccion,
    required this.creditoAutorizado,
    required this.cupoMaximo,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_completo'] = Variable<String>(nombreCompleto);
    map['documento'] = Variable<String>(documento);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    map['credito_autorizado'] = Variable<int>(creditoAutorizado);
    map['cupo_maximo'] = Variable<double>(cupoMaximo);
    map['activo'] = Variable<int>(activo);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombreCompleto: Value(nombreCompleto),
      documento: Value(documento),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      creditoAutorizado: Value(creditoAutorizado),
      cupoMaximo: Value(cupoMaximo),
      activo: Value(activo),
    );
  }

  factory DBCliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBCliente(
      id: serializer.fromJson<int>(json['id']),
      nombreCompleto: serializer.fromJson<String>(json['nombreCompleto']),
      documento: serializer.fromJson<String>(json['documento']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      creditoAutorizado: serializer.fromJson<int>(json['creditoAutorizado']),
      cupoMaximo: serializer.fromJson<double>(json['cupoMaximo']),
      activo: serializer.fromJson<int>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreCompleto': serializer.toJson<String>(nombreCompleto),
      'documento': serializer.toJson<String>(documento),
      'telefono': serializer.toJson<String?>(telefono),
      'direccion': serializer.toJson<String?>(direccion),
      'creditoAutorizado': serializer.toJson<int>(creditoAutorizado),
      'cupoMaximo': serializer.toJson<double>(cupoMaximo),
      'activo': serializer.toJson<int>(activo),
    };
  }

  DBCliente copyWith({
    int? id,
    String? nombreCompleto,
    String? documento,
    Value<String?> telefono = const Value.absent(),
    Value<String?> direccion = const Value.absent(),
    int? creditoAutorizado,
    double? cupoMaximo,
    int? activo,
  }) => DBCliente(
    id: id ?? this.id,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    documento: documento ?? this.documento,
    telefono: telefono.present ? telefono.value : this.telefono,
    direccion: direccion.present ? direccion.value : this.direccion,
    creditoAutorizado: creditoAutorizado ?? this.creditoAutorizado,
    cupoMaximo: cupoMaximo ?? this.cupoMaximo,
    activo: activo ?? this.activo,
  );
  DBCliente copyWithCompanion(ClientesCompanion data) {
    return DBCliente(
      id: data.id.present ? data.id.value : this.id,
      nombreCompleto: data.nombreCompleto.present
          ? data.nombreCompleto.value
          : this.nombreCompleto,
      documento: data.documento.present ? data.documento.value : this.documento,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      creditoAutorizado: data.creditoAutorizado.present
          ? data.creditoAutorizado.value
          : this.creditoAutorizado,
      cupoMaximo: data.cupoMaximo.present
          ? data.cupoMaximo.value
          : this.cupoMaximo,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBCliente(')
          ..write('id: $id, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('documento: $documento, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('creditoAutorizado: $creditoAutorizado, ')
          ..write('cupoMaximo: $cupoMaximo, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombreCompleto,
    documento,
    telefono,
    direccion,
    creditoAutorizado,
    cupoMaximo,
    activo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBCliente &&
          other.id == this.id &&
          other.nombreCompleto == this.nombreCompleto &&
          other.documento == this.documento &&
          other.telefono == this.telefono &&
          other.direccion == this.direccion &&
          other.creditoAutorizado == this.creditoAutorizado &&
          other.cupoMaximo == this.cupoMaximo &&
          other.activo == this.activo);
}

class ClientesCompanion extends UpdateCompanion<DBCliente> {
  final Value<int> id;
  final Value<String> nombreCompleto;
  final Value<String> documento;
  final Value<String?> telefono;
  final Value<String?> direccion;
  final Value<int> creditoAutorizado;
  final Value<double> cupoMaximo;
  final Value<int> activo;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombreCompleto = const Value.absent(),
    this.documento = const Value.absent(),
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.creditoAutorizado = const Value.absent(),
    this.cupoMaximo = const Value.absent(),
    this.activo = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombreCompleto,
    required String documento,
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.creditoAutorizado = const Value.absent(),
    this.cupoMaximo = const Value.absent(),
    this.activo = const Value.absent(),
  }) : nombreCompleto = Value(nombreCompleto),
       documento = Value(documento);
  static Insertable<DBCliente> custom({
    Expression<int>? id,
    Expression<String>? nombreCompleto,
    Expression<String>? documento,
    Expression<String>? telefono,
    Expression<String>? direccion,
    Expression<int>? creditoAutorizado,
    Expression<double>? cupoMaximo,
    Expression<int>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (documento != null) 'documento': documento,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (creditoAutorizado != null) 'credito_autorizado': creditoAutorizado,
      if (cupoMaximo != null) 'cupo_maximo': cupoMaximo,
      if (activo != null) 'activo': activo,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? nombreCompleto,
    Value<String>? documento,
    Value<String?>? telefono,
    Value<String?>? direccion,
    Value<int>? creditoAutorizado,
    Value<double>? cupoMaximo,
    Value<int>? activo,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      creditoAutorizado: creditoAutorizado ?? this.creditoAutorizado,
      cupoMaximo: cupoMaximo ?? this.cupoMaximo,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreCompleto.present) {
      map['nombre_completo'] = Variable<String>(nombreCompleto.value);
    }
    if (documento.present) {
      map['documento'] = Variable<String>(documento.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (creditoAutorizado.present) {
      map['credito_autorizado'] = Variable<int>(creditoAutorizado.value);
    }
    if (cupoMaximo.present) {
      map['cupo_maximo'] = Variable<double>(cupoMaximo.value);
    }
    if (activo.present) {
      map['activo'] = Variable<int>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('documento: $documento, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('creditoAutorizado: $creditoAutorizado, ')
          ..write('cupoMaximo: $cupoMaximo, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $LotesBodegaTable extends LotesBodega
    with TableInfo<$LotesBodegaTable, DBLoteBodega> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesBodegaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoLoteMeta = const VerificationMeta(
    'codigoLote',
  );
  @override
  late final GeneratedColumn<String> codigoLote = GeneratedColumn<String>(
    'codigo_lote',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tipoCafeMeta = const VerificationMeta(
    'tipoCafe',
  );
  @override
  late final GeneratedColumn<String> tipoCafe = GeneratedColumn<String>(
    'tipo_cafe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_cafe IN (\'MOJADO\',\'OREADO\',\'SECADO\',\'SECO\',\'PASILLA\'))',
  );
  static const VerificationMeta _pesoInicialMeta = const VerificationMeta(
    'pesoInicial',
  );
  @override
  late final GeneratedColumn<double> pesoInicial = GeneratedColumn<double>(
    'peso_inicial',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (peso_inicial > 0)',
  );
  static const VerificationMeta _pesoActualMeta = const VerificationMeta(
    'pesoActual',
  );
  @override
  late final GeneratedColumn<double> pesoActual = GeneratedColumn<double>(
    'peso_actual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (peso_actual >= 0)',
  );
  static const VerificationMeta _costoInicialKgMeta = const VerificationMeta(
    'costoInicialKg',
  );
  @override
  late final GeneratedColumn<double> costoInicialKg = GeneratedColumn<double>(
    'costo_inicial_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (costo_inicial_kg >= 0)',
  );
  static const VerificationMeta _fechaIngresoMeta = const VerificationMeta(
    'fechaIngreso',
  );
  @override
  late final GeneratedColumn<int> fechaIngreso = GeneratedColumn<int>(
    'fecha_ingreso',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (estado IN (\'DISPONIBLE\',\'AGOTADO\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoLote,
    tipoCafe,
    pesoInicial,
    pesoActual,
    costoInicialKg,
    fechaIngreso,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes_bodega';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBLoteBodega> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_lote')) {
      context.handle(
        _codigoLoteMeta,
        codigoLote.isAcceptableOrUnknown(data['codigo_lote']!, _codigoLoteMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoLoteMeta);
    }
    if (data.containsKey('tipo_cafe')) {
      context.handle(
        _tipoCafeMeta,
        tipoCafe.isAcceptableOrUnknown(data['tipo_cafe']!, _tipoCafeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoCafeMeta);
    }
    if (data.containsKey('peso_inicial')) {
      context.handle(
        _pesoInicialMeta,
        pesoInicial.isAcceptableOrUnknown(
          data['peso_inicial']!,
          _pesoInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pesoInicialMeta);
    }
    if (data.containsKey('peso_actual')) {
      context.handle(
        _pesoActualMeta,
        pesoActual.isAcceptableOrUnknown(data['peso_actual']!, _pesoActualMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoActualMeta);
    }
    if (data.containsKey('costo_inicial_kg')) {
      context.handle(
        _costoInicialKgMeta,
        costoInicialKg.isAcceptableOrUnknown(
          data['costo_inicial_kg']!,
          _costoInicialKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoInicialKgMeta);
    }
    if (data.containsKey('fecha_ingreso')) {
      context.handle(
        _fechaIngresoMeta,
        fechaIngreso.isAcceptableOrUnknown(
          data['fecha_ingreso']!,
          _fechaIngresoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaIngresoMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBLoteBodega map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBLoteBodega(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoLote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_lote'],
      )!,
      tipoCafe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cafe'],
      )!,
      pesoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_inicial'],
      )!,
      pesoActual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_actual'],
      )!,
      costoInicialKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_inicial_kg'],
      )!,
      fechaIngreso: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_ingreso'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $LotesBodegaTable createAlias(String alias) {
    return $LotesBodegaTable(attachedDatabase, alias);
  }
}

class DBLoteBodega extends DataClass implements Insertable<DBLoteBodega> {
  final int id;
  final String codigoLote;
  final String tipoCafe;
  final double pesoInicial;
  final double pesoActual;
  final double costoInicialKg;
  final int fechaIngreso;
  final String estado;
  const DBLoteBodega({
    required this.id,
    required this.codigoLote,
    required this.tipoCafe,
    required this.pesoInicial,
    required this.pesoActual,
    required this.costoInicialKg,
    required this.fechaIngreso,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo_lote'] = Variable<String>(codigoLote);
    map['tipo_cafe'] = Variable<String>(tipoCafe);
    map['peso_inicial'] = Variable<double>(pesoInicial);
    map['peso_actual'] = Variable<double>(pesoActual);
    map['costo_inicial_kg'] = Variable<double>(costoInicialKg);
    map['fecha_ingreso'] = Variable<int>(fechaIngreso);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  LotesBodegaCompanion toCompanion(bool nullToAbsent) {
    return LotesBodegaCompanion(
      id: Value(id),
      codigoLote: Value(codigoLote),
      tipoCafe: Value(tipoCafe),
      pesoInicial: Value(pesoInicial),
      pesoActual: Value(pesoActual),
      costoInicialKg: Value(costoInicialKg),
      fechaIngreso: Value(fechaIngreso),
      estado: Value(estado),
    );
  }

  factory DBLoteBodega.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBLoteBodega(
      id: serializer.fromJson<int>(json['id']),
      codigoLote: serializer.fromJson<String>(json['codigoLote']),
      tipoCafe: serializer.fromJson<String>(json['tipoCafe']),
      pesoInicial: serializer.fromJson<double>(json['pesoInicial']),
      pesoActual: serializer.fromJson<double>(json['pesoActual']),
      costoInicialKg: serializer.fromJson<double>(json['costoInicialKg']),
      fechaIngreso: serializer.fromJson<int>(json['fechaIngreso']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoLote': serializer.toJson<String>(codigoLote),
      'tipoCafe': serializer.toJson<String>(tipoCafe),
      'pesoInicial': serializer.toJson<double>(pesoInicial),
      'pesoActual': serializer.toJson<double>(pesoActual),
      'costoInicialKg': serializer.toJson<double>(costoInicialKg),
      'fechaIngreso': serializer.toJson<int>(fechaIngreso),
      'estado': serializer.toJson<String>(estado),
    };
  }

  DBLoteBodega copyWith({
    int? id,
    String? codigoLote,
    String? tipoCafe,
    double? pesoInicial,
    double? pesoActual,
    double? costoInicialKg,
    int? fechaIngreso,
    String? estado,
  }) => DBLoteBodega(
    id: id ?? this.id,
    codigoLote: codigoLote ?? this.codigoLote,
    tipoCafe: tipoCafe ?? this.tipoCafe,
    pesoInicial: pesoInicial ?? this.pesoInicial,
    pesoActual: pesoActual ?? this.pesoActual,
    costoInicialKg: costoInicialKg ?? this.costoInicialKg,
    fechaIngreso: fechaIngreso ?? this.fechaIngreso,
    estado: estado ?? this.estado,
  );
  DBLoteBodega copyWithCompanion(LotesBodegaCompanion data) {
    return DBLoteBodega(
      id: data.id.present ? data.id.value : this.id,
      codigoLote: data.codigoLote.present
          ? data.codigoLote.value
          : this.codigoLote,
      tipoCafe: data.tipoCafe.present ? data.tipoCafe.value : this.tipoCafe,
      pesoInicial: data.pesoInicial.present
          ? data.pesoInicial.value
          : this.pesoInicial,
      pesoActual: data.pesoActual.present
          ? data.pesoActual.value
          : this.pesoActual,
      costoInicialKg: data.costoInicialKg.present
          ? data.costoInicialKg.value
          : this.costoInicialKg,
      fechaIngreso: data.fechaIngreso.present
          ? data.fechaIngreso.value
          : this.fechaIngreso,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBLoteBodega(')
          ..write('id: $id, ')
          ..write('codigoLote: $codigoLote, ')
          ..write('tipoCafe: $tipoCafe, ')
          ..write('pesoInicial: $pesoInicial, ')
          ..write('pesoActual: $pesoActual, ')
          ..write('costoInicialKg: $costoInicialKg, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoLote,
    tipoCafe,
    pesoInicial,
    pesoActual,
    costoInicialKg,
    fechaIngreso,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBLoteBodega &&
          other.id == this.id &&
          other.codigoLote == this.codigoLote &&
          other.tipoCafe == this.tipoCafe &&
          other.pesoInicial == this.pesoInicial &&
          other.pesoActual == this.pesoActual &&
          other.costoInicialKg == this.costoInicialKg &&
          other.fechaIngreso == this.fechaIngreso &&
          other.estado == this.estado);
}

class LotesBodegaCompanion extends UpdateCompanion<DBLoteBodega> {
  final Value<int> id;
  final Value<String> codigoLote;
  final Value<String> tipoCafe;
  final Value<double> pesoInicial;
  final Value<double> pesoActual;
  final Value<double> costoInicialKg;
  final Value<int> fechaIngreso;
  final Value<String> estado;
  const LotesBodegaCompanion({
    this.id = const Value.absent(),
    this.codigoLote = const Value.absent(),
    this.tipoCafe = const Value.absent(),
    this.pesoInicial = const Value.absent(),
    this.pesoActual = const Value.absent(),
    this.costoInicialKg = const Value.absent(),
    this.fechaIngreso = const Value.absent(),
    this.estado = const Value.absent(),
  });
  LotesBodegaCompanion.insert({
    this.id = const Value.absent(),
    required String codigoLote,
    required String tipoCafe,
    required double pesoInicial,
    required double pesoActual,
    required double costoInicialKg,
    required int fechaIngreso,
    required String estado,
  }) : codigoLote = Value(codigoLote),
       tipoCafe = Value(tipoCafe),
       pesoInicial = Value(pesoInicial),
       pesoActual = Value(pesoActual),
       costoInicialKg = Value(costoInicialKg),
       fechaIngreso = Value(fechaIngreso),
       estado = Value(estado);
  static Insertable<DBLoteBodega> custom({
    Expression<int>? id,
    Expression<String>? codigoLote,
    Expression<String>? tipoCafe,
    Expression<double>? pesoInicial,
    Expression<double>? pesoActual,
    Expression<double>? costoInicialKg,
    Expression<int>? fechaIngreso,
    Expression<String>? estado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoLote != null) 'codigo_lote': codigoLote,
      if (tipoCafe != null) 'tipo_cafe': tipoCafe,
      if (pesoInicial != null) 'peso_inicial': pesoInicial,
      if (pesoActual != null) 'peso_actual': pesoActual,
      if (costoInicialKg != null) 'costo_inicial_kg': costoInicialKg,
      if (fechaIngreso != null) 'fecha_ingreso': fechaIngreso,
      if (estado != null) 'estado': estado,
    });
  }

  LotesBodegaCompanion copyWith({
    Value<int>? id,
    Value<String>? codigoLote,
    Value<String>? tipoCafe,
    Value<double>? pesoInicial,
    Value<double>? pesoActual,
    Value<double>? costoInicialKg,
    Value<int>? fechaIngreso,
    Value<String>? estado,
  }) {
    return LotesBodegaCompanion(
      id: id ?? this.id,
      codigoLote: codigoLote ?? this.codigoLote,
      tipoCafe: tipoCafe ?? this.tipoCafe,
      pesoInicial: pesoInicial ?? this.pesoInicial,
      pesoActual: pesoActual ?? this.pesoActual,
      costoInicialKg: costoInicialKg ?? this.costoInicialKg,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      estado: estado ?? this.estado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoLote.present) {
      map['codigo_lote'] = Variable<String>(codigoLote.value);
    }
    if (tipoCafe.present) {
      map['tipo_cafe'] = Variable<String>(tipoCafe.value);
    }
    if (pesoInicial.present) {
      map['peso_inicial'] = Variable<double>(pesoInicial.value);
    }
    if (pesoActual.present) {
      map['peso_actual'] = Variable<double>(pesoActual.value);
    }
    if (costoInicialKg.present) {
      map['costo_inicial_kg'] = Variable<double>(costoInicialKg.value);
    }
    if (fechaIngreso.present) {
      map['fecha_ingreso'] = Variable<int>(fechaIngreso.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesBodegaCompanion(')
          ..write('id: $id, ')
          ..write('codigoLote: $codigoLote, ')
          ..write('tipoCafe: $tipoCafe, ')
          ..write('pesoInicial: $pesoInicial, ')
          ..write('pesoActual: $pesoActual, ')
          ..write('costoInicialKg: $costoInicialKg, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }
}

class $TransaccionesTable extends Transacciones
    with TableInfo<$TransaccionesTable, DBTransaccion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransaccionesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoTransaccionMeta = const VerificationMeta(
    'codigoTransaccion',
  );
  @override
  late final GeneratedColumn<String> codigoTransaccion =
      GeneratedColumn<String>(
        'codigo_transaccion',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _cicloOperativoIdMeta = const VerificationMeta(
    'cicloOperativoId',
  );
  @override
  late final GeneratedColumn<int> cicloOperativoId = GeneratedColumn<int>(
    'ciclo_operativo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteBodegaIdMeta = const VerificationMeta(
    'loteBodegaId',
  );
  @override
  late final GeneratedColumn<int> loteBodegaId = GeneratedColumn<int>(
    'lote_bodega_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoOperacionMeta = const VerificationMeta(
    'tipoOperacion',
  );
  @override
  late final GeneratedColumn<String> tipoOperacion = GeneratedColumn<String>(
    'tipo_operacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_operacion IN (\'COMPRA\',\'VENTA\'))',
  );
  static const VerificationMeta _tipoCafeMeta = const VerificationMeta(
    'tipoCafe',
  );
  @override
  late final GeneratedColumn<String> tipoCafe = GeneratedColumn<String>(
    'tipo_cafe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_cafe IN (\'SECO\',\'MOJADO\',\'OREADO\',\'PASILLA\',\'SECADO\'))',
  );
  static const VerificationMeta _pesoBrutoMeta = const VerificationMeta(
    'pesoBruto',
  );
  @override
  late final GeneratedColumn<double> pesoBruto = GeneratedColumn<double>(
    'peso_bruto',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (peso_bruto >= 0)',
  );
  static const VerificationMeta _descuentoEmpaqueMeta = const VerificationMeta(
    'descuentoEmpaque',
  );
  @override
  late final GeneratedColumn<double> descuentoEmpaque = GeneratedColumn<double>(
    'descuento_empaque',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _porcentajeHumedadMeta = const VerificationMeta(
    'porcentajeHumedad',
  );
  @override
  late final GeneratedColumn<double> porcentajeHumedad =
      GeneratedColumn<double>(
        'porcentaje_humedad',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _grameraMeta = const VerificationMeta(
    'gramera',
  );
  @override
  late final GeneratedColumn<double> gramera = GeneratedColumn<double>(
    'gramera',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _factorObtenidoMeta = const VerificationMeta(
    'factorObtenido',
  );
  @override
  late final GeneratedColumn<double> factorObtenido = GeneratedColumn<double>(
    'factor_obtenido',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioBaseMeta = const VerificationMeta(
    'precioBase',
  );
  @override
  late final GeneratedColumn<double> precioBase = GeneratedColumn<double>(
    'precio_base',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioFinalKgMeta = const VerificationMeta(
    'precioFinalKg',
  );
  @override
  late final GeneratedColumn<double> precioFinalKg = GeneratedColumn<double>(
    'precio_final_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pesoNetoFinalMeta = const VerificationMeta(
    'pesoNetoFinal',
  );
  @override
  late final GeneratedColumn<double> pesoNetoFinal = GeneratedColumn<double>(
    'peso_neto_final',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (peso_neto_final >= 0)',
  );
  static const VerificationMeta _totalPagarRecibirMeta = const VerificationMeta(
    'totalPagarRecibir',
  );
  @override
  late final GeneratedColumn<double> totalPagarRecibir =
      GeneratedColumn<double>(
        'total_pagar_recibir',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _estadoLiquidacionMeta = const VerificationMeta(
    'estadoLiquidacion',
  );
  @override
  late final GeneratedColumn<String>
  estadoLiquidacion = GeneratedColumn<String>(
    'estado_liquidacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (estado_liquidacion IN (\'PENDIENTE\',\'LIQUIDADA\'))',
  );
  static const VerificationMeta _anuladoMeta = const VerificationMeta(
    'anulado',
  );
  @override
  late final GeneratedColumn<int> anulado = GeneratedColumn<int>(
    'anulado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fechaRegistroMeta = const VerificationMeta(
    'fechaRegistro',
  );
  @override
  late final GeneratedColumn<int> fechaRegistro = GeneratedColumn<int>(
    'fecha_registro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoTransaccion,
    cicloOperativoId,
    clienteId,
    loteBodegaId,
    tipoOperacion,
    tipoCafe,
    pesoBruto,
    descuentoEmpaque,
    porcentajeHumedad,
    gramera,
    factorObtenido,
    precioBase,
    precioFinalKg,
    pesoNetoFinal,
    totalPagarRecibir,
    estadoLiquidacion,
    anulado,
    fechaRegistro,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transacciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBTransaccion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_transaccion')) {
      context.handle(
        _codigoTransaccionMeta,
        codigoTransaccion.isAcceptableOrUnknown(
          data['codigo_transaccion']!,
          _codigoTransaccionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codigoTransaccionMeta);
    }
    if (data.containsKey('ciclo_operativo_id')) {
      context.handle(
        _cicloOperativoIdMeta,
        cicloOperativoId.isAcceptableOrUnknown(
          data['ciclo_operativo_id']!,
          _cicloOperativoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cicloOperativoIdMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('lote_bodega_id')) {
      context.handle(
        _loteBodegaIdMeta,
        loteBodegaId.isAcceptableOrUnknown(
          data['lote_bodega_id']!,
          _loteBodegaIdMeta,
        ),
      );
    }
    if (data.containsKey('tipo_operacion')) {
      context.handle(
        _tipoOperacionMeta,
        tipoOperacion.isAcceptableOrUnknown(
          data['tipo_operacion']!,
          _tipoOperacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoOperacionMeta);
    }
    if (data.containsKey('tipo_cafe')) {
      context.handle(
        _tipoCafeMeta,
        tipoCafe.isAcceptableOrUnknown(data['tipo_cafe']!, _tipoCafeMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoCafeMeta);
    }
    if (data.containsKey('peso_bruto')) {
      context.handle(
        _pesoBrutoMeta,
        pesoBruto.isAcceptableOrUnknown(data['peso_bruto']!, _pesoBrutoMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoBrutoMeta);
    }
    if (data.containsKey('descuento_empaque')) {
      context.handle(
        _descuentoEmpaqueMeta,
        descuentoEmpaque.isAcceptableOrUnknown(
          data['descuento_empaque']!,
          _descuentoEmpaqueMeta,
        ),
      );
    }
    if (data.containsKey('porcentaje_humedad')) {
      context.handle(
        _porcentajeHumedadMeta,
        porcentajeHumedad.isAcceptableOrUnknown(
          data['porcentaje_humedad']!,
          _porcentajeHumedadMeta,
        ),
      );
    }
    if (data.containsKey('gramera')) {
      context.handle(
        _grameraMeta,
        gramera.isAcceptableOrUnknown(data['gramera']!, _grameraMeta),
      );
    }
    if (data.containsKey('factor_obtenido')) {
      context.handle(
        _factorObtenidoMeta,
        factorObtenido.isAcceptableOrUnknown(
          data['factor_obtenido']!,
          _factorObtenidoMeta,
        ),
      );
    }
    if (data.containsKey('precio_base')) {
      context.handle(
        _precioBaseMeta,
        precioBase.isAcceptableOrUnknown(data['precio_base']!, _precioBaseMeta),
      );
    } else if (isInserting) {
      context.missing(_precioBaseMeta);
    }
    if (data.containsKey('precio_final_kg')) {
      context.handle(
        _precioFinalKgMeta,
        precioFinalKg.isAcceptableOrUnknown(
          data['precio_final_kg']!,
          _precioFinalKgMeta,
        ),
      );
    }
    if (data.containsKey('peso_neto_final')) {
      context.handle(
        _pesoNetoFinalMeta,
        pesoNetoFinal.isAcceptableOrUnknown(
          data['peso_neto_final']!,
          _pesoNetoFinalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pesoNetoFinalMeta);
    }
    if (data.containsKey('total_pagar_recibir')) {
      context.handle(
        _totalPagarRecibirMeta,
        totalPagarRecibir.isAcceptableOrUnknown(
          data['total_pagar_recibir']!,
          _totalPagarRecibirMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPagarRecibirMeta);
    }
    if (data.containsKey('estado_liquidacion')) {
      context.handle(
        _estadoLiquidacionMeta,
        estadoLiquidacion.isAcceptableOrUnknown(
          data['estado_liquidacion']!,
          _estadoLiquidacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estadoLiquidacionMeta);
    }
    if (data.containsKey('anulado')) {
      context.handle(
        _anuladoMeta,
        anulado.isAcceptableOrUnknown(data['anulado']!, _anuladoMeta),
      );
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
        _fechaRegistroMeta,
        fechaRegistro.isAcceptableOrUnknown(
          data['fecha_registro']!,
          _fechaRegistroMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaRegistroMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBTransaccion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBTransaccion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoTransaccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_transaccion'],
      )!,
      cicloOperativoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_operativo_id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      ),
      loteBodegaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lote_bodega_id'],
      ),
      tipoOperacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_operacion'],
      )!,
      tipoCafe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cafe'],
      )!,
      pesoBruto: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_bruto'],
      )!,
      descuentoEmpaque: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}descuento_empaque'],
      )!,
      porcentajeHumedad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}porcentaje_humedad'],
      )!,
      gramera: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gramera'],
      )!,
      factorObtenido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor_obtenido'],
      )!,
      precioBase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_base'],
      )!,
      precioFinalKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_final_kg'],
      )!,
      pesoNetoFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_neto_final'],
      )!,
      totalPagarRecibir: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_pagar_recibir'],
      )!,
      estadoLiquidacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_liquidacion'],
      )!,
      anulado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anulado'],
      )!,
      fechaRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_registro'],
      )!,
    );
  }

  @override
  $TransaccionesTable createAlias(String alias) {
    return $TransaccionesTable(attachedDatabase, alias);
  }
}

class DBTransaccion extends DataClass implements Insertable<DBTransaccion> {
  final int id;
  final String codigoTransaccion;
  final int cicloOperativoId;
  final int? clienteId;
  final int? loteBodegaId;
  final String tipoOperacion;
  final String tipoCafe;
  final double pesoBruto;
  final double descuentoEmpaque;
  final double porcentajeHumedad;
  final double gramera;
  final double factorObtenido;
  final double precioBase;
  final double precioFinalKg;
  final double pesoNetoFinal;
  final double totalPagarRecibir;
  final String estadoLiquidacion;
  final int anulado;
  final int fechaRegistro;
  const DBTransaccion({
    required this.id,
    required this.codigoTransaccion,
    required this.cicloOperativoId,
    this.clienteId,
    this.loteBodegaId,
    required this.tipoOperacion,
    required this.tipoCafe,
    required this.pesoBruto,
    required this.descuentoEmpaque,
    required this.porcentajeHumedad,
    required this.gramera,
    required this.factorObtenido,
    required this.precioBase,
    required this.precioFinalKg,
    required this.pesoNetoFinal,
    required this.totalPagarRecibir,
    required this.estadoLiquidacion,
    required this.anulado,
    required this.fechaRegistro,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo_transaccion'] = Variable<String>(codigoTransaccion);
    map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    if (!nullToAbsent || loteBodegaId != null) {
      map['lote_bodega_id'] = Variable<int>(loteBodegaId);
    }
    map['tipo_operacion'] = Variable<String>(tipoOperacion);
    map['tipo_cafe'] = Variable<String>(tipoCafe);
    map['peso_bruto'] = Variable<double>(pesoBruto);
    map['descuento_empaque'] = Variable<double>(descuentoEmpaque);
    map['porcentaje_humedad'] = Variable<double>(porcentajeHumedad);
    map['gramera'] = Variable<double>(gramera);
    map['factor_obtenido'] = Variable<double>(factorObtenido);
    map['precio_base'] = Variable<double>(precioBase);
    map['precio_final_kg'] = Variable<double>(precioFinalKg);
    map['peso_neto_final'] = Variable<double>(pesoNetoFinal);
    map['total_pagar_recibir'] = Variable<double>(totalPagarRecibir);
    map['estado_liquidacion'] = Variable<String>(estadoLiquidacion);
    map['anulado'] = Variable<int>(anulado);
    map['fecha_registro'] = Variable<int>(fechaRegistro);
    return map;
  }

  TransaccionesCompanion toCompanion(bool nullToAbsent) {
    return TransaccionesCompanion(
      id: Value(id),
      codigoTransaccion: Value(codigoTransaccion),
      cicloOperativoId: Value(cicloOperativoId),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      loteBodegaId: loteBodegaId == null && nullToAbsent
          ? const Value.absent()
          : Value(loteBodegaId),
      tipoOperacion: Value(tipoOperacion),
      tipoCafe: Value(tipoCafe),
      pesoBruto: Value(pesoBruto),
      descuentoEmpaque: Value(descuentoEmpaque),
      porcentajeHumedad: Value(porcentajeHumedad),
      gramera: Value(gramera),
      factorObtenido: Value(factorObtenido),
      precioBase: Value(precioBase),
      precioFinalKg: Value(precioFinalKg),
      pesoNetoFinal: Value(pesoNetoFinal),
      totalPagarRecibir: Value(totalPagarRecibir),
      estadoLiquidacion: Value(estadoLiquidacion),
      anulado: Value(anulado),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory DBTransaccion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBTransaccion(
      id: serializer.fromJson<int>(json['id']),
      codigoTransaccion: serializer.fromJson<String>(json['codigoTransaccion']),
      cicloOperativoId: serializer.fromJson<int>(json['cicloOperativoId']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      loteBodegaId: serializer.fromJson<int?>(json['loteBodegaId']),
      tipoOperacion: serializer.fromJson<String>(json['tipoOperacion']),
      tipoCafe: serializer.fromJson<String>(json['tipoCafe']),
      pesoBruto: serializer.fromJson<double>(json['pesoBruto']),
      descuentoEmpaque: serializer.fromJson<double>(json['descuentoEmpaque']),
      porcentajeHumedad: serializer.fromJson<double>(json['porcentajeHumedad']),
      gramera: serializer.fromJson<double>(json['gramera']),
      factorObtenido: serializer.fromJson<double>(json['factorObtenido']),
      precioBase: serializer.fromJson<double>(json['precioBase']),
      precioFinalKg: serializer.fromJson<double>(json['precioFinalKg']),
      pesoNetoFinal: serializer.fromJson<double>(json['pesoNetoFinal']),
      totalPagarRecibir: serializer.fromJson<double>(json['totalPagarRecibir']),
      estadoLiquidacion: serializer.fromJson<String>(json['estadoLiquidacion']),
      anulado: serializer.fromJson<int>(json['anulado']),
      fechaRegistro: serializer.fromJson<int>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoTransaccion': serializer.toJson<String>(codigoTransaccion),
      'cicloOperativoId': serializer.toJson<int>(cicloOperativoId),
      'clienteId': serializer.toJson<int?>(clienteId),
      'loteBodegaId': serializer.toJson<int?>(loteBodegaId),
      'tipoOperacion': serializer.toJson<String>(tipoOperacion),
      'tipoCafe': serializer.toJson<String>(tipoCafe),
      'pesoBruto': serializer.toJson<double>(pesoBruto),
      'descuentoEmpaque': serializer.toJson<double>(descuentoEmpaque),
      'porcentajeHumedad': serializer.toJson<double>(porcentajeHumedad),
      'gramera': serializer.toJson<double>(gramera),
      'factorObtenido': serializer.toJson<double>(factorObtenido),
      'precioBase': serializer.toJson<double>(precioBase),
      'precioFinalKg': serializer.toJson<double>(precioFinalKg),
      'pesoNetoFinal': serializer.toJson<double>(pesoNetoFinal),
      'totalPagarRecibir': serializer.toJson<double>(totalPagarRecibir),
      'estadoLiquidacion': serializer.toJson<String>(estadoLiquidacion),
      'anulado': serializer.toJson<int>(anulado),
      'fechaRegistro': serializer.toJson<int>(fechaRegistro),
    };
  }

  DBTransaccion copyWith({
    int? id,
    String? codigoTransaccion,
    int? cicloOperativoId,
    Value<int?> clienteId = const Value.absent(),
    Value<int?> loteBodegaId = const Value.absent(),
    String? tipoOperacion,
    String? tipoCafe,
    double? pesoBruto,
    double? descuentoEmpaque,
    double? porcentajeHumedad,
    double? gramera,
    double? factorObtenido,
    double? precioBase,
    double? precioFinalKg,
    double? pesoNetoFinal,
    double? totalPagarRecibir,
    String? estadoLiquidacion,
    int? anulado,
    int? fechaRegistro,
  }) => DBTransaccion(
    id: id ?? this.id,
    codigoTransaccion: codigoTransaccion ?? this.codigoTransaccion,
    cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    loteBodegaId: loteBodegaId.present ? loteBodegaId.value : this.loteBodegaId,
    tipoOperacion: tipoOperacion ?? this.tipoOperacion,
    tipoCafe: tipoCafe ?? this.tipoCafe,
    pesoBruto: pesoBruto ?? this.pesoBruto,
    descuentoEmpaque: descuentoEmpaque ?? this.descuentoEmpaque,
    porcentajeHumedad: porcentajeHumedad ?? this.porcentajeHumedad,
    gramera: gramera ?? this.gramera,
    factorObtenido: factorObtenido ?? this.factorObtenido,
    precioBase: precioBase ?? this.precioBase,
    precioFinalKg: precioFinalKg ?? this.precioFinalKg,
    pesoNetoFinal: pesoNetoFinal ?? this.pesoNetoFinal,
    totalPagarRecibir: totalPagarRecibir ?? this.totalPagarRecibir,
    estadoLiquidacion: estadoLiquidacion ?? this.estadoLiquidacion,
    anulado: anulado ?? this.anulado,
    fechaRegistro: fechaRegistro ?? this.fechaRegistro,
  );
  DBTransaccion copyWithCompanion(TransaccionesCompanion data) {
    return DBTransaccion(
      id: data.id.present ? data.id.value : this.id,
      codigoTransaccion: data.codigoTransaccion.present
          ? data.codigoTransaccion.value
          : this.codigoTransaccion,
      cicloOperativoId: data.cicloOperativoId.present
          ? data.cicloOperativoId.value
          : this.cicloOperativoId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      loteBodegaId: data.loteBodegaId.present
          ? data.loteBodegaId.value
          : this.loteBodegaId,
      tipoOperacion: data.tipoOperacion.present
          ? data.tipoOperacion.value
          : this.tipoOperacion,
      tipoCafe: data.tipoCafe.present ? data.tipoCafe.value : this.tipoCafe,
      pesoBruto: data.pesoBruto.present ? data.pesoBruto.value : this.pesoBruto,
      descuentoEmpaque: data.descuentoEmpaque.present
          ? data.descuentoEmpaque.value
          : this.descuentoEmpaque,
      porcentajeHumedad: data.porcentajeHumedad.present
          ? data.porcentajeHumedad.value
          : this.porcentajeHumedad,
      gramera: data.gramera.present ? data.gramera.value : this.gramera,
      factorObtenido: data.factorObtenido.present
          ? data.factorObtenido.value
          : this.factorObtenido,
      precioBase: data.precioBase.present
          ? data.precioBase.value
          : this.precioBase,
      precioFinalKg: data.precioFinalKg.present
          ? data.precioFinalKg.value
          : this.precioFinalKg,
      pesoNetoFinal: data.pesoNetoFinal.present
          ? data.pesoNetoFinal.value
          : this.pesoNetoFinal,
      totalPagarRecibir: data.totalPagarRecibir.present
          ? data.totalPagarRecibir.value
          : this.totalPagarRecibir,
      estadoLiquidacion: data.estadoLiquidacion.present
          ? data.estadoLiquidacion.value
          : this.estadoLiquidacion,
      anulado: data.anulado.present ? data.anulado.value : this.anulado,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBTransaccion(')
          ..write('id: $id, ')
          ..write('codigoTransaccion: $codigoTransaccion, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('loteBodegaId: $loteBodegaId, ')
          ..write('tipoOperacion: $tipoOperacion, ')
          ..write('tipoCafe: $tipoCafe, ')
          ..write('pesoBruto: $pesoBruto, ')
          ..write('descuentoEmpaque: $descuentoEmpaque, ')
          ..write('porcentajeHumedad: $porcentajeHumedad, ')
          ..write('gramera: $gramera, ')
          ..write('factorObtenido: $factorObtenido, ')
          ..write('precioBase: $precioBase, ')
          ..write('precioFinalKg: $precioFinalKg, ')
          ..write('pesoNetoFinal: $pesoNetoFinal, ')
          ..write('totalPagarRecibir: $totalPagarRecibir, ')
          ..write('estadoLiquidacion: $estadoLiquidacion, ')
          ..write('anulado: $anulado, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoTransaccion,
    cicloOperativoId,
    clienteId,
    loteBodegaId,
    tipoOperacion,
    tipoCafe,
    pesoBruto,
    descuentoEmpaque,
    porcentajeHumedad,
    gramera,
    factorObtenido,
    precioBase,
    precioFinalKg,
    pesoNetoFinal,
    totalPagarRecibir,
    estadoLiquidacion,
    anulado,
    fechaRegistro,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBTransaccion &&
          other.id == this.id &&
          other.codigoTransaccion == this.codigoTransaccion &&
          other.cicloOperativoId == this.cicloOperativoId &&
          other.clienteId == this.clienteId &&
          other.loteBodegaId == this.loteBodegaId &&
          other.tipoOperacion == this.tipoOperacion &&
          other.tipoCafe == this.tipoCafe &&
          other.pesoBruto == this.pesoBruto &&
          other.descuentoEmpaque == this.descuentoEmpaque &&
          other.porcentajeHumedad == this.porcentajeHumedad &&
          other.gramera == this.gramera &&
          other.factorObtenido == this.factorObtenido &&
          other.precioBase == this.precioBase &&
          other.precioFinalKg == this.precioFinalKg &&
          other.pesoNetoFinal == this.pesoNetoFinal &&
          other.totalPagarRecibir == this.totalPagarRecibir &&
          other.estadoLiquidacion == this.estadoLiquidacion &&
          other.anulado == this.anulado &&
          other.fechaRegistro == this.fechaRegistro);
}

class TransaccionesCompanion extends UpdateCompanion<DBTransaccion> {
  final Value<int> id;
  final Value<String> codigoTransaccion;
  final Value<int> cicloOperativoId;
  final Value<int?> clienteId;
  final Value<int?> loteBodegaId;
  final Value<String> tipoOperacion;
  final Value<String> tipoCafe;
  final Value<double> pesoBruto;
  final Value<double> descuentoEmpaque;
  final Value<double> porcentajeHumedad;
  final Value<double> gramera;
  final Value<double> factorObtenido;
  final Value<double> precioBase;
  final Value<double> precioFinalKg;
  final Value<double> pesoNetoFinal;
  final Value<double> totalPagarRecibir;
  final Value<String> estadoLiquidacion;
  final Value<int> anulado;
  final Value<int> fechaRegistro;
  const TransaccionesCompanion({
    this.id = const Value.absent(),
    this.codigoTransaccion = const Value.absent(),
    this.cicloOperativoId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.loteBodegaId = const Value.absent(),
    this.tipoOperacion = const Value.absent(),
    this.tipoCafe = const Value.absent(),
    this.pesoBruto = const Value.absent(),
    this.descuentoEmpaque = const Value.absent(),
    this.porcentajeHumedad = const Value.absent(),
    this.gramera = const Value.absent(),
    this.factorObtenido = const Value.absent(),
    this.precioBase = const Value.absent(),
    this.precioFinalKg = const Value.absent(),
    this.pesoNetoFinal = const Value.absent(),
    this.totalPagarRecibir = const Value.absent(),
    this.estadoLiquidacion = const Value.absent(),
    this.anulado = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  TransaccionesCompanion.insert({
    this.id = const Value.absent(),
    required String codigoTransaccion,
    required int cicloOperativoId,
    this.clienteId = const Value.absent(),
    this.loteBodegaId = const Value.absent(),
    required String tipoOperacion,
    required String tipoCafe,
    required double pesoBruto,
    this.descuentoEmpaque = const Value.absent(),
    this.porcentajeHumedad = const Value.absent(),
    this.gramera = const Value.absent(),
    this.factorObtenido = const Value.absent(),
    required double precioBase,
    this.precioFinalKg = const Value.absent(),
    required double pesoNetoFinal,
    required double totalPagarRecibir,
    required String estadoLiquidacion,
    this.anulado = const Value.absent(),
    required int fechaRegistro,
  }) : codigoTransaccion = Value(codigoTransaccion),
       cicloOperativoId = Value(cicloOperativoId),
       tipoOperacion = Value(tipoOperacion),
       tipoCafe = Value(tipoCafe),
       pesoBruto = Value(pesoBruto),
       precioBase = Value(precioBase),
       pesoNetoFinal = Value(pesoNetoFinal),
       totalPagarRecibir = Value(totalPagarRecibir),
       estadoLiquidacion = Value(estadoLiquidacion),
       fechaRegistro = Value(fechaRegistro);
  static Insertable<DBTransaccion> custom({
    Expression<int>? id,
    Expression<String>? codigoTransaccion,
    Expression<int>? cicloOperativoId,
    Expression<int>? clienteId,
    Expression<int>? loteBodegaId,
    Expression<String>? tipoOperacion,
    Expression<String>? tipoCafe,
    Expression<double>? pesoBruto,
    Expression<double>? descuentoEmpaque,
    Expression<double>? porcentajeHumedad,
    Expression<double>? gramera,
    Expression<double>? factorObtenido,
    Expression<double>? precioBase,
    Expression<double>? precioFinalKg,
    Expression<double>? pesoNetoFinal,
    Expression<double>? totalPagarRecibir,
    Expression<String>? estadoLiquidacion,
    Expression<int>? anulado,
    Expression<int>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoTransaccion != null) 'codigo_transaccion': codigoTransaccion,
      if (cicloOperativoId != null) 'ciclo_operativo_id': cicloOperativoId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (loteBodegaId != null) 'lote_bodega_id': loteBodegaId,
      if (tipoOperacion != null) 'tipo_operacion': tipoOperacion,
      if (tipoCafe != null) 'tipo_cafe': tipoCafe,
      if (pesoBruto != null) 'peso_bruto': pesoBruto,
      if (descuentoEmpaque != null) 'descuento_empaque': descuentoEmpaque,
      if (porcentajeHumedad != null) 'porcentaje_humedad': porcentajeHumedad,
      if (gramera != null) 'gramera': gramera,
      if (factorObtenido != null) 'factor_obtenido': factorObtenido,
      if (precioBase != null) 'precio_base': precioBase,
      if (precioFinalKg != null) 'precio_final_kg': precioFinalKg,
      if (pesoNetoFinal != null) 'peso_neto_final': pesoNetoFinal,
      if (totalPagarRecibir != null) 'total_pagar_recibir': totalPagarRecibir,
      if (estadoLiquidacion != null) 'estado_liquidacion': estadoLiquidacion,
      if (anulado != null) 'anulado': anulado,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  TransaccionesCompanion copyWith({
    Value<int>? id,
    Value<String>? codigoTransaccion,
    Value<int>? cicloOperativoId,
    Value<int?>? clienteId,
    Value<int?>? loteBodegaId,
    Value<String>? tipoOperacion,
    Value<String>? tipoCafe,
    Value<double>? pesoBruto,
    Value<double>? descuentoEmpaque,
    Value<double>? porcentajeHumedad,
    Value<double>? gramera,
    Value<double>? factorObtenido,
    Value<double>? precioBase,
    Value<double>? precioFinalKg,
    Value<double>? pesoNetoFinal,
    Value<double>? totalPagarRecibir,
    Value<String>? estadoLiquidacion,
    Value<int>? anulado,
    Value<int>? fechaRegistro,
  }) {
    return TransaccionesCompanion(
      id: id ?? this.id,
      codigoTransaccion: codigoTransaccion ?? this.codigoTransaccion,
      cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
      clienteId: clienteId ?? this.clienteId,
      loteBodegaId: loteBodegaId ?? this.loteBodegaId,
      tipoOperacion: tipoOperacion ?? this.tipoOperacion,
      tipoCafe: tipoCafe ?? this.tipoCafe,
      pesoBruto: pesoBruto ?? this.pesoBruto,
      descuentoEmpaque: descuentoEmpaque ?? this.descuentoEmpaque,
      porcentajeHumedad: porcentajeHumedad ?? this.porcentajeHumedad,
      gramera: gramera ?? this.gramera,
      factorObtenido: factorObtenido ?? this.factorObtenido,
      precioBase: precioBase ?? this.precioBase,
      precioFinalKg: precioFinalKg ?? this.precioFinalKg,
      pesoNetoFinal: pesoNetoFinal ?? this.pesoNetoFinal,
      totalPagarRecibir: totalPagarRecibir ?? this.totalPagarRecibir,
      estadoLiquidacion: estadoLiquidacion ?? this.estadoLiquidacion,
      anulado: anulado ?? this.anulado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoTransaccion.present) {
      map['codigo_transaccion'] = Variable<String>(codigoTransaccion.value);
    }
    if (cicloOperativoId.present) {
      map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (loteBodegaId.present) {
      map['lote_bodega_id'] = Variable<int>(loteBodegaId.value);
    }
    if (tipoOperacion.present) {
      map['tipo_operacion'] = Variable<String>(tipoOperacion.value);
    }
    if (tipoCafe.present) {
      map['tipo_cafe'] = Variable<String>(tipoCafe.value);
    }
    if (pesoBruto.present) {
      map['peso_bruto'] = Variable<double>(pesoBruto.value);
    }
    if (descuentoEmpaque.present) {
      map['descuento_empaque'] = Variable<double>(descuentoEmpaque.value);
    }
    if (porcentajeHumedad.present) {
      map['porcentaje_humedad'] = Variable<double>(porcentajeHumedad.value);
    }
    if (gramera.present) {
      map['gramera'] = Variable<double>(gramera.value);
    }
    if (factorObtenido.present) {
      map['factor_obtenido'] = Variable<double>(factorObtenido.value);
    }
    if (precioBase.present) {
      map['precio_base'] = Variable<double>(precioBase.value);
    }
    if (precioFinalKg.present) {
      map['precio_final_kg'] = Variable<double>(precioFinalKg.value);
    }
    if (pesoNetoFinal.present) {
      map['peso_neto_final'] = Variable<double>(pesoNetoFinal.value);
    }
    if (totalPagarRecibir.present) {
      map['total_pagar_recibir'] = Variable<double>(totalPagarRecibir.value);
    }
    if (estadoLiquidacion.present) {
      map['estado_liquidacion'] = Variable<String>(estadoLiquidacion.value);
    }
    if (anulado.present) {
      map['anulado'] = Variable<int>(anulado.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<int>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransaccionesCompanion(')
          ..write('id: $id, ')
          ..write('codigoTransaccion: $codigoTransaccion, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('loteBodegaId: $loteBodegaId, ')
          ..write('tipoOperacion: $tipoOperacion, ')
          ..write('tipoCafe: $tipoCafe, ')
          ..write('pesoBruto: $pesoBruto, ')
          ..write('descuentoEmpaque: $descuentoEmpaque, ')
          ..write('porcentajeHumedad: $porcentajeHumedad, ')
          ..write('gramera: $gramera, ')
          ..write('factorObtenido: $factorObtenido, ')
          ..write('precioBase: $precioBase, ')
          ..write('precioFinalKg: $precioFinalKg, ')
          ..write('pesoNetoFinal: $pesoNetoFinal, ')
          ..write('totalPagarRecibir: $totalPagarRecibir, ')
          ..write('estadoLiquidacion: $estadoLiquidacion, ')
          ..write('anulado: $anulado, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $LiquidacionesTable extends Liquidaciones
    with TableInfo<$LiquidacionesTable, DBLiquidacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LiquidacionesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _transaccionIdMeta = const VerificationMeta(
    'transaccionId',
  );
  @override
  late final GeneratedColumn<int> transaccionId = GeneratedColumn<int>(
    'transaccion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
    'caja_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoTotalTransaccionMeta =
      const VerificationMeta('montoTotalTransaccion');
  @override
  late final GeneratedColumn<double> montoTotalTransaccion =
      GeneratedColumn<double>(
        'monto_total_transaccion',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _montoAnticiposPreviosMeta =
      const VerificationMeta('montoAnticiposPrevios');
  @override
  late final GeneratedColumn<double> montoAnticiposPrevios =
      GeneratedColumn<double>(
        'monto_anticipos_previos',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _descuentoCarteraMeta = const VerificationMeta(
    'descuentoCartera',
  );
  @override
  late final GeneratedColumn<double> descuentoCartera = GeneratedColumn<double>(
    'descuento_cartera',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _saldoNetoPagadoMeta = const VerificationMeta(
    'saldoNetoPagado',
  );
  @override
  late final GeneratedColumn<double> saldoNetoPagado = GeneratedColumn<double>(
    'saldo_neto_pagado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'VALIDADA\' CHECK (estado IN (\'VALIDADA\',\'ANULADA\'))',
    defaultValue: const CustomExpression('\'VALIDADA\''),
    clientDefault: () => 'VALIDADA',
  );
  static const VerificationMeta _fechaAnulacionMeta = const VerificationMeta(
    'fechaAnulacion',
  );
  @override
  late final GeneratedColumn<int> fechaAnulacion = GeneratedColumn<int>(
    'fecha_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoAnulacionMeta = const VerificationMeta(
    'motivoAnulacion',
  );
  @override
  late final GeneratedColumn<String> motivoAnulacion = GeneratedColumn<String>(
    'motivo_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaLiquidacionMeta = const VerificationMeta(
    'fechaLiquidacion',
  );
  @override
  late final GeneratedColumn<int> fechaLiquidacion = GeneratedColumn<int>(
    'fecha_liquidacion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transaccionId,
    cajaId,
    montoTotalTransaccion,
    montoAnticiposPrevios,
    descuentoCartera,
    saldoNetoPagado,
    estado,
    fechaAnulacion,
    motivoAnulacion,
    fechaLiquidacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liquidaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBLiquidacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaccion_id')) {
      context.handle(
        _transaccionIdMeta,
        transaccionId.isAcceptableOrUnknown(
          data['transaccion_id']!,
          _transaccionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transaccionIdMeta);
    }
    if (data.containsKey('caja_id')) {
      context.handle(
        _cajaIdMeta,
        cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('monto_total_transaccion')) {
      context.handle(
        _montoTotalTransaccionMeta,
        montoTotalTransaccion.isAcceptableOrUnknown(
          data['monto_total_transaccion']!,
          _montoTotalTransaccionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoTotalTransaccionMeta);
    }
    if (data.containsKey('monto_anticipos_previos')) {
      context.handle(
        _montoAnticiposPreviosMeta,
        montoAnticiposPrevios.isAcceptableOrUnknown(
          data['monto_anticipos_previos']!,
          _montoAnticiposPreviosMeta,
        ),
      );
    }
    if (data.containsKey('descuento_cartera')) {
      context.handle(
        _descuentoCarteraMeta,
        descuentoCartera.isAcceptableOrUnknown(
          data['descuento_cartera']!,
          _descuentoCarteraMeta,
        ),
      );
    }
    if (data.containsKey('saldo_neto_pagado')) {
      context.handle(
        _saldoNetoPagadoMeta,
        saldoNetoPagado.isAcceptableOrUnknown(
          data['saldo_neto_pagado']!,
          _saldoNetoPagadoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saldoNetoPagadoMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('fecha_anulacion')) {
      context.handle(
        _fechaAnulacionMeta,
        fechaAnulacion.isAcceptableOrUnknown(
          data['fecha_anulacion']!,
          _fechaAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('motivo_anulacion')) {
      context.handle(
        _motivoAnulacionMeta,
        motivoAnulacion.isAcceptableOrUnknown(
          data['motivo_anulacion']!,
          _motivoAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('fecha_liquidacion')) {
      context.handle(
        _fechaLiquidacionMeta,
        fechaLiquidacion.isAcceptableOrUnknown(
          data['fecha_liquidacion']!,
          _fechaLiquidacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaLiquidacionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBLiquidacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBLiquidacion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transaccionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaccion_id'],
      )!,
      cajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caja_id'],
      )!,
      montoTotalTransaccion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_total_transaccion'],
      )!,
      montoAnticiposPrevios: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_anticipos_previos'],
      )!,
      descuentoCartera: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}descuento_cartera'],
      )!,
      saldoNetoPagado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_neto_pagado'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      fechaAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_anulacion'],
      ),
      motivoAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_anulacion'],
      ),
      fechaLiquidacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_liquidacion'],
      )!,
    );
  }

  @override
  $LiquidacionesTable createAlias(String alias) {
    return $LiquidacionesTable(attachedDatabase, alias);
  }
}

class DBLiquidacion extends DataClass implements Insertable<DBLiquidacion> {
  final int id;
  final int transaccionId;
  final int cajaId;
  final double montoTotalTransaccion;
  final double montoAnticiposPrevios;
  final double descuentoCartera;
  final double saldoNetoPagado;
  final String estado;
  final int? fechaAnulacion;
  final String? motivoAnulacion;
  final int fechaLiquidacion;
  const DBLiquidacion({
    required this.id,
    required this.transaccionId,
    required this.cajaId,
    required this.montoTotalTransaccion,
    required this.montoAnticiposPrevios,
    required this.descuentoCartera,
    required this.saldoNetoPagado,
    required this.estado,
    this.fechaAnulacion,
    this.motivoAnulacion,
    required this.fechaLiquidacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaccion_id'] = Variable<int>(transaccionId);
    map['caja_id'] = Variable<int>(cajaId);
    map['monto_total_transaccion'] = Variable<double>(montoTotalTransaccion);
    map['monto_anticipos_previos'] = Variable<double>(montoAnticiposPrevios);
    map['descuento_cartera'] = Variable<double>(descuentoCartera);
    map['saldo_neto_pagado'] = Variable<double>(saldoNetoPagado);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || fechaAnulacion != null) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion);
    }
    if (!nullToAbsent || motivoAnulacion != null) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion);
    }
    map['fecha_liquidacion'] = Variable<int>(fechaLiquidacion);
    return map;
  }

  LiquidacionesCompanion toCompanion(bool nullToAbsent) {
    return LiquidacionesCompanion(
      id: Value(id),
      transaccionId: Value(transaccionId),
      cajaId: Value(cajaId),
      montoTotalTransaccion: Value(montoTotalTransaccion),
      montoAnticiposPrevios: Value(montoAnticiposPrevios),
      descuentoCartera: Value(descuentoCartera),
      saldoNetoPagado: Value(saldoNetoPagado),
      estado: Value(estado),
      fechaAnulacion: fechaAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaAnulacion),
      motivoAnulacion: motivoAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoAnulacion),
      fechaLiquidacion: Value(fechaLiquidacion),
    );
  }

  factory DBLiquidacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBLiquidacion(
      id: serializer.fromJson<int>(json['id']),
      transaccionId: serializer.fromJson<int>(json['transaccionId']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      montoTotalTransaccion: serializer.fromJson<double>(
        json['montoTotalTransaccion'],
      ),
      montoAnticiposPrevios: serializer.fromJson<double>(
        json['montoAnticiposPrevios'],
      ),
      descuentoCartera: serializer.fromJson<double>(json['descuentoCartera']),
      saldoNetoPagado: serializer.fromJson<double>(json['saldoNetoPagado']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaAnulacion: serializer.fromJson<int?>(json['fechaAnulacion']),
      motivoAnulacion: serializer.fromJson<String?>(json['motivoAnulacion']),
      fechaLiquidacion: serializer.fromJson<int>(json['fechaLiquidacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transaccionId': serializer.toJson<int>(transaccionId),
      'cajaId': serializer.toJson<int>(cajaId),
      'montoTotalTransaccion': serializer.toJson<double>(montoTotalTransaccion),
      'montoAnticiposPrevios': serializer.toJson<double>(montoAnticiposPrevios),
      'descuentoCartera': serializer.toJson<double>(descuentoCartera),
      'saldoNetoPagado': serializer.toJson<double>(saldoNetoPagado),
      'estado': serializer.toJson<String>(estado),
      'fechaAnulacion': serializer.toJson<int?>(fechaAnulacion),
      'motivoAnulacion': serializer.toJson<String?>(motivoAnulacion),
      'fechaLiquidacion': serializer.toJson<int>(fechaLiquidacion),
    };
  }

  DBLiquidacion copyWith({
    int? id,
    int? transaccionId,
    int? cajaId,
    double? montoTotalTransaccion,
    double? montoAnticiposPrevios,
    double? descuentoCartera,
    double? saldoNetoPagado,
    String? estado,
    Value<int?> fechaAnulacion = const Value.absent(),
    Value<String?> motivoAnulacion = const Value.absent(),
    int? fechaLiquidacion,
  }) => DBLiquidacion(
    id: id ?? this.id,
    transaccionId: transaccionId ?? this.transaccionId,
    cajaId: cajaId ?? this.cajaId,
    montoTotalTransaccion: montoTotalTransaccion ?? this.montoTotalTransaccion,
    montoAnticiposPrevios: montoAnticiposPrevios ?? this.montoAnticiposPrevios,
    descuentoCartera: descuentoCartera ?? this.descuentoCartera,
    saldoNetoPagado: saldoNetoPagado ?? this.saldoNetoPagado,
    estado: estado ?? this.estado,
    fechaAnulacion: fechaAnulacion.present
        ? fechaAnulacion.value
        : this.fechaAnulacion,
    motivoAnulacion: motivoAnulacion.present
        ? motivoAnulacion.value
        : this.motivoAnulacion,
    fechaLiquidacion: fechaLiquidacion ?? this.fechaLiquidacion,
  );
  DBLiquidacion copyWithCompanion(LiquidacionesCompanion data) {
    return DBLiquidacion(
      id: data.id.present ? data.id.value : this.id,
      transaccionId: data.transaccionId.present
          ? data.transaccionId.value
          : this.transaccionId,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      montoTotalTransaccion: data.montoTotalTransaccion.present
          ? data.montoTotalTransaccion.value
          : this.montoTotalTransaccion,
      montoAnticiposPrevios: data.montoAnticiposPrevios.present
          ? data.montoAnticiposPrevios.value
          : this.montoAnticiposPrevios,
      descuentoCartera: data.descuentoCartera.present
          ? data.descuentoCartera.value
          : this.descuentoCartera,
      saldoNetoPagado: data.saldoNetoPagado.present
          ? data.saldoNetoPagado.value
          : this.saldoNetoPagado,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaAnulacion: data.fechaAnulacion.present
          ? data.fechaAnulacion.value
          : this.fechaAnulacion,
      motivoAnulacion: data.motivoAnulacion.present
          ? data.motivoAnulacion.value
          : this.motivoAnulacion,
      fechaLiquidacion: data.fechaLiquidacion.present
          ? data.fechaLiquidacion.value
          : this.fechaLiquidacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBLiquidacion(')
          ..write('id: $id, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoTotalTransaccion: $montoTotalTransaccion, ')
          ..write('montoAnticiposPrevios: $montoAnticiposPrevios, ')
          ..write('descuentoCartera: $descuentoCartera, ')
          ..write('saldoNetoPagado: $saldoNetoPagado, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion, ')
          ..write('fechaLiquidacion: $fechaLiquidacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transaccionId,
    cajaId,
    montoTotalTransaccion,
    montoAnticiposPrevios,
    descuentoCartera,
    saldoNetoPagado,
    estado,
    fechaAnulacion,
    motivoAnulacion,
    fechaLiquidacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBLiquidacion &&
          other.id == this.id &&
          other.transaccionId == this.transaccionId &&
          other.cajaId == this.cajaId &&
          other.montoTotalTransaccion == this.montoTotalTransaccion &&
          other.montoAnticiposPrevios == this.montoAnticiposPrevios &&
          other.descuentoCartera == this.descuentoCartera &&
          other.saldoNetoPagado == this.saldoNetoPagado &&
          other.estado == this.estado &&
          other.fechaAnulacion == this.fechaAnulacion &&
          other.motivoAnulacion == this.motivoAnulacion &&
          other.fechaLiquidacion == this.fechaLiquidacion);
}

class LiquidacionesCompanion extends UpdateCompanion<DBLiquidacion> {
  final Value<int> id;
  final Value<int> transaccionId;
  final Value<int> cajaId;
  final Value<double> montoTotalTransaccion;
  final Value<double> montoAnticiposPrevios;
  final Value<double> descuentoCartera;
  final Value<double> saldoNetoPagado;
  final Value<String> estado;
  final Value<int?> fechaAnulacion;
  final Value<String?> motivoAnulacion;
  final Value<int> fechaLiquidacion;
  const LiquidacionesCompanion({
    this.id = const Value.absent(),
    this.transaccionId = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.montoTotalTransaccion = const Value.absent(),
    this.montoAnticiposPrevios = const Value.absent(),
    this.descuentoCartera = const Value.absent(),
    this.saldoNetoPagado = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
    this.fechaLiquidacion = const Value.absent(),
  });
  LiquidacionesCompanion.insert({
    this.id = const Value.absent(),
    required int transaccionId,
    required int cajaId,
    required double montoTotalTransaccion,
    this.montoAnticiposPrevios = const Value.absent(),
    this.descuentoCartera = const Value.absent(),
    required double saldoNetoPagado,
    this.estado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
    required int fechaLiquidacion,
  }) : transaccionId = Value(transaccionId),
       cajaId = Value(cajaId),
       montoTotalTransaccion = Value(montoTotalTransaccion),
       saldoNetoPagado = Value(saldoNetoPagado),
       fechaLiquidacion = Value(fechaLiquidacion);
  static Insertable<DBLiquidacion> custom({
    Expression<int>? id,
    Expression<int>? transaccionId,
    Expression<int>? cajaId,
    Expression<double>? montoTotalTransaccion,
    Expression<double>? montoAnticiposPrevios,
    Expression<double>? descuentoCartera,
    Expression<double>? saldoNetoPagado,
    Expression<String>? estado,
    Expression<int>? fechaAnulacion,
    Expression<String>? motivoAnulacion,
    Expression<int>? fechaLiquidacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transaccionId != null) 'transaccion_id': transaccionId,
      if (cajaId != null) 'caja_id': cajaId,
      if (montoTotalTransaccion != null)
        'monto_total_transaccion': montoTotalTransaccion,
      if (montoAnticiposPrevios != null)
        'monto_anticipos_previos': montoAnticiposPrevios,
      if (descuentoCartera != null) 'descuento_cartera': descuentoCartera,
      if (saldoNetoPagado != null) 'saldo_neto_pagado': saldoNetoPagado,
      if (estado != null) 'estado': estado,
      if (fechaAnulacion != null) 'fecha_anulacion': fechaAnulacion,
      if (motivoAnulacion != null) 'motivo_anulacion': motivoAnulacion,
      if (fechaLiquidacion != null) 'fecha_liquidacion': fechaLiquidacion,
    });
  }

  LiquidacionesCompanion copyWith({
    Value<int>? id,
    Value<int>? transaccionId,
    Value<int>? cajaId,
    Value<double>? montoTotalTransaccion,
    Value<double>? montoAnticiposPrevios,
    Value<double>? descuentoCartera,
    Value<double>? saldoNetoPagado,
    Value<String>? estado,
    Value<int?>? fechaAnulacion,
    Value<String?>? motivoAnulacion,
    Value<int>? fechaLiquidacion,
  }) {
    return LiquidacionesCompanion(
      id: id ?? this.id,
      transaccionId: transaccionId ?? this.transaccionId,
      cajaId: cajaId ?? this.cajaId,
      montoTotalTransaccion:
          montoTotalTransaccion ?? this.montoTotalTransaccion,
      montoAnticiposPrevios:
          montoAnticiposPrevios ?? this.montoAnticiposPrevios,
      descuentoCartera: descuentoCartera ?? this.descuentoCartera,
      saldoNetoPagado: saldoNetoPagado ?? this.saldoNetoPagado,
      estado: estado ?? this.estado,
      fechaAnulacion: fechaAnulacion ?? this.fechaAnulacion,
      motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
      fechaLiquidacion: fechaLiquidacion ?? this.fechaLiquidacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transaccionId.present) {
      map['transaccion_id'] = Variable<int>(transaccionId.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (montoTotalTransaccion.present) {
      map['monto_total_transaccion'] = Variable<double>(
        montoTotalTransaccion.value,
      );
    }
    if (montoAnticiposPrevios.present) {
      map['monto_anticipos_previos'] = Variable<double>(
        montoAnticiposPrevios.value,
      );
    }
    if (descuentoCartera.present) {
      map['descuento_cartera'] = Variable<double>(descuentoCartera.value);
    }
    if (saldoNetoPagado.present) {
      map['saldo_neto_pagado'] = Variable<double>(saldoNetoPagado.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaAnulacion.present) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion.value);
    }
    if (motivoAnulacion.present) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion.value);
    }
    if (fechaLiquidacion.present) {
      map['fecha_liquidacion'] = Variable<int>(fechaLiquidacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LiquidacionesCompanion(')
          ..write('id: $id, ')
          ..write('transaccionId: $transaccionId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoTotalTransaccion: $montoTotalTransaccion, ')
          ..write('montoAnticiposPrevios: $montoAnticiposPrevios, ')
          ..write('descuentoCartera: $descuentoCartera, ')
          ..write('saldoNetoPagado: $saldoNetoPagado, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion, ')
          ..write('fechaLiquidacion: $fechaLiquidacion')
          ..write(')'))
        .toString();
  }
}

class $PrestamosTable extends Prestamos
    with TableInfo<$PrestamosTable, DBPrestamo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrestamosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cicloOperativoIdMeta = const VerificationMeta(
    'cicloOperativoId',
  );
  @override
  late final GeneratedColumn<int> cicloOperativoId = GeneratedColumn<int>(
    'ciclo_operativo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoPrestadoMeta = const VerificationMeta(
    'montoPrestado',
  );
  @override
  late final GeneratedColumn<double> montoPrestado = GeneratedColumn<double>(
    'monto_prestado',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monto_prestado > 0)',
  );
  static const VerificationMeta _saldoPendienteMeta = const VerificationMeta(
    'saldoPendiente',
  );
  @override
  late final GeneratedColumn<double> saldoPendiente = GeneratedColumn<double>(
    'saldo_pendiente',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (saldo_pendiente >= 0)',
  );
  static const VerificationMeta _fechaPrestamoMeta = const VerificationMeta(
    'fechaPrestamo',
  );
  @override
  late final GeneratedColumn<int> fechaPrestamo = GeneratedColumn<int>(
    'fecha_prestamo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (estado IN (\'VIGENTE\',\'PAGADO\',\'ANULADO\'))',
  );
  static const VerificationMeta _fechaAnulacionMeta = const VerificationMeta(
    'fechaAnulacion',
  );
  @override
  late final GeneratedColumn<int> fechaAnulacion = GeneratedColumn<int>(
    'fecha_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoAnulacionMeta = const VerificationMeta(
    'motivoAnulacion',
  );
  @override
  late final GeneratedColumn<String> motivoAnulacion = GeneratedColumn<String>(
    'motivo_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    cicloOperativoId,
    montoPrestado,
    saldoPendiente,
    fechaPrestamo,
    estado,
    fechaAnulacion,
    motivoAnulacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prestamos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBPrestamo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('ciclo_operativo_id')) {
      context.handle(
        _cicloOperativoIdMeta,
        cicloOperativoId.isAcceptableOrUnknown(
          data['ciclo_operativo_id']!,
          _cicloOperativoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cicloOperativoIdMeta);
    }
    if (data.containsKey('monto_prestado')) {
      context.handle(
        _montoPrestadoMeta,
        montoPrestado.isAcceptableOrUnknown(
          data['monto_prestado']!,
          _montoPrestadoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoPrestadoMeta);
    }
    if (data.containsKey('saldo_pendiente')) {
      context.handle(
        _saldoPendienteMeta,
        saldoPendiente.isAcceptableOrUnknown(
          data['saldo_pendiente']!,
          _saldoPendienteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saldoPendienteMeta);
    }
    if (data.containsKey('fecha_prestamo')) {
      context.handle(
        _fechaPrestamoMeta,
        fechaPrestamo.isAcceptableOrUnknown(
          data['fecha_prestamo']!,
          _fechaPrestamoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaPrestamoMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('fecha_anulacion')) {
      context.handle(
        _fechaAnulacionMeta,
        fechaAnulacion.isAcceptableOrUnknown(
          data['fecha_anulacion']!,
          _fechaAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('motivo_anulacion')) {
      context.handle(
        _motivoAnulacionMeta,
        motivoAnulacion.isAcceptableOrUnknown(
          data['motivo_anulacion']!,
          _motivoAnulacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBPrestamo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBPrestamo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      cicloOperativoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_operativo_id'],
      )!,
      montoPrestado: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_prestado'],
      )!,
      saldoPendiente: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saldo_pendiente'],
      )!,
      fechaPrestamo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_prestamo'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      fechaAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_anulacion'],
      ),
      motivoAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_anulacion'],
      ),
    );
  }

  @override
  $PrestamosTable createAlias(String alias) {
    return $PrestamosTable(attachedDatabase, alias);
  }
}

class DBPrestamo extends DataClass implements Insertable<DBPrestamo> {
  final int id;
  final int clienteId;
  final int cicloOperativoId;
  final double montoPrestado;
  final double saldoPendiente;
  final int fechaPrestamo;
  final String estado;
  final int? fechaAnulacion;
  final String? motivoAnulacion;
  const DBPrestamo({
    required this.id,
    required this.clienteId,
    required this.cicloOperativoId,
    required this.montoPrestado,
    required this.saldoPendiente,
    required this.fechaPrestamo,
    required this.estado,
    this.fechaAnulacion,
    this.motivoAnulacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId);
    map['monto_prestado'] = Variable<double>(montoPrestado);
    map['saldo_pendiente'] = Variable<double>(saldoPendiente);
    map['fecha_prestamo'] = Variable<int>(fechaPrestamo);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || fechaAnulacion != null) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion);
    }
    if (!nullToAbsent || motivoAnulacion != null) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion);
    }
    return map;
  }

  PrestamosCompanion toCompanion(bool nullToAbsent) {
    return PrestamosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      cicloOperativoId: Value(cicloOperativoId),
      montoPrestado: Value(montoPrestado),
      saldoPendiente: Value(saldoPendiente),
      fechaPrestamo: Value(fechaPrestamo),
      estado: Value(estado),
      fechaAnulacion: fechaAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaAnulacion),
      motivoAnulacion: motivoAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoAnulacion),
    );
  }

  factory DBPrestamo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBPrestamo(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      cicloOperativoId: serializer.fromJson<int>(json['cicloOperativoId']),
      montoPrestado: serializer.fromJson<double>(json['montoPrestado']),
      saldoPendiente: serializer.fromJson<double>(json['saldoPendiente']),
      fechaPrestamo: serializer.fromJson<int>(json['fechaPrestamo']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaAnulacion: serializer.fromJson<int?>(json['fechaAnulacion']),
      motivoAnulacion: serializer.fromJson<String?>(json['motivoAnulacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'cicloOperativoId': serializer.toJson<int>(cicloOperativoId),
      'montoPrestado': serializer.toJson<double>(montoPrestado),
      'saldoPendiente': serializer.toJson<double>(saldoPendiente),
      'fechaPrestamo': serializer.toJson<int>(fechaPrestamo),
      'estado': serializer.toJson<String>(estado),
      'fechaAnulacion': serializer.toJson<int?>(fechaAnulacion),
      'motivoAnulacion': serializer.toJson<String?>(motivoAnulacion),
    };
  }

  DBPrestamo copyWith({
    int? id,
    int? clienteId,
    int? cicloOperativoId,
    double? montoPrestado,
    double? saldoPendiente,
    int? fechaPrestamo,
    String? estado,
    Value<int?> fechaAnulacion = const Value.absent(),
    Value<String?> motivoAnulacion = const Value.absent(),
  }) => DBPrestamo(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
    montoPrestado: montoPrestado ?? this.montoPrestado,
    saldoPendiente: saldoPendiente ?? this.saldoPendiente,
    fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
    estado: estado ?? this.estado,
    fechaAnulacion: fechaAnulacion.present
        ? fechaAnulacion.value
        : this.fechaAnulacion,
    motivoAnulacion: motivoAnulacion.present
        ? motivoAnulacion.value
        : this.motivoAnulacion,
  );
  DBPrestamo copyWithCompanion(PrestamosCompanion data) {
    return DBPrestamo(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      cicloOperativoId: data.cicloOperativoId.present
          ? data.cicloOperativoId.value
          : this.cicloOperativoId,
      montoPrestado: data.montoPrestado.present
          ? data.montoPrestado.value
          : this.montoPrestado,
      saldoPendiente: data.saldoPendiente.present
          ? data.saldoPendiente.value
          : this.saldoPendiente,
      fechaPrestamo: data.fechaPrestamo.present
          ? data.fechaPrestamo.value
          : this.fechaPrestamo,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaAnulacion: data.fechaAnulacion.present
          ? data.fechaAnulacion.value
          : this.fechaAnulacion,
      motivoAnulacion: data.motivoAnulacion.present
          ? data.motivoAnulacion.value
          : this.motivoAnulacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBPrestamo(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('montoPrestado: $montoPrestado, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('fechaPrestamo: $fechaPrestamo, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    cicloOperativoId,
    montoPrestado,
    saldoPendiente,
    fechaPrestamo,
    estado,
    fechaAnulacion,
    motivoAnulacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBPrestamo &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.cicloOperativoId == this.cicloOperativoId &&
          other.montoPrestado == this.montoPrestado &&
          other.saldoPendiente == this.saldoPendiente &&
          other.fechaPrestamo == this.fechaPrestamo &&
          other.estado == this.estado &&
          other.fechaAnulacion == this.fechaAnulacion &&
          other.motivoAnulacion == this.motivoAnulacion);
}

class PrestamosCompanion extends UpdateCompanion<DBPrestamo> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<int> cicloOperativoId;
  final Value<double> montoPrestado;
  final Value<double> saldoPendiente;
  final Value<int> fechaPrestamo;
  final Value<String> estado;
  final Value<int?> fechaAnulacion;
  final Value<String?> motivoAnulacion;
  const PrestamosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.cicloOperativoId = const Value.absent(),
    this.montoPrestado = const Value.absent(),
    this.saldoPendiente = const Value.absent(),
    this.fechaPrestamo = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
  });
  PrestamosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required int cicloOperativoId,
    required double montoPrestado,
    required double saldoPendiente,
    required int fechaPrestamo,
    required String estado,
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
  }) : clienteId = Value(clienteId),
       cicloOperativoId = Value(cicloOperativoId),
       montoPrestado = Value(montoPrestado),
       saldoPendiente = Value(saldoPendiente),
       fechaPrestamo = Value(fechaPrestamo),
       estado = Value(estado);
  static Insertable<DBPrestamo> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? cicloOperativoId,
    Expression<double>? montoPrestado,
    Expression<double>? saldoPendiente,
    Expression<int>? fechaPrestamo,
    Expression<String>? estado,
    Expression<int>? fechaAnulacion,
    Expression<String>? motivoAnulacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (cicloOperativoId != null) 'ciclo_operativo_id': cicloOperativoId,
      if (montoPrestado != null) 'monto_prestado': montoPrestado,
      if (saldoPendiente != null) 'saldo_pendiente': saldoPendiente,
      if (fechaPrestamo != null) 'fecha_prestamo': fechaPrestamo,
      if (estado != null) 'estado': estado,
      if (fechaAnulacion != null) 'fecha_anulacion': fechaAnulacion,
      if (motivoAnulacion != null) 'motivo_anulacion': motivoAnulacion,
    });
  }

  PrestamosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<int>? cicloOperativoId,
    Value<double>? montoPrestado,
    Value<double>? saldoPendiente,
    Value<int>? fechaPrestamo,
    Value<String>? estado,
    Value<int?>? fechaAnulacion,
    Value<String?>? motivoAnulacion,
  }) {
    return PrestamosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
      montoPrestado: montoPrestado ?? this.montoPrestado,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      fechaPrestamo: fechaPrestamo ?? this.fechaPrestamo,
      estado: estado ?? this.estado,
      fechaAnulacion: fechaAnulacion ?? this.fechaAnulacion,
      motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (cicloOperativoId.present) {
      map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId.value);
    }
    if (montoPrestado.present) {
      map['monto_prestado'] = Variable<double>(montoPrestado.value);
    }
    if (saldoPendiente.present) {
      map['saldo_pendiente'] = Variable<double>(saldoPendiente.value);
    }
    if (fechaPrestamo.present) {
      map['fecha_prestamo'] = Variable<int>(fechaPrestamo.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaAnulacion.present) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion.value);
    }
    if (motivoAnulacion.present) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrestamosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('montoPrestado: $montoPrestado, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('fechaPrestamo: $fechaPrestamo, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion')
          ..write(')'))
        .toString();
  }
}

class $AbonosTable extends Abonos with TableInfo<$AbonosTable, DBAbono> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbonosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
    'caja_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoTotalMeta = const VerificationMeta(
    'montoTotal',
  );
  @override
  late final GeneratedColumn<double> montoTotal = GeneratedColumn<double>(
    'monto_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monto_total > 0)',
  );
  static const VerificationMeta _anuladoMeta = const VerificationMeta(
    'anulado',
  );
  @override
  late final GeneratedColumn<int> anulado = GeneratedColumn<int>(
    'anulado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fechaAnulacionMeta = const VerificationMeta(
    'fechaAnulacion',
  );
  @override
  late final GeneratedColumn<int> fechaAnulacion = GeneratedColumn<int>(
    'fecha_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoAnulacionMeta = const VerificationMeta(
    'motivoAnulacion',
  );
  @override
  late final GeneratedColumn<String> motivoAnulacion = GeneratedColumn<String>(
    'motivo_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaAbonoMeta = const VerificationMeta(
    'fechaAbono',
  );
  @override
  late final GeneratedColumn<int> fechaAbono = GeneratedColumn<int>(
    'fecha_abono',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    cajaId,
    montoTotal,
    anulado,
    fechaAnulacion,
    motivoAnulacion,
    fechaAbono,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abonos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBAbono> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('caja_id')) {
      context.handle(
        _cajaIdMeta,
        cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('monto_total')) {
      context.handle(
        _montoTotalMeta,
        montoTotal.isAcceptableOrUnknown(data['monto_total']!, _montoTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_montoTotalMeta);
    }
    if (data.containsKey('anulado')) {
      context.handle(
        _anuladoMeta,
        anulado.isAcceptableOrUnknown(data['anulado']!, _anuladoMeta),
      );
    }
    if (data.containsKey('fecha_anulacion')) {
      context.handle(
        _fechaAnulacionMeta,
        fechaAnulacion.isAcceptableOrUnknown(
          data['fecha_anulacion']!,
          _fechaAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('motivo_anulacion')) {
      context.handle(
        _motivoAnulacionMeta,
        motivoAnulacion.isAcceptableOrUnknown(
          data['motivo_anulacion']!,
          _motivoAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('fecha_abono')) {
      context.handle(
        _fechaAbonoMeta,
        fechaAbono.isAcceptableOrUnknown(data['fecha_abono']!, _fechaAbonoMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaAbonoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBAbono map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBAbono(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      cajaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}caja_id'],
      )!,
      montoTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_total'],
      )!,
      anulado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anulado'],
      )!,
      fechaAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_anulacion'],
      ),
      motivoAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_anulacion'],
      ),
      fechaAbono: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_abono'],
      )!,
    );
  }

  @override
  $AbonosTable createAlias(String alias) {
    return $AbonosTable(attachedDatabase, alias);
  }
}

class DBAbono extends DataClass implements Insertable<DBAbono> {
  final int id;
  final int clienteId;
  final int cajaId;
  final double montoTotal;
  final int anulado;
  final int? fechaAnulacion;
  final String? motivoAnulacion;
  final int fechaAbono;
  const DBAbono({
    required this.id,
    required this.clienteId,
    required this.cajaId,
    required this.montoTotal,
    required this.anulado,
    this.fechaAnulacion,
    this.motivoAnulacion,
    required this.fechaAbono,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['caja_id'] = Variable<int>(cajaId);
    map['monto_total'] = Variable<double>(montoTotal);
    map['anulado'] = Variable<int>(anulado);
    if (!nullToAbsent || fechaAnulacion != null) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion);
    }
    if (!nullToAbsent || motivoAnulacion != null) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion);
    }
    map['fecha_abono'] = Variable<int>(fechaAbono);
    return map;
  }

  AbonosCompanion toCompanion(bool nullToAbsent) {
    return AbonosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      cajaId: Value(cajaId),
      montoTotal: Value(montoTotal),
      anulado: Value(anulado),
      fechaAnulacion: fechaAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaAnulacion),
      motivoAnulacion: motivoAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoAnulacion),
      fechaAbono: Value(fechaAbono),
    );
  }

  factory DBAbono.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBAbono(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      montoTotal: serializer.fromJson<double>(json['montoTotal']),
      anulado: serializer.fromJson<int>(json['anulado']),
      fechaAnulacion: serializer.fromJson<int?>(json['fechaAnulacion']),
      motivoAnulacion: serializer.fromJson<String?>(json['motivoAnulacion']),
      fechaAbono: serializer.fromJson<int>(json['fechaAbono']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'cajaId': serializer.toJson<int>(cajaId),
      'montoTotal': serializer.toJson<double>(montoTotal),
      'anulado': serializer.toJson<int>(anulado),
      'fechaAnulacion': serializer.toJson<int?>(fechaAnulacion),
      'motivoAnulacion': serializer.toJson<String?>(motivoAnulacion),
      'fechaAbono': serializer.toJson<int>(fechaAbono),
    };
  }

  DBAbono copyWith({
    int? id,
    int? clienteId,
    int? cajaId,
    double? montoTotal,
    int? anulado,
    Value<int?> fechaAnulacion = const Value.absent(),
    Value<String?> motivoAnulacion = const Value.absent(),
    int? fechaAbono,
  }) => DBAbono(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    cajaId: cajaId ?? this.cajaId,
    montoTotal: montoTotal ?? this.montoTotal,
    anulado: anulado ?? this.anulado,
    fechaAnulacion: fechaAnulacion.present
        ? fechaAnulacion.value
        : this.fechaAnulacion,
    motivoAnulacion: motivoAnulacion.present
        ? motivoAnulacion.value
        : this.motivoAnulacion,
    fechaAbono: fechaAbono ?? this.fechaAbono,
  );
  DBAbono copyWithCompanion(AbonosCompanion data) {
    return DBAbono(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      montoTotal: data.montoTotal.present
          ? data.montoTotal.value
          : this.montoTotal,
      anulado: data.anulado.present ? data.anulado.value : this.anulado,
      fechaAnulacion: data.fechaAnulacion.present
          ? data.fechaAnulacion.value
          : this.fechaAnulacion,
      motivoAnulacion: data.motivoAnulacion.present
          ? data.motivoAnulacion.value
          : this.motivoAnulacion,
      fechaAbono: data.fechaAbono.present
          ? data.fechaAbono.value
          : this.fechaAbono,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBAbono(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoTotal: $montoTotal, ')
          ..write('anulado: $anulado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion, ')
          ..write('fechaAbono: $fechaAbono')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    cajaId,
    montoTotal,
    anulado,
    fechaAnulacion,
    motivoAnulacion,
    fechaAbono,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBAbono &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.cajaId == this.cajaId &&
          other.montoTotal == this.montoTotal &&
          other.anulado == this.anulado &&
          other.fechaAnulacion == this.fechaAnulacion &&
          other.motivoAnulacion == this.motivoAnulacion &&
          other.fechaAbono == this.fechaAbono);
}

class AbonosCompanion extends UpdateCompanion<DBAbono> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<int> cajaId;
  final Value<double> montoTotal;
  final Value<int> anulado;
  final Value<int?> fechaAnulacion;
  final Value<String?> motivoAnulacion;
  final Value<int> fechaAbono;
  const AbonosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.montoTotal = const Value.absent(),
    this.anulado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
    this.fechaAbono = const Value.absent(),
  });
  AbonosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required int cajaId,
    required double montoTotal,
    this.anulado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
    required int fechaAbono,
  }) : clienteId = Value(clienteId),
       cajaId = Value(cajaId),
       montoTotal = Value(montoTotal),
       fechaAbono = Value(fechaAbono);
  static Insertable<DBAbono> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? cajaId,
    Expression<double>? montoTotal,
    Expression<int>? anulado,
    Expression<int>? fechaAnulacion,
    Expression<String>? motivoAnulacion,
    Expression<int>? fechaAbono,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (cajaId != null) 'caja_id': cajaId,
      if (montoTotal != null) 'monto_total': montoTotal,
      if (anulado != null) 'anulado': anulado,
      if (fechaAnulacion != null) 'fecha_anulacion': fechaAnulacion,
      if (motivoAnulacion != null) 'motivo_anulacion': motivoAnulacion,
      if (fechaAbono != null) 'fecha_abono': fechaAbono,
    });
  }

  AbonosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<int>? cajaId,
    Value<double>? montoTotal,
    Value<int>? anulado,
    Value<int?>? fechaAnulacion,
    Value<String?>? motivoAnulacion,
    Value<int>? fechaAbono,
  }) {
    return AbonosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      cajaId: cajaId ?? this.cajaId,
      montoTotal: montoTotal ?? this.montoTotal,
      anulado: anulado ?? this.anulado,
      fechaAnulacion: fechaAnulacion ?? this.fechaAnulacion,
      motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
      fechaAbono: fechaAbono ?? this.fechaAbono,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (montoTotal.present) {
      map['monto_total'] = Variable<double>(montoTotal.value);
    }
    if (anulado.present) {
      map['anulado'] = Variable<int>(anulado.value);
    }
    if (fechaAnulacion.present) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion.value);
    }
    if (motivoAnulacion.present) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion.value);
    }
    if (fechaAbono.present) {
      map['fecha_abono'] = Variable<int>(fechaAbono.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbonosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoTotal: $montoTotal, ')
          ..write('anulado: $anulado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion, ')
          ..write('fechaAbono: $fechaAbono')
          ..write(')'))
        .toString();
  }
}

class $AbonosDetallesTable extends AbonosDetalles
    with TableInfo<$AbonosDetallesTable, DBAbonoDetalle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbonosDetallesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _abonoIdMeta = const VerificationMeta(
    'abonoId',
  );
  @override
  late final GeneratedColumn<int> abonoId = GeneratedColumn<int>(
    'abono_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinoTipoMeta = const VerificationMeta(
    'destinoTipo',
  );
  @override
  late final GeneratedColumn<String> destinoTipo = GeneratedColumn<String>(
    'destino_tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (destino_tipo IN (\'ANTICIPO_COMPRA\',\'PRESTAMO\',\'CREDITO_POS\',\'VENTA_PENDIENTE\'))',
  );
  static const VerificationMeta _destinoIdMeta = const VerificationMeta(
    'destinoId',
  );
  @override
  late final GeneratedColumn<int> destinoId = GeneratedColumn<int>(
    'destino_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoAppliedMeta = const VerificationMeta(
    'montoApplied',
  );
  @override
  late final GeneratedColumn<double> montoApplied = GeneratedColumn<double>(
    'monto_applied',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (monto_applied >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    abonoId,
    destinoTipo,
    destinoId,
    montoApplied,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abonos_detalles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBAbonoDetalle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('abono_id')) {
      context.handle(
        _abonoIdMeta,
        abonoId.isAcceptableOrUnknown(data['abono_id']!, _abonoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_abonoIdMeta);
    }
    if (data.containsKey('destino_tipo')) {
      context.handle(
        _destinoTipoMeta,
        destinoTipo.isAcceptableOrUnknown(
          data['destino_tipo']!,
          _destinoTipoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinoTipoMeta);
    }
    if (data.containsKey('destino_id')) {
      context.handle(
        _destinoIdMeta,
        destinoId.isAcceptableOrUnknown(data['destino_id']!, _destinoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_destinoIdMeta);
    }
    if (data.containsKey('monto_applied')) {
      context.handle(
        _montoAppliedMeta,
        montoApplied.isAcceptableOrUnknown(
          data['monto_applied']!,
          _montoAppliedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoAppliedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBAbonoDetalle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBAbonoDetalle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      abonoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}abono_id'],
      )!,
      destinoTipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destino_tipo'],
      )!,
      destinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}destino_id'],
      )!,
      montoApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_applied'],
      )!,
    );
  }

  @override
  $AbonosDetallesTable createAlias(String alias) {
    return $AbonosDetallesTable(attachedDatabase, alias);
  }
}

class DBAbonoDetalle extends DataClass implements Insertable<DBAbonoDetalle> {
  final int id;
  final int abonoId;
  final String destinoTipo;
  final int destinoId;
  final double montoApplied;
  const DBAbonoDetalle({
    required this.id,
    required this.abonoId,
    required this.destinoTipo,
    required this.destinoId,
    required this.montoApplied,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['abono_id'] = Variable<int>(abonoId);
    map['destino_tipo'] = Variable<String>(destinoTipo);
    map['destino_id'] = Variable<int>(destinoId);
    map['monto_applied'] = Variable<double>(montoApplied);
    return map;
  }

  AbonosDetallesCompanion toCompanion(bool nullToAbsent) {
    return AbonosDetallesCompanion(
      id: Value(id),
      abonoId: Value(abonoId),
      destinoTipo: Value(destinoTipo),
      destinoId: Value(destinoId),
      montoApplied: Value(montoApplied),
    );
  }

  factory DBAbonoDetalle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBAbonoDetalle(
      id: serializer.fromJson<int>(json['id']),
      abonoId: serializer.fromJson<int>(json['abonoId']),
      destinoTipo: serializer.fromJson<String>(json['destinoTipo']),
      destinoId: serializer.fromJson<int>(json['destinoId']),
      montoApplied: serializer.fromJson<double>(json['montoApplied']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'abonoId': serializer.toJson<int>(abonoId),
      'destinoTipo': serializer.toJson<String>(destinoTipo),
      'destinoId': serializer.toJson<int>(destinoId),
      'montoApplied': serializer.toJson<double>(montoApplied),
    };
  }

  DBAbonoDetalle copyWith({
    int? id,
    int? abonoId,
    String? destinoTipo,
    int? destinoId,
    double? montoApplied,
  }) => DBAbonoDetalle(
    id: id ?? this.id,
    abonoId: abonoId ?? this.abonoId,
    destinoTipo: destinoTipo ?? this.destinoTipo,
    destinoId: destinoId ?? this.destinoId,
    montoApplied: montoApplied ?? this.montoApplied,
  );
  DBAbonoDetalle copyWithCompanion(AbonosDetallesCompanion data) {
    return DBAbonoDetalle(
      id: data.id.present ? data.id.value : this.id,
      abonoId: data.abonoId.present ? data.abonoId.value : this.abonoId,
      destinoTipo: data.destinoTipo.present
          ? data.destinoTipo.value
          : this.destinoTipo,
      destinoId: data.destinoId.present ? data.destinoId.value : this.destinoId,
      montoApplied: data.montoApplied.present
          ? data.montoApplied.value
          : this.montoApplied,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBAbonoDetalle(')
          ..write('id: $id, ')
          ..write('abonoId: $abonoId, ')
          ..write('destinoTipo: $destinoTipo, ')
          ..write('destinoId: $destinoId, ')
          ..write('montoApplied: $montoApplied')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, abonoId, destinoTipo, destinoId, montoApplied);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBAbonoDetalle &&
          other.id == this.id &&
          other.abonoId == this.abonoId &&
          other.destinoTipo == this.destinoTipo &&
          other.destinoId == this.destinoId &&
          other.montoApplied == this.montoApplied);
}

class AbonosDetallesCompanion extends UpdateCompanion<DBAbonoDetalle> {
  final Value<int> id;
  final Value<int> abonoId;
  final Value<String> destinoTipo;
  final Value<int> destinoId;
  final Value<double> montoApplied;
  const AbonosDetallesCompanion({
    this.id = const Value.absent(),
    this.abonoId = const Value.absent(),
    this.destinoTipo = const Value.absent(),
    this.destinoId = const Value.absent(),
    this.montoApplied = const Value.absent(),
  });
  AbonosDetallesCompanion.insert({
    this.id = const Value.absent(),
    required int abonoId,
    required String destinoTipo,
    required int destinoId,
    required double montoApplied,
  }) : abonoId = Value(abonoId),
       destinoTipo = Value(destinoTipo),
       destinoId = Value(destinoId),
       montoApplied = Value(montoApplied);
  static Insertable<DBAbonoDetalle> custom({
    Expression<int>? id,
    Expression<int>? abonoId,
    Expression<String>? destinoTipo,
    Expression<int>? destinoId,
    Expression<double>? montoApplied,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (abonoId != null) 'abono_id': abonoId,
      if (destinoTipo != null) 'destino_tipo': destinoTipo,
      if (destinoId != null) 'destino_id': destinoId,
      if (montoApplied != null) 'monto_applied': montoApplied,
    });
  }

  AbonosDetallesCompanion copyWith({
    Value<int>? id,
    Value<int>? abonoId,
    Value<String>? destinoTipo,
    Value<int>? destinoId,
    Value<double>? montoApplied,
  }) {
    return AbonosDetallesCompanion(
      id: id ?? this.id,
      abonoId: abonoId ?? this.abonoId,
      destinoTipo: destinoTipo ?? this.destinoTipo,
      destinoId: destinoId ?? this.destinoId,
      montoApplied: montoApplied ?? this.montoApplied,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (abonoId.present) {
      map['abono_id'] = Variable<int>(abonoId.value);
    }
    if (destinoTipo.present) {
      map['destino_tipo'] = Variable<String>(destinoTipo.value);
    }
    if (destinoId.present) {
      map['destino_id'] = Variable<int>(destinoId.value);
    }
    if (montoApplied.present) {
      map['monto_applied'] = Variable<double>(montoApplied.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbonosDetallesCompanion(')
          ..write('id: $id, ')
          ..write('abonoId: $abonoId, ')
          ..write('destinoTipo: $destinoTipo, ')
          ..write('destinoId: $destinoId, ')
          ..write('montoApplied: $montoApplied')
          ..write(')'))
        .toString();
  }
}

class $ProductosPosTable extends ProductosPos
    with TableInfo<$ProductosPosTable, DBProductoPos> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosPosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoBarrasMeta = const VerificationMeta(
    'codigoBarras',
  );
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
    'codigo_barras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioCompraMeta = const VerificationMeta(
    'precioCompra',
  );
  @override
  late final GeneratedColumn<double> precioCompra = GeneratedColumn<double>(
    'precio_compra',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (precio_compra >= 0)',
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (precio_venta >= 0)',
  );
  static const VerificationMeta _existenciaInicialMeta = const VerificationMeta(
    'existenciaInicial',
  );
  @override
  late final GeneratedColumn<double> existenciaInicial =
      GeneratedColumn<double>(
        'existencia_inicial',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _stockActualMeta = const VerificationMeta(
    'stockActual',
  );
  @override
  late final GeneratedColumn<double> stockActual = GeneratedColumn<double>(
    'stock_actual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (stock_actual >= 0)',
  );
  static const VerificationMeta _stockMinimoAlertaMeta = const VerificationMeta(
    'stockMinimoAlerta',
  );
  @override
  late final GeneratedColumn<double> stockMinimoAlerta =
      GeneratedColumn<double>(
        'stock_minimo_alerta',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<int> activo = GeneratedColumn<int>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoBarras,
    descripcion,
    categoria,
    precioCompra,
    precioVenta,
    existenciaInicial,
    stockActual,
    stockMinimoAlerta,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos_pos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBProductoPos> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
        _codigoBarrasMeta,
        codigoBarras.isAcceptableOrUnknown(
          data['codigo_barras']!,
          _codigoBarrasMeta,
        ),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
        _precioCompraMeta,
        precioCompra.isAcceptableOrUnknown(
          data['precio_compra']!,
          _precioCompraMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioCompraMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('existencia_inicial')) {
      context.handle(
        _existenciaInicialMeta,
        existenciaInicial.isAcceptableOrUnknown(
          data['existencia_inicial']!,
          _existenciaInicialMeta,
        ),
      );
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
        _stockActualMeta,
        stockActual.isAcceptableOrUnknown(
          data['stock_actual']!,
          _stockActualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockActualMeta);
    }
    if (data.containsKey('stock_minimo_alerta')) {
      context.handle(
        _stockMinimoAlertaMeta,
        stockMinimoAlerta.isAcceptableOrUnknown(
          data['stock_minimo_alerta']!,
          _stockMinimoAlertaMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBProductoPos map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBProductoPos(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoBarras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_barras'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      precioCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_compra'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      existenciaInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}existencia_inicial'],
      )!,
      stockActual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_actual'],
      )!,
      stockMinimoAlerta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_minimo_alerta'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $ProductosPosTable createAlias(String alias) {
    return $ProductosPosTable(attachedDatabase, alias);
  }
}

class DBProductoPos extends DataClass implements Insertable<DBProductoPos> {
  final int id;
  final String? codigoBarras;
  final String descripcion;
  final String categoria;
  final double precioCompra;
  final double precioVenta;
  final double existenciaInicial;
  final double stockActual;
  final double stockMinimoAlerta;
  final int activo;
  const DBProductoPos({
    required this.id,
    this.codigoBarras,
    required this.descripcion,
    required this.categoria,
    required this.precioCompra,
    required this.precioVenta,
    required this.existenciaInicial,
    required this.stockActual,
    required this.stockMinimoAlerta,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['descripcion'] = Variable<String>(descripcion);
    map['categoria'] = Variable<String>(categoria);
    map['precio_compra'] = Variable<double>(precioCompra);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['existencia_inicial'] = Variable<double>(existenciaInicial);
    map['stock_actual'] = Variable<double>(stockActual);
    map['stock_minimo_alerta'] = Variable<double>(stockMinimoAlerta);
    map['activo'] = Variable<int>(activo);
    return map;
  }

  ProductosPosCompanion toCompanion(bool nullToAbsent) {
    return ProductosPosCompanion(
      id: Value(id),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      descripcion: Value(descripcion),
      categoria: Value(categoria),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      existenciaInicial: Value(existenciaInicial),
      stockActual: Value(stockActual),
      stockMinimoAlerta: Value(stockMinimoAlerta),
      activo: Value(activo),
    );
  }

  factory DBProductoPos.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBProductoPos(
      id: serializer.fromJson<int>(json['id']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      categoria: serializer.fromJson<String>(json['categoria']),
      precioCompra: serializer.fromJson<double>(json['precioCompra']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      existenciaInicial: serializer.fromJson<double>(json['existenciaInicial']),
      stockActual: serializer.fromJson<double>(json['stockActual']),
      stockMinimoAlerta: serializer.fromJson<double>(json['stockMinimoAlerta']),
      activo: serializer.fromJson<int>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'descripcion': serializer.toJson<String>(descripcion),
      'categoria': serializer.toJson<String>(categoria),
      'precioCompra': serializer.toJson<double>(precioCompra),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'existenciaInicial': serializer.toJson<double>(existenciaInicial),
      'stockActual': serializer.toJson<double>(stockActual),
      'stockMinimoAlerta': serializer.toJson<double>(stockMinimoAlerta),
      'activo': serializer.toJson<int>(activo),
    };
  }

  DBProductoPos copyWith({
    int? id,
    Value<String?> codigoBarras = const Value.absent(),
    String? descripcion,
    String? categoria,
    double? precioCompra,
    double? precioVenta,
    double? existenciaInicial,
    double? stockActual,
    double? stockMinimoAlerta,
    int? activo,
  }) => DBProductoPos(
    id: id ?? this.id,
    codigoBarras: codigoBarras.present ? codigoBarras.value : this.codigoBarras,
    descripcion: descripcion ?? this.descripcion,
    categoria: categoria ?? this.categoria,
    precioCompra: precioCompra ?? this.precioCompra,
    precioVenta: precioVenta ?? this.precioVenta,
    existenciaInicial: existenciaInicial ?? this.existenciaInicial,
    stockActual: stockActual ?? this.stockActual,
    stockMinimoAlerta: stockMinimoAlerta ?? this.stockMinimoAlerta,
    activo: activo ?? this.activo,
  );
  DBProductoPos copyWithCompanion(ProductosPosCompanion data) {
    return DBProductoPos(
      id: data.id.present ? data.id.value : this.id,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      existenciaInicial: data.existenciaInicial.present
          ? data.existenciaInicial.value
          : this.existenciaInicial,
      stockActual: data.stockActual.present
          ? data.stockActual.value
          : this.stockActual,
      stockMinimoAlerta: data.stockMinimoAlerta.present
          ? data.stockMinimoAlerta.value
          : this.stockMinimoAlerta,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBProductoPos(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('existenciaInicial: $existenciaInicial, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimoAlerta: $stockMinimoAlerta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoBarras,
    descripcion,
    categoria,
    precioCompra,
    precioVenta,
    existenciaInicial,
    stockActual,
    stockMinimoAlerta,
    activo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBProductoPos &&
          other.id == this.id &&
          other.codigoBarras == this.codigoBarras &&
          other.descripcion == this.descripcion &&
          other.categoria == this.categoria &&
          other.precioCompra == this.precioCompra &&
          other.precioVenta == this.precioVenta &&
          other.existenciaInicial == this.existenciaInicial &&
          other.stockActual == this.stockActual &&
          other.stockMinimoAlerta == this.stockMinimoAlerta &&
          other.activo == this.activo);
}

class ProductosPosCompanion extends UpdateCompanion<DBProductoPos> {
  final Value<int> id;
  final Value<String?> codigoBarras;
  final Value<String> descripcion;
  final Value<String> categoria;
  final Value<double> precioCompra;
  final Value<double> precioVenta;
  final Value<double> existenciaInicial;
  final Value<double> stockActual;
  final Value<double> stockMinimoAlerta;
  final Value<int> activo;
  const ProductosPosCompanion({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoria = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.existenciaInicial = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimoAlerta = const Value.absent(),
    this.activo = const Value.absent(),
  });
  ProductosPosCompanion.insert({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    required String descripcion,
    required String categoria,
    required double precioCompra,
    required double precioVenta,
    this.existenciaInicial = const Value.absent(),
    required double stockActual,
    this.stockMinimoAlerta = const Value.absent(),
    this.activo = const Value.absent(),
  }) : descripcion = Value(descripcion),
       categoria = Value(categoria),
       precioCompra = Value(precioCompra),
       precioVenta = Value(precioVenta),
       stockActual = Value(stockActual);
  static Insertable<DBProductoPos> custom({
    Expression<int>? id,
    Expression<String>? codigoBarras,
    Expression<String>? descripcion,
    Expression<String>? categoria,
    Expression<double>? precioCompra,
    Expression<double>? precioVenta,
    Expression<double>? existenciaInicial,
    Expression<double>? stockActual,
    Expression<double>? stockMinimoAlerta,
    Expression<int>? activo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoria != null) 'categoria': categoria,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (existenciaInicial != null) 'existencia_inicial': existenciaInicial,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimoAlerta != null) 'stock_minimo_alerta': stockMinimoAlerta,
      if (activo != null) 'activo': activo,
    });
  }

  ProductosPosCompanion copyWith({
    Value<int>? id,
    Value<String?>? codigoBarras,
    Value<String>? descripcion,
    Value<String>? categoria,
    Value<double>? precioCompra,
    Value<double>? precioVenta,
    Value<double>? existenciaInicial,
    Value<double>? stockActual,
    Value<double>? stockMinimoAlerta,
    Value<int>? activo,
  }) {
    return ProductosPosCompanion(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      existenciaInicial: existenciaInicial ?? this.existenciaInicial,
      stockActual: stockActual ?? this.stockActual,
      stockMinimoAlerta: stockMinimoAlerta ?? this.stockMinimoAlerta,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<double>(precioCompra.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (existenciaInicial.present) {
      map['existencia_inicial'] = Variable<double>(existenciaInicial.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<double>(stockActual.value);
    }
    if (stockMinimoAlerta.present) {
      map['stock_minimo_alerta'] = Variable<double>(stockMinimoAlerta.value);
    }
    if (activo.present) {
      map['activo'] = Variable<int>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosPosCompanion(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoria: $categoria, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('existenciaInicial: $existenciaInicial, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimoAlerta: $stockMinimoAlerta, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $VentasPosTable extends VentasPos
    with TableInfo<$VentasPosTable, DBVentaPos> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasPosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoVentaMeta = const VerificationMeta(
    'codigoVenta',
  );
  @override
  late final GeneratedColumn<String> codigoVenta = GeneratedColumn<String>(
    'codigo_venta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cicloOperativoIdMeta = const VerificationMeta(
    'cicloOperativoId',
  );
  @override
  late final GeneratedColumn<int> cicloOperativoId = GeneratedColumn<int>(
    'ciclo_operativo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoPagoMeta = const VerificationMeta(
    'tipoPago',
  );
  @override
  late final GeneratedColumn<String> tipoPago = GeneratedColumn<String>(
    'tipo_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_pago IN (\'CONTADO\',\'CREDITO\'))',
  );
  static const VerificationMeta _totalVentaMeta = const VerificationMeta(
    'totalVenta',
  );
  @override
  late final GeneratedColumn<double> totalVenta = GeneratedColumn<double>(
    'total_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaVentaMeta = const VerificationMeta(
    'fechaVenta',
  );
  @override
  late final GeneratedColumn<int> fechaVenta = GeneratedColumn<int>(
    'fecha_venta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estado IN (\'VALIDADA\',\'ANULADA\'))',
  );
  static const VerificationMeta _fechaAnulacionMeta = const VerificationMeta(
    'fechaAnulacion',
  );
  @override
  late final GeneratedColumn<int> fechaAnulacion = GeneratedColumn<int>(
    'fecha_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoAnulacionMeta = const VerificationMeta(
    'motivoAnulacion',
  );
  @override
  late final GeneratedColumn<String> motivoAnulacion = GeneratedColumn<String>(
    'motivo_anulacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoVenta,
    cicloOperativoId,
    clienteId,
    tipoPago,
    totalVenta,
    fechaVenta,
    estado,
    fechaAnulacion,
    motivoAnulacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas_pos';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBVentaPos> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_venta')) {
      context.handle(
        _codigoVentaMeta,
        codigoVenta.isAcceptableOrUnknown(
          data['codigo_venta']!,
          _codigoVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codigoVentaMeta);
    }
    if (data.containsKey('ciclo_operativo_id')) {
      context.handle(
        _cicloOperativoIdMeta,
        cicloOperativoId.isAcceptableOrUnknown(
          data['ciclo_operativo_id']!,
          _cicloOperativoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cicloOperativoIdMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('tipo_pago')) {
      context.handle(
        _tipoPagoMeta,
        tipoPago.isAcceptableOrUnknown(data['tipo_pago']!, _tipoPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoPagoMeta);
    }
    if (data.containsKey('total_venta')) {
      context.handle(
        _totalVentaMeta,
        totalVenta.isAcceptableOrUnknown(data['total_venta']!, _totalVentaMeta),
      );
    } else if (isInserting) {
      context.missing(_totalVentaMeta);
    }
    if (data.containsKey('fecha_venta')) {
      context.handle(
        _fechaVentaMeta,
        fechaVenta.isAcceptableOrUnknown(data['fecha_venta']!, _fechaVentaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaVentaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('fecha_anulacion')) {
      context.handle(
        _fechaAnulacionMeta,
        fechaAnulacion.isAcceptableOrUnknown(
          data['fecha_anulacion']!,
          _fechaAnulacionMeta,
        ),
      );
    }
    if (data.containsKey('motivo_anulacion')) {
      context.handle(
        _motivoAnulacionMeta,
        motivoAnulacion.isAcceptableOrUnknown(
          data['motivo_anulacion']!,
          _motivoAnulacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBVentaPos map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBVentaPos(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_venta'],
      )!,
      cicloOperativoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ciclo_operativo_id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      ),
      tipoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_pago'],
      )!,
      totalVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_venta'],
      )!,
      fechaVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_venta'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      fechaAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_anulacion'],
      ),
      motivoAnulacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo_anulacion'],
      ),
    );
  }

  @override
  $VentasPosTable createAlias(String alias) {
    return $VentasPosTable(attachedDatabase, alias);
  }
}

class DBVentaPos extends DataClass implements Insertable<DBVentaPos> {
  final int id;
  final String codigoVenta;
  final int cicloOperativoId;
  final int? clienteId;
  final String tipoPago;
  final double totalVenta;
  final int fechaVenta;
  final String estado;
  final int? fechaAnulacion;
  final String? motivoAnulacion;
  const DBVentaPos({
    required this.id,
    required this.codigoVenta,
    required this.cicloOperativoId,
    this.clienteId,
    required this.tipoPago,
    required this.totalVenta,
    required this.fechaVenta,
    required this.estado,
    this.fechaAnulacion,
    this.motivoAnulacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo_venta'] = Variable<String>(codigoVenta);
    map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    map['tipo_pago'] = Variable<String>(tipoPago);
    map['total_venta'] = Variable<double>(totalVenta);
    map['fecha_venta'] = Variable<int>(fechaVenta);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || fechaAnulacion != null) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion);
    }
    if (!nullToAbsent || motivoAnulacion != null) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion);
    }
    return map;
  }

  VentasPosCompanion toCompanion(bool nullToAbsent) {
    return VentasPosCompanion(
      id: Value(id),
      codigoVenta: Value(codigoVenta),
      cicloOperativoId: Value(cicloOperativoId),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      tipoPago: Value(tipoPago),
      totalVenta: Value(totalVenta),
      fechaVenta: Value(fechaVenta),
      estado: Value(estado),
      fechaAnulacion: fechaAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaAnulacion),
      motivoAnulacion: motivoAnulacion == null && nullToAbsent
          ? const Value.absent()
          : Value(motivoAnulacion),
    );
  }

  factory DBVentaPos.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBVentaPos(
      id: serializer.fromJson<int>(json['id']),
      codigoVenta: serializer.fromJson<String>(json['codigoVenta']),
      cicloOperativoId: serializer.fromJson<int>(json['cicloOperativoId']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      tipoPago: serializer.fromJson<String>(json['tipoPago']),
      totalVenta: serializer.fromJson<double>(json['totalVenta']),
      fechaVenta: serializer.fromJson<int>(json['fechaVenta']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaAnulacion: serializer.fromJson<int?>(json['fechaAnulacion']),
      motivoAnulacion: serializer.fromJson<String?>(json['motivoAnulacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoVenta': serializer.toJson<String>(codigoVenta),
      'cicloOperativoId': serializer.toJson<int>(cicloOperativoId),
      'clienteId': serializer.toJson<int?>(clienteId),
      'tipoPago': serializer.toJson<String>(tipoPago),
      'totalVenta': serializer.toJson<double>(totalVenta),
      'fechaVenta': serializer.toJson<int>(fechaVenta),
      'estado': serializer.toJson<String>(estado),
      'fechaAnulacion': serializer.toJson<int?>(fechaAnulacion),
      'motivoAnulacion': serializer.toJson<String?>(motivoAnulacion),
    };
  }

  DBVentaPos copyWith({
    int? id,
    String? codigoVenta,
    int? cicloOperativoId,
    Value<int?> clienteId = const Value.absent(),
    String? tipoPago,
    double? totalVenta,
    int? fechaVenta,
    String? estado,
    Value<int?> fechaAnulacion = const Value.absent(),
    Value<String?> motivoAnulacion = const Value.absent(),
  }) => DBVentaPos(
    id: id ?? this.id,
    codigoVenta: codigoVenta ?? this.codigoVenta,
    cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    tipoPago: tipoPago ?? this.tipoPago,
    totalVenta: totalVenta ?? this.totalVenta,
    fechaVenta: fechaVenta ?? this.fechaVenta,
    estado: estado ?? this.estado,
    fechaAnulacion: fechaAnulacion.present
        ? fechaAnulacion.value
        : this.fechaAnulacion,
    motivoAnulacion: motivoAnulacion.present
        ? motivoAnulacion.value
        : this.motivoAnulacion,
  );
  DBVentaPos copyWithCompanion(VentasPosCompanion data) {
    return DBVentaPos(
      id: data.id.present ? data.id.value : this.id,
      codigoVenta: data.codigoVenta.present
          ? data.codigoVenta.value
          : this.codigoVenta,
      cicloOperativoId: data.cicloOperativoId.present
          ? data.cicloOperativoId.value
          : this.cicloOperativoId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      tipoPago: data.tipoPago.present ? data.tipoPago.value : this.tipoPago,
      totalVenta: data.totalVenta.present
          ? data.totalVenta.value
          : this.totalVenta,
      fechaVenta: data.fechaVenta.present
          ? data.fechaVenta.value
          : this.fechaVenta,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaAnulacion: data.fechaAnulacion.present
          ? data.fechaAnulacion.value
          : this.fechaAnulacion,
      motivoAnulacion: data.motivoAnulacion.present
          ? data.motivoAnulacion.value
          : this.motivoAnulacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBVentaPos(')
          ..write('id: $id, ')
          ..write('codigoVenta: $codigoVenta, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoPago: $tipoPago, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoVenta,
    cicloOperativoId,
    clienteId,
    tipoPago,
    totalVenta,
    fechaVenta,
    estado,
    fechaAnulacion,
    motivoAnulacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBVentaPos &&
          other.id == this.id &&
          other.codigoVenta == this.codigoVenta &&
          other.cicloOperativoId == this.cicloOperativoId &&
          other.clienteId == this.clienteId &&
          other.tipoPago == this.tipoPago &&
          other.totalVenta == this.totalVenta &&
          other.fechaVenta == this.fechaVenta &&
          other.estado == this.estado &&
          other.fechaAnulacion == this.fechaAnulacion &&
          other.motivoAnulacion == this.motivoAnulacion);
}

class VentasPosCompanion extends UpdateCompanion<DBVentaPos> {
  final Value<int> id;
  final Value<String> codigoVenta;
  final Value<int> cicloOperativoId;
  final Value<int?> clienteId;
  final Value<String> tipoPago;
  final Value<double> totalVenta;
  final Value<int> fechaVenta;
  final Value<String> estado;
  final Value<int?> fechaAnulacion;
  final Value<String?> motivoAnulacion;
  const VentasPosCompanion({
    this.id = const Value.absent(),
    this.codigoVenta = const Value.absent(),
    this.cicloOperativoId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.tipoPago = const Value.absent(),
    this.totalVenta = const Value.absent(),
    this.fechaVenta = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
  });
  VentasPosCompanion.insert({
    this.id = const Value.absent(),
    required String codigoVenta,
    required int cicloOperativoId,
    this.clienteId = const Value.absent(),
    required String tipoPago,
    required double totalVenta,
    required int fechaVenta,
    required String estado,
    this.fechaAnulacion = const Value.absent(),
    this.motivoAnulacion = const Value.absent(),
  }) : codigoVenta = Value(codigoVenta),
       cicloOperativoId = Value(cicloOperativoId),
       tipoPago = Value(tipoPago),
       totalVenta = Value(totalVenta),
       fechaVenta = Value(fechaVenta),
       estado = Value(estado);
  static Insertable<DBVentaPos> custom({
    Expression<int>? id,
    Expression<String>? codigoVenta,
    Expression<int>? cicloOperativoId,
    Expression<int>? clienteId,
    Expression<String>? tipoPago,
    Expression<double>? totalVenta,
    Expression<int>? fechaVenta,
    Expression<String>? estado,
    Expression<int>? fechaAnulacion,
    Expression<String>? motivoAnulacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoVenta != null) 'codigo_venta': codigoVenta,
      if (cicloOperativoId != null) 'ciclo_operativo_id': cicloOperativoId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (tipoPago != null) 'tipo_pago': tipoPago,
      if (totalVenta != null) 'total_venta': totalVenta,
      if (fechaVenta != null) 'fecha_venta': fechaVenta,
      if (estado != null) 'estado': estado,
      if (fechaAnulacion != null) 'fecha_anulacion': fechaAnulacion,
      if (motivoAnulacion != null) 'motivo_anulacion': motivoAnulacion,
    });
  }

  VentasPosCompanion copyWith({
    Value<int>? id,
    Value<String>? codigoVenta,
    Value<int>? cicloOperativoId,
    Value<int?>? clienteId,
    Value<String>? tipoPago,
    Value<double>? totalVenta,
    Value<int>? fechaVenta,
    Value<String>? estado,
    Value<int?>? fechaAnulacion,
    Value<String?>? motivoAnulacion,
  }) {
    return VentasPosCompanion(
      id: id ?? this.id,
      codigoVenta: codigoVenta ?? this.codigoVenta,
      cicloOperativoId: cicloOperativoId ?? this.cicloOperativoId,
      clienteId: clienteId ?? this.clienteId,
      tipoPago: tipoPago ?? this.tipoPago,
      totalVenta: totalVenta ?? this.totalVenta,
      fechaVenta: fechaVenta ?? this.fechaVenta,
      estado: estado ?? this.estado,
      fechaAnulacion: fechaAnulacion ?? this.fechaAnulacion,
      motivoAnulacion: motivoAnulacion ?? this.motivoAnulacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoVenta.present) {
      map['codigo_venta'] = Variable<String>(codigoVenta.value);
    }
    if (cicloOperativoId.present) {
      map['ciclo_operativo_id'] = Variable<int>(cicloOperativoId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (tipoPago.present) {
      map['tipo_pago'] = Variable<String>(tipoPago.value);
    }
    if (totalVenta.present) {
      map['total_venta'] = Variable<double>(totalVenta.value);
    }
    if (fechaVenta.present) {
      map['fecha_venta'] = Variable<int>(fechaVenta.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaAnulacion.present) {
      map['fecha_anulacion'] = Variable<int>(fechaAnulacion.value);
    }
    if (motivoAnulacion.present) {
      map['motivo_anulacion'] = Variable<String>(motivoAnulacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasPosCompanion(')
          ..write('id: $id, ')
          ..write('codigoVenta: $codigoVenta, ')
          ..write('cicloOperativoId: $cicloOperativoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoPago: $tipoPago, ')
          ..write('totalVenta: $totalVenta, ')
          ..write('fechaVenta: $fechaVenta, ')
          ..write('estado: $estado, ')
          ..write('fechaAnulacion: $fechaAnulacion, ')
          ..write('motivoAnulacion: $motivoAnulacion')
          ..write(')'))
        .toString();
  }
}

class $VentasPosDetallesTable extends VentasPosDetalles
    with TableInfo<$VentasPosDetallesTable, DBVentaPosDetalle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasPosDetallesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ventaPosIdMeta = const VerificationMeta(
    'ventaPosId',
  );
  @override
  late final GeneratedColumn<int> ventaPosId = GeneratedColumn<int>(
    'venta_pos_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoPosIdMeta = const VerificationMeta(
    'productoPosId',
  );
  @override
  late final GeneratedColumn<int> productoPosId = GeneratedColumn<int>(
    'producto_pos_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (cantidad > 0)',
  );
  static const VerificationMeta _precioUnitarioHistoricoMeta =
      const VerificationMeta('precioUnitarioHistorico');
  @override
  late final GeneratedColumn<double> precioUnitarioHistorico =
      GeneratedColumn<double>(
        'precio_unitario_historico',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaPosId,
    productoPosId,
    cantidad,
    precioUnitarioHistorico,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas_pos_detalles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBVentaPosDetalle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_pos_id')) {
      context.handle(
        _ventaPosIdMeta,
        ventaPosId.isAcceptableOrUnknown(
          data['venta_pos_id']!,
          _ventaPosIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ventaPosIdMeta);
    }
    if (data.containsKey('producto_pos_id')) {
      context.handle(
        _productoPosIdMeta,
        productoPosId.isAcceptableOrUnknown(
          data['producto_pos_id']!,
          _productoPosIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productoPosIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario_historico')) {
      context.handle(
        _precioUnitarioHistoricoMeta,
        precioUnitarioHistorico.isAcceptableOrUnknown(
          data['precio_unitario_historico']!,
          _precioUnitarioHistoricoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioHistoricoMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBVentaPosDetalle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBVentaPosDetalle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaPosId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_pos_id'],
      )!,
      productoPosId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_pos_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitarioHistorico: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario_historico'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $VentasPosDetallesTable createAlias(String alias) {
    return $VentasPosDetallesTable(attachedDatabase, alias);
  }
}

class DBVentaPosDetalle extends DataClass
    implements Insertable<DBVentaPosDetalle> {
  final int id;
  final int ventaPosId;
  final int productoPosId;
  final double cantidad;
  final double precioUnitarioHistorico;
  final double subtotal;
  const DBVentaPosDetalle({
    required this.id,
    required this.ventaPosId,
    required this.productoPosId,
    required this.cantidad,
    required this.precioUnitarioHistorico,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_pos_id'] = Variable<int>(ventaPosId);
    map['producto_pos_id'] = Variable<int>(productoPosId);
    map['cantidad'] = Variable<double>(cantidad);
    map['precio_unitario_historico'] = Variable<double>(
      precioUnitarioHistorico,
    );
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  VentasPosDetallesCompanion toCompanion(bool nullToAbsent) {
    return VentasPosDetallesCompanion(
      id: Value(id),
      ventaPosId: Value(ventaPosId),
      productoPosId: Value(productoPosId),
      cantidad: Value(cantidad),
      precioUnitarioHistorico: Value(precioUnitarioHistorico),
      subtotal: Value(subtotal),
    );
  }

  factory DBVentaPosDetalle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBVentaPosDetalle(
      id: serializer.fromJson<int>(json['id']),
      ventaPosId: serializer.fromJson<int>(json['ventaPosId']),
      productoPosId: serializer.fromJson<int>(json['productoPosId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      precioUnitarioHistorico: serializer.fromJson<double>(
        json['precioUnitarioHistorico'],
      ),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaPosId': serializer.toJson<int>(ventaPosId),
      'productoPosId': serializer.toJson<int>(productoPosId),
      'cantidad': serializer.toJson<double>(cantidad),
      'precioUnitarioHistorico': serializer.toJson<double>(
        precioUnitarioHistorico,
      ),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  DBVentaPosDetalle copyWith({
    int? id,
    int? ventaPosId,
    int? productoPosId,
    double? cantidad,
    double? precioUnitarioHistorico,
    double? subtotal,
  }) => DBVentaPosDetalle(
    id: id ?? this.id,
    ventaPosId: ventaPosId ?? this.ventaPosId,
    productoPosId: productoPosId ?? this.productoPosId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitarioHistorico:
        precioUnitarioHistorico ?? this.precioUnitarioHistorico,
    subtotal: subtotal ?? this.subtotal,
  );
  DBVentaPosDetalle copyWithCompanion(VentasPosDetallesCompanion data) {
    return DBVentaPosDetalle(
      id: data.id.present ? data.id.value : this.id,
      ventaPosId: data.ventaPosId.present
          ? data.ventaPosId.value
          : this.ventaPosId,
      productoPosId: data.productoPosId.present
          ? data.productoPosId.value
          : this.productoPosId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitarioHistorico: data.precioUnitarioHistorico.present
          ? data.precioUnitarioHistorico.value
          : this.precioUnitarioHistorico,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBVentaPosDetalle(')
          ..write('id: $id, ')
          ..write('ventaPosId: $ventaPosId, ')
          ..write('productoPosId: $productoPosId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitarioHistorico: $precioUnitarioHistorico, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaPosId,
    productoPosId,
    cantidad,
    precioUnitarioHistorico,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBVentaPosDetalle &&
          other.id == this.id &&
          other.ventaPosId == this.ventaPosId &&
          other.productoPosId == this.productoPosId &&
          other.cantidad == this.cantidad &&
          other.precioUnitarioHistorico == this.precioUnitarioHistorico &&
          other.subtotal == this.subtotal);
}

class VentasPosDetallesCompanion extends UpdateCompanion<DBVentaPosDetalle> {
  final Value<int> id;
  final Value<int> ventaPosId;
  final Value<int> productoPosId;
  final Value<double> cantidad;
  final Value<double> precioUnitarioHistorico;
  final Value<double> subtotal;
  const VentasPosDetallesCompanion({
    this.id = const Value.absent(),
    this.ventaPosId = const Value.absent(),
    this.productoPosId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitarioHistorico = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  VentasPosDetallesCompanion.insert({
    this.id = const Value.absent(),
    required int ventaPosId,
    required int productoPosId,
    required double cantidad,
    required double precioUnitarioHistorico,
    required double subtotal,
  }) : ventaPosId = Value(ventaPosId),
       productoPosId = Value(productoPosId),
       cantidad = Value(cantidad),
       precioUnitarioHistorico = Value(precioUnitarioHistorico),
       subtotal = Value(subtotal);
  static Insertable<DBVentaPosDetalle> custom({
    Expression<int>? id,
    Expression<int>? ventaPosId,
    Expression<int>? productoPosId,
    Expression<double>? cantidad,
    Expression<double>? precioUnitarioHistorico,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaPosId != null) 'venta_pos_id': ventaPosId,
      if (productoPosId != null) 'producto_pos_id': productoPosId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitarioHistorico != null)
        'precio_unitario_historico': precioUnitarioHistorico,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  VentasPosDetallesCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaPosId,
    Value<int>? productoPosId,
    Value<double>? cantidad,
    Value<double>? precioUnitarioHistorico,
    Value<double>? subtotal,
  }) {
    return VentasPosDetallesCompanion(
      id: id ?? this.id,
      ventaPosId: ventaPosId ?? this.ventaPosId,
      productoPosId: productoPosId ?? this.productoPosId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitarioHistorico:
          precioUnitarioHistorico ?? this.precioUnitarioHistorico,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaPosId.present) {
      map['venta_pos_id'] = Variable<int>(ventaPosId.value);
    }
    if (productoPosId.present) {
      map['producto_pos_id'] = Variable<int>(productoPosId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (precioUnitarioHistorico.present) {
      map['precio_unitario_historico'] = Variable<double>(
        precioUnitarioHistorico.value,
      );
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasPosDetallesCompanion(')
          ..write('id: $id, ')
          ..write('ventaPosId: $ventaPosId, ')
          ..write('productoPosId: $productoPosId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitarioHistorico: $precioUnitarioHistorico, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $LotesSecadoTable extends LotesSecado
    with TableInfo<$LotesSecadoTable, DBLoteSecado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesSecadoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoCafeInicialMeta = const VerificationMeta(
    'tipoCafeInicial',
  );
  @override
  late final GeneratedColumn<String> tipoCafeInicial = GeneratedColumn<String>(
    'tipo_cafe_inicial',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo_cafe_inicial IN (\'MOJADO\',\'OREADO\',\'SECO\',\'PASILLA\'))',
  );
  static const VerificationMeta _pesoInicialHumedoMeta = const VerificationMeta(
    'pesoInicialHumedo',
  );
  @override
  late final GeneratedColumn<double> pesoInicialHumedo =
      GeneratedColumn<double>(
        'peso_inicial_humedo',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL CHECK (peso_inicial_humedo > 0)',
      );
  static const VerificationMeta _precioEstimadoInicialMeta =
      const VerificationMeta('precioEstimadoInicial');
  @override
  late final GeneratedColumn<double> precioEstimadoInicial =
      GeneratedColumn<double>(
        'precio_estimado_inicial',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL CHECK (precio_estimado_inicial >= 0)',
      );
  static const VerificationMeta _fechaInicioMeta = const VerificationMeta(
    'fechaInicio',
  );
  @override
  late final GeneratedColumn<int> fechaInicio = GeneratedColumn<int>(
    'fecha_inicio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaFinalizacionMeta = const VerificationMeta(
    'fechaFinalizacion',
  );
  @override
  late final GeneratedColumn<int> fechaFinalizacion = GeneratedColumn<int>(
    'fecha_finalizacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pesoSecoObtenidoMeta = const VerificationMeta(
    'pesoSecoObtenido',
  );
  @override
  late final GeneratedColumn<double> pesoSecoObtenido = GeneratedColumn<double>(
    'peso_seco_obtenido',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mermaCalculadaMeta = const VerificationMeta(
    'mermaCalculada',
  );
  @override
  late final GeneratedColumn<double> mermaCalculada = GeneratedColumn<double>(
    'merma_calculada',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _porcentajeRendimientoMeta =
      const VerificationMeta('porcentajeRendimiento');
  @override
  late final GeneratedColumn<double> porcentajeRendimiento =
      GeneratedColumn<double>(
        'porcentaje_rendimiento',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (estado IN (\'SECANDO\',\'FINALIZADO\'))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    tipoCafeInicial,
    pesoInicialHumedo,
    precioEstimadoInicial,
    fechaInicio,
    fechaFinalizacion,
    pesoSecoObtenido,
    mermaCalculada,
    porcentajeRendimiento,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes_secado';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBLoteSecado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    }
    if (data.containsKey('tipo_cafe_inicial')) {
      context.handle(
        _tipoCafeInicialMeta,
        tipoCafeInicial.isAcceptableOrUnknown(
          data['tipo_cafe_inicial']!,
          _tipoCafeInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoCafeInicialMeta);
    }
    if (data.containsKey('peso_inicial_humedo')) {
      context.handle(
        _pesoInicialHumedoMeta,
        pesoInicialHumedo.isAcceptableOrUnknown(
          data['peso_inicial_humedo']!,
          _pesoInicialHumedoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pesoInicialHumedoMeta);
    }
    if (data.containsKey('precio_estimado_inicial')) {
      context.handle(
        _precioEstimadoInicialMeta,
        precioEstimadoInicial.isAcceptableOrUnknown(
          data['precio_estimado_inicial']!,
          _precioEstimadoInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioEstimadoInicialMeta);
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
        _fechaInicioMeta,
        fechaInicio.isAcceptableOrUnknown(
          data['fecha_inicio']!,
          _fechaInicioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaInicioMeta);
    }
    if (data.containsKey('fecha_finalizacion')) {
      context.handle(
        _fechaFinalizacionMeta,
        fechaFinalizacion.isAcceptableOrUnknown(
          data['fecha_finalizacion']!,
          _fechaFinalizacionMeta,
        ),
      );
    }
    if (data.containsKey('peso_seco_obtenido')) {
      context.handle(
        _pesoSecoObtenidoMeta,
        pesoSecoObtenido.isAcceptableOrUnknown(
          data['peso_seco_obtenido']!,
          _pesoSecoObtenidoMeta,
        ),
      );
    }
    if (data.containsKey('merma_calculada')) {
      context.handle(
        _mermaCalculadaMeta,
        mermaCalculada.isAcceptableOrUnknown(
          data['merma_calculada']!,
          _mermaCalculadaMeta,
        ),
      );
    }
    if (data.containsKey('porcentaje_rendimiento')) {
      context.handle(
        _porcentajeRendimientoMeta,
        porcentajeRendimiento.isAcceptableOrUnknown(
          data['porcentaje_rendimiento']!,
          _porcentajeRendimientoMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBLoteSecado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBLoteSecado(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      ),
      tipoCafeInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cafe_inicial'],
      )!,
      pesoInicialHumedo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_inicial_humedo'],
      )!,
      precioEstimadoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_estimado_inicial'],
      )!,
      fechaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_inicio'],
      )!,
      fechaFinalizacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_finalizacion'],
      ),
      pesoSecoObtenido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_seco_obtenido'],
      ),
      mermaCalculada: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}merma_calculada'],
      ),
      porcentajeRendimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}porcentaje_rendimiento'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $LotesSecadoTable createAlias(String alias) {
    return $LotesSecadoTable(attachedDatabase, alias);
  }
}

class DBLoteSecado extends DataClass implements Insertable<DBLoteSecado> {
  final int id;
  final int? clienteId;
  final String tipoCafeInicial;
  final double pesoInicialHumedo;
  final double precioEstimadoInicial;
  final int fechaInicio;
  final int? fechaFinalizacion;
  final double? pesoSecoObtenido;
  final double? mermaCalculada;
  final double? porcentajeRendimiento;
  final String estado;
  const DBLoteSecado({
    required this.id,
    this.clienteId,
    required this.tipoCafeInicial,
    required this.pesoInicialHumedo,
    required this.precioEstimadoInicial,
    required this.fechaInicio,
    this.fechaFinalizacion,
    this.pesoSecoObtenido,
    this.mermaCalculada,
    this.porcentajeRendimiento,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || clienteId != null) {
      map['cliente_id'] = Variable<int>(clienteId);
    }
    map['tipo_cafe_inicial'] = Variable<String>(tipoCafeInicial);
    map['peso_inicial_humedo'] = Variable<double>(pesoInicialHumedo);
    map['precio_estimado_inicial'] = Variable<double>(precioEstimadoInicial);
    map['fecha_inicio'] = Variable<int>(fechaInicio);
    if (!nullToAbsent || fechaFinalizacion != null) {
      map['fecha_finalizacion'] = Variable<int>(fechaFinalizacion);
    }
    if (!nullToAbsent || pesoSecoObtenido != null) {
      map['peso_seco_obtenido'] = Variable<double>(pesoSecoObtenido);
    }
    if (!nullToAbsent || mermaCalculada != null) {
      map['merma_calculada'] = Variable<double>(mermaCalculada);
    }
    if (!nullToAbsent || porcentajeRendimiento != null) {
      map['porcentaje_rendimiento'] = Variable<double>(porcentajeRendimiento);
    }
    map['estado'] = Variable<String>(estado);
    return map;
  }

  LotesSecadoCompanion toCompanion(bool nullToAbsent) {
    return LotesSecadoCompanion(
      id: Value(id),
      clienteId: clienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(clienteId),
      tipoCafeInicial: Value(tipoCafeInicial),
      pesoInicialHumedo: Value(pesoInicialHumedo),
      precioEstimadoInicial: Value(precioEstimadoInicial),
      fechaInicio: Value(fechaInicio),
      fechaFinalizacion: fechaFinalizacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaFinalizacion),
      pesoSecoObtenido: pesoSecoObtenido == null && nullToAbsent
          ? const Value.absent()
          : Value(pesoSecoObtenido),
      mermaCalculada: mermaCalculada == null && nullToAbsent
          ? const Value.absent()
          : Value(mermaCalculada),
      porcentajeRendimiento: porcentajeRendimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(porcentajeRendimiento),
      estado: Value(estado),
    );
  }

  factory DBLoteSecado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBLoteSecado(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int?>(json['clienteId']),
      tipoCafeInicial: serializer.fromJson<String>(json['tipoCafeInicial']),
      pesoInicialHumedo: serializer.fromJson<double>(json['pesoInicialHumedo']),
      precioEstimadoInicial: serializer.fromJson<double>(
        json['precioEstimadoInicial'],
      ),
      fechaInicio: serializer.fromJson<int>(json['fechaInicio']),
      fechaFinalizacion: serializer.fromJson<int?>(json['fechaFinalizacion']),
      pesoSecoObtenido: serializer.fromJson<double?>(json['pesoSecoObtenido']),
      mermaCalculada: serializer.fromJson<double?>(json['mermaCalculada']),
      porcentajeRendimiento: serializer.fromJson<double?>(
        json['porcentajeRendimiento'],
      ),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int?>(clienteId),
      'tipoCafeInicial': serializer.toJson<String>(tipoCafeInicial),
      'pesoInicialHumedo': serializer.toJson<double>(pesoInicialHumedo),
      'precioEstimadoInicial': serializer.toJson<double>(precioEstimadoInicial),
      'fechaInicio': serializer.toJson<int>(fechaInicio),
      'fechaFinalizacion': serializer.toJson<int?>(fechaFinalizacion),
      'pesoSecoObtenido': serializer.toJson<double?>(pesoSecoObtenido),
      'mermaCalculada': serializer.toJson<double?>(mermaCalculada),
      'porcentajeRendimiento': serializer.toJson<double?>(
        porcentajeRendimiento,
      ),
      'estado': serializer.toJson<String>(estado),
    };
  }

  DBLoteSecado copyWith({
    int? id,
    Value<int?> clienteId = const Value.absent(),
    String? tipoCafeInicial,
    double? pesoInicialHumedo,
    double? precioEstimadoInicial,
    int? fechaInicio,
    Value<int?> fechaFinalizacion = const Value.absent(),
    Value<double?> pesoSecoObtenido = const Value.absent(),
    Value<double?> mermaCalculada = const Value.absent(),
    Value<double?> porcentajeRendimiento = const Value.absent(),
    String? estado,
  }) => DBLoteSecado(
    id: id ?? this.id,
    clienteId: clienteId.present ? clienteId.value : this.clienteId,
    tipoCafeInicial: tipoCafeInicial ?? this.tipoCafeInicial,
    pesoInicialHumedo: pesoInicialHumedo ?? this.pesoInicialHumedo,
    precioEstimadoInicial: precioEstimadoInicial ?? this.precioEstimadoInicial,
    fechaInicio: fechaInicio ?? this.fechaInicio,
    fechaFinalizacion: fechaFinalizacion.present
        ? fechaFinalizacion.value
        : this.fechaFinalizacion,
    pesoSecoObtenido: pesoSecoObtenido.present
        ? pesoSecoObtenido.value
        : this.pesoSecoObtenido,
    mermaCalculada: mermaCalculada.present
        ? mermaCalculada.value
        : this.mermaCalculada,
    porcentajeRendimiento: porcentajeRendimiento.present
        ? porcentajeRendimiento.value
        : this.porcentajeRendimiento,
    estado: estado ?? this.estado,
  );
  DBLoteSecado copyWithCompanion(LotesSecadoCompanion data) {
    return DBLoteSecado(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      tipoCafeInicial: data.tipoCafeInicial.present
          ? data.tipoCafeInicial.value
          : this.tipoCafeInicial,
      pesoInicialHumedo: data.pesoInicialHumedo.present
          ? data.pesoInicialHumedo.value
          : this.pesoInicialHumedo,
      precioEstimadoInicial: data.precioEstimadoInicial.present
          ? data.precioEstimadoInicial.value
          : this.precioEstimadoInicial,
      fechaInicio: data.fechaInicio.present
          ? data.fechaInicio.value
          : this.fechaInicio,
      fechaFinalizacion: data.fechaFinalizacion.present
          ? data.fechaFinalizacion.value
          : this.fechaFinalizacion,
      pesoSecoObtenido: data.pesoSecoObtenido.present
          ? data.pesoSecoObtenido.value
          : this.pesoSecoObtenido,
      mermaCalculada: data.mermaCalculada.present
          ? data.mermaCalculada.value
          : this.mermaCalculada,
      porcentajeRendimiento: data.porcentajeRendimiento.present
          ? data.porcentajeRendimiento.value
          : this.porcentajeRendimiento,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBLoteSecado(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoCafeInicial: $tipoCafeInicial, ')
          ..write('pesoInicialHumedo: $pesoInicialHumedo, ')
          ..write('precioEstimadoInicial: $precioEstimadoInicial, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFinalizacion: $fechaFinalizacion, ')
          ..write('pesoSecoObtenido: $pesoSecoObtenido, ')
          ..write('mermaCalculada: $mermaCalculada, ')
          ..write('porcentajeRendimiento: $porcentajeRendimiento, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    tipoCafeInicial,
    pesoInicialHumedo,
    precioEstimadoInicial,
    fechaInicio,
    fechaFinalizacion,
    pesoSecoObtenido,
    mermaCalculada,
    porcentajeRendimiento,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBLoteSecado &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.tipoCafeInicial == this.tipoCafeInicial &&
          other.pesoInicialHumedo == this.pesoInicialHumedo &&
          other.precioEstimadoInicial == this.precioEstimadoInicial &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaFinalizacion == this.fechaFinalizacion &&
          other.pesoSecoObtenido == this.pesoSecoObtenido &&
          other.mermaCalculada == this.mermaCalculada &&
          other.porcentajeRendimiento == this.porcentajeRendimiento &&
          other.estado == this.estado);
}

class LotesSecadoCompanion extends UpdateCompanion<DBLoteSecado> {
  final Value<int> id;
  final Value<int?> clienteId;
  final Value<String> tipoCafeInicial;
  final Value<double> pesoInicialHumedo;
  final Value<double> precioEstimadoInicial;
  final Value<int> fechaInicio;
  final Value<int?> fechaFinalizacion;
  final Value<double?> pesoSecoObtenido;
  final Value<double?> mermaCalculada;
  final Value<double?> porcentajeRendimiento;
  final Value<String> estado;
  const LotesSecadoCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.tipoCafeInicial = const Value.absent(),
    this.pesoInicialHumedo = const Value.absent(),
    this.precioEstimadoInicial = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFinalizacion = const Value.absent(),
    this.pesoSecoObtenido = const Value.absent(),
    this.mermaCalculada = const Value.absent(),
    this.porcentajeRendimiento = const Value.absent(),
    this.estado = const Value.absent(),
  });
  LotesSecadoCompanion.insert({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    required String tipoCafeInicial,
    required double pesoInicialHumedo,
    required double precioEstimadoInicial,
    required int fechaInicio,
    this.fechaFinalizacion = const Value.absent(),
    this.pesoSecoObtenido = const Value.absent(),
    this.mermaCalculada = const Value.absent(),
    this.porcentajeRendimiento = const Value.absent(),
    required String estado,
  }) : tipoCafeInicial = Value(tipoCafeInicial),
       pesoInicialHumedo = Value(pesoInicialHumedo),
       precioEstimadoInicial = Value(precioEstimadoInicial),
       fechaInicio = Value(fechaInicio),
       estado = Value(estado);
  static Insertable<DBLoteSecado> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? tipoCafeInicial,
    Expression<double>? pesoInicialHumedo,
    Expression<double>? precioEstimadoInicial,
    Expression<int>? fechaInicio,
    Expression<int>? fechaFinalizacion,
    Expression<double>? pesoSecoObtenido,
    Expression<double>? mermaCalculada,
    Expression<double>? porcentajeRendimiento,
    Expression<String>? estado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (tipoCafeInicial != null) 'tipo_cafe_inicial': tipoCafeInicial,
      if (pesoInicialHumedo != null) 'peso_inicial_humedo': pesoInicialHumedo,
      if (precioEstimadoInicial != null)
        'precio_estimado_inicial': precioEstimadoInicial,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFinalizacion != null) 'fecha_finalizacion': fechaFinalizacion,
      if (pesoSecoObtenido != null) 'peso_seco_obtenido': pesoSecoObtenido,
      if (mermaCalculada != null) 'merma_calculada': mermaCalculada,
      if (porcentajeRendimiento != null)
        'porcentaje_rendimiento': porcentajeRendimiento,
      if (estado != null) 'estado': estado,
    });
  }

  LotesSecadoCompanion copyWith({
    Value<int>? id,
    Value<int?>? clienteId,
    Value<String>? tipoCafeInicial,
    Value<double>? pesoInicialHumedo,
    Value<double>? precioEstimadoInicial,
    Value<int>? fechaInicio,
    Value<int?>? fechaFinalizacion,
    Value<double?>? pesoSecoObtenido,
    Value<double?>? mermaCalculada,
    Value<double?>? porcentajeRendimiento,
    Value<String>? estado,
  }) {
    return LotesSecadoCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      tipoCafeInicial: tipoCafeInicial ?? this.tipoCafeInicial,
      pesoInicialHumedo: pesoInicialHumedo ?? this.pesoInicialHumedo,
      precioEstimadoInicial:
          precioEstimadoInicial ?? this.precioEstimadoInicial,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFinalizacion: fechaFinalizacion ?? this.fechaFinalizacion,
      pesoSecoObtenido: pesoSecoObtenido ?? this.pesoSecoObtenido,
      mermaCalculada: mermaCalculada ?? this.mermaCalculada,
      porcentajeRendimiento:
          porcentajeRendimiento ?? this.porcentajeRendimiento,
      estado: estado ?? this.estado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (tipoCafeInicial.present) {
      map['tipo_cafe_inicial'] = Variable<String>(tipoCafeInicial.value);
    }
    if (pesoInicialHumedo.present) {
      map['peso_inicial_humedo'] = Variable<double>(pesoInicialHumedo.value);
    }
    if (precioEstimadoInicial.present) {
      map['precio_estimado_inicial'] = Variable<double>(
        precioEstimadoInicial.value,
      );
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<int>(fechaInicio.value);
    }
    if (fechaFinalizacion.present) {
      map['fecha_finalizacion'] = Variable<int>(fechaFinalizacion.value);
    }
    if (pesoSecoObtenido.present) {
      map['peso_seco_obtenido'] = Variable<double>(pesoSecoObtenido.value);
    }
    if (mermaCalculada.present) {
      map['merma_calculada'] = Variable<double>(mermaCalculada.value);
    }
    if (porcentajeRendimiento.present) {
      map['porcentaje_rendimiento'] = Variable<double>(
        porcentajeRendimiento.value,
      );
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesSecadoCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('tipoCafeInicial: $tipoCafeInicial, ')
          ..write('pesoInicialHumedo: $pesoInicialHumedo, ')
          ..write('precioEstimadoInicial: $precioEstimadoInicial, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFinalizacion: $fechaFinalizacion, ')
          ..write('pesoSecoObtenido: $pesoSecoObtenido, ')
          ..write('mermaCalculada: $mermaCalculada, ')
          ..write('porcentajeRendimiento: $porcentajeRendimiento, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, DBAuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usuarioMeta = const VerificationMeta(
    'usuario',
  );
  @override
  late final GeneratedColumn<String> usuario = GeneratedColumn<String>(
    'usuario',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detalleMeta = const VerificationMeta(
    'detalle',
  );
  @override
  late final GeneratedColumn<String> detalle = GeneratedColumn<String>(
    'detalle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaEventoMeta = const VerificationMeta(
    'fechaEvento',
  );
  @override
  late final GeneratedColumn<int> fechaEvento = GeneratedColumn<int>(
    'fecha_evento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    usuario,
    accion,
    detalle,
    fechaEvento,
    origen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBAuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('usuario')) {
      context.handle(
        _usuarioMeta,
        usuario.isAcceptableOrUnknown(data['usuario']!, _usuarioMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('detalle')) {
      context.handle(
        _detalleMeta,
        detalle.isAcceptableOrUnknown(data['detalle']!, _detalleMeta),
      );
    } else if (isInserting) {
      context.missing(_detalleMeta);
    }
    if (data.containsKey('fecha_evento')) {
      context.handle(
        _fechaEventoMeta,
        fechaEvento.isAcceptableOrUnknown(
          data['fecha_evento']!,
          _fechaEventoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaEventoMeta);
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBAuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBAuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      usuario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario'],
      )!,
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      detalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle'],
      )!,
      fechaEvento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_evento'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class DBAuditLog extends DataClass implements Insertable<DBAuditLog> {
  final int id;
  final String usuario;
  final String accion;
  final String detalle;
  final int fechaEvento;
  final String origen;
  const DBAuditLog({
    required this.id,
    required this.usuario,
    required this.accion,
    required this.detalle,
    required this.fechaEvento,
    required this.origen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['usuario'] = Variable<String>(usuario);
    map['accion'] = Variable<String>(accion);
    map['detalle'] = Variable<String>(detalle);
    map['fecha_evento'] = Variable<int>(fechaEvento);
    map['origen'] = Variable<String>(origen);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      usuario: Value(usuario),
      accion: Value(accion),
      detalle: Value(detalle),
      fechaEvento: Value(fechaEvento),
      origen: Value(origen),
    );
  }

  factory DBAuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBAuditLog(
      id: serializer.fromJson<int>(json['id']),
      usuario: serializer.fromJson<String>(json['usuario']),
      accion: serializer.fromJson<String>(json['accion']),
      detalle: serializer.fromJson<String>(json['detalle']),
      fechaEvento: serializer.fromJson<int>(json['fechaEvento']),
      origen: serializer.fromJson<String>(json['origen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'usuario': serializer.toJson<String>(usuario),
      'accion': serializer.toJson<String>(accion),
      'detalle': serializer.toJson<String>(detalle),
      'fechaEvento': serializer.toJson<int>(fechaEvento),
      'origen': serializer.toJson<String>(origen),
    };
  }

  DBAuditLog copyWith({
    int? id,
    String? usuario,
    String? accion,
    String? detalle,
    int? fechaEvento,
    String? origen,
  }) => DBAuditLog(
    id: id ?? this.id,
    usuario: usuario ?? this.usuario,
    accion: accion ?? this.accion,
    detalle: detalle ?? this.detalle,
    fechaEvento: fechaEvento ?? this.fechaEvento,
    origen: origen ?? this.origen,
  );
  DBAuditLog copyWithCompanion(AuditLogsCompanion data) {
    return DBAuditLog(
      id: data.id.present ? data.id.value : this.id,
      usuario: data.usuario.present ? data.usuario.value : this.usuario,
      accion: data.accion.present ? data.accion.value : this.accion,
      detalle: data.detalle.present ? data.detalle.value : this.detalle,
      fechaEvento: data.fechaEvento.present
          ? data.fechaEvento.value
          : this.fechaEvento,
      origen: data.origen.present ? data.origen.value : this.origen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBAuditLog(')
          ..write('id: $id, ')
          ..write('usuario: $usuario, ')
          ..write('accion: $accion, ')
          ..write('detalle: $detalle, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('origen: $origen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, usuario, accion, detalle, fechaEvento, origen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBAuditLog &&
          other.id == this.id &&
          other.usuario == this.usuario &&
          other.accion == this.accion &&
          other.detalle == this.detalle &&
          other.fechaEvento == this.fechaEvento &&
          other.origen == this.origen);
}

class AuditLogsCompanion extends UpdateCompanion<DBAuditLog> {
  final Value<int> id;
  final Value<String> usuario;
  final Value<String> accion;
  final Value<String> detalle;
  final Value<int> fechaEvento;
  final Value<String> origen;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.usuario = const Value.absent(),
    this.accion = const Value.absent(),
    this.detalle = const Value.absent(),
    this.fechaEvento = const Value.absent(),
    this.origen = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    required String usuario,
    required String accion,
    required String detalle,
    required int fechaEvento,
    required String origen,
  }) : usuario = Value(usuario),
       accion = Value(accion),
       detalle = Value(detalle),
       fechaEvento = Value(fechaEvento),
       origen = Value(origen);
  static Insertable<DBAuditLog> custom({
    Expression<int>? id,
    Expression<String>? usuario,
    Expression<String>? accion,
    Expression<String>? detalle,
    Expression<int>? fechaEvento,
    Expression<String>? origen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (usuario != null) 'usuario': usuario,
      if (accion != null) 'accion': accion,
      if (detalle != null) 'detalle': detalle,
      if (fechaEvento != null) 'fecha_evento': fechaEvento,
      if (origen != null) 'origen': origen,
    });
  }

  AuditLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? usuario,
    Value<String>? accion,
    Value<String>? detalle,
    Value<int>? fechaEvento,
    Value<String>? origen,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      accion: accion ?? this.accion,
      detalle: detalle ?? this.detalle,
      fechaEvento: fechaEvento ?? this.fechaEvento,
      origen: origen ?? this.origen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (usuario.present) {
      map['usuario'] = Variable<String>(usuario.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (detalle.present) {
      map['detalle'] = Variable<String>(detalle.value);
    }
    if (fechaEvento.present) {
      map['fecha_evento'] = Variable<int>(fechaEvento.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('usuario: $usuario, ')
          ..write('accion: $accion, ')
          ..write('detalle: $detalle, ')
          ..write('fechaEvento: $fechaEvento, ')
          ..write('origen: $origen')
          ..write(')'))
        .toString();
  }
}

class $LicenciaTable extends Licencia
    with TableInfo<$LicenciaTable, DBLicencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenciaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dispositivoIdMeta = const VerificationMeta(
    'dispositivoId',
  );
  @override
  late final GeneratedColumn<String> dispositivoId = GeneratedColumn<String>(
    'dispositivo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaVencimientoMeta = const VerificationMeta(
    'fechaVencimiento',
  );
  @override
  late final GeneratedColumn<int> fechaVencimiento = GeneratedColumn<int>(
    'fecha_vencimiento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planActualMeta = const VerificationMeta(
    'planActual',
  );
  @override
  late final GeneratedColumn<String> planActual = GeneratedColumn<String>(
    'plan_actual',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dispositivoId,
    fechaVencimiento,
    planActual,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'licencia';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBLicencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dispositivo_id')) {
      context.handle(
        _dispositivoIdMeta,
        dispositivoId.isAcceptableOrUnknown(
          data['dispositivo_id']!,
          _dispositivoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dispositivoIdMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
        _fechaVencimientoMeta,
        fechaVencimiento.isAcceptableOrUnknown(
          data['fecha_vencimiento']!,
          _fechaVencimientoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('plan_actual')) {
      context.handle(
        _planActualMeta,
        planActual.isAcceptableOrUnknown(data['plan_actual']!, _planActualMeta),
      );
    } else if (isInserting) {
      context.missing(_planActualMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DBLicencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBLicencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dispositivoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dispositivo_id'],
      )!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_vencimiento'],
      )!,
      planActual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_actual'],
      )!,
    );
  }

  @override
  $LicenciaTable createAlias(String alias) {
    return $LicenciaTable(attachedDatabase, alias);
  }
}

class DBLicencia extends DataClass implements Insertable<DBLicencia> {
  final int id;
  final String dispositivoId;
  final int fechaVencimiento;
  final String planActual;
  const DBLicencia({
    required this.id,
    required this.dispositivoId,
    required this.fechaVencimiento,
    required this.planActual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dispositivo_id'] = Variable<String>(dispositivoId);
    map['fecha_vencimiento'] = Variable<int>(fechaVencimiento);
    map['plan_actual'] = Variable<String>(planActual);
    return map;
  }

  LicenciaCompanion toCompanion(bool nullToAbsent) {
    return LicenciaCompanion(
      id: Value(id),
      dispositivoId: Value(dispositivoId),
      fechaVencimiento: Value(fechaVencimiento),
      planActual: Value(planActual),
    );
  }

  factory DBLicencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBLicencia(
      id: serializer.fromJson<int>(json['id']),
      dispositivoId: serializer.fromJson<String>(json['dispositivoId']),
      fechaVencimiento: serializer.fromJson<int>(json['fechaVencimiento']),
      planActual: serializer.fromJson<String>(json['planActual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dispositivoId': serializer.toJson<String>(dispositivoId),
      'fechaVencimiento': serializer.toJson<int>(fechaVencimiento),
      'planActual': serializer.toJson<String>(planActual),
    };
  }

  DBLicencia copyWith({
    int? id,
    String? dispositivoId,
    int? fechaVencimiento,
    String? planActual,
  }) => DBLicencia(
    id: id ?? this.id,
    dispositivoId: dispositivoId ?? this.dispositivoId,
    fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
    planActual: planActual ?? this.planActual,
  );
  DBLicencia copyWithCompanion(LicenciaCompanion data) {
    return DBLicencia(
      id: data.id.present ? data.id.value : this.id,
      dispositivoId: data.dispositivoId.present
          ? data.dispositivoId.value
          : this.dispositivoId,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      planActual: data.planActual.present
          ? data.planActual.value
          : this.planActual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBLicencia(')
          ..write('id: $id, ')
          ..write('dispositivoId: $dispositivoId, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('planActual: $planActual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dispositivoId, fechaVencimiento, planActual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBLicencia &&
          other.id == this.id &&
          other.dispositivoId == this.dispositivoId &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.planActual == this.planActual);
}

class LicenciaCompanion extends UpdateCompanion<DBLicencia> {
  final Value<int> id;
  final Value<String> dispositivoId;
  final Value<int> fechaVencimiento;
  final Value<String> planActual;
  final Value<int> rowid;
  const LicenciaCompanion({
    this.id = const Value.absent(),
    this.dispositivoId = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.planActual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicenciaCompanion.insert({
    required int id,
    required String dispositivoId,
    required int fechaVencimiento,
    required String planActual,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dispositivoId = Value(dispositivoId),
       fechaVencimiento = Value(fechaVencimiento),
       planActual = Value(planActual);
  static Insertable<DBLicencia> custom({
    Expression<int>? id,
    Expression<String>? dispositivoId,
    Expression<int>? fechaVencimiento,
    Expression<String>? planActual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dispositivoId != null) 'dispositivo_id': dispositivoId,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (planActual != null) 'plan_actual': planActual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicenciaCompanion copyWith({
    Value<int>? id,
    Value<String>? dispositivoId,
    Value<int>? fechaVencimiento,
    Value<String>? planActual,
    Value<int>? rowid,
  }) {
    return LicenciaCompanion(
      id: id ?? this.id,
      dispositivoId: dispositivoId ?? this.dispositivoId,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      planActual: planActual ?? this.planActual,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dispositivoId.present) {
      map['dispositivo_id'] = Variable<String>(dispositivoId.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<int>(fechaVencimiento.value);
    }
    if (planActual.present) {
      map['plan_actual'] = Variable<String>(planActual.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenciaCompanion(')
          ..write('id: $id, ')
          ..write('dispositivoId: $dispositivoId, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('planActual: $planActual, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PinesCanjeadosTable extends PinesCanjeados
    with TableInfo<$PinesCanjeadosTable, DBPinCanjeado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinesCanjeadosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pinMeta = const VerificationMeta('pin');
  @override
  late final GeneratedColumn<String> pin = GeneratedColumn<String>(
    'pin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diasMeta = const VerificationMeta('dias');
  @override
  late final GeneratedColumn<int> dias = GeneratedColumn<int>(
    'dias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCanjeMeta = const VerificationMeta(
    'fechaCanje',
  );
  @override
  late final GeneratedColumn<int> fechaCanje = GeneratedColumn<int>(
    'fecha_canje',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pin, tipo, dias, fechaCanje];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pines_canjeados';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBPinCanjeado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin')) {
      context.handle(
        _pinMeta,
        pin.isAcceptableOrUnknown(data['pin']!, _pinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('dias')) {
      context.handle(
        _diasMeta,
        dias.isAcceptableOrUnknown(data['dias']!, _diasMeta),
      );
    } else if (isInserting) {
      context.missing(_diasMeta);
    }
    if (data.containsKey('fecha_canje')) {
      context.handle(
        _fechaCanjeMeta,
        fechaCanje.isAcceptableOrUnknown(data['fecha_canje']!, _fechaCanjeMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaCanjeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBPinCanjeado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBPinCanjeado(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      dias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dias'],
      )!,
      fechaCanje: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fecha_canje'],
      )!,
    );
  }

  @override
  $PinesCanjeadosTable createAlias(String alias) {
    return $PinesCanjeadosTable(attachedDatabase, alias);
  }
}

class DBPinCanjeado extends DataClass implements Insertable<DBPinCanjeado> {
  final int id;
  final String pin;
  final String tipo;
  final int dias;
  final int fechaCanje;
  const DBPinCanjeado({
    required this.id,
    required this.pin,
    required this.tipo,
    required this.dias,
    required this.fechaCanje,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pin'] = Variable<String>(pin);
    map['tipo'] = Variable<String>(tipo);
    map['dias'] = Variable<int>(dias);
    map['fecha_canje'] = Variable<int>(fechaCanje);
    return map;
  }

  PinesCanjeadosCompanion toCompanion(bool nullToAbsent) {
    return PinesCanjeadosCompanion(
      id: Value(id),
      pin: Value(pin),
      tipo: Value(tipo),
      dias: Value(dias),
      fechaCanje: Value(fechaCanje),
    );
  }

  factory DBPinCanjeado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBPinCanjeado(
      id: serializer.fromJson<int>(json['id']),
      pin: serializer.fromJson<String>(json['pin']),
      tipo: serializer.fromJson<String>(json['tipo']),
      dias: serializer.fromJson<int>(json['dias']),
      fechaCanje: serializer.fromJson<int>(json['fechaCanje']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pin': serializer.toJson<String>(pin),
      'tipo': serializer.toJson<String>(tipo),
      'dias': serializer.toJson<int>(dias),
      'fechaCanje': serializer.toJson<int>(fechaCanje),
    };
  }

  DBPinCanjeado copyWith({
    int? id,
    String? pin,
    String? tipo,
    int? dias,
    int? fechaCanje,
  }) => DBPinCanjeado(
    id: id ?? this.id,
    pin: pin ?? this.pin,
    tipo: tipo ?? this.tipo,
    dias: dias ?? this.dias,
    fechaCanje: fechaCanje ?? this.fechaCanje,
  );
  DBPinCanjeado copyWithCompanion(PinesCanjeadosCompanion data) {
    return DBPinCanjeado(
      id: data.id.present ? data.id.value : this.id,
      pin: data.pin.present ? data.pin.value : this.pin,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      dias: data.dias.present ? data.dias.value : this.dias,
      fechaCanje: data.fechaCanje.present
          ? data.fechaCanje.value
          : this.fechaCanje,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBPinCanjeado(')
          ..write('id: $id, ')
          ..write('pin: $pin, ')
          ..write('tipo: $tipo, ')
          ..write('dias: $dias, ')
          ..write('fechaCanje: $fechaCanje')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pin, tipo, dias, fechaCanje);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBPinCanjeado &&
          other.id == this.id &&
          other.pin == this.pin &&
          other.tipo == this.tipo &&
          other.dias == this.dias &&
          other.fechaCanje == this.fechaCanje);
}

class PinesCanjeadosCompanion extends UpdateCompanion<DBPinCanjeado> {
  final Value<int> id;
  final Value<String> pin;
  final Value<String> tipo;
  final Value<int> dias;
  final Value<int> fechaCanje;
  const PinesCanjeadosCompanion({
    this.id = const Value.absent(),
    this.pin = const Value.absent(),
    this.tipo = const Value.absent(),
    this.dias = const Value.absent(),
    this.fechaCanje = const Value.absent(),
  });
  PinesCanjeadosCompanion.insert({
    this.id = const Value.absent(),
    required String pin,
    required String tipo,
    required int dias,
    required int fechaCanje,
  }) : pin = Value(pin),
       tipo = Value(tipo),
       dias = Value(dias),
       fechaCanje = Value(fechaCanje);
  static Insertable<DBPinCanjeado> custom({
    Expression<int>? id,
    Expression<String>? pin,
    Expression<String>? tipo,
    Expression<int>? dias,
    Expression<int>? fechaCanje,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pin != null) 'pin': pin,
      if (tipo != null) 'tipo': tipo,
      if (dias != null) 'dias': dias,
      if (fechaCanje != null) 'fecha_canje': fechaCanje,
    });
  }

  PinesCanjeadosCompanion copyWith({
    Value<int>? id,
    Value<String>? pin,
    Value<String>? tipo,
    Value<int>? dias,
    Value<int>? fechaCanje,
  }) {
    return PinesCanjeadosCompanion(
      id: id ?? this.id,
      pin: pin ?? this.pin,
      tipo: tipo ?? this.tipo,
      dias: dias ?? this.dias,
      fechaCanje: fechaCanje ?? this.fechaCanje,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pin.present) {
      map['pin'] = Variable<String>(pin.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (dias.present) {
      map['dias'] = Variable<int>(dias.value);
    }
    if (fechaCanje.present) {
      map['fecha_canje'] = Variable<int>(fechaCanje.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinesCanjeadosCompanion(')
          ..write('id: $id, ')
          ..write('pin: $pin, ')
          ..write('tipo: $tipo, ')
          ..write('dias: $dias, ')
          ..write('fechaCanje: $fechaCanje')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CiclosOperativosTable ciclosOperativos = $CiclosOperativosTable(
    this,
  );
  late final $CajasTable cajas = $CajasTable(this);
  late final $CierresCajaTable cierresCaja = $CierresCajaTable(this);
  late final $MovimientosCajaTable movimientosCaja = $MovimientosCajaTable(
    this,
  );
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $LotesBodegaTable lotesBodega = $LotesBodegaTable(this);
  late final $TransaccionesTable transacciones = $TransaccionesTable(this);
  late final $LiquidacionesTable liquidaciones = $LiquidacionesTable(this);
  late final $PrestamosTable prestamos = $PrestamosTable(this);
  late final $AbonosTable abonos = $AbonosTable(this);
  late final $AbonosDetallesTable abonosDetalles = $AbonosDetallesTable(this);
  late final $ProductosPosTable productosPos = $ProductosPosTable(this);
  late final $VentasPosTable ventasPos = $VentasPosTable(this);
  late final $VentasPosDetallesTable ventasPosDetalles =
      $VentasPosDetallesTable(this);
  late final $LotesSecadoTable lotesSecado = $LotesSecadoTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $LicenciaTable licencia = $LicenciaTable(this);
  late final $PinesCanjeadosTable pinesCanjeados = $PinesCanjeadosTable(this);
  late final Index idxMovimientosCajaHistorial = Index(
    'idx_movimientos_caja_historial',
    'CREATE INDEX idx_movimientos_caja_historial ON movimientos_caja (caja_id, anulado)',
  );
  late final Index idxClientesBusqueda = Index(
    'idx_clientes_busqueda',
    'CREATE INDEX idx_clientes_busqueda ON clientes (activo, documento, nombre_completo)',
  );
  late final Index idxLotesBodegaInventario = Index(
    'idx_lotes_bodega_inventario',
    'CREATE INDEX idx_lotes_bodega_inventario ON lotes_bodega (estado, tipo_cafe)',
  );
  late final Index idxTransaccionesPendientes = Index(
    'idx_transacciones_pendientes',
    'CREATE INDEX idx_transacciones_pendientes ON transacciones (estado_liquidacion, tipo_operacion)',
  );
  late final Index idxAuditLogsFecha = Index(
    'idx_audit_logs_fecha',
    'CREATE INDEX idx_audit_logs_fecha ON audit_logs (fecha_evento)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ciclosOperativos,
    cajas,
    cierresCaja,
    movimientosCaja,
    clientes,
    lotesBodega,
    transacciones,
    liquidaciones,
    prestamos,
    abonos,
    abonosDetalles,
    productosPos,
    ventasPos,
    ventasPosDetalles,
    lotesSecado,
    auditLogs,
    licencia,
    pinesCanjeados,
    idxMovimientosCajaHistorial,
    idxClientesBusqueda,
    idxLotesBodegaInventario,
    idxTransaccionesPendientes,
    idxAuditLogsFecha,
  ];
}

typedef $$CiclosOperativosTableCreateCompanionBuilder =
    CiclosOperativosCompanion Function({
      Value<int> id,
      required int fechaApertura,
      Value<int?> fechaCierre,
      required String estado,
      Value<String?> observaciones,
    });
typedef $$CiclosOperativosTableUpdateCompanionBuilder =
    CiclosOperativosCompanion Function({
      Value<int> id,
      Value<int> fechaApertura,
      Value<int?> fechaCierre,
      Value<String> estado,
      Value<String?> observaciones,
    });

class $$CiclosOperativosTableFilterComposer
    extends Composer<_$AppDatabase, $CiclosOperativosTable> {
  $$CiclosOperativosTableFilterComposer({
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

  ColumnFilters<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CiclosOperativosTableOrderingComposer
    extends Composer<_$AppDatabase, $CiclosOperativosTable> {
  $$CiclosOperativosTableOrderingComposer({
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

  ColumnOrderings<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CiclosOperativosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CiclosOperativosTable> {
  $$CiclosOperativosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );
}

class $$CiclosOperativosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CiclosOperativosTable,
          DBCicloOperativo,
          $$CiclosOperativosTableFilterComposer,
          $$CiclosOperativosTableOrderingComposer,
          $$CiclosOperativosTableAnnotationComposer,
          $$CiclosOperativosTableCreateCompanionBuilder,
          $$CiclosOperativosTableUpdateCompanionBuilder,
          (
            DBCicloOperativo,
            BaseReferences<
              _$AppDatabase,
              $CiclosOperativosTable,
              DBCicloOperativo
            >,
          ),
          DBCicloOperativo,
          PrefetchHooks Function()
        > {
  $$CiclosOperativosTableTableManager(
    _$AppDatabase db,
    $CiclosOperativosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CiclosOperativosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CiclosOperativosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CiclosOperativosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fechaApertura = const Value.absent(),
                Value<int?> fechaCierre = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
              }) => CiclosOperativosCompanion(
                id: id,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                estado: estado,
                observaciones: observaciones,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fechaApertura,
                Value<int?> fechaCierre = const Value.absent(),
                required String estado,
                Value<String?> observaciones = const Value.absent(),
              }) => CiclosOperativosCompanion.insert(
                id: id,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                estado: estado,
                observaciones: observaciones,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CiclosOperativosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CiclosOperativosTable,
      DBCicloOperativo,
      $$CiclosOperativosTableFilterComposer,
      $$CiclosOperativosTableOrderingComposer,
      $$CiclosOperativosTableAnnotationComposer,
      $$CiclosOperativosTableCreateCompanionBuilder,
      $$CiclosOperativosTableUpdateCompanionBuilder,
      (
        DBCicloOperativo,
        BaseReferences<_$AppDatabase, $CiclosOperativosTable, DBCicloOperativo>,
      ),
      DBCicloOperativo,
      PrefetchHooks Function()
    >;
typedef $$CajasTableCreateCompanionBuilder =
    CajasCompanion Function({
      Value<int> id,
      required int cicloOperativoId,
      required int fechaApertura,
      Value<int?> fechaCierre,
      required double saldoInicial,
      Value<double?> saldoFinalTeorico,
      required String estado,
      required String abiertaPor,
    });
typedef $$CajasTableUpdateCompanionBuilder =
    CajasCompanion Function({
      Value<int> id,
      Value<int> cicloOperativoId,
      Value<int> fechaApertura,
      Value<int?> fechaCierre,
      Value<double> saldoInicial,
      Value<double?> saldoFinalTeorico,
      Value<String> estado,
      Value<String> abiertaPor,
    });

class $$CajasTableFilterComposer extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableFilterComposer({
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

  ColumnFilters<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoFinalTeorico => $composableBuilder(
    column: $table.saldoFinalTeorico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abiertaPor => $composableBuilder(
    column: $table.abiertaPor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CajasTableOrderingComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableOrderingComposer({
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

  ColumnOrderings<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoFinalTeorico => $composableBuilder(
    column: $table.saldoFinalTeorico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abiertaPor => $composableBuilder(
    column: $table.abiertaPor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CajasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saldoInicial => $composableBuilder(
    column: $table.saldoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saldoFinalTeorico => $composableBuilder(
    column: $table.saldoFinalTeorico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get abiertaPor => $composableBuilder(
    column: $table.abiertaPor,
    builder: (column) => column,
  );
}

class $$CajasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CajasTable,
          DBCaja,
          $$CajasTableFilterComposer,
          $$CajasTableOrderingComposer,
          $$CajasTableAnnotationComposer,
          $$CajasTableCreateCompanionBuilder,
          $$CajasTableUpdateCompanionBuilder,
          (DBCaja, BaseReferences<_$AppDatabase, $CajasTable, DBCaja>),
          DBCaja,
          PrefetchHooks Function()
        > {
  $$CajasTableTableManager(_$AppDatabase db, $CajasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cicloOperativoId = const Value.absent(),
                Value<int> fechaApertura = const Value.absent(),
                Value<int?> fechaCierre = const Value.absent(),
                Value<double> saldoInicial = const Value.absent(),
                Value<double?> saldoFinalTeorico = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> abiertaPor = const Value.absent(),
              }) => CajasCompanion(
                id: id,
                cicloOperativoId: cicloOperativoId,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                saldoInicial: saldoInicial,
                saldoFinalTeorico: saldoFinalTeorico,
                estado: estado,
                abiertaPor: abiertaPor,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cicloOperativoId,
                required int fechaApertura,
                Value<int?> fechaCierre = const Value.absent(),
                required double saldoInicial,
                Value<double?> saldoFinalTeorico = const Value.absent(),
                required String estado,
                required String abiertaPor,
              }) => CajasCompanion.insert(
                id: id,
                cicloOperativoId: cicloOperativoId,
                fechaApertura: fechaApertura,
                fechaCierre: fechaCierre,
                saldoInicial: saldoInicial,
                saldoFinalTeorico: saldoFinalTeorico,
                estado: estado,
                abiertaPor: abiertaPor,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CajasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CajasTable,
      DBCaja,
      $$CajasTableFilterComposer,
      $$CajasTableOrderingComposer,
      $$CajasTableAnnotationComposer,
      $$CajasTableCreateCompanionBuilder,
      $$CajasTableUpdateCompanionBuilder,
      (DBCaja, BaseReferences<_$AppDatabase, $CajasTable, DBCaja>),
      DBCaja,
      PrefetchHooks Function()
    >;
typedef $$CierresCajaTableCreateCompanionBuilder =
    CierresCajaCompanion Function({
      Value<int> id,
      required int cajaId,
      required double dineroFisicoContado,
      required double saldoTeorico,
      required double diferencia,
      required String validadoPor,
      required int fechaCierre,
      required String comprobantePdf,
      required String estado,
      Value<String?> observaciones,
      required String tipoCierre,
    });
typedef $$CierresCajaTableUpdateCompanionBuilder =
    CierresCajaCompanion Function({
      Value<int> id,
      Value<int> cajaId,
      Value<double> dineroFisicoContado,
      Value<double> saldoTeorico,
      Value<double> diferencia,
      Value<String> validadoPor,
      Value<int> fechaCierre,
      Value<String> comprobantePdf,
      Value<String> estado,
      Value<String?> observaciones,
      Value<String> tipoCierre,
    });

class $$CierresCajaTableFilterComposer
    extends Composer<_$AppDatabase, $CierresCajaTable> {
  $$CierresCajaTableFilterComposer({
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

  ColumnFilters<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dineroFisicoContado => $composableBuilder(
    column: $table.dineroFisicoContado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoTeorico => $composableBuilder(
    column: $table.saldoTeorico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validadoPor => $composableBuilder(
    column: $table.validadoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comprobantePdf => $composableBuilder(
    column: $table.comprobantePdf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCierre => $composableBuilder(
    column: $table.tipoCierre,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CierresCajaTableOrderingComposer
    extends Composer<_$AppDatabase, $CierresCajaTable> {
  $$CierresCajaTableOrderingComposer({
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

  ColumnOrderings<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dineroFisicoContado => $composableBuilder(
    column: $table.dineroFisicoContado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoTeorico => $composableBuilder(
    column: $table.saldoTeorico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validadoPor => $composableBuilder(
    column: $table.validadoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comprobantePdf => $composableBuilder(
    column: $table.comprobantePdf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCierre => $composableBuilder(
    column: $table.tipoCierre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CierresCajaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CierresCajaTable> {
  $$CierresCajaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cajaId =>
      $composableBuilder(column: $table.cajaId, builder: (column) => column);

  GeneratedColumn<double> get dineroFisicoContado => $composableBuilder(
    column: $table.dineroFisicoContado,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saldoTeorico => $composableBuilder(
    column: $table.saldoTeorico,
    builder: (column) => column,
  );

  GeneratedColumn<double> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get validadoPor => $composableBuilder(
    column: $table.validadoPor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comprobantePdf => $composableBuilder(
    column: $table.comprobantePdf,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCierre => $composableBuilder(
    column: $table.tipoCierre,
    builder: (column) => column,
  );
}

class $$CierresCajaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CierresCajaTable,
          DBCierreCaja,
          $$CierresCajaTableFilterComposer,
          $$CierresCajaTableOrderingComposer,
          $$CierresCajaTableAnnotationComposer,
          $$CierresCajaTableCreateCompanionBuilder,
          $$CierresCajaTableUpdateCompanionBuilder,
          (
            DBCierreCaja,
            BaseReferences<_$AppDatabase, $CierresCajaTable, DBCierreCaja>,
          ),
          DBCierreCaja,
          PrefetchHooks Function()
        > {
  $$CierresCajaTableTableManager(_$AppDatabase db, $CierresCajaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CierresCajaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CierresCajaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CierresCajaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cajaId = const Value.absent(),
                Value<double> dineroFisicoContado = const Value.absent(),
                Value<double> saldoTeorico = const Value.absent(),
                Value<double> diferencia = const Value.absent(),
                Value<String> validadoPor = const Value.absent(),
                Value<int> fechaCierre = const Value.absent(),
                Value<String> comprobantePdf = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String> tipoCierre = const Value.absent(),
              }) => CierresCajaCompanion(
                id: id,
                cajaId: cajaId,
                dineroFisicoContado: dineroFisicoContado,
                saldoTeorico: saldoTeorico,
                diferencia: diferencia,
                validadoPor: validadoPor,
                fechaCierre: fechaCierre,
                comprobantePdf: comprobantePdf,
                estado: estado,
                observaciones: observaciones,
                tipoCierre: tipoCierre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cajaId,
                required double dineroFisicoContado,
                required double saldoTeorico,
                required double diferencia,
                required String validadoPor,
                required int fechaCierre,
                required String comprobantePdf,
                required String estado,
                Value<String?> observaciones = const Value.absent(),
                required String tipoCierre,
              }) => CierresCajaCompanion.insert(
                id: id,
                cajaId: cajaId,
                dineroFisicoContado: dineroFisicoContado,
                saldoTeorico: saldoTeorico,
                diferencia: diferencia,
                validadoPor: validadoPor,
                fechaCierre: fechaCierre,
                comprobantePdf: comprobantePdf,
                estado: estado,
                observaciones: observaciones,
                tipoCierre: tipoCierre,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CierresCajaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CierresCajaTable,
      DBCierreCaja,
      $$CierresCajaTableFilterComposer,
      $$CierresCajaTableOrderingComposer,
      $$CierresCajaTableAnnotationComposer,
      $$CierresCajaTableCreateCompanionBuilder,
      $$CierresCajaTableUpdateCompanionBuilder,
      (
        DBCierreCaja,
        BaseReferences<_$AppDatabase, $CierresCajaTable, DBCierreCaja>,
      ),
      DBCierreCaja,
      PrefetchHooks Function()
    >;
typedef $$MovimientosCajaTableCreateCompanionBuilder =
    MovimientosCajaCompanion Function({
      Value<int> id,
      required int cajaId,
      required String tipoMovimiento,
      required double monto,
      required String concepto,
      required String categoria,
      Value<String?> origenTabla,
      Value<int?> origenId,
      required int fechaRegistro,
      Value<int> anulado,
    });
typedef $$MovimientosCajaTableUpdateCompanionBuilder =
    MovimientosCajaCompanion Function({
      Value<int> id,
      Value<int> cajaId,
      Value<String> tipoMovimiento,
      Value<double> monto,
      Value<String> concepto,
      Value<String> categoria,
      Value<String?> origenTabla,
      Value<int?> origenId,
      Value<int> fechaRegistro,
      Value<int> anulado,
    });

class $$MovimientosCajaTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableFilterComposer({
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

  ColumnFilters<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoMovimiento => $composableBuilder(
    column: $table.tipoMovimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origenTabla => $composableBuilder(
    column: $table.origenTabla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get origenId => $composableBuilder(
    column: $table.origenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosCajaTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableOrderingComposer({
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

  ColumnOrderings<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoMovimiento => $composableBuilder(
    column: $table.tipoMovimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origenTabla => $composableBuilder(
    column: $table.origenTabla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get origenId => $composableBuilder(
    column: $table.origenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosCajaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosCajaTable> {
  $$MovimientosCajaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cajaId =>
      $composableBuilder(column: $table.cajaId, builder: (column) => column);

  GeneratedColumn<String> get tipoMovimiento => $composableBuilder(
    column: $table.tipoMovimiento,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get origenTabla => $composableBuilder(
    column: $table.origenTabla,
    builder: (column) => column,
  );

  GeneratedColumn<int> get origenId =>
      $composableBuilder(column: $table.origenId, builder: (column) => column);

  GeneratedColumn<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anulado =>
      $composableBuilder(column: $table.anulado, builder: (column) => column);
}

class $$MovimientosCajaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosCajaTable,
          DBMovimientoCaja,
          $$MovimientosCajaTableFilterComposer,
          $$MovimientosCajaTableOrderingComposer,
          $$MovimientosCajaTableAnnotationComposer,
          $$MovimientosCajaTableCreateCompanionBuilder,
          $$MovimientosCajaTableUpdateCompanionBuilder,
          (
            DBMovimientoCaja,
            BaseReferences<
              _$AppDatabase,
              $MovimientosCajaTable,
              DBMovimientoCaja
            >,
          ),
          DBMovimientoCaja,
          PrefetchHooks Function()
        > {
  $$MovimientosCajaTableTableManager(
    _$AppDatabase db,
    $MovimientosCajaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosCajaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosCajaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosCajaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cajaId = const Value.absent(),
                Value<String> tipoMovimiento = const Value.absent(),
                Value<double> monto = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String?> origenTabla = const Value.absent(),
                Value<int?> origenId = const Value.absent(),
                Value<int> fechaRegistro = const Value.absent(),
                Value<int> anulado = const Value.absent(),
              }) => MovimientosCajaCompanion(
                id: id,
                cajaId: cajaId,
                tipoMovimiento: tipoMovimiento,
                monto: monto,
                concepto: concepto,
                categoria: categoria,
                origenTabla: origenTabla,
                origenId: origenId,
                fechaRegistro: fechaRegistro,
                anulado: anulado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cajaId,
                required String tipoMovimiento,
                required double monto,
                required String concepto,
                required String categoria,
                Value<String?> origenTabla = const Value.absent(),
                Value<int?> origenId = const Value.absent(),
                required int fechaRegistro,
                Value<int> anulado = const Value.absent(),
              }) => MovimientosCajaCompanion.insert(
                id: id,
                cajaId: cajaId,
                tipoMovimiento: tipoMovimiento,
                monto: monto,
                concepto: concepto,
                categoria: categoria,
                origenTabla: origenTabla,
                origenId: origenId,
                fechaRegistro: fechaRegistro,
                anulado: anulado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosCajaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosCajaTable,
      DBMovimientoCaja,
      $$MovimientosCajaTableFilterComposer,
      $$MovimientosCajaTableOrderingComposer,
      $$MovimientosCajaTableAnnotationComposer,
      $$MovimientosCajaTableCreateCompanionBuilder,
      $$MovimientosCajaTableUpdateCompanionBuilder,
      (
        DBMovimientoCaja,
        BaseReferences<_$AppDatabase, $MovimientosCajaTable, DBMovimientoCaja>,
      ),
      DBMovimientoCaja,
      PrefetchHooks Function()
    >;
typedef $$ClientesTableCreateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      required String nombreCompleto,
      required String documento,
      Value<String?> telefono,
      Value<String?> direccion,
      Value<int> creditoAutorizado,
      Value<double> cupoMaximo,
      Value<int> activo,
    });
typedef $$ClientesTableUpdateCompanionBuilder =
    ClientesCompanion Function({
      Value<int> id,
      Value<String> nombreCompleto,
      Value<String> documento,
      Value<String?> telefono,
      Value<String?> direccion,
      Value<int> creditoAutorizado,
      Value<double> cupoMaximo,
      Value<int> activo,
    });

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
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

  ColumnFilters<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditoAutorizado => $composableBuilder(
    column: $table.creditoAutorizado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cupoMaximo => $composableBuilder(
    column: $table.cupoMaximo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
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

  ColumnOrderings<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditoAutorizado => $composableBuilder(
    column: $table.creditoAutorizado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cupoMaximo => $composableBuilder(
    column: $table.cupoMaximo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreCompleto => $composableBuilder(
    column: $table.nombreCompleto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documento =>
      $composableBuilder(column: $table.documento, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<int> get creditoAutorizado => $composableBuilder(
    column: $table.creditoAutorizado,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cupoMaximo => $composableBuilder(
    column: $table.cupoMaximo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          DBCliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (DBCliente, BaseReferences<_$AppDatabase, $ClientesTable, DBCliente>),
          DBCliente,
          PrefetchHooks Function()
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreCompleto = const Value.absent(),
                Value<String> documento = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<int> creditoAutorizado = const Value.absent(),
                Value<double> cupoMaximo = const Value.absent(),
                Value<int> activo = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nombreCompleto: nombreCompleto,
                documento: documento,
                telefono: telefono,
                direccion: direccion,
                creditoAutorizado: creditoAutorizado,
                cupoMaximo: cupoMaximo,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombreCompleto,
                required String documento,
                Value<String?> telefono = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<int> creditoAutorizado = const Value.absent(),
                Value<double> cupoMaximo = const Value.absent(),
                Value<int> activo = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nombreCompleto: nombreCompleto,
                documento: documento,
                telefono: telefono,
                direccion: direccion,
                creditoAutorizado: creditoAutorizado,
                cupoMaximo: cupoMaximo,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      DBCliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (DBCliente, BaseReferences<_$AppDatabase, $ClientesTable, DBCliente>),
      DBCliente,
      PrefetchHooks Function()
    >;
typedef $$LotesBodegaTableCreateCompanionBuilder =
    LotesBodegaCompanion Function({
      Value<int> id,
      required String codigoLote,
      required String tipoCafe,
      required double pesoInicial,
      required double pesoActual,
      required double costoInicialKg,
      required int fechaIngreso,
      required String estado,
    });
typedef $$LotesBodegaTableUpdateCompanionBuilder =
    LotesBodegaCompanion Function({
      Value<int> id,
      Value<String> codigoLote,
      Value<String> tipoCafe,
      Value<double> pesoInicial,
      Value<double> pesoActual,
      Value<double> costoInicialKg,
      Value<int> fechaIngreso,
      Value<String> estado,
    });

class $$LotesBodegaTableFilterComposer
    extends Composer<_$AppDatabase, $LotesBodegaTable> {
  $$LotesBodegaTableFilterComposer({
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

  ColumnFilters<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCafe => $composableBuilder(
    column: $table.tipoCafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoInicial => $composableBuilder(
    column: $table.pesoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoActual => $composableBuilder(
    column: $table.pesoActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoInicialKg => $composableBuilder(
    column: $table.costoInicialKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotesBodegaTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesBodegaTable> {
  $$LotesBodegaTableOrderingComposer({
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

  ColumnOrderings<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCafe => $composableBuilder(
    column: $table.tipoCafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoInicial => $composableBuilder(
    column: $table.pesoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoActual => $composableBuilder(
    column: $table.pesoActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoInicialKg => $composableBuilder(
    column: $table.costoInicialKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesBodegaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesBodegaTable> {
  $$LotesBodegaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCafe =>
      $composableBuilder(column: $table.tipoCafe, builder: (column) => column);

  GeneratedColumn<double> get pesoInicial => $composableBuilder(
    column: $table.pesoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoActual => $composableBuilder(
    column: $table.pesoActual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costoInicialKg => $composableBuilder(
    column: $table.costoInicialKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$LotesBodegaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesBodegaTable,
          DBLoteBodega,
          $$LotesBodegaTableFilterComposer,
          $$LotesBodegaTableOrderingComposer,
          $$LotesBodegaTableAnnotationComposer,
          $$LotesBodegaTableCreateCompanionBuilder,
          $$LotesBodegaTableUpdateCompanionBuilder,
          (
            DBLoteBodega,
            BaseReferences<_$AppDatabase, $LotesBodegaTable, DBLoteBodega>,
          ),
          DBLoteBodega,
          PrefetchHooks Function()
        > {
  $$LotesBodegaTableTableManager(_$AppDatabase db, $LotesBodegaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesBodegaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesBodegaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesBodegaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigoLote = const Value.absent(),
                Value<String> tipoCafe = const Value.absent(),
                Value<double> pesoInicial = const Value.absent(),
                Value<double> pesoActual = const Value.absent(),
                Value<double> costoInicialKg = const Value.absent(),
                Value<int> fechaIngreso = const Value.absent(),
                Value<String> estado = const Value.absent(),
              }) => LotesBodegaCompanion(
                id: id,
                codigoLote: codigoLote,
                tipoCafe: tipoCafe,
                pesoInicial: pesoInicial,
                pesoActual: pesoActual,
                costoInicialKg: costoInicialKg,
                fechaIngreso: fechaIngreso,
                estado: estado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigoLote,
                required String tipoCafe,
                required double pesoInicial,
                required double pesoActual,
                required double costoInicialKg,
                required int fechaIngreso,
                required String estado,
              }) => LotesBodegaCompanion.insert(
                id: id,
                codigoLote: codigoLote,
                tipoCafe: tipoCafe,
                pesoInicial: pesoInicial,
                pesoActual: pesoActual,
                costoInicialKg: costoInicialKg,
                fechaIngreso: fechaIngreso,
                estado: estado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotesBodegaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesBodegaTable,
      DBLoteBodega,
      $$LotesBodegaTableFilterComposer,
      $$LotesBodegaTableOrderingComposer,
      $$LotesBodegaTableAnnotationComposer,
      $$LotesBodegaTableCreateCompanionBuilder,
      $$LotesBodegaTableUpdateCompanionBuilder,
      (
        DBLoteBodega,
        BaseReferences<_$AppDatabase, $LotesBodegaTable, DBLoteBodega>,
      ),
      DBLoteBodega,
      PrefetchHooks Function()
    >;
typedef $$TransaccionesTableCreateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      required String codigoTransaccion,
      required int cicloOperativoId,
      Value<int?> clienteId,
      Value<int?> loteBodegaId,
      required String tipoOperacion,
      required String tipoCafe,
      required double pesoBruto,
      Value<double> descuentoEmpaque,
      Value<double> porcentajeHumedad,
      Value<double> gramera,
      Value<double> factorObtenido,
      required double precioBase,
      Value<double> precioFinalKg,
      required double pesoNetoFinal,
      required double totalPagarRecibir,
      required String estadoLiquidacion,
      Value<int> anulado,
      required int fechaRegistro,
    });
typedef $$TransaccionesTableUpdateCompanionBuilder =
    TransaccionesCompanion Function({
      Value<int> id,
      Value<String> codigoTransaccion,
      Value<int> cicloOperativoId,
      Value<int?> clienteId,
      Value<int?> loteBodegaId,
      Value<String> tipoOperacion,
      Value<String> tipoCafe,
      Value<double> pesoBruto,
      Value<double> descuentoEmpaque,
      Value<double> porcentajeHumedad,
      Value<double> gramera,
      Value<double> factorObtenido,
      Value<double> precioBase,
      Value<double> precioFinalKg,
      Value<double> pesoNetoFinal,
      Value<double> totalPagarRecibir,
      Value<String> estadoLiquidacion,
      Value<int> anulado,
      Value<int> fechaRegistro,
    });

class $$TransaccionesTableFilterComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableFilterComposer({
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

  ColumnFilters<String> get codigoTransaccion => $composableBuilder(
    column: $table.codigoTransaccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loteBodegaId => $composableBuilder(
    column: $table.loteBodegaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoOperacion => $composableBuilder(
    column: $table.tipoOperacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCafe => $composableBuilder(
    column: $table.tipoCafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoBruto => $composableBuilder(
    column: $table.pesoBruto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get descuentoEmpaque => $composableBuilder(
    column: $table.descuentoEmpaque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get porcentajeHumedad => $composableBuilder(
    column: $table.porcentajeHumedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramera => $composableBuilder(
    column: $table.gramera,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factorObtenido => $composableBuilder(
    column: $table.factorObtenido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioFinalKg => $composableBuilder(
    column: $table.precioFinalKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoNetoFinal => $composableBuilder(
    column: $table.pesoNetoFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPagarRecibir => $composableBuilder(
    column: $table.totalPagarRecibir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoLiquidacion => $composableBuilder(
    column: $table.estadoLiquidacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransaccionesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableOrderingComposer({
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

  ColumnOrderings<String> get codigoTransaccion => $composableBuilder(
    column: $table.codigoTransaccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loteBodegaId => $composableBuilder(
    column: $table.loteBodegaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoOperacion => $composableBuilder(
    column: $table.tipoOperacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCafe => $composableBuilder(
    column: $table.tipoCafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoBruto => $composableBuilder(
    column: $table.pesoBruto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get descuentoEmpaque => $composableBuilder(
    column: $table.descuentoEmpaque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get porcentajeHumedad => $composableBuilder(
    column: $table.porcentajeHumedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramera => $composableBuilder(
    column: $table.gramera,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factorObtenido => $composableBuilder(
    column: $table.factorObtenido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioFinalKg => $composableBuilder(
    column: $table.precioFinalKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoNetoFinal => $composableBuilder(
    column: $table.pesoNetoFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPagarRecibir => $composableBuilder(
    column: $table.totalPagarRecibir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoLiquidacion => $composableBuilder(
    column: $table.estadoLiquidacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransaccionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransaccionesTable> {
  $$TransaccionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoTransaccion => $composableBuilder(
    column: $table.codigoTransaccion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<int> get loteBodegaId => $composableBuilder(
    column: $table.loteBodegaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoOperacion => $composableBuilder(
    column: $table.tipoOperacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCafe =>
      $composableBuilder(column: $table.tipoCafe, builder: (column) => column);

  GeneratedColumn<double> get pesoBruto =>
      $composableBuilder(column: $table.pesoBruto, builder: (column) => column);

  GeneratedColumn<double> get descuentoEmpaque => $composableBuilder(
    column: $table.descuentoEmpaque,
    builder: (column) => column,
  );

  GeneratedColumn<double> get porcentajeHumedad => $composableBuilder(
    column: $table.porcentajeHumedad,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gramera =>
      $composableBuilder(column: $table.gramera, builder: (column) => column);

  GeneratedColumn<double> get factorObtenido => $composableBuilder(
    column: $table.factorObtenido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioBase => $composableBuilder(
    column: $table.precioBase,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioFinalKg => $composableBuilder(
    column: $table.precioFinalKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoNetoFinal => $composableBuilder(
    column: $table.pesoNetoFinal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalPagarRecibir => $composableBuilder(
    column: $table.totalPagarRecibir,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoLiquidacion => $composableBuilder(
    column: $table.estadoLiquidacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anulado =>
      $composableBuilder(column: $table.anulado, builder: (column) => column);

  GeneratedColumn<int> get fechaRegistro => $composableBuilder(
    column: $table.fechaRegistro,
    builder: (column) => column,
  );
}

class $$TransaccionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransaccionesTable,
          DBTransaccion,
          $$TransaccionesTableFilterComposer,
          $$TransaccionesTableOrderingComposer,
          $$TransaccionesTableAnnotationComposer,
          $$TransaccionesTableCreateCompanionBuilder,
          $$TransaccionesTableUpdateCompanionBuilder,
          (
            DBTransaccion,
            BaseReferences<_$AppDatabase, $TransaccionesTable, DBTransaccion>,
          ),
          DBTransaccion,
          PrefetchHooks Function()
        > {
  $$TransaccionesTableTableManager(_$AppDatabase db, $TransaccionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransaccionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransaccionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransaccionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigoTransaccion = const Value.absent(),
                Value<int> cicloOperativoId = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                Value<int?> loteBodegaId = const Value.absent(),
                Value<String> tipoOperacion = const Value.absent(),
                Value<String> tipoCafe = const Value.absent(),
                Value<double> pesoBruto = const Value.absent(),
                Value<double> descuentoEmpaque = const Value.absent(),
                Value<double> porcentajeHumedad = const Value.absent(),
                Value<double> gramera = const Value.absent(),
                Value<double> factorObtenido = const Value.absent(),
                Value<double> precioBase = const Value.absent(),
                Value<double> precioFinalKg = const Value.absent(),
                Value<double> pesoNetoFinal = const Value.absent(),
                Value<double> totalPagarRecibir = const Value.absent(),
                Value<String> estadoLiquidacion = const Value.absent(),
                Value<int> anulado = const Value.absent(),
                Value<int> fechaRegistro = const Value.absent(),
              }) => TransaccionesCompanion(
                id: id,
                codigoTransaccion: codigoTransaccion,
                cicloOperativoId: cicloOperativoId,
                clienteId: clienteId,
                loteBodegaId: loteBodegaId,
                tipoOperacion: tipoOperacion,
                tipoCafe: tipoCafe,
                pesoBruto: pesoBruto,
                descuentoEmpaque: descuentoEmpaque,
                porcentajeHumedad: porcentajeHumedad,
                gramera: gramera,
                factorObtenido: factorObtenido,
                precioBase: precioBase,
                precioFinalKg: precioFinalKg,
                pesoNetoFinal: pesoNetoFinal,
                totalPagarRecibir: totalPagarRecibir,
                estadoLiquidacion: estadoLiquidacion,
                anulado: anulado,
                fechaRegistro: fechaRegistro,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigoTransaccion,
                required int cicloOperativoId,
                Value<int?> clienteId = const Value.absent(),
                Value<int?> loteBodegaId = const Value.absent(),
                required String tipoOperacion,
                required String tipoCafe,
                required double pesoBruto,
                Value<double> descuentoEmpaque = const Value.absent(),
                Value<double> porcentajeHumedad = const Value.absent(),
                Value<double> gramera = const Value.absent(),
                Value<double> factorObtenido = const Value.absent(),
                required double precioBase,
                Value<double> precioFinalKg = const Value.absent(),
                required double pesoNetoFinal,
                required double totalPagarRecibir,
                required String estadoLiquidacion,
                Value<int> anulado = const Value.absent(),
                required int fechaRegistro,
              }) => TransaccionesCompanion.insert(
                id: id,
                codigoTransaccion: codigoTransaccion,
                cicloOperativoId: cicloOperativoId,
                clienteId: clienteId,
                loteBodegaId: loteBodegaId,
                tipoOperacion: tipoOperacion,
                tipoCafe: tipoCafe,
                pesoBruto: pesoBruto,
                descuentoEmpaque: descuentoEmpaque,
                porcentajeHumedad: porcentajeHumedad,
                gramera: gramera,
                factorObtenido: factorObtenido,
                precioBase: precioBase,
                precioFinalKg: precioFinalKg,
                pesoNetoFinal: pesoNetoFinal,
                totalPagarRecibir: totalPagarRecibir,
                estadoLiquidacion: estadoLiquidacion,
                anulado: anulado,
                fechaRegistro: fechaRegistro,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransaccionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransaccionesTable,
      DBTransaccion,
      $$TransaccionesTableFilterComposer,
      $$TransaccionesTableOrderingComposer,
      $$TransaccionesTableAnnotationComposer,
      $$TransaccionesTableCreateCompanionBuilder,
      $$TransaccionesTableUpdateCompanionBuilder,
      (
        DBTransaccion,
        BaseReferences<_$AppDatabase, $TransaccionesTable, DBTransaccion>,
      ),
      DBTransaccion,
      PrefetchHooks Function()
    >;
typedef $$LiquidacionesTableCreateCompanionBuilder =
    LiquidacionesCompanion Function({
      Value<int> id,
      required int transaccionId,
      required int cajaId,
      required double montoTotalTransaccion,
      Value<double> montoAnticiposPrevios,
      Value<double> descuentoCartera,
      required double saldoNetoPagado,
      Value<String> estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
      required int fechaLiquidacion,
    });
typedef $$LiquidacionesTableUpdateCompanionBuilder =
    LiquidacionesCompanion Function({
      Value<int> id,
      Value<int> transaccionId,
      Value<int> cajaId,
      Value<double> montoTotalTransaccion,
      Value<double> montoAnticiposPrevios,
      Value<double> descuentoCartera,
      Value<double> saldoNetoPagado,
      Value<String> estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
      Value<int> fechaLiquidacion,
    });

class $$LiquidacionesTableFilterComposer
    extends Composer<_$AppDatabase, $LiquidacionesTable> {
  $$LiquidacionesTableFilterComposer({
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

  ColumnFilters<int> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoTotalTransaccion => $composableBuilder(
    column: $table.montoTotalTransaccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoAnticiposPrevios => $composableBuilder(
    column: $table.montoAnticiposPrevios,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get descuentoCartera => $composableBuilder(
    column: $table.descuentoCartera,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoNetoPagado => $composableBuilder(
    column: $table.saldoNetoPagado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaLiquidacion => $composableBuilder(
    column: $table.fechaLiquidacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LiquidacionesTableOrderingComposer
    extends Composer<_$AppDatabase, $LiquidacionesTable> {
  $$LiquidacionesTableOrderingComposer({
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

  ColumnOrderings<int> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoTotalTransaccion => $composableBuilder(
    column: $table.montoTotalTransaccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoAnticiposPrevios => $composableBuilder(
    column: $table.montoAnticiposPrevios,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get descuentoCartera => $composableBuilder(
    column: $table.descuentoCartera,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoNetoPagado => $composableBuilder(
    column: $table.saldoNetoPagado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaLiquidacion => $composableBuilder(
    column: $table.fechaLiquidacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LiquidacionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LiquidacionesTable> {
  $$LiquidacionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get transaccionId => $composableBuilder(
    column: $table.transaccionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cajaId =>
      $composableBuilder(column: $table.cajaId, builder: (column) => column);

  GeneratedColumn<double> get montoTotalTransaccion => $composableBuilder(
    column: $table.montoTotalTransaccion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoAnticiposPrevios => $composableBuilder(
    column: $table.montoAnticiposPrevios,
    builder: (column) => column,
  );

  GeneratedColumn<double> get descuentoCartera => $composableBuilder(
    column: $table.descuentoCartera,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saldoNetoPagado => $composableBuilder(
    column: $table.saldoNetoPagado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaLiquidacion => $composableBuilder(
    column: $table.fechaLiquidacion,
    builder: (column) => column,
  );
}

class $$LiquidacionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LiquidacionesTable,
          DBLiquidacion,
          $$LiquidacionesTableFilterComposer,
          $$LiquidacionesTableOrderingComposer,
          $$LiquidacionesTableAnnotationComposer,
          $$LiquidacionesTableCreateCompanionBuilder,
          $$LiquidacionesTableUpdateCompanionBuilder,
          (
            DBLiquidacion,
            BaseReferences<_$AppDatabase, $LiquidacionesTable, DBLiquidacion>,
          ),
          DBLiquidacion,
          PrefetchHooks Function()
        > {
  $$LiquidacionesTableTableManager(_$AppDatabase db, $LiquidacionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LiquidacionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LiquidacionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LiquidacionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transaccionId = const Value.absent(),
                Value<int> cajaId = const Value.absent(),
                Value<double> montoTotalTransaccion = const Value.absent(),
                Value<double> montoAnticiposPrevios = const Value.absent(),
                Value<double> descuentoCartera = const Value.absent(),
                Value<double> saldoNetoPagado = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
                Value<int> fechaLiquidacion = const Value.absent(),
              }) => LiquidacionesCompanion(
                id: id,
                transaccionId: transaccionId,
                cajaId: cajaId,
                montoTotalTransaccion: montoTotalTransaccion,
                montoAnticiposPrevios: montoAnticiposPrevios,
                descuentoCartera: descuentoCartera,
                saldoNetoPagado: saldoNetoPagado,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
                fechaLiquidacion: fechaLiquidacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transaccionId,
                required int cajaId,
                required double montoTotalTransaccion,
                Value<double> montoAnticiposPrevios = const Value.absent(),
                Value<double> descuentoCartera = const Value.absent(),
                required double saldoNetoPagado,
                Value<String> estado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
                required int fechaLiquidacion,
              }) => LiquidacionesCompanion.insert(
                id: id,
                transaccionId: transaccionId,
                cajaId: cajaId,
                montoTotalTransaccion: montoTotalTransaccion,
                montoAnticiposPrevios: montoAnticiposPrevios,
                descuentoCartera: descuentoCartera,
                saldoNetoPagado: saldoNetoPagado,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
                fechaLiquidacion: fechaLiquidacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LiquidacionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LiquidacionesTable,
      DBLiquidacion,
      $$LiquidacionesTableFilterComposer,
      $$LiquidacionesTableOrderingComposer,
      $$LiquidacionesTableAnnotationComposer,
      $$LiquidacionesTableCreateCompanionBuilder,
      $$LiquidacionesTableUpdateCompanionBuilder,
      (
        DBLiquidacion,
        BaseReferences<_$AppDatabase, $LiquidacionesTable, DBLiquidacion>,
      ),
      DBLiquidacion,
      PrefetchHooks Function()
    >;
typedef $$PrestamosTableCreateCompanionBuilder =
    PrestamosCompanion Function({
      Value<int> id,
      required int clienteId,
      required int cicloOperativoId,
      required double montoPrestado,
      required double saldoPendiente,
      required int fechaPrestamo,
      required String estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
    });
typedef $$PrestamosTableUpdateCompanionBuilder =
    PrestamosCompanion Function({
      Value<int> id,
      Value<int> clienteId,
      Value<int> cicloOperativoId,
      Value<double> montoPrestado,
      Value<double> saldoPendiente,
      Value<int> fechaPrestamo,
      Value<String> estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
    });

class $$PrestamosTableFilterComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableFilterComposer({
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

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoPrestado => $composableBuilder(
    column: $table.montoPrestado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saldoPendiente => $composableBuilder(
    column: $table.saldoPendiente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaPrestamo => $composableBuilder(
    column: $table.fechaPrestamo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrestamosTableOrderingComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableOrderingComposer({
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

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoPrestado => $composableBuilder(
    column: $table.montoPrestado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saldoPendiente => $composableBuilder(
    column: $table.saldoPendiente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaPrestamo => $composableBuilder(
    column: $table.fechaPrestamo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrestamosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoPrestado => $composableBuilder(
    column: $table.montoPrestado,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saldoPendiente => $composableBuilder(
    column: $table.saldoPendiente,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaPrestamo => $composableBuilder(
    column: $table.fechaPrestamo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => column,
  );
}

class $$PrestamosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrestamosTable,
          DBPrestamo,
          $$PrestamosTableFilterComposer,
          $$PrestamosTableOrderingComposer,
          $$PrestamosTableAnnotationComposer,
          $$PrestamosTableCreateCompanionBuilder,
          $$PrestamosTableUpdateCompanionBuilder,
          (
            DBPrestamo,
            BaseReferences<_$AppDatabase, $PrestamosTable, DBPrestamo>,
          ),
          DBPrestamo,
          PrefetchHooks Function()
        > {
  $$PrestamosTableTableManager(_$AppDatabase db, $PrestamosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrestamosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrestamosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrestamosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<int> cicloOperativoId = const Value.absent(),
                Value<double> montoPrestado = const Value.absent(),
                Value<double> saldoPendiente = const Value.absent(),
                Value<int> fechaPrestamo = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
              }) => PrestamosCompanion(
                id: id,
                clienteId: clienteId,
                cicloOperativoId: cicloOperativoId,
                montoPrestado: montoPrestado,
                saldoPendiente: saldoPendiente,
                fechaPrestamo: fechaPrestamo,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required int cicloOperativoId,
                required double montoPrestado,
                required double saldoPendiente,
                required int fechaPrestamo,
                required String estado,
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
              }) => PrestamosCompanion.insert(
                id: id,
                clienteId: clienteId,
                cicloOperativoId: cicloOperativoId,
                montoPrestado: montoPrestado,
                saldoPendiente: saldoPendiente,
                fechaPrestamo: fechaPrestamo,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrestamosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrestamosTable,
      DBPrestamo,
      $$PrestamosTableFilterComposer,
      $$PrestamosTableOrderingComposer,
      $$PrestamosTableAnnotationComposer,
      $$PrestamosTableCreateCompanionBuilder,
      $$PrestamosTableUpdateCompanionBuilder,
      (DBPrestamo, BaseReferences<_$AppDatabase, $PrestamosTable, DBPrestamo>),
      DBPrestamo,
      PrefetchHooks Function()
    >;
typedef $$AbonosTableCreateCompanionBuilder =
    AbonosCompanion Function({
      Value<int> id,
      required int clienteId,
      required int cajaId,
      required double montoTotal,
      Value<int> anulado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
      required int fechaAbono,
    });
typedef $$AbonosTableUpdateCompanionBuilder =
    AbonosCompanion Function({
      Value<int> id,
      Value<int> clienteId,
      Value<int> cajaId,
      Value<double> montoTotal,
      Value<int> anulado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
      Value<int> fechaAbono,
    });

class $$AbonosTableFilterComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableFilterComposer({
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

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoTotal => $composableBuilder(
    column: $table.montoTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaAbono => $composableBuilder(
    column: $table.fechaAbono,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AbonosTableOrderingComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableOrderingComposer({
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

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cajaId => $composableBuilder(
    column: $table.cajaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoTotal => $composableBuilder(
    column: $table.montoTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anulado => $composableBuilder(
    column: $table.anulado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaAbono => $composableBuilder(
    column: $table.fechaAbono,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AbonosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbonosTable> {
  $$AbonosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<int> get cajaId =>
      $composableBuilder(column: $table.cajaId, builder: (column) => column);

  GeneratedColumn<double> get montoTotal => $composableBuilder(
    column: $table.montoTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anulado =>
      $composableBuilder(column: $table.anulado, builder: (column) => column);

  GeneratedColumn<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaAbono => $composableBuilder(
    column: $table.fechaAbono,
    builder: (column) => column,
  );
}

class $$AbonosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbonosTable,
          DBAbono,
          $$AbonosTableFilterComposer,
          $$AbonosTableOrderingComposer,
          $$AbonosTableAnnotationComposer,
          $$AbonosTableCreateCompanionBuilder,
          $$AbonosTableUpdateCompanionBuilder,
          (DBAbono, BaseReferences<_$AppDatabase, $AbonosTable, DBAbono>),
          DBAbono,
          PrefetchHooks Function()
        > {
  $$AbonosTableTableManager(_$AppDatabase db, $AbonosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbonosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbonosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbonosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<int> cajaId = const Value.absent(),
                Value<double> montoTotal = const Value.absent(),
                Value<int> anulado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
                Value<int> fechaAbono = const Value.absent(),
              }) => AbonosCompanion(
                id: id,
                clienteId: clienteId,
                cajaId: cajaId,
                montoTotal: montoTotal,
                anulado: anulado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
                fechaAbono: fechaAbono,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required int cajaId,
                required double montoTotal,
                Value<int> anulado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
                required int fechaAbono,
              }) => AbonosCompanion.insert(
                id: id,
                clienteId: clienteId,
                cajaId: cajaId,
                montoTotal: montoTotal,
                anulado: anulado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
                fechaAbono: fechaAbono,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AbonosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbonosTable,
      DBAbono,
      $$AbonosTableFilterComposer,
      $$AbonosTableOrderingComposer,
      $$AbonosTableAnnotationComposer,
      $$AbonosTableCreateCompanionBuilder,
      $$AbonosTableUpdateCompanionBuilder,
      (DBAbono, BaseReferences<_$AppDatabase, $AbonosTable, DBAbono>),
      DBAbono,
      PrefetchHooks Function()
    >;
typedef $$AbonosDetallesTableCreateCompanionBuilder =
    AbonosDetallesCompanion Function({
      Value<int> id,
      required int abonoId,
      required String destinoTipo,
      required int destinoId,
      required double montoApplied,
    });
typedef $$AbonosDetallesTableUpdateCompanionBuilder =
    AbonosDetallesCompanion Function({
      Value<int> id,
      Value<int> abonoId,
      Value<String> destinoTipo,
      Value<int> destinoId,
      Value<double> montoApplied,
    });

class $$AbonosDetallesTableFilterComposer
    extends Composer<_$AppDatabase, $AbonosDetallesTable> {
  $$AbonosDetallesTableFilterComposer({
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

  ColumnFilters<int> get abonoId => $composableBuilder(
    column: $table.abonoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinoTipo => $composableBuilder(
    column: $table.destinoTipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get destinoId => $composableBuilder(
    column: $table.destinoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoApplied => $composableBuilder(
    column: $table.montoApplied,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AbonosDetallesTableOrderingComposer
    extends Composer<_$AppDatabase, $AbonosDetallesTable> {
  $$AbonosDetallesTableOrderingComposer({
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

  ColumnOrderings<int> get abonoId => $composableBuilder(
    column: $table.abonoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinoTipo => $composableBuilder(
    column: $table.destinoTipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get destinoId => $composableBuilder(
    column: $table.destinoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoApplied => $composableBuilder(
    column: $table.montoApplied,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AbonosDetallesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AbonosDetallesTable> {
  $$AbonosDetallesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get abonoId =>
      $composableBuilder(column: $table.abonoId, builder: (column) => column);

  GeneratedColumn<String> get destinoTipo => $composableBuilder(
    column: $table.destinoTipo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get destinoId =>
      $composableBuilder(column: $table.destinoId, builder: (column) => column);

  GeneratedColumn<double> get montoApplied => $composableBuilder(
    column: $table.montoApplied,
    builder: (column) => column,
  );
}

class $$AbonosDetallesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AbonosDetallesTable,
          DBAbonoDetalle,
          $$AbonosDetallesTableFilterComposer,
          $$AbonosDetallesTableOrderingComposer,
          $$AbonosDetallesTableAnnotationComposer,
          $$AbonosDetallesTableCreateCompanionBuilder,
          $$AbonosDetallesTableUpdateCompanionBuilder,
          (
            DBAbonoDetalle,
            BaseReferences<_$AppDatabase, $AbonosDetallesTable, DBAbonoDetalle>,
          ),
          DBAbonoDetalle,
          PrefetchHooks Function()
        > {
  $$AbonosDetallesTableTableManager(
    _$AppDatabase db,
    $AbonosDetallesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbonosDetallesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbonosDetallesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbonosDetallesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> abonoId = const Value.absent(),
                Value<String> destinoTipo = const Value.absent(),
                Value<int> destinoId = const Value.absent(),
                Value<double> montoApplied = const Value.absent(),
              }) => AbonosDetallesCompanion(
                id: id,
                abonoId: abonoId,
                destinoTipo: destinoTipo,
                destinoId: destinoId,
                montoApplied: montoApplied,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int abonoId,
                required String destinoTipo,
                required int destinoId,
                required double montoApplied,
              }) => AbonosDetallesCompanion.insert(
                id: id,
                abonoId: abonoId,
                destinoTipo: destinoTipo,
                destinoId: destinoId,
                montoApplied: montoApplied,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AbonosDetallesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AbonosDetallesTable,
      DBAbonoDetalle,
      $$AbonosDetallesTableFilterComposer,
      $$AbonosDetallesTableOrderingComposer,
      $$AbonosDetallesTableAnnotationComposer,
      $$AbonosDetallesTableCreateCompanionBuilder,
      $$AbonosDetallesTableUpdateCompanionBuilder,
      (
        DBAbonoDetalle,
        BaseReferences<_$AppDatabase, $AbonosDetallesTable, DBAbonoDetalle>,
      ),
      DBAbonoDetalle,
      PrefetchHooks Function()
    >;
typedef $$ProductosPosTableCreateCompanionBuilder =
    ProductosPosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      required String descripcion,
      required String categoria,
      required double precioCompra,
      required double precioVenta,
      Value<double> existenciaInicial,
      required double stockActual,
      Value<double> stockMinimoAlerta,
      Value<int> activo,
    });
typedef $$ProductosPosTableUpdateCompanionBuilder =
    ProductosPosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      Value<String> descripcion,
      Value<String> categoria,
      Value<double> precioCompra,
      Value<double> precioVenta,
      Value<double> existenciaInicial,
      Value<double> stockActual,
      Value<double> stockMinimoAlerta,
      Value<int> activo,
    });

class $$ProductosPosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosPosTable> {
  $$ProductosPosTableFilterComposer({
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

  ColumnFilters<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get existenciaInicial => $composableBuilder(
    column: $table.existenciaInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockMinimoAlerta => $composableBuilder(
    column: $table.stockMinimoAlerta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosPosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosPosTable> {
  $$ProductosPosTableOrderingComposer({
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

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get existenciaInicial => $composableBuilder(
    column: $table.existenciaInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockMinimoAlerta => $composableBuilder(
    column: $table.stockMinimoAlerta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosPosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosPosTable> {
  $$ProductosPosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get existenciaInicial => $composableBuilder(
    column: $table.existenciaInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockMinimoAlerta => $composableBuilder(
    column: $table.stockMinimoAlerta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$ProductosPosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosPosTable,
          DBProductoPos,
          $$ProductosPosTableFilterComposer,
          $$ProductosPosTableOrderingComposer,
          $$ProductosPosTableAnnotationComposer,
          $$ProductosPosTableCreateCompanionBuilder,
          $$ProductosPosTableUpdateCompanionBuilder,
          (
            DBProductoPos,
            BaseReferences<_$AppDatabase, $ProductosPosTable, DBProductoPos>,
          ),
          DBProductoPos,
          PrefetchHooks Function()
        > {
  $$ProductosPosTableTableManager(_$AppDatabase db, $ProductosPosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosPosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosPosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosPosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<double> precioCompra = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<double> existenciaInicial = const Value.absent(),
                Value<double> stockActual = const Value.absent(),
                Value<double> stockMinimoAlerta = const Value.absent(),
                Value<int> activo = const Value.absent(),
              }) => ProductosPosCompanion(
                id: id,
                codigoBarras: codigoBarras,
                descripcion: descripcion,
                categoria: categoria,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                existenciaInicial: existenciaInicial,
                stockActual: stockActual,
                stockMinimoAlerta: stockMinimoAlerta,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                required String descripcion,
                required String categoria,
                required double precioCompra,
                required double precioVenta,
                Value<double> existenciaInicial = const Value.absent(),
                required double stockActual,
                Value<double> stockMinimoAlerta = const Value.absent(),
                Value<int> activo = const Value.absent(),
              }) => ProductosPosCompanion.insert(
                id: id,
                codigoBarras: codigoBarras,
                descripcion: descripcion,
                categoria: categoria,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                existenciaInicial: existenciaInicial,
                stockActual: stockActual,
                stockMinimoAlerta: stockMinimoAlerta,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosPosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosPosTable,
      DBProductoPos,
      $$ProductosPosTableFilterComposer,
      $$ProductosPosTableOrderingComposer,
      $$ProductosPosTableAnnotationComposer,
      $$ProductosPosTableCreateCompanionBuilder,
      $$ProductosPosTableUpdateCompanionBuilder,
      (
        DBProductoPos,
        BaseReferences<_$AppDatabase, $ProductosPosTable, DBProductoPos>,
      ),
      DBProductoPos,
      PrefetchHooks Function()
    >;
typedef $$VentasPosTableCreateCompanionBuilder =
    VentasPosCompanion Function({
      Value<int> id,
      required String codigoVenta,
      required int cicloOperativoId,
      Value<int?> clienteId,
      required String tipoPago,
      required double totalVenta,
      required int fechaVenta,
      required String estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
    });
typedef $$VentasPosTableUpdateCompanionBuilder =
    VentasPosCompanion Function({
      Value<int> id,
      Value<String> codigoVenta,
      Value<int> cicloOperativoId,
      Value<int?> clienteId,
      Value<String> tipoPago,
      Value<double> totalVenta,
      Value<int> fechaVenta,
      Value<String> estado,
      Value<int?> fechaAnulacion,
      Value<String?> motivoAnulacion,
    });

class $$VentasPosTableFilterComposer
    extends Composer<_$AppDatabase, $VentasPosTable> {
  $$VentasPosTableFilterComposer({
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

  ColumnFilters<String> get codigoVenta => $composableBuilder(
    column: $table.codigoVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoPago => $composableBuilder(
    column: $table.tipoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasPosTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasPosTable> {
  $$VentasPosTableOrderingComposer({
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

  ColumnOrderings<String> get codigoVenta => $composableBuilder(
    column: $table.codigoVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoPago => $composableBuilder(
    column: $table.tipoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasPosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasPosTable> {
  $$VentasPosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoVenta => $composableBuilder(
    column: $table.codigoVenta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cicloOperativoId => $composableBuilder(
    column: $table.cicloOperativoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get tipoPago =>
      $composableBuilder(column: $table.tipoPago, builder: (column) => column);

  GeneratedColumn<double> get totalVenta => $composableBuilder(
    column: $table.totalVenta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaVenta => $composableBuilder(
    column: $table.fechaVenta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get fechaAnulacion => $composableBuilder(
    column: $table.fechaAnulacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivoAnulacion => $composableBuilder(
    column: $table.motivoAnulacion,
    builder: (column) => column,
  );
}

class $$VentasPosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasPosTable,
          DBVentaPos,
          $$VentasPosTableFilterComposer,
          $$VentasPosTableOrderingComposer,
          $$VentasPosTableAnnotationComposer,
          $$VentasPosTableCreateCompanionBuilder,
          $$VentasPosTableUpdateCompanionBuilder,
          (
            DBVentaPos,
            BaseReferences<_$AppDatabase, $VentasPosTable, DBVentaPos>,
          ),
          DBVentaPos,
          PrefetchHooks Function()
        > {
  $$VentasPosTableTableManager(_$AppDatabase db, $VentasPosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasPosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasPosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasPosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codigoVenta = const Value.absent(),
                Value<int> cicloOperativoId = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                Value<String> tipoPago = const Value.absent(),
                Value<double> totalVenta = const Value.absent(),
                Value<int> fechaVenta = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
              }) => VentasPosCompanion(
                id: id,
                codigoVenta: codigoVenta,
                cicloOperativoId: cicloOperativoId,
                clienteId: clienteId,
                tipoPago: tipoPago,
                totalVenta: totalVenta,
                fechaVenta: fechaVenta,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codigoVenta,
                required int cicloOperativoId,
                Value<int?> clienteId = const Value.absent(),
                required String tipoPago,
                required double totalVenta,
                required int fechaVenta,
                required String estado,
                Value<int?> fechaAnulacion = const Value.absent(),
                Value<String?> motivoAnulacion = const Value.absent(),
              }) => VentasPosCompanion.insert(
                id: id,
                codigoVenta: codigoVenta,
                cicloOperativoId: cicloOperativoId,
                clienteId: clienteId,
                tipoPago: tipoPago,
                totalVenta: totalVenta,
                fechaVenta: fechaVenta,
                estado: estado,
                fechaAnulacion: fechaAnulacion,
                motivoAnulacion: motivoAnulacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasPosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasPosTable,
      DBVentaPos,
      $$VentasPosTableFilterComposer,
      $$VentasPosTableOrderingComposer,
      $$VentasPosTableAnnotationComposer,
      $$VentasPosTableCreateCompanionBuilder,
      $$VentasPosTableUpdateCompanionBuilder,
      (DBVentaPos, BaseReferences<_$AppDatabase, $VentasPosTable, DBVentaPos>),
      DBVentaPos,
      PrefetchHooks Function()
    >;
typedef $$VentasPosDetallesTableCreateCompanionBuilder =
    VentasPosDetallesCompanion Function({
      Value<int> id,
      required int ventaPosId,
      required int productoPosId,
      required double cantidad,
      required double precioUnitarioHistorico,
      required double subtotal,
    });
typedef $$VentasPosDetallesTableUpdateCompanionBuilder =
    VentasPosDetallesCompanion Function({
      Value<int> id,
      Value<int> ventaPosId,
      Value<int> productoPosId,
      Value<double> cantidad,
      Value<double> precioUnitarioHistorico,
      Value<double> subtotal,
    });

class $$VentasPosDetallesTableFilterComposer
    extends Composer<_$AppDatabase, $VentasPosDetallesTable> {
  $$VentasPosDetallesTableFilterComposer({
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

  ColumnFilters<int> get ventaPosId => $composableBuilder(
    column: $table.ventaPosId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoPosId => $composableBuilder(
    column: $table.productoPosId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitarioHistorico => $composableBuilder(
    column: $table.precioUnitarioHistorico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasPosDetallesTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasPosDetallesTable> {
  $$VentasPosDetallesTableOrderingComposer({
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

  ColumnOrderings<int> get ventaPosId => $composableBuilder(
    column: $table.ventaPosId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoPosId => $composableBuilder(
    column: $table.productoPosId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitarioHistorico => $composableBuilder(
    column: $table.precioUnitarioHistorico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasPosDetallesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasPosDetallesTable> {
  $$VentasPosDetallesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ventaPosId => $composableBuilder(
    column: $table.ventaPosId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productoPosId => $composableBuilder(
    column: $table.productoPosId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get precioUnitarioHistorico => $composableBuilder(
    column: $table.precioUnitarioHistorico,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);
}

class $$VentasPosDetallesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasPosDetallesTable,
          DBVentaPosDetalle,
          $$VentasPosDetallesTableFilterComposer,
          $$VentasPosDetallesTableOrderingComposer,
          $$VentasPosDetallesTableAnnotationComposer,
          $$VentasPosDetallesTableCreateCompanionBuilder,
          $$VentasPosDetallesTableUpdateCompanionBuilder,
          (
            DBVentaPosDetalle,
            BaseReferences<
              _$AppDatabase,
              $VentasPosDetallesTable,
              DBVentaPosDetalle
            >,
          ),
          DBVentaPosDetalle,
          PrefetchHooks Function()
        > {
  $$VentasPosDetallesTableTableManager(
    _$AppDatabase db,
    $VentasPosDetallesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasPosDetallesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasPosDetallesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasPosDetallesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaPosId = const Value.absent(),
                Value<int> productoPosId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double> precioUnitarioHistorico = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => VentasPosDetallesCompanion(
                id: id,
                ventaPosId: ventaPosId,
                productoPosId: productoPosId,
                cantidad: cantidad,
                precioUnitarioHistorico: precioUnitarioHistorico,
                subtotal: subtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaPosId,
                required int productoPosId,
                required double cantidad,
                required double precioUnitarioHistorico,
                required double subtotal,
              }) => VentasPosDetallesCompanion.insert(
                id: id,
                ventaPosId: ventaPosId,
                productoPosId: productoPosId,
                cantidad: cantidad,
                precioUnitarioHistorico: precioUnitarioHistorico,
                subtotal: subtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasPosDetallesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasPosDetallesTable,
      DBVentaPosDetalle,
      $$VentasPosDetallesTableFilterComposer,
      $$VentasPosDetallesTableOrderingComposer,
      $$VentasPosDetallesTableAnnotationComposer,
      $$VentasPosDetallesTableCreateCompanionBuilder,
      $$VentasPosDetallesTableUpdateCompanionBuilder,
      (
        DBVentaPosDetalle,
        BaseReferences<
          _$AppDatabase,
          $VentasPosDetallesTable,
          DBVentaPosDetalle
        >,
      ),
      DBVentaPosDetalle,
      PrefetchHooks Function()
    >;
typedef $$LotesSecadoTableCreateCompanionBuilder =
    LotesSecadoCompanion Function({
      Value<int> id,
      Value<int?> clienteId,
      required String tipoCafeInicial,
      required double pesoInicialHumedo,
      required double precioEstimadoInicial,
      required int fechaInicio,
      Value<int?> fechaFinalizacion,
      Value<double?> pesoSecoObtenido,
      Value<double?> mermaCalculada,
      Value<double?> porcentajeRendimiento,
      required String estado,
    });
typedef $$LotesSecadoTableUpdateCompanionBuilder =
    LotesSecadoCompanion Function({
      Value<int> id,
      Value<int?> clienteId,
      Value<String> tipoCafeInicial,
      Value<double> pesoInicialHumedo,
      Value<double> precioEstimadoInicial,
      Value<int> fechaInicio,
      Value<int?> fechaFinalizacion,
      Value<double?> pesoSecoObtenido,
      Value<double?> mermaCalculada,
      Value<double?> porcentajeRendimiento,
      Value<String> estado,
    });

class $$LotesSecadoTableFilterComposer
    extends Composer<_$AppDatabase, $LotesSecadoTable> {
  $$LotesSecadoTableFilterComposer({
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

  ColumnFilters<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCafeInicial => $composableBuilder(
    column: $table.tipoCafeInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoInicialHumedo => $composableBuilder(
    column: $table.pesoInicialHumedo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioEstimadoInicial => $composableBuilder(
    column: $table.precioEstimadoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoSecoObtenido => $composableBuilder(
    column: $table.pesoSecoObtenido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mermaCalculada => $composableBuilder(
    column: $table.mermaCalculada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get porcentajeRendimiento => $composableBuilder(
    column: $table.porcentajeRendimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotesSecadoTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesSecadoTable> {
  $$LotesSecadoTableOrderingComposer({
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

  ColumnOrderings<int> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCafeInicial => $composableBuilder(
    column: $table.tipoCafeInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoInicialHumedo => $composableBuilder(
    column: $table.pesoInicialHumedo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioEstimadoInicial => $composableBuilder(
    column: $table.precioEstimadoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoSecoObtenido => $composableBuilder(
    column: $table.pesoSecoObtenido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mermaCalculada => $composableBuilder(
    column: $table.mermaCalculada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get porcentajeRendimiento => $composableBuilder(
    column: $table.porcentajeRendimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesSecadoTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesSecadoTable> {
  $$LotesSecadoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get tipoCafeInicial => $composableBuilder(
    column: $table.tipoCafeInicial,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoInicialHumedo => $composableBuilder(
    column: $table.pesoInicialHumedo,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioEstimadoInicial => $composableBuilder(
    column: $table.precioEstimadoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaInicio => $composableBuilder(
    column: $table.fechaInicio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaFinalizacion => $composableBuilder(
    column: $table.fechaFinalizacion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pesoSecoObtenido => $composableBuilder(
    column: $table.pesoSecoObtenido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mermaCalculada => $composableBuilder(
    column: $table.mermaCalculada,
    builder: (column) => column,
  );

  GeneratedColumn<double> get porcentajeRendimiento => $composableBuilder(
    column: $table.porcentajeRendimiento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$LotesSecadoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesSecadoTable,
          DBLoteSecado,
          $$LotesSecadoTableFilterComposer,
          $$LotesSecadoTableOrderingComposer,
          $$LotesSecadoTableAnnotationComposer,
          $$LotesSecadoTableCreateCompanionBuilder,
          $$LotesSecadoTableUpdateCompanionBuilder,
          (
            DBLoteSecado,
            BaseReferences<_$AppDatabase, $LotesSecadoTable, DBLoteSecado>,
          ),
          DBLoteSecado,
          PrefetchHooks Function()
        > {
  $$LotesSecadoTableTableManager(_$AppDatabase db, $LotesSecadoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesSecadoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesSecadoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesSecadoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                Value<String> tipoCafeInicial = const Value.absent(),
                Value<double> pesoInicialHumedo = const Value.absent(),
                Value<double> precioEstimadoInicial = const Value.absent(),
                Value<int> fechaInicio = const Value.absent(),
                Value<int?> fechaFinalizacion = const Value.absent(),
                Value<double?> pesoSecoObtenido = const Value.absent(),
                Value<double?> mermaCalculada = const Value.absent(),
                Value<double?> porcentajeRendimiento = const Value.absent(),
                Value<String> estado = const Value.absent(),
              }) => LotesSecadoCompanion(
                id: id,
                clienteId: clienteId,
                tipoCafeInicial: tipoCafeInicial,
                pesoInicialHumedo: pesoInicialHumedo,
                precioEstimadoInicial: precioEstimadoInicial,
                fechaInicio: fechaInicio,
                fechaFinalizacion: fechaFinalizacion,
                pesoSecoObtenido: pesoSecoObtenido,
                mermaCalculada: mermaCalculada,
                porcentajeRendimiento: porcentajeRendimiento,
                estado: estado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> clienteId = const Value.absent(),
                required String tipoCafeInicial,
                required double pesoInicialHumedo,
                required double precioEstimadoInicial,
                required int fechaInicio,
                Value<int?> fechaFinalizacion = const Value.absent(),
                Value<double?> pesoSecoObtenido = const Value.absent(),
                Value<double?> mermaCalculada = const Value.absent(),
                Value<double?> porcentajeRendimiento = const Value.absent(),
                required String estado,
              }) => LotesSecadoCompanion.insert(
                id: id,
                clienteId: clienteId,
                tipoCafeInicial: tipoCafeInicial,
                pesoInicialHumedo: pesoInicialHumedo,
                precioEstimadoInicial: precioEstimadoInicial,
                fechaInicio: fechaInicio,
                fechaFinalizacion: fechaFinalizacion,
                pesoSecoObtenido: pesoSecoObtenido,
                mermaCalculada: mermaCalculada,
                porcentajeRendimiento: porcentajeRendimiento,
                estado: estado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotesSecadoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesSecadoTable,
      DBLoteSecado,
      $$LotesSecadoTableFilterComposer,
      $$LotesSecadoTableOrderingComposer,
      $$LotesSecadoTableAnnotationComposer,
      $$LotesSecadoTableCreateCompanionBuilder,
      $$LotesSecadoTableUpdateCompanionBuilder,
      (
        DBLoteSecado,
        BaseReferences<_$AppDatabase, $LotesSecadoTable, DBLoteSecado>,
      ),
      DBLoteSecado,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      required String usuario,
      required String accion,
      required String detalle,
      required int fechaEvento,
      required String origen,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      Value<String> usuario,
      Value<String> accion,
      Value<String> detalle,
      Value<int> fechaEvento,
      Value<String> origen,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<String> get usuario => $composableBuilder(
    column: $table.usuario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaEvento => $composableBuilder(
    column: $table.fechaEvento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<String> get usuario => $composableBuilder(
    column: $table.usuario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaEvento => $composableBuilder(
    column: $table.fechaEvento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get usuario =>
      $composableBuilder(column: $table.usuario, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get detalle =>
      $composableBuilder(column: $table.detalle, builder: (column) => column);

  GeneratedColumn<int> get fechaEvento => $composableBuilder(
    column: $table.fechaEvento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          DBAuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (
            DBAuditLog,
            BaseReferences<_$AppDatabase, $AuditLogsTable, DBAuditLog>,
          ),
          DBAuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> usuario = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String> detalle = const Value.absent(),
                Value<int> fechaEvento = const Value.absent(),
                Value<String> origen = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                usuario: usuario,
                accion: accion,
                detalle: detalle,
                fechaEvento: fechaEvento,
                origen: origen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String usuario,
                required String accion,
                required String detalle,
                required int fechaEvento,
                required String origen,
              }) => AuditLogsCompanion.insert(
                id: id,
                usuario: usuario,
                accion: accion,
                detalle: detalle,
                fechaEvento: fechaEvento,
                origen: origen,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      DBAuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (DBAuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, DBAuditLog>),
      DBAuditLog,
      PrefetchHooks Function()
    >;
typedef $$LicenciaTableCreateCompanionBuilder =
    LicenciaCompanion Function({
      required int id,
      required String dispositivoId,
      required int fechaVencimiento,
      required String planActual,
      Value<int> rowid,
    });
typedef $$LicenciaTableUpdateCompanionBuilder =
    LicenciaCompanion Function({
      Value<int> id,
      Value<String> dispositivoId,
      Value<int> fechaVencimiento,
      Value<String> planActual,
      Value<int> rowid,
    });

class $$LicenciaTableFilterComposer
    extends Composer<_$AppDatabase, $LicenciaTable> {
  $$LicenciaTableFilterComposer({
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

  ColumnFilters<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planActual => $composableBuilder(
    column: $table.planActual,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenciaTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenciaTable> {
  $$LicenciaTableOrderingComposer({
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

  ColumnOrderings<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planActual => $composableBuilder(
    column: $table.planActual,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenciaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenciaTable> {
  $$LicenciaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dispositivoId => $composableBuilder(
    column: $table.dispositivoId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planActual => $composableBuilder(
    column: $table.planActual,
    builder: (column) => column,
  );
}

class $$LicenciaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenciaTable,
          DBLicencia,
          $$LicenciaTableFilterComposer,
          $$LicenciaTableOrderingComposer,
          $$LicenciaTableAnnotationComposer,
          $$LicenciaTableCreateCompanionBuilder,
          $$LicenciaTableUpdateCompanionBuilder,
          (
            DBLicencia,
            BaseReferences<_$AppDatabase, $LicenciaTable, DBLicencia>,
          ),
          DBLicencia,
          PrefetchHooks Function()
        > {
  $$LicenciaTableTableManager(_$AppDatabase db, $LicenciaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenciaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenciaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenciaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dispositivoId = const Value.absent(),
                Value<int> fechaVencimiento = const Value.absent(),
                Value<String> planActual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenciaCompanion(
                id: id,
                dispositivoId: dispositivoId,
                fechaVencimiento: fechaVencimiento,
                planActual: planActual,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String dispositivoId,
                required int fechaVencimiento,
                required String planActual,
                Value<int> rowid = const Value.absent(),
              }) => LicenciaCompanion.insert(
                id: id,
                dispositivoId: dispositivoId,
                fechaVencimiento: fechaVencimiento,
                planActual: planActual,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenciaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenciaTable,
      DBLicencia,
      $$LicenciaTableFilterComposer,
      $$LicenciaTableOrderingComposer,
      $$LicenciaTableAnnotationComposer,
      $$LicenciaTableCreateCompanionBuilder,
      $$LicenciaTableUpdateCompanionBuilder,
      (DBLicencia, BaseReferences<_$AppDatabase, $LicenciaTable, DBLicencia>),
      DBLicencia,
      PrefetchHooks Function()
    >;
typedef $$PinesCanjeadosTableCreateCompanionBuilder =
    PinesCanjeadosCompanion Function({
      Value<int> id,
      required String pin,
      required String tipo,
      required int dias,
      required int fechaCanje,
    });
typedef $$PinesCanjeadosTableUpdateCompanionBuilder =
    PinesCanjeadosCompanion Function({
      Value<int> id,
      Value<String> pin,
      Value<String> tipo,
      Value<int> dias,
      Value<int> fechaCanje,
    });

class $$PinesCanjeadosTableFilterComposer
    extends Composer<_$AppDatabase, $PinesCanjeadosTable> {
  $$PinesCanjeadosTableFilterComposer({
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

  ColumnFilters<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dias => $composableBuilder(
    column: $table.dias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fechaCanje => $composableBuilder(
    column: $table.fechaCanje,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinesCanjeadosTableOrderingComposer
    extends Composer<_$AppDatabase, $PinesCanjeadosTable> {
  $$PinesCanjeadosTableOrderingComposer({
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

  ColumnOrderings<String> get pin => $composableBuilder(
    column: $table.pin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dias => $composableBuilder(
    column: $table.dias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fechaCanje => $composableBuilder(
    column: $table.fechaCanje,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinesCanjeadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinesCanjeadosTable> {
  $$PinesCanjeadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pin =>
      $composableBuilder(column: $table.pin, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get dias =>
      $composableBuilder(column: $table.dias, builder: (column) => column);

  GeneratedColumn<int> get fechaCanje => $composableBuilder(
    column: $table.fechaCanje,
    builder: (column) => column,
  );
}

class $$PinesCanjeadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinesCanjeadosTable,
          DBPinCanjeado,
          $$PinesCanjeadosTableFilterComposer,
          $$PinesCanjeadosTableOrderingComposer,
          $$PinesCanjeadosTableAnnotationComposer,
          $$PinesCanjeadosTableCreateCompanionBuilder,
          $$PinesCanjeadosTableUpdateCompanionBuilder,
          (
            DBPinCanjeado,
            BaseReferences<_$AppDatabase, $PinesCanjeadosTable, DBPinCanjeado>,
          ),
          DBPinCanjeado,
          PrefetchHooks Function()
        > {
  $$PinesCanjeadosTableTableManager(
    _$AppDatabase db,
    $PinesCanjeadosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinesCanjeadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinesCanjeadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinesCanjeadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pin = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> dias = const Value.absent(),
                Value<int> fechaCanje = const Value.absent(),
              }) => PinesCanjeadosCompanion(
                id: id,
                pin: pin,
                tipo: tipo,
                dias: dias,
                fechaCanje: fechaCanje,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pin,
                required String tipo,
                required int dias,
                required int fechaCanje,
              }) => PinesCanjeadosCompanion.insert(
                id: id,
                pin: pin,
                tipo: tipo,
                dias: dias,
                fechaCanje: fechaCanje,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinesCanjeadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinesCanjeadosTable,
      DBPinCanjeado,
      $$PinesCanjeadosTableFilterComposer,
      $$PinesCanjeadosTableOrderingComposer,
      $$PinesCanjeadosTableAnnotationComposer,
      $$PinesCanjeadosTableCreateCompanionBuilder,
      $$PinesCanjeadosTableUpdateCompanionBuilder,
      (
        DBPinCanjeado,
        BaseReferences<_$AppDatabase, $PinesCanjeadosTable, DBPinCanjeado>,
      ),
      DBPinCanjeado,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CiclosOperativosTableTableManager get ciclosOperativos =>
      $$CiclosOperativosTableTableManager(_db, _db.ciclosOperativos);
  $$CajasTableTableManager get cajas =>
      $$CajasTableTableManager(_db, _db.cajas);
  $$CierresCajaTableTableManager get cierresCaja =>
      $$CierresCajaTableTableManager(_db, _db.cierresCaja);
  $$MovimientosCajaTableTableManager get movimientosCaja =>
      $$MovimientosCajaTableTableManager(_db, _db.movimientosCaja);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$LotesBodegaTableTableManager get lotesBodega =>
      $$LotesBodegaTableTableManager(_db, _db.lotesBodega);
  $$TransaccionesTableTableManager get transacciones =>
      $$TransaccionesTableTableManager(_db, _db.transacciones);
  $$LiquidacionesTableTableManager get liquidaciones =>
      $$LiquidacionesTableTableManager(_db, _db.liquidaciones);
  $$PrestamosTableTableManager get prestamos =>
      $$PrestamosTableTableManager(_db, _db.prestamos);
  $$AbonosTableTableManager get abonos =>
      $$AbonosTableTableManager(_db, _db.abonos);
  $$AbonosDetallesTableTableManager get abonosDetalles =>
      $$AbonosDetallesTableTableManager(_db, _db.abonosDetalles);
  $$ProductosPosTableTableManager get productosPos =>
      $$ProductosPosTableTableManager(_db, _db.productosPos);
  $$VentasPosTableTableManager get ventasPos =>
      $$VentasPosTableTableManager(_db, _db.ventasPos);
  $$VentasPosDetallesTableTableManager get ventasPosDetalles =>
      $$VentasPosDetallesTableTableManager(_db, _db.ventasPosDetalles);
  $$LotesSecadoTableTableManager get lotesSecado =>
      $$LotesSecadoTableTableManager(_db, _db.lotesSecado);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$LicenciaTableTableManager get licencia =>
      $$LicenciaTableTableManager(_db, _db.licencia);
  $$PinesCanjeadosTableTableManager get pinesCanjeados =>
      $$PinesCanjeadosTableTableManager(_db, _db.pinesCanjeados);
}
