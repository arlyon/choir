// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'database_helper.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NewOrExistingUser {
  String get id => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(String id, String name, String? email) create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? email)? create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? email)? create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingUser value) existing,
    required TResult Function(CreateUser value) create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingUser value)? existing,
    TResult? Function(CreateUser value)? create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingUser value)? existing,
    TResult Function(CreateUser value)? create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewOrExistingUserCopyWith<NewOrExistingUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewOrExistingUserCopyWith<$Res> {
  factory $NewOrExistingUserCopyWith(
    NewOrExistingUser value,
    $Res Function(NewOrExistingUser) then,
  ) = _$NewOrExistingUserCopyWithImpl<$Res, NewOrExistingUser>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$NewOrExistingUserCopyWithImpl<$Res, $Val extends NewOrExistingUser>
    implements $NewOrExistingUserCopyWith<$Res> {
  _$NewOrExistingUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExistingUserImplCopyWith<$Res>
    implements $NewOrExistingUserCopyWith<$Res> {
  factory _$$ExistingUserImplCopyWith(
    _$ExistingUserImpl value,
    $Res Function(_$ExistingUserImpl) then,
  ) = __$$ExistingUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$ExistingUserImplCopyWithImpl<$Res>
    extends _$NewOrExistingUserCopyWithImpl<$Res, _$ExistingUserImpl>
    implements _$$ExistingUserImplCopyWith<$Res> {
  __$$ExistingUserImplCopyWithImpl(
    _$ExistingUserImpl _value,
    $Res Function(_$ExistingUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$ExistingUserImpl(
        null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ExistingUserImpl with DiagnosticableTreeMixin implements ExistingUser {
  const _$ExistingUserImpl(this.id);

  @override
  final String id;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NewOrExistingUser.existing(id: $id)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NewOrExistingUser.existing'))
      ..add(DiagnosticsProperty('id', id));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExistingUserImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExistingUserImplCopyWith<_$ExistingUserImpl> get copyWith =>
      __$$ExistingUserImplCopyWithImpl<_$ExistingUserImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(String id, String name, String? email) create,
  }) {
    return existing(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? email)? create,
  }) {
    return existing?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? email)? create,
    required TResult orElse(),
  }) {
    if (existing != null) {
      return existing(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingUser value) existing,
    required TResult Function(CreateUser value) create,
  }) {
    return existing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingUser value)? existing,
    TResult? Function(CreateUser value)? create,
  }) {
    return existing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingUser value)? existing,
    TResult Function(CreateUser value)? create,
    required TResult orElse(),
  }) {
    if (existing != null) {
      return existing(this);
    }
    return orElse();
  }
}

abstract class ExistingUser implements NewOrExistingUser {
  const factory ExistingUser(final String id) = _$ExistingUserImpl;

  @override
  String get id;

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExistingUserImplCopyWith<_$ExistingUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreateUserImplCopyWith<$Res>
    implements $NewOrExistingUserCopyWith<$Res> {
  factory _$$CreateUserImplCopyWith(
    _$CreateUserImpl value,
    $Res Function(_$CreateUserImpl) then,
  ) = __$$CreateUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? email});
}

/// @nodoc
class __$$CreateUserImplCopyWithImpl<$Res>
    extends _$NewOrExistingUserCopyWithImpl<$Res, _$CreateUserImpl>
    implements _$$CreateUserImplCopyWith<$Res> {
  __$$CreateUserImplCopyWithImpl(
    _$CreateUserImpl _value,
    $Res Function(_$CreateUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? email = freezed}) {
    return _then(
      _$CreateUserImpl(
        null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                as String,
        freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc

class _$CreateUserImpl with DiagnosticableTreeMixin implements CreateUser {
  const _$CreateUserImpl(this.id, this.name, this.email);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? email;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NewOrExistingUser.create(id: $id, name: $name, email: $email)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NewOrExistingUser.create'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('email', email));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateUserImplCopyWith<_$CreateUserImpl> get copyWith =>
      __$$CreateUserImplCopyWithImpl<_$CreateUserImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(String id, String name, String? email) create,
  }) {
    return create(id, name, email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? email)? create,
  }) {
    return create?.call(id, name, email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? email)? create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(id, name, email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingUser value) existing,
    required TResult Function(CreateUser value) create,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingUser value)? existing,
    TResult? Function(CreateUser value)? create,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingUser value)? existing,
    TResult Function(CreateUser value)? create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class CreateUser implements NewOrExistingUser {
  const factory CreateUser(
    final String id,
    final String name,
    final String? email,
  ) = _$CreateUserImpl;

  @override
  String get id;
  String get name;
  String? get email;

  /// Create a copy of NewOrExistingUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateUserImplCopyWith<_$CreateUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NewOrExistingWork {
  String get id => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(
      String id,
      String name,
      String? composer,
      int? instance,
    )
    create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? composer, int? instance)?
    create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? composer, int? instance)?
    create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingWork value) existing,
    required TResult Function(CreateWork value) create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingWork value)? existing,
    TResult? Function(CreateWork value)? create,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingWork value)? existing,
    TResult Function(CreateWork value)? create,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewOrExistingWorkCopyWith<NewOrExistingWork> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewOrExistingWorkCopyWith<$Res> {
  factory $NewOrExistingWorkCopyWith(
    NewOrExistingWork value,
    $Res Function(NewOrExistingWork) then,
  ) = _$NewOrExistingWorkCopyWithImpl<$Res, NewOrExistingWork>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$NewOrExistingWorkCopyWithImpl<$Res, $Val extends NewOrExistingWork>
    implements $NewOrExistingWorkCopyWith<$Res> {
  _$NewOrExistingWorkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExistingWorkImplCopyWith<$Res>
    implements $NewOrExistingWorkCopyWith<$Res> {
  factory _$$ExistingWorkImplCopyWith(
    _$ExistingWorkImpl value,
    $Res Function(_$ExistingWorkImpl) then,
  ) = __$$ExistingWorkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$ExistingWorkImplCopyWithImpl<$Res>
    extends _$NewOrExistingWorkCopyWithImpl<$Res, _$ExistingWorkImpl>
    implements _$$ExistingWorkImplCopyWith<$Res> {
  __$$ExistingWorkImplCopyWithImpl(
    _$ExistingWorkImpl _value,
    $Res Function(_$ExistingWorkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null}) {
    return _then(
      _$ExistingWorkImpl(
        null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ExistingWorkImpl with DiagnosticableTreeMixin implements ExistingWork {
  const _$ExistingWorkImpl(this.id);

  @override
  final String id;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NewOrExistingWork.existing(id: $id)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NewOrExistingWork.existing'))
      ..add(DiagnosticsProperty('id', id));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExistingWorkImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExistingWorkImplCopyWith<_$ExistingWorkImpl> get copyWith =>
      __$$ExistingWorkImplCopyWithImpl<_$ExistingWorkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(
      String id,
      String name,
      String? composer,
      int? instance,
    )
    create,
  }) {
    return existing(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? composer, int? instance)?
    create,
  }) {
    return existing?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? composer, int? instance)?
    create,
    required TResult orElse(),
  }) {
    if (existing != null) {
      return existing(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingWork value) existing,
    required TResult Function(CreateWork value) create,
  }) {
    return existing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingWork value)? existing,
    TResult? Function(CreateWork value)? create,
  }) {
    return existing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingWork value)? existing,
    TResult Function(CreateWork value)? create,
    required TResult orElse(),
  }) {
    if (existing != null) {
      return existing(this);
    }
    return orElse();
  }
}

abstract class ExistingWork implements NewOrExistingWork {
  const factory ExistingWork(final String id) = _$ExistingWorkImpl;

  @override
  String get id;

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExistingWorkImplCopyWith<_$ExistingWorkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CreateWorkImplCopyWith<$Res>
    implements $NewOrExistingWorkCopyWith<$Res> {
  factory _$$CreateWorkImplCopyWith(
    _$CreateWorkImpl value,
    $Res Function(_$CreateWorkImpl) then,
  ) = __$$CreateWorkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? composer, int? instance});
}

/// @nodoc
class __$$CreateWorkImplCopyWithImpl<$Res>
    extends _$NewOrExistingWorkCopyWithImpl<$Res, _$CreateWorkImpl>
    implements _$$CreateWorkImplCopyWith<$Res> {
  __$$CreateWorkImplCopyWithImpl(
    _$CreateWorkImpl _value,
    $Res Function(_$CreateWorkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? composer = freezed,
    Object? instance = freezed,
  }) {
    return _then(
      _$CreateWorkImpl(
        null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                as String,
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                as String,
        freezed == composer
            ? _value.composer
            : composer // ignore: cast_nullable_to_non_nullable
                as String?,
        freezed == instance
            ? _value.instance
            : instance // ignore: cast_nullable_to_non_nullable
                as int?,
      ),
    );
  }
}

/// @nodoc

class _$CreateWorkImpl with DiagnosticableTreeMixin implements CreateWork {
  const _$CreateWorkImpl(this.id, this.name, this.composer, this.instance);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? composer;
  @override
  final int? instance;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NewOrExistingWork.create(id: $id, name: $name, composer: $composer, instance: $instance)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NewOrExistingWork.create'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('composer', composer))
      ..add(DiagnosticsProperty('instance', instance));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateWorkImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.composer, composer) ||
                other.composer == composer) &&
            (identical(other.instance, instance) ||
                other.instance == instance));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, composer, instance);

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateWorkImplCopyWith<_$CreateWorkImpl> get copyWith =>
      __$$CreateWorkImplCopyWithImpl<_$CreateWorkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String id) existing,
    required TResult Function(
      String id,
      String name,
      String? composer,
      int? instance,
    )
    create,
  }) {
    return create(id, name, composer, instance);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id)? existing,
    TResult? Function(String id, String name, String? composer, int? instance)?
    create,
  }) {
    return create?.call(id, name, composer, instance);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id)? existing,
    TResult Function(String id, String name, String? composer, int? instance)?
    create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(id, name, composer, instance);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ExistingWork value) existing,
    required TResult Function(CreateWork value) create,
  }) {
    return create(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ExistingWork value)? existing,
    TResult? Function(CreateWork value)? create,
  }) {
    return create?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ExistingWork value)? existing,
    TResult Function(CreateWork value)? create,
    required TResult orElse(),
  }) {
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class CreateWork implements NewOrExistingWork {
  const factory CreateWork(
    final String id,
    final String name,
    final String? composer,
    final int? instance,
  ) = _$CreateWorkImpl;

  @override
  String get id;
  String get name;
  String? get composer;
  int? get instance;

  /// Create a copy of NewOrExistingWork
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateWorkImplCopyWith<_$CreateWorkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
