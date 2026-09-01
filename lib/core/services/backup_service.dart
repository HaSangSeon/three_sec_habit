import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../database/database_helper.dart';

/// 데이터 백업(내보내기) 및 복원(가져오기) 서비스
class BackupService {
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// 1. 데이터 백업 (JSON 파일 생성 후 공유/저장 창 호출)
  static Future<Map<String, dynamic>> exportBackup() async {
    try {
      final db = await _dbHelper.database;

      // 습관 및 로그 데이터 조회
      final habits = await db.query(AppConstants.tableHabits);
      final logs = await db.query(AppConstants.tableHabitLogs);

      final now = DateTime.now();
      final dateFormatted =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

      final backupData = {
        'app': 'three_sec_habit',
        'schema_version': AppConstants.dbVersion,
        'exported_at': now.toIso8601String(),
        'habit_count': habits.length,
        'log_count': logs.length,
        'habits': habits,
        'habit_logs': logs,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // 캐시/임시 디렉토리에 백업 파일 쓰기
      final tempDir = await getTemporaryDirectory();
      final fileName = 'three_sec_habit_backup_$dateFormatted.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 공유 다이얼로그 호출 (구글 드라이브, 카카오톡, 메일, 파일 앱 등에 파일 전송 가능)
      final xFile = XFile(file.path, mimeType: 'application/json', name: fileName);
      final shareResult = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          subject: '3초 습관 백업 파일 ($fileName)',
          text: '3초 습관 앱의 백업 데이터입니다. 새 기기에서 [데이터 복원]을 통해 복구할 수 있습니다.',
        ),
      );

      return {
        'success': true,
        'habitCount': habits.length,
        'logCount': logs.length,
        'fileName': fileName,
        'shared': shareResult.status == ShareResultStatus.success,
      };
    } catch (e) {
      debugPrint('Backup export error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 2. 데이터 복원 (사용자가 선택한 JSON 파일로부터 복구)
  static Future<Map<String, dynamic>> importBackup() async {
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (pickedFiles.isEmpty) {
        return {'cancelled': true};
      }

      final file = pickedFiles.first;
      String jsonContent;

      if (file.path != null && file.path!.isNotEmpty) {
        jsonContent = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        jsonContent = utf8.decode(bytes);
      }

      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic> || decoded['app'] != 'three_sec_habit') {
        return {
          'success': false,
          'error': '유효한 3초 습관 백업 파일이 아닙니다.',
        };
      }

      final rawHabits = (decoded['habits'] as List<dynamic>?) ?? [];
      final rawLogs = (decoded['habit_logs'] as List<dynamic>?) ?? [];

      final db = await _dbHelper.database;

      int restoredHabits = 0;
      int restoredLogs = 0;

      // 트랜잭션으로 안전하게 기존 데이터 대체 및 외래키 맵핑 복원
      await db.transaction((txn) async {
        // 기존 데이터 정리
        await txn.delete(AppConstants.tableHabitLogs);
        await txn.delete(AppConstants.tableHabits);

        final oldToNewIdMap = <int, int>{};

        for (final item in rawHabits) {
          if (item is Map<String, dynamic>) {
            final habitMap = Map<String, dynamic>.from(item);
            final oldId = habitMap['id'] as int?;
            habitMap.remove('id'); // 자동 증가 생성

            final newId = await txn.insert(AppConstants.tableHabits, habitMap);
            if (oldId != null) {
              oldToNewIdMap[oldId] = newId;
            }
            restoredHabits++;
          }
        }

        for (final item in rawLogs) {
          if (item is Map<String, dynamic>) {
            final logMap = Map<String, dynamic>.from(item);
            final oldHabitId = logMap['habit_id'] as int?;
            final newHabitId = oldToNewIdMap[oldHabitId];

            if (newHabitId != null) {
              logMap.remove('id');
              logMap['habit_id'] = newHabitId;
              await txn.insert(AppConstants.tableHabitLogs, logMap);
              restoredLogs++;
            }
          }
        }
      });

      return {
        'success': true,
        'habitCount': restoredHabits,
        'logCount': restoredLogs,
      };
    } catch (e) {
      debugPrint('Backup import error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
