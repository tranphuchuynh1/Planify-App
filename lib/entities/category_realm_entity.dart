import 'package:realm/realm.dart';  // import realm package

@RealmModel()
class $_CategoryRealmEntity {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late int? iconCodePoint;
  late String? backgroundColorHex;
  late String? iconColorHex;

}