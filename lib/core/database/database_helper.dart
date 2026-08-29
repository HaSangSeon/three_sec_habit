import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

/// SQLite 로컬 데이터베이스 헬퍼 (싱글톤)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// DB 인스턴스 반환 (지연 초기화)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  /// 테스트 환경 또는 특수 목적을 위해 외부 Database 주입 가능
  static void setDatabaseForTesting(Database? db) {
    _database = db;
  }

  static void resetForTesting() {
    _database = null;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  /// 외래키 제약조건 활성화 (SQLite는 기본적으로 비활성화되어 있음)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 테이블 및 인덱스 생성
  Future<void> _createDB(Database db, int version) async {
    // 1. 습관 테이블
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHabits} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        icon_name TEXT NOT NULL DEFAULT 'check_circle',
        color_value INTEGER NOT NULL DEFAULT 4287332342,
        repeat_type TEXT NOT NULL DEFAULT 'daily',
        repeat_days TEXT,
        repeat_count INTEGER,
        reminder_time TEXT,
        reminder_enabled INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. 일자별 체크 로그 테이블
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHabitLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 1,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES ${AppConstants.tableHabits} (id) ON DELETE CASCADE
      )
    ''');

    // 3. 인덱스 생성 (조회 속도 극대화)
    // 습관별 + 날짜별 유니크 인덱스 (중복 체크 방지 및 빠른 upsert/조회)
    await db.execute('''
      CREATE UNIQUE INDEX idx_habit_logs_unique
      ON ${AppConstants.tableHabitLogs} (habit_id, date)
    ''');

    // 날짜별 인덱스 (오늘 체크한 모든 습관 조회 시 O(1))
    await db.execute('''
      CREATE INDEX idx_habit_logs_date
      ON ${AppConstants.tableHabitLogs} (date)
    ''');
  }

  /// DB 연결 닫기
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
