import 'package:sqflite/sqflite.dart';

class UserDatabase {

  //region DB CONSTANTS

  static const String TBL_USER = 'MatrimonyUsers';

  static const String USER_ID = 'UserID';
  static const String NAME = 'Name';
  static const String EMAIL = 'Email';
  static const String PHONE = 'Phone';
  static const String DOB = 'DOB';
  static const String AGE = 'Age';
  static const String CITY = 'City';
  static const String GENDER = 'Gender';
  static const String HOBBIES = 'Hobbies';
  static const String IMAGE = 'Image';
  static const String IS_FAVOURITE = 'isFavourite';
  static const String RELIGION = 'Religion';
  static const String LOOKING_FOR = 'LookingFor';
  static const String MARITAL_STATUS = 'MaritalStatus';
  static const String MOTHER_TONGUE = 'MotherTongue';
  static const String BIO = 'Bio';
  static const String PASSWORD = 'Password';

  int DB_VERSION = 7;

  //endregion

  //region INIT DATABASE

  Future<Database> initDatabase() async {
    Database db = await openDatabase(
      '${await getDatabasesPath()}/Matrimony.db',
      version: DB_VERSION,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $TBL_USER ('
              '$USER_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
              '$NAME TEXT NOT NULL, '
              '$EMAIL TEXT NOT NULL, '
              '$PHONE INTEGER NOT NULL, '
              '$DOB TEXT, '
              '$AGE INTEGER NOT NULL, '
              '$CITY TEXT NOT NULL, '
              '$GENDER TEXT NOT NULL, '
              '$HOBBIES TEXT, '
              '$IMAGE TEXT, '
              '$IS_FAVOURITE INTEGER NOT NULL, '
              '$RELIGION TEXT NOT NULL, '
              '$LOOKING_FOR TEXT NOT NULL, '
              '$MARITAL_STATUS TEXT NOT NULL, '
              '$MOTHER_TONGUE TEXT NOT NULL, '
              '$BIO TEXT NOT NULL,'
              '$PASSWORD TEXT NOT NULL);',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < DB_VERSION) {
          await db.execute('DROP TABLE IF EXISTS $TBL_USER;');
          await db.execute(
            'CREATE TABLE $TBL_USER ('
                '$USER_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
                '$NAME TEXT NOT NULL, '
                '$EMAIL TEXT NOT NULL, '
                '$PHONE INTEGER NOT NULL, '
                '$DOB TEXT NOT NULL, '
                '$AGE INTEGER NOT NULL, '
                '$CITY TEXT NOT NULL, '
                '$GENDER TEXT NOT NULL, '
                '$HOBBIES TEXT, '
                '$IMAGE TEXT, '
                '$IS_FAVOURITE INTEGER NOT NULL, '
                '$RELIGION TEXT NOT NULL, '
                '$LOOKING_FOR TEXT NOT NULL, '
                '$MARITAL_STATUS TEXT NOT NULL, '
                '$MOTHER_TONGUE TEXT NOT NULL, '
                '$BIO TEXT,'
                '$PASSWORD TEXT NOT NULL);',
          );

          print("Database upgraded from $oldVersion to $newVersion: Dropped and recreated MatrimonyUsers table.");
        }
      },
    );
    return db;
  }

  //endregion

}