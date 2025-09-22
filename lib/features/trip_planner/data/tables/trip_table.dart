import 'package:drift/drift.dart';

class TripTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get tripId => text().withLength(min: 1, max: 50).unique()();
  
  DateTimeColumn get date => dateTime()();
  
  TextColumn get assignedVehicleId => text().withLength(min: 1, max: 50).nullable()();
  
  TextColumn get assignedOrderIds => text().map(const OrderIdsConverter())();
  
  IntColumn get statusIndex => integer()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class OrderIdsConverter extends TypeConverter<List<String>, String> {
  const OrderIdsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}
