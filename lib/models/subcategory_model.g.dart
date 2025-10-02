// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubCategoryAdapter extends TypeAdapter<SubCategory> {
  @override
  final int typeId = 2;

  @override
  SubCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubCategory(
      id: fields[0] as int,
      parentCategoryId: fields[1] as int,
      name: fields[2] as String,
      monthlyBudget: fields[3] as double,
      spent: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SubCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parentCategoryId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.monthlyBudget)
      ..writeByte(4)
      ..write(obj.spent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
