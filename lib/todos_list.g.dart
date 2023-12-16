// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

part of 'todos_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class todoslistAdapter extends TypeAdapter<todoslist> {
  @override
  final int typeId = 1;

  @override
  todoslist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return todoslist(
      title: fields[0] as String,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, todoslist obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is todoslistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
