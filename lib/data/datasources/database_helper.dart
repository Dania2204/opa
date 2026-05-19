import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/delivery_model.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';

/// Single SQLite source of truth for all offline-first data.
class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB('paego.db');
    return _db!;
  }

  Future<Database> _initDB(String name) async {
    final path = join(await getDatabasesPath(), name);
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name      TEXT NOT NULL,
        email          TEXT NOT NULL UNIQUE,
        phone          TEXT NOT NULL,
        id_number      TEXT NOT NULL UNIQUE,
        role           TEXT NOT NULL,
        institution    TEXT,
        photo_path     TEXT,
        password_hash  TEXT,
        created_at     TEXT,
        synced_at      TEXT,
        is_synced      INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE school_locations (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        name               TEXT NOT NULL,
        address            TEXT NOT NULL,
        latitude           REAL NOT NULL,
        longitude          REAL NOT NULL,
        added_by_user_id   INTEGER NOT NULL,
        is_synced          INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE delivery_orders (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        school_id            INTEGER NOT NULL,
        school_name          TEXT NOT NULL,
        school_lat           REAL NOT NULL,
        school_lng           REAL NOT NULL,
        pickup_lat           REAL NOT NULL,
        pickup_lng           REAL NOT NULL,
        assigned_driver_id   INTEGER,
        assigned_driver_name TEXT,
        status               TEXT NOT NULL DEFAULT 'pending',
        created_at           TEXT,
        is_synced            INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE delivery_reports (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id              INTEGER NOT NULL,
        school_name           TEXT NOT NULL,
        submitted_by_user_id  INTEGER NOT NULL,
        submitted_by_name     TEXT NOT NULL,
        condition             TEXT NOT NULL DEFAULT 'good',
        notes                 TEXT NOT NULL DEFAULT '',
        photo_paths           TEXT NOT NULL DEFAULT '',
        created_at            TEXT,
        is_synced             INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tracking_points (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id   INTEGER NOT NULL,
        driver_id  INTEGER NOT NULL,
        latitude   REAL NOT NULL,
        longitude  REAL NOT NULL,
        recorded_at TEXT NOT NULL,
        is_synced  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _seedDefaultAdmin(db, resetCredentials: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedDefaultAdmin(db, resetCredentials: true);
    }
  }

  Future<void> _seedDefaultAdmin(Database db,
      {required bool resetCredentials}) async {
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: ['admin'],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert('users', {
        'full_name': 'Administrador',
        'email': 'admin',
        'phone': '',
        'id_number': 'ADMIN-${DateTime.now().millisecondsSinceEpoch}',
        'role': 'admin',
        'institution': null,
        'photo_path': null,
        'password_hash': _hashPassword('12345678'),
        'created_at': DateTime.now().toIso8601String(),
        'synced_at': null,
        'is_synced': 0,
      });
      return;
    }

    if (!resetCredentials) return;

    await db.update(
      'users',
      {
        'role': 'admin',
        'password_hash': _hashPassword('12345678'),
      },
      where: 'id = ?',
      whereArgs: [rows.first['id']],
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'paego_salt_2024');
    return base64Encode(bytes);
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<int> insertUser(AppUser u) async {
    final db = await database;
    return db.insert('users', u.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<AppUser?> getUserByEmail(String email) async {
    return getUserByIdentifier(email);
  }

  Future<AppUser?> getUserByIdentifier(String identifier) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [identifier.toLowerCase().trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'full_name ASC');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<int> updateUser(AppUser u) async {
    final db = await database;
    return db.update('users', u.toMap(),
        where: 'id = ?', whereArgs: [u.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ── School Locations ──────────────────────────────────────────────────────

  Future<int> insertSchool(SchoolLocation s) async {
    final db = await database;
    return db.insert('school_locations', s.toMap());
  }

  Future<List<SchoolLocation>> getSchools() async {
    final db = await database;
    final rows = await db.query('school_locations', orderBy: 'name ASC');
    return rows.map(SchoolLocation.fromMap).toList();
  }

  Future<int> deleteSchool(int id) async {
    final db = await database;
    return db.delete('school_locations', where: 'id = ?', whereArgs: [id]);
  }

  // ── Delivery Orders ───────────────────────────────────────────────────────

  Future<int> insertOrder(DeliveryOrder o) async {
    final db = await database;
    return db.insert('delivery_orders', o.toMap());
  }

  Future<List<DeliveryOrder>> getOrders() async {
    final db = await database;
    final rows = await db.query('delivery_orders', orderBy: 'created_at DESC');
    return rows.map(DeliveryOrder.fromMap).toList();
  }

  Future<int> updateOrderStatus(int id, DeliveryStatus status,
      {int? driverId, String? driverName}) async {
    final db = await database;
    final map = <String, dynamic>{'status': status.name};
    if (driverId != null) map['assigned_driver_id'] = driverId;
    if (driverName != null) map['assigned_driver_name'] = driverName;
    return db.update('delivery_orders', map,
        where: 'id = ?', whereArgs: [id]);
  }

  // ── Reports ───────────────────────────────────────────────────────────────

  Future<int> insertReport(DeliveryReport r) async {
    final db = await database;
    return db.insert('delivery_reports', r.toMap());
  }

  Future<List<DeliveryReport>> getReports() async {
    final db = await database;
    final rows =
        await db.query('delivery_reports', orderBy: 'created_at DESC');
    return rows.map(DeliveryReport.fromMap).toList();
  }

  // ── Tracking ──────────────────────────────────────────────────────────────

  Future<void> insertTrackingPoint({
    required int orderId,
    required int driverId,
    required double lat,
    required double lng,
  }) async {
    final db = await database;
    await db.insert('tracking_points', {
      'order_id': orderId,
      'driver_id': driverId,
      'latitude': lat,
      'longitude': lng,
      'recorded_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getTrackingForOrder(int orderId) async {
    final db = await database;
    return db.query('tracking_points',
        where: 'order_id = ?',
        whereArgs: [orderId],
        orderBy: 'recorded_at ASC');
  }

  // ── Pending sync counts ───────────────────────────────────────────────────

  Future<int> pendingSyncCount() async {
    final db = await database;
    int count = 0;
    for (final table in [
      'users',
      'school_locations',
      'delivery_orders',
      'delivery_reports',
      'tracking_points'
    ]) {
      final r = await db.rawQuery(
          'SELECT COUNT(*) as c FROM $table WHERE is_synced = 0');
      count += (r.first['c'] as int? ?? 0);
    }
    return count;
  }
}
