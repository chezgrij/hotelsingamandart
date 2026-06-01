import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite_pkg;
import '../models/guest.dart';
import '../models/room.dart';
import '../models/reservation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hotel.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE guests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        document TEXT UNIQUE NOT NULL,
        phone TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        room_number TEXT UNIQUE NOT NULL,
        room_type TEXT NOT NULL,
        price REAL NOT NULL,
        status TEXT DEFAULT 'Disponible'
      )
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_id INTEGER,
        room_id INTEGER,
        check_in_date TEXT NOT NULL,
        check_out_date TEXT NOT NULL,
        status TEXT DEFAULT 'Activa',
        FOREIGN KEY (guest_id) REFERENCES guests (id),
        FOREIGN KEY (room_id) REFERENCES rooms (id)
      )
    ''');

    // Seed default rooms
    await db.insert('rooms', {'room_number': '101', 'room_type': 'Sencilla', 'price': 50.0, 'status': 'Disponible'});
    await db.insert('rooms', {'room_number': '102', 'room_type': 'Doble', 'price': 80.0, 'status': 'Disponible'});
    await db.insert('rooms', {'room_number': '103', 'room_type': 'Suite', 'price': 150.0, 'status': 'Disponible'});
    await db.insert('rooms', {'room_number': '201', 'room_type': 'Sencilla', 'price': 50.0, 'status': 'Disponible'});
    await db.insert('rooms', {'room_number': '202', 'room_type': 'Doble', 'price': 80.0, 'status': 'Disponible'});
    await db.insert('rooms', {'room_number': '203', 'room_type': 'Suite', 'price': 150.0, 'status': 'Disponible'});
  }

  // --- Guests ---
  Future<int> insertGuest(Guest guest) async {
    final db = await instance.database;
    try {
      return await db.insert('guests', guest.toMap());
    } catch (e) {
      return -1; // Usually duplicate document
    }
  }

  Future<List<Guest>> getAllGuests({String? query}) async {
    final db = await instance.database;
    if (query != null && query.isNotEmpty) {
      final result = await db.query(
        'guests',
        where: 'name LIKE ? OR document LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return result.map((json) => Guest.fromMap(json)).toList();
    } else {
      final result = await db.query('guests');
      return result.map((json) => Guest.fromMap(json)).toList();
    }
  }

  // --- Rooms ---
  Future<List<Room>> getAllRooms() async {
    final db = await instance.database;
    final result = await db.query('rooms');
    return result.map((json) => Room.fromMap(json)).toList();
  }

  Future<void> updateRoomStatus(int roomId, String status) async {
    final db = await instance.database;
    await db.update(
      'rooms',
      {'status': status},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  Future<List<Room>> getAvailableRooms(String checkIn, String checkOut) async {
    final db = await instance.database;
    final rooms = await db.rawQuery('''
      SELECT * FROM rooms 
      WHERE id NOT IN (
        SELECT room_id FROM reservations 
        WHERE status = 'Activa' 
        AND check_in_date < ? 
        AND check_out_date > ?
      )
    ''', [checkOut, checkIn]);
    return rooms.map((json) => Room.fromMap(json)).toList();
  }

  // --- Reservations ---
  Future<int> insertReservation(Reservation res) async {
    final db = await instance.database;
    return await db.insert('reservations', res.toMap());
  }

  Future<List<Map<String, dynamic>>> getActiveReservationsWithStatus() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT r.*, g.name as guest_name, rm.room_number, rm.status as room_status
      FROM reservations r
      JOIN guests g ON r.guest_id = g.id
      JOIN rooms rm ON r.room_id = rm.id
      WHERE r.status = 'Activa'
    ''');
    return result;
  }
  
  Future<List<Reservation>> getActiveReservations() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT r.*, g.name as guest_name, rm.room_number 
      FROM reservations r
      JOIN guests g ON r.guest_id = g.id
      JOIN rooms rm ON r.room_id = rm.id
      WHERE r.status = 'Activa'
    ''');
    return result.map((json) => Reservation.fromMap(json)).toList();
  }
  
  Future<List<Reservation>> getAllReservations() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT r.*, g.name as guest_name, rm.room_number 
      FROM reservations r
      JOIN guests g ON r.guest_id = g.id
      JOIN rooms rm ON r.room_id = rm.id
    ''');
    return result.map((json) => Reservation.fromMap(json)).toList();
  }

  Future<void> updateReservationStatus(int resId, String status) async {
    final db = await instance.database;
    await db.update(
      'reservations',
      {'status': status},
      where: 'id = ?',
      whereArgs: [resId],
    );
  }

  // --- Stats / Reports ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await instance.database;
    
    final guestsCount = sqflite_pkg.Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM guests')) ?? 0;
    final activeResCount = sqflite_pkg.Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM reservations WHERE status = 'Activa'")) ?? 0;
    
    final occupiedRooms = sqflite_pkg.Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM rooms WHERE status = 'Ocupada'")) ?? 0;
    final availableRooms = sqflite_pkg.Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM rooms WHERE status = 'Disponible'")) ?? 0;
    
    return {
      'guests': guestsCount,
      'active_reservations': activeResCount,
      'occupied_rooms': occupiedRooms,
      'available_rooms': availableRooms,
    };
  }
}
