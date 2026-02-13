import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stacked/stacked.dart'; // ListenableServiceMixin 必需的导入
import '../../app/app.locator.dart';

import '../models/word.dart';
import '../models/study_stat.dart'; // Add import
import '../models/dictation_session.dart';
import '../utils/app_logger.dart';
import '../utils/streak_rules.dart';
import 'email_service.dart'; // Add import
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

/// 数据库服务类
/// 
/// 负责本地数据的持久化存储，包括单词库、听写记录和错题记录。
/// 
/// ## 智能推荐分数系统
/// - 使用持久化的 `recommendation_score` 进行推荐排序
/// - 分数越高，推荐优先级越高
/// - 分数在以下时机更新：
///   1. 听写完成后（答对降分，答错加分）
///   2. 阶梯学习完成后（温和降分）
///   3. 每日首次启动时（处理时间遗忘）
class DatabaseService with ListenableServiceMixin {
  final _emailService = locator<EmailService>(); // Add locator

  static Database? _database;
  static Completer<Database>? _dbCompleter;
  
  // 当前选中的词书 ID
  String _currentBookId = 'user_default';
  String get currentBookId => _currentBookId;

  /// 获取数据库实例 (单例模式)
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (_dbCompleter != null) {
      return _dbCompleter!.future;
    }

    _dbCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _dbCompleter!.complete(_database!);
      return _database!;
    } catch (e) {
      _dbCompleter!.completeError(e);
      _dbCompleter = null; // 重置以便重试
      rethrow;
    }
  }

  /// 切换当前词书
  Future<void> switchBook(String bookId) async {
    if (_currentBookId == bookId) return;
    
    _currentBookId = bookId;
    
    // 更新数据库中的激活状态
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('books', {'is_active': 0});
      await txn.update(
        'books', 
        {'is_active': 1}, 
        where: 'id = ?', 
        whereArgs: [bookId]
      );
    });
    
    notifyListeners();
  }

  /// 获取所有词书列表
  Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await database;
    // 使用子查询动态计算实际单词数量，覆盖表中的默认值
    return await db.rawQuery('''
      SELECT b.*, (SELECT COUNT(*) FROM words w WHERE w.book_id = b.id) as total_words
      FROM books b
      ORDER BY b.created_at ASC
    ''');
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dictation_pal.db');
    return await openDatabase(
      path,
      version: 14, // v14: 补签与每日奖励记录
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建表结构
  Future<void> _onCreate(Database db, int version) async {
    // 单词表 - 记录所有识别或手动输入的单词
    await db.execute('''
      CREATE TABLE words(
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        phonetic TEXT,
        meaning_full TEXT,
        meaning_for_dictation TEXT,
        sentence TEXT,
        mnemonic TEXT,
        source_image_id TEXT,
        
        -- 毕业状态（简化版，替代原三星）
        is_graduated INTEGER DEFAULT 0,
        first_mastered_at TEXT,
        
        -- 智能推荐字段
        recommendation_score REAL DEFAULT 0,
        last_reviewed_at TEXT,
        last_learning_session_at TEXT,
        score_updated_at TEXT,
        
        -- 历史统计
        wrong_count INTEGER DEFAULT 0,
        is_in_mistake_book INTEGER DEFAULT 0,
        total_reviews INTEGER DEFAULT 0,
        
        -- 跟读功能
        shadowing_url TEXT,
        shadowing_attempts INTEGER DEFAULT 0,
        
        -- 云同步
        last_modified INTEGER,
        is_synced INTEGER DEFAULT 0,
        
        -- 多词书支持 (v12)
        book_id TEXT DEFAULT 'user_default',
        
        -- 元数据
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        -- 保留旧字段（兼容性，不再使用）
        mastery_a INTEGER DEFAULT 0,
        mastery_b INTEGER DEFAULT 0,
        mastery_c INTEGER DEFAULT 0,
        consecutive_correct INTEGER DEFAULT 0,
        ease_factor REAL DEFAULT 2.5
      )
    ''');
    
    // 为 word 字段创建唯一索引
    // v12 Update: 唯一索引改为 (book_id, word) 联合唯一
    await db.execute('CREATE UNIQUE INDEX idx_book_word_content ON words(book_id, word)');
    
    // 词书表 - 管理不同的词库来源
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 0,
        total_words INTEGER DEFAULT 0,
        grade_level TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // 初始化默认词书
    await db.insert('books', {
      'id': 'user_default',
      'name': '我的生词本',
      'description': '默认词书，存放手动添加的单词',
      'is_active': 1,
    });

    // 听写会话表 - 记录每次听写的总体情况
    await db.execute('''
      CREATE TABLE sessions(
        session_id TEXT PRIMARY KEY,
        mode TEXT NOT NULL,
        date TEXT NOT NULL,
        total_words INTEGER,
        score INTEGER,
        duration_seconds INTEGER
      )
    ''');

    // 错误记录表 - 记录每次听写中的具体错误
    await db.execute('''
      CREATE TABLE mistakes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT,
        word TEXT,
        student_input TEXT,
        is_correct INTEGER,
        FOREIGN KEY (session_id) REFERENCES sessions (session_id) ON DELETE CASCADE
      )
    ''');

    // 学习统计表 - 记录每次大复习的耗时详情
    await db.execute('''
      CREATE TABLE study_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        session_type TEXT,
        duration_seconds INTEGER,
        word_count INTEGER,
        start_time TEXT,
        end_time TEXT
      )
    ''');

    // 补签记录表 - 记录日历补签事件
    await db.execute('''
      CREATE TABLE retro_checkins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_key TEXT NOT NULL,
        created_at TEXT NOT NULL,
        points_cost INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_retro_checkins_date ON retro_checkins(date_key)');

    // 每日奖励记录表 - 防止重复发放
    await db.execute('''
      CREATE TABLE daily_rewards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_key TEXT NOT NULL,
        type TEXT NOT NULL,
        points INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_rewards_date_type ON daily_rewards(date_key, type)');
    
    // 初始化 KET 词汇
    await _loadKetWords(db);
  }

  /// 数据库升级处理
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 为旧版本用户补全唯一索引
      try {
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_word_content ON words(word)');
      } catch (e) {
        AppLogger.w('创建排重索引失败 (可能已存在重复数据)', error: e);
      }
    }

    if (oldVersion < 3) {
      // 升级到版本 3：增加掌握度列（旧设计）
      await _safeAddColumn(db, 'words', 'mastery_a INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'words', 'mastery_b INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'words', 'mastery_c INTEGER DEFAULT 0');
    }

    if (oldVersion < 4) {
      // 升级到版本 4: 智能复习全家桶（旧设计）
      await _safeAddColumn(db, 'words', 'last_reviewed_at TEXT');
      await _safeAddColumn(db, 'words', 'first_mastered_at TEXT');
      await _safeAddColumn(db, 'words', 'consecutive_correct INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'words', 'ease_factor REAL DEFAULT 2.5');
      await _safeAddColumn(db, 'words', 'total_reviews INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'words', 'wrong_count INTEGER DEFAULT 0');
    }

    if (oldVersion < 5) {
      // 升级到版本 5: 增加记忆法字段
      await _safeAddColumn(db, 'words', 'mnemonic TEXT');
    }

    if (oldVersion < 6) {
      // 升级到版本 6: 智能推荐分数系统
      await _safeAddColumn(db, 'words', 'is_graduated INTEGER DEFAULT 0');
      await _safeAddColumn(db, 'words', 'recommendation_score REAL DEFAULT 0');
      await _safeAddColumn(db, 'words', 'last_learning_session_at TEXT');
      await _safeAddColumn(db, 'words', 'score_updated_at TEXT');
      
      // 数据迁移：将旧的三星状态转换为 is_graduated
      // 判定已毕业条件：三星全部填满 (mastery_a = 1 且 mastery_b = 1 且 mastery_c = 1)
      await db.execute('''
        UPDATE words 
        SET is_graduated = CASE 
          WHEN mastery_a = 1 AND mastery_b = 1 AND mastery_c = 1 THEN 1 
          ELSE 0 
        END
      ''');
      
      // 初始化所有单词的分数
      await _initializeAllScores(db);
    }

    if (oldVersion < 7) {
      // 升级到版本 7: 数据统计
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_stats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          session_type TEXT,
          duration_seconds INTEGER,
          word_count INTEGER,
          start_time TEXT,
          end_time TEXT
        )
      ''');
    }

    if (oldVersion < 8) {
      // 升级到版本 8: 精准统计每日新词 (first_learned_at)
      await _safeAddColumn(db, 'words', 'first_learned_at TEXT');
    }

    if (oldVersion < 9) {
      // 升级到版本 9: 为sessions表添加完成时长字段
      await _safeAddColumn(db, 'sessions', 'duration_seconds INTEGER');
    }

    if (oldVersion < 10) {
      // 升级到版本 10: 添加错题本动态标记字段
      await _safeAddColumn(db, 'words', 'is_in_mistake_book INTEGER DEFAULT 0');
      
      // 数据迁移：将现有的未毕业错题标记为在错题本中
      // 逻辑：wrong_count > 0 AND is_graduated = 0 → is_in_mistake_book = 1
      await db.execute('''
        UPDATE words 
        SET is_in_mistake_book = 1 
        WHERE wrong_count > 0 AND is_graduated = 0
      ''');
      
      AppLogger.i('数据库升级到v10：添加错题本动态标记，已迁移现有错题数据');
    }

    if (oldVersion < 11) {
      // 升级到版本 11: 强制修复 study_stats 表缺失问题
      await db.execute('''
        CREATE TABLE IF NOT EXISTS study_stats(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          session_type TEXT,
          duration_seconds INTEGER,
          word_count INTEGER,
          start_time TEXT,
          end_time TEXT
        )
      ''');
      AppLogger.i('数据库升级到v11：确保 study_stats 表存在');
    }
    
    if (oldVersion < 12) {
      // 升级到版本 12: 多词书支持
      AppLogger.i('开始升级数据库到 v12 (多词书支持)...');
      
      // 1. 创建 books 表
      await db.execute('''
        CREATE TABLE books(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          is_active INTEGER DEFAULT 0,
          total_words INTEGER DEFAULT 0,
          grade_level TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      // 2. 为 words 表添加 book_id列
      await _safeAddColumn(db, 'words', "book_id TEXT DEFAULT 'user_default'");
      
      // 3. 升级索引：从 word 唯一 改为 (book_id, word) 联合唯一
      try {
        await db.execute('DROP INDEX IF EXISTS idx_word_content');
        await db.execute('CREATE UNIQUE INDEX idx_book_word_content ON words(book_id, word)');
      } catch (e) {
        AppLogger.w('索引迁移警告', error: e);
      }
      
      // 4. 初始化默认词书
      await db.insert('books', {
        'id': 'user_default',
        'name': '我的生词本',
        'description': '默认词书，存放手动添加的单词',
        'is_active': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      
      // 5. 导入 KET 词汇
      await _loadKetWords(db);
    }
    
    if (oldVersion < 13) {
      // 升级到版本 13: 推荐分数模型 v2.0
      // 将旧分数范围 [0, 3000+] 转换为新范围 [0, 2.0]
      AppLogger.i('开始升级数据库到 v13 (推荐分数模型 v2.0)...');
      
      final now = DateTime.now();
      final nowStr = now.toIso8601String();
      final words = await db.query('words');
      
      for (var row in words) {
        final isGraduated = row['is_graduated'] == 1 || 
            (row['mastery_a'] == 1 && row['mastery_b'] == 1 && row['mastery_c'] == 1);
        
        double newScore;
        
        if (!isGraduated) {
          // 未毕业词（含新词）：固定 1.0
          newScore = 1.0;
        } else {
          // 已毕业词：基础 0.4，并计算时间因子
          newScore = 0.4;
          
          final lastReviewedStr = row['last_reviewed_at'] as String?;
          final totalReviews = (row['total_reviews'] as int?) ?? 0;
          
          if (lastReviewedStr != null) {
            final lastReviewed = DateTime.tryParse(lastReviewedStr);
            if (lastReviewed != null) {
              final daysSince = now.difference(lastReviewed).inDays;
              
              // 计算推荐间隔
              int recommendedInterval;
              if (totalReviews <= 1) {
                recommendedInterval = 1;
              } else if (totalReviews == 2) {
                recommendedInterval = 3;
              } else if (totalReviews == 3) {
                recommendedInterval = 7;
              } else if (totalReviews == 4) {
                recommendedInterval = 15;
              } else {
                recommendedInterval = 30;
              }
              
              if (daysSince >= recommendedInterval) {
                // 已到期
                newScore += 1.0;
                final overdueDays = daysSince - recommendedInterval;
                newScore += (overdueDays * 0.1).clamp(0.0, 0.6);
              }
            }
          }
          
          // 错题因子
          final wrongCount = (row['wrong_count'] as int?) ?? 0;
          final isInMistakeBook = (row['is_in_mistake_book'] as int?) == 1;
          if (wrongCount > 0 && isInMistakeBook) {
            newScore += (wrongCount * 0.15).clamp(0.0, 0.4);
          }
          
          // 边界管理
          newScore = newScore.clamp(0.0, 2.0);
        }
        
        await db.update(
          'words',
          {
            'recommendation_score': newScore,
            'score_updated_at': nowStr,
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
      
      AppLogger.i('数据库升级到 v13 完成，已迁移 ${words.length} 个单词的分数');
    }

    if (oldVersion < 14) {
      // 升级到版本 14: 补签与每日奖励记录
      await db.execute('''
        CREATE TABLE IF NOT EXISTS retro_checkins(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date_key TEXT NOT NULL,
          created_at TEXT NOT NULL,
          points_cost INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_retro_checkins_date ON retro_checkins(date_key)');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_rewards(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date_key TEXT NOT NULL,
          type TEXT NOT NULL,
          points INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_rewards_date_type ON daily_rewards(date_key, type)');
      AppLogger.i('数据库升级到v14：新增补签与每日奖励记录表');
    }
  }

  /// [Migration Helper] 导入 KET 词汇
  Future<void> _loadKetWords(Database db) async {
    try {
      AppLogger.i('正在导入 KET 核心词汇...');
      // 1. 读取 CSV 文件
      final csvString = await rootBundle.loadString('assets/data/danci.csv');
      // 2. 解析 CSV
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString, eol: '\n');
      
      if (rows.isEmpty) return;
      
      // 3. 创建 KET 词书记录
      const ketBookId = 'ket_core';
      await db.insert('books', {
        'id': ketBookId,
        'name': 'KET核心词汇',
        'description': '剑桥通用英语第一级核心词汇',
        'is_active': 0, // 默认不激活，让用户手动切换
        'total_words': rows.length - 1, // 减去表头
        'grade_level': 'KET'
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      
      // 4. 批量插入单词
      final batch = db.batch();
      final nowStr = DateTime.now().toIso8601String();
      final uuid = Uuid();
      
      int count = 0;
      // 跳过表头 (第一行)
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 4) continue;
        
        // CSV 结构: 单词,音标,词性,中文释义,例句,记忆法
        final wordText = row[0].toString().trim();
        if (wordText.isEmpty) continue;
        
        final phonetic = row[1].toString().trim();
        // 此处不再单独存储词性，直接拼接到释义或忽略
        // 简单处理：meaning_full = "词性 释义" 或者就是释义
        // 这里假设 danci.csv 的第3列是词性，第4列是释义
        final partOfSpeech = row[2].toString().trim(); 
        final meaning = row[3].toString().trim();
        final fullMeaning = '$partOfSpeech $meaning';
        
        final sentence = row[4].toString().trim();
        final mnemonic = row.length > 5 ? row[5].toString().trim() : '';

        batch.insert('words', {
          'id': uuid.v4(), // 生成新的 UUID
          'word': wordText,
          'phonetic': phonetic,
          'meaning_full': fullMeaning,
          'meaning_for_dictation': meaning, // 听写用简化释义
          'sentence': sentence,
          'mnemonic': mnemonic,
          'book_id': ketBookId,
          
          // 默认状态
          'is_graduated': 0,
          'recommendation_score': 0.0, 
          'wrong_count': 0,
          'is_in_mistake_book': 0,
          'total_reviews': 0,
          'created_at': nowStr,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        
        count++;
      }
      
      await batch.commit(noResult: true);
      AppLogger.i('KET 词汇导入完成，共导入 $count 个单词');
      
    } catch (e) {
      AppLogger.e('导入 KET 词汇失败', error: e);
      // 不抛出异常，以免阻断整个数据库升级
    }
  }

  /// 初始化所有单词的推荐分数（迁移用）
  Future<void> _initializeAllScores(Database db) async {
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    final words = await db.query('words');
    for (var row in words) {
      final score = _calculateScoreFromRow(row, now);
      await db.update(
        'words',
        {
          'recommendation_score': score,
          'score_updated_at': nowStr,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  /// 从数据库行计算分数（v2.0 极简模型）
  /// 
  /// ## 分数范围：[0, 2.0]
  /// - 未毕业词（含新词）：固定 1.0
  /// - 已毕业词：0.4 + Time因子 + 错题因子
  /// 
  /// ## 分数语义
  /// - [0.0-0.6]：深度掌握区（刚学完，不推荐）
  /// - [0.6-1.2]：巩固区（正常复习）
  /// - [1.2-1.6]：学习区（新词或到期词）
  /// - [1.6-2.0]：紧急区（严重逾期或难词）
  double _calculateScoreFromRow(Map<String, dynamic> row, DateTime now) {
    final isGraduated = row['is_graduated'] == 1 || 
        (row['mastery_a'] == 1 && row['mastery_b'] == 1 && row['mastery_c'] == 1);

    // ========== 1. 未毕业词（含新词）：固定锚点 1.0 ==========
    if (!isGraduated) {
      return 1.0;
    }
    
    // ========== 2. 已毕业词：基础分 0.4 ==========
    double score = 0.4;
    
    // ========== 3. 时间因子（艾宾浩斯曲线）==========
    final lastReviewedStr = row['last_reviewed_at'] as String?;
    final totalReviews = (row['total_reviews'] as int?) ?? 0;
    
    if (lastReviewedStr != null) {
      final lastReviewed = DateTime.tryParse(lastReviewedStr);
      if (lastReviewed != null) {
        final daysSince = now.difference(lastReviewed).inDays;
        
        // 计算推荐间隔（艾宾浩斯简化模型）
        int recommendedInterval;
        if (totalReviews <= 1) {
          recommendedInterval = 1;  // 第1次复习后，隔1天
        } else if (totalReviews == 2) {
          recommendedInterval = 3;  // 第2次，隔3天
        } else if (totalReviews == 3) {
          recommendedInterval = 7;  // 第3次，隔1周
        } else if (totalReviews == 4) {
          recommendedInterval = 15; // 第4次，隔半月
        } else {
          recommendedInterval = 30; // 之后每月一次
        }

        if (daysSince >= recommendedInterval) {
          // 📈 已到期：基础+1.0，保证超过新词(1.0)
          score += 1.0;
          // 逾期加成：每天 +0.1，上限0.6
          final overdueDays = daysSince - recommendedInterval;
          score += (overdueDays * 0.1).clamp(0.0, 0.6);
        }
        // 未到期：不加分，保持0.4沉底
      }
    }
    
    // ========== 4. 历史错题因子（轻量加成）==========
    // 基于历史出错次数，不依赖错题本标记
    // 逻辑：曾经错过的词更容易再次遗忘，需要更频繁复习
    final wrongCount = (row['wrong_count'] as int?) ?? 0;
    
    if (wrongCount > 0) {
      // 历史错题：每错1次 +0.1，上限0.3
      score += (wrongCount * 0.1).clamp(0.0, 0.3);
    }
    
    // ========== 5. 边界管理 ==========
    return score.clamp(0.0, 2.0);
  }

  /// 辅助方法：安全添加列 (忽略已存在的列错误)
  Future<void> _safeAddColumn(Database db, String table, String columnDef) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDef');
    } catch (e) {
      // SQLite 不支持 IF NOT EXISTS 用于 ADD COLUMN，所以我们捕获异常
      AppLogger.d('迁移信息：列可能已经存在', error: e);
    }
  }



  // ============================================================
  // 单词管理 (Words)
  // ============================================================

  /// 保存单个单词
  Future<void> saveWord(Word word) async {
    final db = await database;
    final data = word.toJson();
    final now = DateTime.now();
    
    // 计算初始推荐分数
    final score = word.recommendationScore > 0 
        ? word.recommendationScore 
        : _calculateInitialScore(word);
    
    await db.insert(
      'words',
      {
        'id': data['id'],
        'word': data['word'],
        'phonetic': data['phonetic'],
        'meaning_full': data['meaning_full'],
        'meaning_for_dictation': data['meaning_for_dictation'],
        'sentence': data['sentence'],
        'mnemonic': data['mnemonic'],
        'source_image_id': data['sourceImageId'],
        'is_graduated': (data['is_graduated'] == true) ? 1 : 0,
        'first_mastered_at': data['first_mastered_at'],
        'recommendation_score': score,
        'last_reviewed_at': data['last_reviewed_at'],
        'last_learning_session_at': data['last_learning_session_at'],
        'first_learned_at': data['first_learned_at'],
        'score_updated_at': now.toIso8601String(),
        'wrong_count': data['wrong_count'] ?? 0,
        'is_in_mistake_book': (data['is_in_mistake_book'] == true) ? 1 : 0,
        'total_reviews': data['total_reviews'] ?? 0,
        'shadowing_url': data['shadowing_url'],
        'shadowing_attempts': data['shadowing_attempts'] ?? 0,
        'last_modified': data['last_modified'],
        'is_synced': (data['is_synced'] == true) ? 1 : 0,
        'book_id': data['book_id'], // Ensure book_id is preserved
        // 兼容旧字段
        'mastery_a': (data['is_graduated'] == true) ? 1 : 0,
        'mastery_b': (data['is_graduated'] == true) ? 1 : 0,
        'mastery_c': (data['is_graduated'] == true) ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  /// 计算新词的初始分数（v2.0 模型）
  double _calculateInitialScore(Word word) {
    // 新词/未毕业：固定锚点 1.0
    return 1.0;
  }

  /// 批量保存单词
  Future<void> saveWords(List<Word> words) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    for (var word in words) {
      final data = word.toJson();
      final score = word.recommendationScore > 0 
          ? word.recommendationScore 
          : _calculateInitialScore(word);
      
      batch.insert(
        'words',
        {
          'id': data['id'],
          'word': data['word'],
          'phonetic': data['phonetic'],
          'meaning_full': data['meaning_full'],
          'meaning_for_dictation': data['meaning_for_dictation'],
          'sentence': data['sentence'],
          'mnemonic': data['mnemonic'],
          'source_image_id': data['sourceImageId'],
          'is_graduated': (data['is_graduated'] == true) ? 1 : 0,
          'first_mastered_at': data['first_mastered_at'],
          'recommendation_score': score,
          'last_reviewed_at': data['last_reviewed_at'],
          'last_learning_session_at': data['last_learning_session_at'],
          'first_learned_at': data['first_learned_at'],
          'score_updated_at': nowStr,
          'wrong_count': data['wrong_count'] ?? 0,
          'is_in_mistake_book': (data['is_in_mistake_book'] == true) ? 1 : 0,
          'total_reviews': data['total_reviews'] ?? 0,
          'shadowing_url': data['shadowing_url'],
          'shadowing_attempts': data['shadowing_attempts'] ?? 0,
          'last_modified': data['last_modified'],
          'is_synced': (data['is_synced'] == true) ? 1 : 0,
          'book_id': data['book_id'], // Ensure book_id is preserved
          // 兼容旧字段
          'mastery_a': (data['is_graduated'] == true) ? 1 : 0,
          'mastery_b': (data['is_graduated'] == true) ? 1 : 0,
          'mastery_c': (data['is_graduated'] == true) ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    notifyListeners();
  }

  /// 获取所有单词 (当前词书)
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words', 
      where: 'book_id = ?',
      whereArgs: [_currentBookId],
      orderBy: 'created_at DESC'
    );
    return maps.map((m) {
      final mutableMap = Map<String, dynamic>.from(m);
      _mapDbToModel(mutableMap);
      return Word.fromJson(mutableMap);
    }).toList();
  }

  /// 搜索单词 (当前词书)
  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'word LIKE ? AND book_id = ?',
      whereArgs: ['%$query%', _currentBookId],
    );
    return maps.map((m) {
      final mutableMap = Map<String, dynamic>.from(m);
      _mapDbToModel(mutableMap);
      return Word.fromJson(mutableMap);
    }).toList();
  }

  /// 删除单词
  Future<void> deleteWord(String wordId) async {
    final db = await database;
    await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [wordId],
    );
    notifyListeners();
  }

  /// 更新单词（编辑拼写/释义）
  Future<void> updateWord(Word word) async {
    final db = await database;
    await db.update(
      'words',
      {
        'word': word.word,
        'phonetic': word.phonetic,
        'meaning_full': word.meaningFull,
        'meaning_for_dictation': word.meaningForDictation,
        'sentence': word.sentence,
        'mnemonic': word.mnemonic,
      },
      where: 'id = ?',
      whereArgs: [word.id],
    );
    notifyListeners();
  }

  // ============================================================
  // 听写会话管理 (Sessions)
  // ============================================================

  /// 保存听写会话和结果(智能推荐分数系统)
  /// 
  /// 核心逻辑:
  /// - 答对:分数 -50,标记毕业
  /// - 答错:分数 +100,取消毕业,wrong_count++
  /// 
  /// [durationSeconds] 可选参数,记录完成该会话所花费的时间(秒)
  Future<void> saveSession(
    DictationSession session, 
    SessionResult result, 
    {int? durationSeconds}
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. 保存会话元数据
      await txn.insert('sessions', {
        'session_id': session.sessionId,
        'mode': session.mode.toString().split('.').last,
        'date': session.date,
        'total_words': result.total,
        'score': result.score,
        'duration_seconds': durationSeconds,
      });

      // 2. 构建快速查找 Map
      final mistakeMap = {
        for (var m in result.mistakes) m.word.toLowerCase(): m
      };

      // 3. 准备批量更新单词状态
      final now = DateTime.now();
      final nowStr = now.toIso8601String();
      
      for (var wordObj in session.words) {
        final key = wordObj.word.toLowerCase();
        bool isCorrect = true;
        String? studentInput;

        if (mistakeMap.containsKey(key)) {
          final m = mistakeMap[key]!;
          studentInput = m.studentInput;
          isCorrect = m.isCorrect;
        } else {
          studentInput = wordObj.word;
          isCorrect = true;
        }

        // A. 插入 mistakes 表记录 (现在保存所有记录，包括正确和错误)
        // if (!isCorrect || mistakeMap.containsKey(key)) { // OLD: Only save mistakes
          await txn.insert('mistakes', {
            'session_id': session.sessionId,
            'word': wordObj.word,
            'student_input': studentInput,
            'is_correct': isCorrect ? 1 : 0,
          });
        // }

        // B. 更新 Words 表
        final List<Map<String, dynamic>> currentWordRows = await txn.query(
          'words', 
          where: 'id = ?', 
          whereArgs: [wordObj.id]
        );
        
        if (currentWordRows.isNotEmpty) {
          final currentData = currentWordRows.first;
          
          int wrongCount = (currentData['wrong_count'] as int?) ?? 0;
          int totalReviews = (currentData['total_reviews'] as int?) ?? 0;
          double currentScore = (currentData['recommendation_score'] as num?)?.toDouble() ?? 0;
          bool isGraduated = currentData['is_graduated'] == 1;
          String? firstMasteredAt = currentData['first_mastered_at'] as String?;
          String? firstLearnedAt = currentData['first_learned_at'] as String?;
          
          totalReviews++;

          // [New] 首次学习时间记录 (如果是第1次复习，说明是这次变成1的，但听写可能直接增加totalReviews)
          // 听写通常不是"新学"，但如果是第一次听写这个词，也算"掌握"
          if (firstLearnedAt == null && totalReviews == 1) {
             firstLearnedAt = nowStr;
          }
          
          bool isInMistakeBook = false; // 默认为 false，下面会根据结果设置

          if (isCorrect) {
            // ✅ 答对：直接赋值 0.4（深度掌握区）
            currentScore = 0.4;
            isGraduated = true;
            isInMistakeBook = false; // 答对移出错题本
            
            // 首次毕业记录
            firstMasteredAt ??= nowStr;
          } else {
            // ❌ 答错：直接赋值 2.0（紧急区置顶）
            currentScore = 2.0;
            wrongCount++; // 历史记录增加
            isGraduated = false;
            isInMistakeBook = true; // 答错进入错题本
          }
          
          // 确保分数不为负
          if (currentScore < 0) currentScore = 0;

          // 更新数据库
          await txn.update(
            'words',
            {
              'is_graduated': isGraduated ? 1 : 0,
              'is_in_mistake_book': isInMistakeBook ? 1 : 0, // ✅由于是动态标记，每次听写都更新
              'first_mastered_at': firstMasteredAt,
              'first_learned_at': firstLearnedAt,
              'recommendation_score': currentScore,
              'last_reviewed_at': nowStr,
              'score_updated_at': nowStr,
              'wrong_count': wrongCount,
              'total_reviews': totalReviews,
              // 兼容旧字段
              'mastery_a': isGraduated ? 1 : 0,
              'mastery_b': isGraduated ? 1 : 0,
              'mastery_c': isGraduated ? 1 : 0,
            },
            where: 'id = ?',
            whereArgs: [wordObj.id],
          );
        }
      }
    });
    // Automatically send email report.
    // Use unawaited/fire-and-forget to avoid blocking UI.
    try {
      // _emailService is initialized at class level via locator
      _emailService.sendSessionReport(session, result);
    } catch (e) {
      AppLogger.w('Failed to trigger email report', error: e);
    }

    notifyListeners();
  }

  /// 阶梯学习完成后更新分数（v2.0 模型）
  /// 
  /// 效果：直接赋值 0.6（巩固区），标记已毕业
  Future<void> updateScoreAfterLearningSession(List<Word> words) async {
    final db = await database;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    for (var word in words) {
      final rows = await db.query('words', where: 'id = ?', whereArgs: [word.id]);
      if (rows.isNotEmpty) {
        final currentData = rows.first;
        double currentScore = (currentData['recommendation_score'] as num?)?.toDouble() ?? 0;
        int totalReviews = (currentData['total_reviews'] as int?) ?? 0;
        String? firstLearnedAt = currentData['first_learned_at'] as String?;
        
        // ✅ 阶梯学习完成：直接赋值 0.6（巩固区）
        currentScore = 0.6;
        totalReviews++;
        
        // [New] 首次学习时间记录
        if (firstLearnedAt == null && totalReviews == 1) {
           firstLearnedAt = nowStr;
        }
        
        await db.update(
          'words',
          {
            'recommendation_score': currentScore,
            'is_graduated': 1,
            'is_in_mistake_book': 0, // ✅ 学习完成，移出错题本
            'last_reviewed_at': nowStr,
            'last_learning_session_at': nowStr,
            'first_learned_at': firstLearnedAt,
            'score_updated_at': nowStr,
            'total_reviews': totalReviews,
          },
          where: 'id = ?',
          whereArgs: [word.id],
        );
      }
    }
    notifyListeners();
  }

  /// 每日刷新所有单词的分数（v2.0 模型）\n  /// \n  /// ## 核心逻辑\n  /// - 未毕业词：保持固定 1.0（不受时间影响）\n  /// - 已毕业词：根据距上次复习时间重新计算\n  /// \n  /// 调用时机：App 启动时检查，如果是新的一天则执行
  Future<void> refreshDailyScores() async {
    final db = await database;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    // 只更新当前词书的单词
    final words = await db.query(
      'words',
      where: 'book_id = ?',
      whereArgs: [_currentBookId],
    );
    
    for (var row in words) {
      final score = _calculateScoreFromRow(row, now);
      await db.update(
        'words',
        {
          'recommendation_score': score,
          'score_updated_at': nowStr,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    notifyListeners();
  }

  /// 检查是否需要每日刷新
  Future<bool> needsDailyRefresh() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT MAX(score_updated_at) as last_update FROM words
    ''');
    
    if (result.isEmpty || result.first['last_update'] == null) {
      return true;
    }
    
    final lastUpdateStr = result.first['last_update'] as String;
    final lastUpdate = DateTime.tryParse(lastUpdateStr);
    if (lastUpdate == null) return true;
    
    final now = DateTime.now();
    // 检查是否是新的一天
    return now.year != lastUpdate.year || 
           now.month != lastUpdate.month || 
           now.day != lastUpdate.day;
  }

  /// 获取历史会话列表
  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    final db = await database;
    return await db.query('sessions', orderBy: 'date DESC');
  }

  // ============================================================
  // 补签与每日奖励 (Retro Check-ins & Daily Rewards)
  // ============================================================

  Future<Set<String>> getRetroCheckinDates() async {
    final db = await database;
    final rows = await db.query('retro_checkins', columns: ['date_key']);
    return rows.map((row) => row['date_key'] as String).toSet();
  }

  Future<bool> hasRetroCheckin(String dateKey) async {
    final db = await database;
    final rows = await db.query(
      'retro_checkins',
      columns: ['id'],
      where: 'date_key = ?',
      whereArgs: [dateKey],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> getRetroCheckinCountForMonth(DateTime date) async {
    final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM retro_checkins WHERE substr(created_at, 1, 7) = ?',
      [monthKey],
    );
    if (result.isEmpty) return 0;
    return (result.first['count'] as int?) ?? 0;
  }

  Future<bool> insertRetroCheckin(String dateKey, int pointsCost) async {
    final db = await database;
    final nowStr = DateTime.now().toIso8601String();
    final insertedId = await db.insert(
      'retro_checkins',
      {
        'date_key': dateKey,
        'created_at': nowStr,
        'points_cost': pointsCost,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return insertedId > 0;
  }

  Future<bool> hasDailyReward(String dateKey, String type) async {
    final db = await database;
    final rows = await db.query(
      'daily_rewards',
      columns: ['id'],
      where: 'date_key = ? AND type = ?',
      whereArgs: [dateKey, type],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> insertDailyReward(String dateKey, String type, int points) async {
    final db = await database;
    final nowStr = DateTime.now().toIso8601String();
    final insertedId = await db.insert(
      'daily_rewards',
      {
        'date_key': dateKey,
        'type': type,
        'points': points,
        'created_at': nowStr,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return insertedId > 0;
  }

  Future<Map<DictationMode, int>> getModeWordCountsForDateKey(String dateKey) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT mode, SUM(total_words) as total_words FROM sessions WHERE substr(date, 1, 10) = ? GROUP BY mode',
      [dateKey],
    );
    final counts = <DictationMode, int>{};
    for (final row in rows) {
      final rawMode = row['mode'] as String?;
      final mode = parseDictationMode(rawMode);
      final total = (row['total_words'] as num?)?.toInt() ?? 0;
      counts[mode] = (counts[mode] ?? 0) + total;
    }
    return counts;
  }

  Future<bool> isGoldEligibleForDateKey(String dateKey) async {
    final counts = await getModeWordCountsForDateKey(dateKey);
    final a = counts[DictationMode.modeA] ?? 0;
    final b = counts[DictationMode.modeB] ?? 0;
    final c = counts[DictationMode.modeC] ?? 0;
    final total = a + b + c;
    return a >= StreakRules.goldPerModeWordThreshold &&
        b >= StreakRules.goldPerModeWordThreshold &&
        c >= StreakRules.goldPerModeWordThreshold &&
        total >= StreakRules.goldTotalWordThreshold;
  }

  /// 获取特定会话的详细记录 (包括正确和错误的条目)
  /// 
  /// 返回 List<Mistake>，其中 Mistake 对象代表一次答题记录
  Future<List<Mistake>> getSessionItems(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mistakes',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return maps.map((m) => Mistake(
      word: m['word'],
      studentInput: m['student_input'],
      isCorrect: m['is_correct'] == 1,
    )).toList();
  }

  // ============================================================
  // 智能推荐系统
  // ============================================================

  /// 获取错题本单词
  /// 
  /// 逻辑：is_in_mistake_book = 1（动态标记）
  /// - 答错时进入错题本（is_in_mistake_book = 1）
  /// - 答对时移出错题本（is_in_mistake_book = 0）
  /// - wrongCount 保留历史记录，用于权重计算
  Future<List<Word>> getMistakenWords() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'is_in_mistake_book = 1 AND book_id = ?',
      whereArgs: [_currentBookId],
      orderBy: 'wrong_count DESC',  // 按错误次数降序，顽固错题优先
    );
    
    return maps.map((m) {
      final mutableMap = Map<String, dynamic>.from(m);
      _mapDbToModel(mutableMap);
      return Word.fromJson(mutableMap);
    }).toList();
  }

  /// 获取智能复习单词列表（v2.0 混合策略）
  /// 
  /// ## 核心策略：新知 + 温故（20个/组）
  /// 1. **每日新词限额**：每天最多推荐 10 个新词。
  ///    - 如果今天已学 3 个，则本轮推荐最多再推 7 个新词。
  /// 2. **复习词补位**：剩余名额由“待复习词”填充。
  ///    - 包含：到期复习词、刚毕业需要巩固的词。
  ///    - 排序：按推荐分数降序（分数越高越紧急）。
  /// 3. **总数控制**：默认每组 20 个（可配置）。
  /// 
  /// ## 场景演练
  /// - 场景A（早晨首次）：推 10 个新词 + 10 个老词。
  /// - 场景B（二轮复习）：新词限额已用完，推 0 个新词 + 20 个老词（含刚背完的）。
  Future<List<Word>> getSmartReviewWords({int limit = 20}) async {
    final db = await database;
    
    // 1. 计算今日已学新词数 (用于控制每日上限)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final todayNewCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM words WHERE first_learned_at >= ? AND book_id = ?',
      [todayStart, _currentBookId]
    )) ?? 0;

    // 2. 设定本轮新词配额 (每日上限 10 - 今日已学)
    const int dailyNewSortLimit = 10;
    int newWordsQuota = dailyNewSortLimit - todayNewCount;
    if (newWordsQuota < 0) newWordsQuota = 0;
    
    // 如果 limit 小于 quota，优先满足 limit
    if (newWordsQuota > limit) newWordsQuota = limit;

    List<Word> resultWords = [];
    List<String> excludedIds = [];

    // ==========================================
    // 3. 获取新词 (New Words) - 优先填满配额
    // ==========================================
    if (newWordsQuota > 0) {
      final List<Map<String, dynamic>> newWordMaps = await db.query(
        'words',
        where: 'book_id = ? AND is_in_mistake_book = 0 AND total_reviews = 0', // total_reviews=0 才是纯新词
        whereArgs: [_currentBookId],
        limit: newWordsQuota,
      );
      
      for (var m in newWordMaps) {
        final mutableMap = Map<String, dynamic>.from(m);
        _mapDbToModel(mutableMap);
        final w = Word.fromJson(mutableMap);
        resultWords.add(w);
        excludedIds.add(w.id);
      }
    }

    // ==========================================
    // 4. 获取复习词 (Review Words) - 填补剩余空位
    // ==========================================
    int reviewQuota = limit - resultWords.length;
    
    if (reviewQuota > 0) {
      // 构造排除 ID 的 SQL 片段
      String excludeClause = '';
      if (excludedIds.isNotEmpty) {
        final placeholder = List.filled(excludedIds.length, '?').join(',');
        excludeClause = 'AND id NOT IN ($placeholder)';
      }

      final List<Map<String, dynamic>> reviewWordMaps = await db.query(
        'words',
        where: 'book_id = ? AND is_in_mistake_book = 0 AND total_reviews > 0 $excludeClause', // ✅ 修复：确保只抓"已学过的词"
        whereArgs: [_currentBookId, ...excludedIds],
        orderBy: 'recommendation_score DESC', // 核心：分数越高越优先（含刚毕业的0.6和到期的1.5）
        limit: reviewQuota,
      );

      for (var m in reviewWordMaps) {
        final mutableMap = Map<String, dynamic>.from(m);
        _mapDbToModel(mutableMap);
        resultWords.add(Word.fromJson(mutableMap));
      }
    }
    
    // 5. 打乱顺序（实现新老穿插）
    resultWords.shuffle();
    
    return resultWords;
  }

  /// 获取待复习单词数量
  Future<int> getSmartReviewCount() async {
    final db = await database;
    final result = await db.query(
      'words',
      where: 'recommendation_score > -90000 AND book_id = ?',
      whereArgs: [_currentBookId],
    );
    
    return result.length;
  }

  /// 获取词库统计数据
  /// 
  /// 返回统计字典，包含：已毕业 (mastered)、学习中 (learning)、新词 (new)、总数 (total)
  Future<Map<String, int>> getLibraryStats() async {
    final db = await database;
    
    // 已毕业
    final masteredCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM words WHERE is_graduated = 1 AND book_id = ?',
      [_currentBookId]
    )) ?? 0;

    // 新词：未毕业 + 从未复习
    final newCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM words WHERE is_graduated = 0 AND total_reviews = 0 AND book_id = ?',
      [_currentBookId]
    )) ?? 0;

    // 总数
    final totalCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM words WHERE book_id = ?',
      [_currentBookId]
    )) ?? 0;

    // 学习中 = 总数 - 已毕业 - 新词
    return {
      'mastered': masteredCount,
      'learning': totalCount - masteredCount - newCount,
      'new': newCount,
      'total': totalCount,
    };
  }

  /// P1: 获取未完全掌握的单词
  Future<List<Word>> getWordsNeedingMastery() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'is_graduated = 0 AND total_reviews > 0 AND book_id = ?',
      whereArgs: [_currentBookId],
      orderBy: 'wrong_count DESC, last_reviewed_at ASC',
    );
    return maps.map((m) {
      final mutableMap = Map<String, dynamic>.from(m);
      _mapDbToModel(mutableMap);
      return Word.fromJson(mutableMap);
    }).toList();
  }

  /// P2: 获取遗忘危机单词 (已毕业但需要复习)
  Future<List<Word>> getWordsAtRisk() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'words',
      where: 'is_graduated = 1 AND book_id = ?',
      whereArgs: [_currentBookId],
    );

    final List<Word> atRiskWords = [];
    final currentTime = DateTime.now();

    for (var row in result) {
      final lastReviewedStr = row['last_reviewed_at'] as String?;
      if (lastReviewedStr == null) {
        final mutableMap = Map<String, dynamic>.from(row);
        _mapDbToModel(mutableMap);
        atRiskWords.add(Word.fromJson(mutableMap));
        continue;
      }

      final lastReviewed = DateTime.tryParse(lastReviewedStr);
      if (lastReviewed == null) {
        final mutableMap = Map<String, dynamic>.from(row);
        _mapDbToModel(mutableMap);
        atRiskWords.add(Word.fromJson(mutableMap));
        continue;
      }

      // 超过3天未复习就算遗忘危机
      if (currentTime.difference(lastReviewed).inDays >= 3) {
        final mutableMap = Map<String, dynamic>.from(row);
        _mapDbToModel(mutableMap);
        atRiskWords.add(Word.fromJson(mutableMap));
      }
    }
    return atRiskWords;
  }

  /// P3: 获取可巩固单词 (已毕业且稳固，随机抽取)
  Future<List<Word>> getStableWords({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM words 
      WHERE is_graduated = 1 AND book_id = ?
      ORDER BY RANDOM()
      LIMIT ?
    ''', [_currentBookId, limit]);
    return maps.map((m) {
      final mutableMap = Map<String, dynamic>.from(m);
      _mapDbToModel(mutableMap);
      return Word.fromJson(mutableMap);
    }).toList();
  }

  /// 获取智能复习推荐 (综合三层策略)
  Future<Map<String, List<Word>>> getReviewRecommendations() async {
    final needingMastery = await getWordsNeedingMastery();
    final atRisk = await getWordsAtRisk();
    final stable = await getStableWords(limit: 5);

    return {
      'needingMastery': needingMastery,
      'atRisk': atRisk,
      'stable': stable,
    };
  }

  // ============================================================
  // 数据统计 (Study Stats)
  // ============================================================

  /// 插入学习统计记录
  Future<void> insertStudyStat(StudyStat stat) async {
    final db = await database;
    await db.insert(
      'study_stats',
      stat.toJson()..remove('id'), // 让数据库自动生成 ID
    );
    notifyListeners();
  }

  /// 获取指定日期范围的学习统计
  Future<List<StudyStat>> getStudyStats({DateTime? start, DateTime? end}) async {
    final db = await database;
    
    String? whereClause;
    List<dynamic>? whereArgs;

    if (start != null && end != null) {
      whereClause = 'date >= ? AND date <= ?';
      // 简单的字符串比较 (yyyy-MM-dd)
      whereArgs = [
        start.toIso8601String().split('T')[0],
        end.toIso8601String().split('T')[0]
      ];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'study_stats',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_time ASC',
    );

    return maps.map((m) => StudyStat.fromJson(m)).toList();
  }

  /// 获取当日完成的会话组数 (用于任务饱和度统计)
  /// filterType: 可选，如 'smart_review'
  Future<int> getDailyCompletedSessionsCount(DateTime date, {String? filterType}) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    String sql = 'SELECT COUNT(*) FROM study_stats WHERE date = ?';
    List<dynamic> args = [dateStr];

    if (filterType != null) {
      sql += ' AND session_type = ?';
      args.add(filterType);
    }

    return Sqflite.firstIntValue(await db.rawQuery(sql, args)) ?? 0;
  }

  /// 导出所有数据（用于备份）
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    
    return {
      'metadata': {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': 14, // DB Version
      },
      'books': await db.query('books'),
      'words': await db.query('words'),
      'sessions': await db.query('sessions'),
      'mistakes': await db.query('mistakes'),
      'study_stats': await db.query('study_stats'),
      'retro_checkins': await db.query('retro_checkins'),
      'daily_rewards': await db.query('daily_rewards'),
    };
  }

  // ============================================================
  // 兼容性方法（保留旧接口）
  // ============================================================

  /// 更新单个单词的掌握度（兼容旧代码）
  @Deprecated('使用 saveSession 或 updateScoreAfterLearningSession 替代')
  Future<void> updateWordMastery(String wordId, {bool? a, bool? b, bool? c}) async {
    final db = await database;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    
    // 如果全部传入 true，则标记为毕业
    if (a == true && b == true && c == true) {
      await db.update(
        'words',
        {
          'is_graduated': 1,
          'mastery_a': 1,
          'mastery_b': 1,
          'mastery_c': 1,
          'last_reviewed_at': nowStr,
        },
        where: 'id = ?',
        whereArgs: [wordId],
      );
    }
    notifyListeners();
  }

  // ============================================================
  // 私有辅助方法
  // ============================================================

  /// 辅助方法：统一映射 DB 字段到 Model
  void _mapDbToModel(Map<String, dynamic> map) {
    if (map.containsKey('source_image_id')) {
      map['sourceImageId'] = map['source_image_id'];
    }
    
    // 新字段映射
    map['is_graduated'] = map['is_graduated'] == 1;
    map['recommendation_score'] = (map['recommendation_score'] as num?)?.toDouble() ?? 0.0;
    
    // 兼容旧字段（如果新字段不存在，从旧字段推断）
    if (map['is_graduated'] == false && map['mastery_a'] == 1 && map['mastery_b'] == 1 && map['mastery_c'] == 1) {
      map['is_graduated'] = true;
    }
  }
}
