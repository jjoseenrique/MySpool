import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myspool/filament_catalog.dart';
import 'package:myspool/database.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher/url_launcher.dart';

const _manufacturers = [
  'Anycubic',
  'Bambu Lab',
  'Creality',
  'eSUN',
  'Fiberlogy',
  'Fillamentum',
  'FormFutura',
  'Hatchbox',
  'HobbyKing',
  'Overture',
  'Polymaker',
  'Prusament',
  'Sunlu',
  '3DJAKE',
  'Geeetech',
  'JAYO',
  'Sakata 3D',
  'SUNLU',
  'ELEGOO',
  'Amolen',
  'FlashForge',
  'Kingroon',
  'Otro',
];

const _anycubicSkuNames = {
  'AHHSBK-102': 'PLA High Speed Pearl Black',
  'AHHSBR-102': 'PLA High Speed Bright Red',
  'AHHSBW-102': 'PLA High Speed Strahlendes Weiß',
  'AHHSCG-102': 'PLA High Speed Klassisches Grün',
  'AHHSDB-102': 'PLA High Speed Bright Blue',
  'AHHSGY-102': 'PLA High Speed Structured Grey',
  'AHHSPO-102': 'PLA High Speed Purple Opulence',
  'AHHSSP-102': 'PLA High Speed Strawberry Pink',
  'AHHSVO-102': 'PLA High Speed Vibrant Orange',
  'AHHSVY-102': 'PLA High Speed Vibrant Yellow',
  'AHLSBR-101': 'PLA Marble Brick Red',
  'AHLSMW-101': 'PLA Marble Marmorweiß',
  'AHPEAB-101': 'PETG Sea Blue',
  'AHPEBK-101': 'PETG Black',
  'AHPEBR-101': 'PETG Brown',
  'AHPEBW-101': 'PETG Weiß',
  'AHPECG-101': 'PETG Grün',
  'AHPECL-101': 'PETG Translucent Clear',
  'AHPECR-101': 'PETG Cream',
  'AHPEDB-101': 'PETG Blau',
  'AHPEDG-101': 'PETG Dark Grey',
  'AHPEFG-101': 'PETG Waldgrün',
  'AHPEGE-101': 'PETG Grey',
  'AHPEGY-101': 'PETG Structured Grey',
  'AHPELB-101': 'PETG Beige',
  'AHPELG-101': 'PETG Limettengrün',
  'AHPEPB-101': 'PETG Peanut Brown',
  'AHPEPO-101': 'PETG Purple',
  'AHPERR-101': 'PETG Red',
  'AHPESL-101': 'PETG Structured Silver',
  'AHPESP-101': 'PETG Pink',
  'AHPETB-101': 'PETG Translucent Transparentes Blau',
  'AHPETG-101': 'PETG Translucent Transparentes Grau',
  'AHPETK-101': 'PETG Translucent Transparentes Rosa',
  'AHPETL-101': 'PETG Translucent Transparentes Olivgrün',
  'AHPETO-101': 'PETG Translucent Transparentes Orange',
  'AHPETP-101': 'PETG Translucent Transparentes Lila',
  'AHPETR-101': 'PETG Translucent Transparentes Grün',
  'AHPETW-101': 'PETG Translucent Transparentes Braun',
  'AHPEVO-101': 'PETG Orange',
  'AHPEVY-101': 'PETG Yellow',
  'AHPLBK-105': 'PLA Basic Black',
  'AHPLBK-A106': 'PLA Basic Refill Black',
  'AHPLBR-105': 'PLA Basic Brown',
  'AHPLBW-105': 'PLA Basic Weiß',
  'AHPLBW-A106': 'PLA Basic Refill Weiß',
  'AHPLBZ-105': 'PLA Basic Bronze',
  'AHPLCG-105': 'PLA Basic Grün',
  'AHPLCG-A106': 'PLA Basic Refill Grün',
  'AHPLCL-105': 'PLA Basic Clear',
  'AHPLCY-105': 'PLA Basic Cyan',
  'AHPLDB-105': 'PLA Basic Blue (Navy)',
  'AHPLDB-A106': 'PLA Basic Refill Blau',
  'AHPLGE-106': 'PLA Basic Grey',
  'AHPLGF-105': 'PLA Basic Grüner Blitz',
  'AHPLGY-105': 'PLA Basic Structured Grey',
  'AHPLGY-A106': 'PLA Basic Refill Structured Grey',
  'AHPLKB-105': 'PLA Basic Dark Brown',
  'AHPLLB-105': 'PLA Basic Beige',
  'AHPLOG-107': 'PLA Basic Olive Green',
  'AHPLMG-105': 'PLA Basic Magenta',
  'AHPLP16-107': 'PLA+ Peach Pink',
  'AHPLP17-107': 'PLA+ Interstellar Violet',
  'AHPLP18-107': 'PLA+ Tropisches Türkis',
  'AHPLP19-107': 'PLA+ Frühlingsblatt',
  'AHPLPBK-102': 'PLA+ Black',
  'AHPLPBK-A108': 'PLA+ Refill Black',
  'AHPLPBR-106': 'PLA+ Bright Red',
  'AHPLPBR-107': 'PLA+ Brown',
  'AHPLPBW-102': 'PLA+ Weiß',
  'AHPLPBW-A108': 'PLA+ Refill Weiß',
  'AHPLPCG-107': 'PLA+ Grün',
  'AHPLPCG-A108': 'PLA+ Refill Grün',
  'AHPLPDB-102': 'PLA+ Blau',
  'AHPLPDB-A108': 'PLA+ Refill Blau',
  'AHPLPGE-107': 'PLA+ Grey',
  'AHPLPGF-102': 'PLA+ Grüner Blitz',
  'AHPLPGY-102': 'PLA+ Structured Grey',
  'AHPLPGY-A108': 'PLA+ Refill Structured Grey',
  'AHPLPLB-106': 'PLA+ Light Blue',
  'AHPLPLB-108': 'PLA+ Beige',
  'AHPLPO-105': 'PLA Basic Purple',
  'AHPLPO-A106': 'PLA Basic Refill Purple',
  'AHPLPPO-103': 'PLA+ Purple',
  'AHPLPPO-A108': 'PLA+ Refill Purple',
  'AHPLPRR-107': 'PLA+ Red',
  'AHPLPRR-A108': 'PLA+ Refill Red',
  'AHPLPSL-102': 'PLA+ Silver',
  'AHPLPSP-107': 'PLA+ Pink',
  'AHPLPSP-A108': 'PLA+ Refill Pink',
  'AHPLPVO-102': 'PLA+ Orange',
  'AHPLPVO-A108': 'PLA+ Refill Orange',
  'AHPLPVY-102': 'PLA+ Yellow',
  'AHPLPVY-A108': 'PLA+ Refill Yellow',
  'AHPLRR-105': 'PLA Basic Red',
  'AHPLRR-A106': 'PLA Basic Refill Red',
  'AHPLSL-105': 'PLA Basic Structured Silver',
  'AHPLSP-105': 'PLA Basic Pink',
  'AHPLSP-A106': 'PLA Basic Refill Pink',
  'AHPLVO-105': 'PLA Basic Orange',
  'AHPLVO-A106': 'PLA Basic Refill Orange',
  'AHPLVY-105': 'PLA Basic Yellow',
  'AHPLVY-A106': 'PLA Basic Refill Yellow',
  'AHSC07-102': 'PLA Silk Dual/Tri-Color Black Gold',
  'AHSC08-102': 'PLA Silk Dual/Tri-Color Black Blue',
  'AHSC09-102': 'PLA Silk Dual/Tri-Color Schwarz Grün',
  'AHSC10-102': 'PLA Silk Dual/Tri-Color Black Purple',
  'AHSC11-102': 'PLA Silk Dual/Tri-Color Pink Gold',
  'AHSC12-102': 'PLA Silk Dual/Tri-Color Red Gold',
  'AHSC13-102': 'PLA Silk Dual/Tri-Color Red Blue',
  'AHSC14-102': 'PLA Silk Dual/Tri-Color Blau Grün Lila',
  'AHSC15-102': 'PLA Silk Dual/Tri-Color Rot Gelb Grün',
  'AHSC16-102': 'PLA Silk Dual/Tri-Color Blau Grün',
  'AHSC17-102': 'PLA Silk Dual/Tri-Color Black Red',
  'AHSC18-102': 'PLA Silk Dual/Tri-Color Red Blue Yellow',
  'AHSCBL-102': 'PLA Silk Blau',
  'AHSCCG-102': 'PLA Silk Weihnachtsgrün',
  'AHSCCO-102': 'PLA Silk Copper',
  'AHSCCR-102': 'PLA Silk Christmas Red',
  'AHSCGD-102': 'PLA Silk Gold',
  'AHSCGR-102': 'PLA Silk Grün',
  'AHSCPK-102': 'PLA Silk Pink',
  'AHSCPU-102': 'PLA Silk Purple',
  'AHSCRB1-102': 'PLA Silk Rainbow',
  'AHSCSG-102': 'PLA Silk Glänzendes Gold',
  'AHSCSL-102': 'PLA Silk Silver',
  'AHSCWH-102': 'PLA Silk Weiß',
  'AHXKGB-101': 'PLA Galaxy Galaxy Brown',
  'AHXKGG-101': 'PLA Galaxy Galaxy Grün',
  'AHXKGL-101': 'PLA Galaxy Galaxy Blue',
  'AHXKGP-101': 'PLA Galaxy Galaxy Purple',
  'HABBK-102': 'ABS Black',
  'HABGY-102': 'ABS Grey',
  'HABWH-102': 'ABS Weiß',
  'HASBK-101': 'ASA Black',
  'HASBL-102': 'ASA Blau',
  'HASGR-102': 'ASA Grün',
  'HASGY-101': 'ASA Grey',
  'HASRE-101': 'ASA Red',
  'HASWH-101': 'ASA Weiß',
  'HFGBE-103': 'PLA Glow Blau',
  'HFGBL-101': 'PLA Glow Glow Blue',
  'HFGGN-103': 'PLA Glow Grün',
  'HFGGR-101': 'PLA Glow Nachleuchtendes Grün',
  'HFGYE-103': 'PLA Glow Glow Yellow',
  'HJSMB-101': 'PLA Metal Metallic Black',
  'HJSMC-101': 'PLA Metal Metallic Champagne',
  'HJSML-101': 'PLA Metal Metallic Blue',
  'HJSMO-101': 'PLA Metal Metallic Copper',
  'HPL16-101': 'PLA Basic Pantone Peach Fuzz',
  'HPL16-105': 'PLA Basic Special Peach Pink',
  'HPL16-107': 'PLA+ Peach Pink',
  'HPL16-108': 'PLA Basic Peach Pink',
  'HPL16-A108': 'PLA Basic Peach Pink Refill',
  'HPL17-101': 'PLA Basic Pantone Interstellar Violet',
  'HPL17-105': 'PLA Basic Special Interstellar Violet',
  'HPL17-107': 'PLA+ Interstellar Violet',
  'HPL18-101': 'PLA Basic Pantone Tropical Turquoise',
  'HPL18-105': 'PLA Basic Special Tropisches Türkis',
  'HPL18-107': 'PLA+ Tropical Turquoise',
  'HPL19-101': 'PLA Basic Pantone Spring Leaf',
  'HPL19-105': 'PLA Basic Special Frühlingsblatt',
  'HPL19-107': 'PLA+ Spring Leaf',
  'HSCGY-101': 'PLA Silk Grey',
  'HSCML-101': 'PLA Silk Metallic Blue',
  'HTPBK-101': 'TPU Black',
  'HTPCB-101': 'TPU Clear Blue',
  'HTPCG-101': 'TPU Klar Grün',
  'HTPCL-101': 'TPU Clear',
  'HTPCO-101': 'TPU Clear Orange',
  'HTPCP-101': 'TPU Clear Purple',
  'HTPCR-101': 'TPU Clear Red',
  'HTPGY-101': 'TPU Grey',
  'HTPMW-101': 'TPU Milchweiß',
  'HYGBK-101': 'PLA Matte Black',
  'HYGBL-102': 'PLA Matte Blau',
  'HYGGB-102': 'PLA Matte Grün-Braun',
  'HYGGR-102': 'PLA Matte Grün',
  'HYGGY-102': 'PLA Matte Grey',
  'HYGIB-102': 'PLA Matte Ice Blue',
  'HYGOR-102': 'PLA Matte Orange',
  'HYGPU-102': 'PLA Matte Purple',
  'HYGRB-102': 'PLA Matte Red-Blue',
  'HYGRE-102': 'PLA Matte Red',
  'HYGSP-102': 'PLA Matte Sakura Pink',
  'HYGWT-101': 'PLA Matte Weiß',
  'HYGYL-101': 'PLA Matte Yellow',
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xfff8f7f4),
      systemNavigationBarDividerColor: Color(0xfff8f7f4),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      statusBarColor: Color(0xfff8f7f4),
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MySpoolApp());
}

class Filament {
  const Filament({
    required this.id,
    required this.brand,
    required this.name,
    required this.material,
    required this.color,
    required this.weight,
    required this.remaining,
    required this.quantity,
    required this.diameter,
    required this.printTemperature,
    required this.bedTemperature,
    required this.notes,
    this.nfcId,
    this.location = '',
    this.purchaseDate,
    this.price,
  });

  final String id;
  final String brand;
  final String name;
  final String material;
  final String color;
  final double weight;
  final double remaining;
  final int quantity;
  final double diameter;
  final String printTemperature;
  final String bedTemperature;
  final String notes;
  final String? nfcId;
  final String location;
  final String? purchaseDate;
  final double? price;

  Filament copyWith({
    double? remaining,
    int? quantity,
    String? location,
    String? purchaseDate,
    double? price,
  }) => Filament(
    id: id,
    brand: brand,
    name: name,
    material: material,
    color: color,
    weight: weight,
    remaining: remaining ?? this.remaining,
    quantity: quantity ?? this.quantity,
    diameter: diameter,
    printTemperature: printTemperature,
    bedTemperature: bedTemperature,
    notes: notes,
    nfcId: nfcId,
    location: location ?? this.location,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    price: price ?? this.price,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'name': name,
    'material': material,
    'color': color,
    'weight': weight,
    'remaining': remaining,
    'quantity': quantity,
    'diameter': diameter,
    'printTemperature': printTemperature,
    'bedTemperature': bedTemperature,
    'notes': notes,
    'nfcId': nfcId,
    'location': location,
    'purchaseDate': purchaseDate,
    'price': price,
  };

  factory Filament.fromJson(Map<String, dynamic> json) => Filament(
    id:
        _stringValue(json['id']) ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    brand: _stringValue(json['brand']) ?? '',
    name: _stringValue(json['name']) ?? '',
    material: _stringValue(json['material']) ?? 'PLA',
    color: _stringValue(json['color']) ?? '#FFFFFF',
    weight: _numberValue(json['weight']) ?? 1000,
    remaining: _numberValue(json['remaining']) ?? 1000,
    quantity: _integerValue(json['quantity']) ?? 1,
    diameter: _numberValue(json['diameter']) ?? 1.75,
    printTemperature: _stringValue(json['printTemperature']) ?? '',
    bedTemperature: _stringValue(json['bedTemperature']) ?? '',
    notes: _stringValue(json['notes']) ?? '',
    nfcId: _stringValue(json['nfcId']),
    location: _stringValue(json['location']) ?? '',
    purchaseDate: _stringValue(json['purchaseDate']),
    price: _numberValue(json['price']),
  );
}

String? _stringValue(Object? value) => value is String ? value : null;

double? _numberValue(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

int? _integerValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

class NfcFilamentData {
  const NfcFilamentData({
    this.brand,
    this.name,
    this.material,
    this.color,
    this.weight,
    this.diameter,
    this.printTemperature,
    this.bedTemperature,
  });

  final String? brand;
  final String? name;
  final String? material;
  final String? color;
  final double? weight;
  final double? diameter;
  final String? printTemperature;
  final String? bedTemperature;
}

class FilamentStore extends ChangeNotifier {
  static const _key = 'filaments';
  static const _trashKey = 'filaments_trash';
  final List<Filament> _items = [];
  final List<Filament> _trash = [];
  Future<void> _writeQueue = Future<void>.value();

  List<Filament> get items => List.unmodifiable(_items);
  List<Filament> get trash => List.unmodifiable(_trash);

  Future<void> load() async {
    final database = await AppDatabase.instance.database;
    final storedItems = await database.query('filaments');
    final storedTrash = await database.query('trash');
    if (storedItems.isNotEmpty || storedTrash.isNotEmpty) {
      _items
        ..clear()
        ..addAll(storedItems.map(_fromDatabase));
      _trash
        ..clear()
        ..addAll(storedTrash.map(_trashFromDatabase));
      notifyListeners();
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    _items
      ..clear()
      ..addAll(_decode(preferences.getString(_key)));
    _trash
      ..clear()
      ..addAll(_decode(preferences.getString(_trashKey)));
    await _persist();
    notifyListeners();
  }

  List<Filament> _decode(String? raw) {
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((value) => Filament.fromJson(Map<String, dynamic>.from(value)))
            .toList();
      }
    } on FormatException {
      return [];
    }
    return [];
  }

  Future<void> save(Filament filament) async {
    final index = _items.indexWhere((item) => item.id == filament.id);
    if (index == -1) {
      _items.insert(0, filament);
    } else {
      _items[index] = filament;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _persist();
    notifyListeners();
  }

  Map<String, Object?> _toDatabase(Filament filament) => {
    'id': filament.id,
    'brand': filament.brand,
    'name': filament.name,
    'material': filament.material,
    'color': filament.color,
    'weight': filament.weight,
    'remaining': filament.remaining,
    'quantity': filament.quantity,
    'diameter': filament.diameter,
    'print_temperature': filament.printTemperature,
    'bed_temperature': filament.bedTemperature,
    'notes': filament.notes,
    'nfc_id': filament.nfcId,
    'location': filament.location,
    'purchase_date': filament.purchaseDate,
    'price': filament.price,
    'created_at': DateTime.now().toIso8601String(),
  };

  Filament _fromDatabase(Map<String, Object?> row) => Filament(
    id: row['id']! as String,
    brand: row['brand']! as String,
    name: row['name']! as String,
    material: row['material']! as String,
    color: row['color']! as String,
    weight: (row['weight']! as num).toDouble(),
    remaining: (row['remaining']! as num).toDouble(),
    quantity: row['quantity']! as int,
    diameter: (row['diameter']! as num).toDouble(),
    printTemperature: row['print_temperature']! as String,
    bedTemperature: row['bed_temperature']! as String,
    notes: row['notes']! as String,
    nfcId: row['nfc_id'] as String?,
    location: row['location'] as String? ?? '',
    purchaseDate: row['purchase_date'] as String?,
    price: (row['price'] as num?)?.toDouble(),
  );

  Map<String, Object?> _toTrashDatabase(Filament filament) => {
    'id': filament.id,
    'filament_json': jsonEncode(filament.toJson()),
    'moved_at': DateTime.now().toIso8601String(),
  };

  Filament _trashFromDatabase(Map<String, Object?> row) =>
      Filament.fromJson(jsonDecode(row['filament_json']! as String));

  Future<void> consumeSpool(Filament filament) async {
    final consumed = filament.weight;
    if (filament.quantity > 1) {
      _items[_items.indexWhere((item) => item.id == filament.id)] = filament
          .copyWith(
            quantity: filament.quantity - 1,
            remaining: (filament.remaining - filament.weight).clamp(
              0,
              double.infinity,
            ),
          );
      _trash.insert(0, filament.copyWith(quantity: 1, remaining: 0));
      await _recordConsumption(filament.id, consumed, 'Bobina gastada');
      await _persist();
      notifyListeners();
    } else {
      _items.removeWhere((item) => item.id == filament.id);
      _trash.insert(0, filament);
      await _recordConsumption(filament.id, consumed, 'Bobina gastada');
      await _persist();
      notifyListeners();
    }
  }

  Future<void> consumeGrams(
    Filament filament,
    double grams, {
    String reason = 'Consumo manual',
  }) async {
    if (grams <= 0) return;
    final index = _items.indexWhere((item) => item.id == filament.id);
    if (index == -1) return;
    final item = _items[index];
    final nextRemaining = (item.remaining - grams)
        .clamp(0, double.infinity)
        .toDouble();
    _items[index] = item.copyWith(remaining: nextRemaining);
    await _recordConsumption(item.id, grams, reason);
    await _persist();
    notifyListeners();
  }

  Future<void> _recordConsumption(
    String filamentId,
    double grams,
    String reason,
  ) async {
    final database = await AppDatabase.instance.database;
    await database.insert('consumption', {
      'filament_id': filamentId,
      'grams': grams,
      'reason': reason,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> moveToTrash(Filament filament) async {
    _items.removeWhere((item) => item.id == filament.id);
    _trash.insert(0, filament);
    await _persist();
    notifyListeners();
  }

  Future<void> restore(Filament filament) async {
    _trash.removeWhere((item) => item.id == filament.id);
    _items.insert(0, filament);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteForever(Filament filament) async {
    _trash.removeWhere((item) => item.id == filament.id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() {
    _writeQueue = _writeQueue.then((_) async {
      final database = await AppDatabase.instance.database;
      await database.transaction((transaction) async {
        final itemIds = _items.map((item) => item.id).toSet();
        final trashIds = _trash.map((item) => item.id).toSet();
        final storedItems = await transaction.query(
          'filaments',
          columns: ['id'],
        );
        final storedTrash = await transaction.query('trash', columns: ['id']);
        for (final row in storedItems) {
          final id = row['id']! as String;
          if (!itemIds.contains(id)) {
            await transaction.delete(
              'filaments',
              where: 'id = ?',
              whereArgs: [id],
            );
          }
        }
        for (final row in storedTrash) {
          final id = row['id']! as String;
          if (!trashIds.contains(id)) {
            await transaction.delete('trash', where: 'id = ?', whereArgs: [id]);
          }
        }
        for (final filament in _items) {
          await transaction.insert(
            'filaments',
            _toDatabase(filament),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final filament in _trash) {
          await transaction.insert(
            'trash',
            _toTrashDatabase(filament),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    });
    return _writeQueue;
  }
}

class MySpoolApp extends StatelessWidget {
  const MySpoolApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MySpool',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffef6c43),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xfff8f7f4),
      useMaterial3: true,
    ),
    home: const LibraryPage(),
  );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final FilamentStore _store = FilamentStore();
  String _query = '';
  String _filter = 'Todos';
  double _lowStockThreshold = 100;
  final Set<String> _dismissedLowStock = {};

  @override
  void initState() {
    super.initState();
    _store.load();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final dismissed = preferences.getStringList('dismissed_low_stock') ?? [];
    if (!mounted) return;
    setState(() {
      _lowStockThreshold = preferences.getDouble('low_stock_threshold') ?? 100;
      _dismissedLowStock.addAll(dismissed);
    });
  }

  List<Filament> get _lowStockItems => _store.items
      .where(
        (filament) =>
            filament.quantity == 1 &&
            filament.remaining <= _lowStockThreshold &&
            !_dismissedLowStock.contains(filament.id),
      )
      .toList();

  Future<void> _dismissLowStock(String id) async {
    final preferences = await SharedPreferences.getInstance();
    setState(() => _dismissedLowStock.add(id));
    await preferences.setStringList(
      'dismissed_low_stock',
      _dismissedLowStock.toList(),
    );
  }

  Future<void> _openReminderSettings() async {
    final controller = TextEditingController(
      text: _lowStockThreshold.toStringAsFixed(0),
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recordatorio de stock bajo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Avisar cuando queden menos de',
            suffixText: 'g',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value < 0) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('low_stock_threshold', value);
    if (!mounted) return;
    setState(() {
      _lowStockThreshold = value;
      _dismissedLowStock.clear();
    });
    await preferences.remove('dismissed_low_stock');
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  List<Filament> get _filtered => _store.items.where((item) {
    final matchesQuery = '${item.brand} ${item.name} ${item.material}'
        .toLowerCase()
        .contains(_query.toLowerCase());
    final matchesFilter = _filter == 'Todos' || item.material == _filter;
    return matchesQuery && matchesFilter;
  }).toList();

  Future<void> _addFilament({
    String? nfcId,
    String? nfcText,
    NfcFilamentData? nfcData,
    Filament? existing,
  }) async {
    final result = await Navigator.of(context).push<Filament>(
      MaterialPageRoute(
        builder: (_) => FilamentFormPage(
          nfcId: nfcId,
          nfcText: nfcText,
          nfcData: nfcData,
          existing: existing,
        ),
      ),
    );
    if (result != null) await _store.save(result);
  }

  void _openPalette() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PalettePage(filaments: _store.items)),
    );
  }

  void _openTrash() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrashPage(store: _store)));
  }

  Future<void> _scanNfc() async {
    final available =
        await NfcManager.instance.checkAvailability() ==
        NfcAvailability.enabled;
    if (!mounted) return;
    if (!available) {
      _showMessage('NFC no está disponible en este dispositivo.');
      return;
    }

    final scanCompleted = Completer<void>();
    String? tagId;
    String? text;
    NfcFilamentData? nfcData;
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (tag) async {
          if (scanCompleted.isCompleted) return;
          try {
            tagId = _tagIdentifier(tag);
            nfcData = await _readAnycubicTag(tag);
            final ndef = Ndef.from(tag);
            final message = await ndef?.read();
            if (message != null) {
              text = message.records
                  .map(
                    (record) =>
                        utf8.decode(record.payload, allowMalformed: true),
                  )
                  .join(' ')
                  .trim();
            }
          } finally {
            await NfcManager.instance.stopSession();
            scanCompleted.complete();
          }
        },
      );
      if (mounted) {
        _showMessage('Acerca la bobina al teléfono para leer su etiqueta NFC.');
      }
      await scanCompleted.future;
      if (!mounted) return;
      if (tagId != null) {
        await _addFilament(nfcId: tagId, nfcText: text, nfcData: nfcData);
      }
    } catch (error) {
      if (mounted) _showMessage('No se pudo leer la etiqueta NFC: $error');
    }
  }

  Future<NfcFilamentData?> _readAnycubicTag(NfcTag tag) async {
    final nfcA = NfcAAndroid.from(tag);
    if (nfcA == null) return null;
    final bytes = <int>[...List.filled(16, 0)];
    try {
      for (var page = 4; page <= 0x2c; page += 4) {
        final response = await nfcA.transceive(
          Uint8List.fromList([0x30, page]),
        );
        if (response.length < 16) return null;
        bytes.addAll(response.take(16));
      }
    } on Exception {
      return null;
    }
    if (bytes.length < 128) return null;
    String readText(int start, int length) {
      final end = (start + length).clamp(0, bytes.length);
      return String.fromCharCodes(
        bytes.sublist(start, end),
      ).replaceAll(RegExp(r'[^\x20-\x7E+]'), '').trim();
    }

    int unsigned16(int offset) => bytes[offset] | (bytes[offset + 1] << 8);
    final rawMaterial = readText(60, 20);
    final rawSku = readText(20, 12);
    final manufacturer = readText(40, 20).toUpperCase();
    final sku =
        RegExp(
          r'[A-Z0-9]+-[A-Z0-9]+',
        ).firstMatch(rawSku.toUpperCase())?.group(0) ??
        rawSku.toUpperCase();
    final material = rawMaterial.isEmpty ? _materialFromSku(sku) : rawMaterial;
    final color =
        bytes[83].toRadixString(16).padLeft(2, '0') +
        bytes[82].toRadixString(16).padLeft(2, '0') +
        bytes[81].toRadixString(16).padLeft(2, '0');
    final nozzle = '${unsigned16(96)}-${unsigned16(98)}';
    final bed = '${unsigned16(116)}-${unsigned16(118)}';
    final diameter = unsigned16(120) / 100;
    final weight =
        bytes[124] |
        (bytes[125] << 8) |
        (bytes[126] << 16) |
        (bytes[127] << 24);
    final formatVersion = bytes[18];
    final looksLikeAnycubic =
        manufacturer == 'AC' ||
        sku.startsWith('H') ||
        (formatVersion == 0x64 || formatVersion == 0x65);
    if (!looksLikeAnycubic && color == '000000') return null;
    final displayName = _anycubicName(sku, material);
    return NfcFilamentData(
      brand: 'Anycubic',
      name: displayName,
      material: _materialName(material, sku),
      color: color == '000000' ? null : '#$color',
      weight: weight > 0 ? weight.toDouble() : null,
      diameter: diameter > 0 ? diameter : null,
      printTemperature: nozzle,
      bedTemperature: bed,
    );
  }

  String _anycubicName(String sku, String material) {
    final direct = _anycubicSkuNames[sku];
    if (direct != null) return direct;
    final codeName = _anycubicColorCodeName(sku);
    if (codeName != null) {
      return 'Anycubic ${_anycubicFamilyName(sku, material)} $codeName';
    }
    if (sku.isNotEmpty) {
      return 'Anycubic ${material.isEmpty ? 'Filamento' : material} · $sku';
    }
    return material.isEmpty ? 'Filamento Anycubic' : 'Anycubic $material';
  }

  String _anycubicFamilyName(String sku, String material) {
    final upper = sku.toUpperCase();
    if (upper.startsWith('AHSC') || upper.startsWith('HSC')) {
      return 'PLA Silk';
    }
    if (upper.startsWith('HJSM')) return 'PLA Metal';
    if (upper.startsWith('AHXKG')) return 'PLA Galaxy';
    if (upper.startsWith('AHLS')) return 'PLA Marble';
    if (upper.startsWith('HF')) return 'PLA Glow';
    return material.isEmpty ? 'PLA Basic' : material;
  }

  String? _anycubicColorCodeName(String sku) {
    final upper = sku.toUpperCase();
    final code =
        RegExp(r'AHPL([A-Z0-9]{2,3})-').firstMatch(upper)?.group(1) ??
        RegExp(
          r'(?:AHSC|HSC|HJSM|AHXKG|AHLS|HF)([A-Z0-9]{1,4})-',
        ).firstMatch(upper)?.group(1);
    const names = {
      'LOG': 'Olive Green',
      'BW': 'Bright White',
      'BK': 'Black',
      'GY': 'Grey',
      'GE': 'Grey',
      'RR': 'Red',
      'BR': 'Bright Red',
      'CG': 'Classic Green',
      'DB': 'Dark Blue',
      'LB': 'Light Blue',
      'VO': 'Vibrant Orange',
      'VY': 'Vibrant Yellow',
      'PO': 'Purple Opulence',
      'SP': 'Strawberry Pink',
      'P16': 'Peach Pink',
      'P17': 'Interstellar Violet',
      'P18': 'Tropical Turquoise',
      'P19': 'Spring Leaf',
      'SL': 'Silver',
      'GF': 'Green Flash',
      'MG': 'Magenta',
      'BZ': 'Bronze',
      'CL': 'Clear',
      'CY': 'Cyan',
      'BL': 'Blue',
      'ML': 'Metallic Blue',
      'GD': 'Gold',
      'WH': 'White',
      'WT': 'White',
      'SG': 'Glossy Gold',
      'CR': 'Christmas Red',
      'CO': 'Copper',
      'O': 'Bronze',
      'RB1': 'Rainbow',
    };
    if (code == 'CG' && upper.startsWith('AHSC')) return 'Christmas Green';
    return code == null ? null : names[code];
  }

  String _materialFromSku(String sku) {
    final upper = sku.toUpperCase();
    if (upper.startsWith('AHPE')) return 'PETG';
    if (upper.startsWith('HAS')) return 'ASA';
    if (upper.startsWith('HAB')) return 'ABS';
    if (upper.startsWith('HTP')) return 'TPU';
    if (upper.startsWith('HYG')) return 'PLA Matte';
    if (upper.startsWith('AHSC') || upper.startsWith('HSC')) return 'PLA Silk';
    if (upper.startsWith('HF')) return 'PLA Glow';
    return upper.contains('PLA') ||
            upper.startsWith('AHPL') ||
            upper.startsWith('HPL')
        ? 'PLA'
        : '';
  }

  String _materialName(String material, String sku) {
    final value = material.trim();
    if (value.isNotEmpty) {
      return value
          .replaceFirst(RegExp(r'\+.*$'), '')
          .replaceFirst(RegExp(r'\?.*$'), '')
          .trim();
    }
    return _materialFromSku(sku);
  }

  String _tagIdentifier(NfcTag tag) {
    final androidTag = NfcTagAndroid.from(tag);
    if (androidTag != null) {
      return androidTag.id
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join(':')
          .toUpperCase();
    }
    return tag.toString();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/logo.png'),
      ),
      actions: [
        IconButton(
          tooltip: 'Paleta de colores',
          onPressed: _openPalette,
          icon: const Icon(Icons.palette_outlined),
        ),
        AnimatedBuilder(
          animation: _store,
          builder: (context, _) => IconButton(
            tooltip: 'Papelera',
            onPressed: _openTrash,
            icon: Badge(
              isLabelVisible: _store.trash.isNotEmpty,
              label: Text('${_store.trash.length}'),
              child: const Icon(Icons.delete_outline),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Escanear NFC',
          onPressed: _scanNfc,
          icon: const Icon(Icons.nfc),
        ),
        IconButton(
          tooltip: 'Configuración de recordatorios',
          onPressed: _openReminderSettings,
          icon: const Icon(Icons.notifications_none_outlined),
        ),
      ],
    ),
    body: AnimatedBuilder(
      animation: _store,
      builder: (context, _) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              itemCount: _store.items.length,
              totalCount: _store.items.fold(
                0,
                (total, filament) => total + filament.quantity,
              ),
            ),
          ),
          if (_lowStockItems.isNotEmpty)
            SliverToBoxAdapter(
              child: _LowStockReminder(
                items: _lowStockItems,
                threshold: _lowStockThreshold,
                onDismiss: _dismissLowStock,
                onOpen: (filament) => _addFilament(existing: filament),
              ),
            ),
          SliverToBoxAdapter(
            child: _SearchBar(
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SliverToBoxAdapter(
            child: _Filters(
              selected: _filter,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          if (_filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final filament = _filtered[index];
                  return Dismissible(
                    key: ValueKey(filament.id),
                    direction: DismissDirection.horizontal,
                    dismissThresholds: const {
                      DismissDirection.startToEnd: 0.25,
                      DismissDirection.endToStart: 0.35,
                    },
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(left: 24),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'Restar 100 g',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(right: 24),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'Gastada',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await _store.consumeGrams(filament, 100);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Se han restado 100 g'),
                            ),
                          );
                        }
                        return false;
                      }
                      return true;
                    },
                    onDismissed: (_) async {
                      await _store.consumeSpool(filament);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            filament.quantity > 1
                                ? 'Bobina marcada como gastada'
                                : 'Filamento eliminado de la biblioteca',
                          ),
                        ),
                      );
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _addFilament(existing: filament),
                      child: _FilamentCard(
                        filament: filament,
                        onDelete: () => _store.remove(filament.id),
                        onConsume: () => _store.consumeGrams(filament, 100),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _addFilament(),
      icon: const Icon(Icons.add),
      label: const Text('Añadir bobina'),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.itemCount, required this.totalCount});
  final int itemCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu biblioteca',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text('$itemCount bobinas registradas · $totalCount stock total'),
      ],
    ),
  );
}

class _LowStockReminder extends StatelessWidget {
  const _LowStockReminder({
    required this.items,
    required this.threshold,
    required this.onDismiss,
    required this.onOpen,
  });
  final List<Filament> items;
  final double threshold;
  final ValueChanged<String> onDismiss;
  final ValueChanged<Filament> onOpen;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    color: Colors.amber.shade50,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stock bajo: menos de ${threshold.toStringAsFixed(0)} g',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Descartar todos',
                onPressed: () {
                  for (final item in items) {
                    onDismiss(item.id);
                  }
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          ...items.map(
            (filament) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: colorFromHex(filament.color),
              ),
              title: Text(
                filament.name.isEmpty ? 'Filamento sin nombre' : filament.name,
              ),
              subtitle: Text(
                '${filament.remaining.toStringAsFixed(0)} g restantes',
              ),
              onTap: () => onOpen(filament),
              trailing: IconButton(
                tooltip: 'Descartar',
                onPressed: () => onDismiss(filament.id),
                icon: const Icon(Icons.visibility_off_outlined),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar marca, color o material...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: ['Todos', 'PLA', 'PETG', 'ABS', 'TPU'].map((filter) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filter),
            selected: selected == filter,
            onSelected: (_) => onSelected(filter),
          ),
        );
      }).toList(),
    ),
  );
}

class _FilamentCard extends StatelessWidget {
  const _FilamentCard({
    required this.filament,
    required this.onDelete,
    required this.onConsume,
  });
  final Filament filament;
  final VoidCallback onDelete;
  final VoidCallback onConsume;

  @override
  Widget build(BuildContext context) {
    final totalCapacity = filament.weight * filament.quantity;
    final progress = (filament.remaining / totalCapacity).clamp(0.0, 1.0);
    final color = colorFromHex(filament.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    gradient: filamentFinishGradient(filament, color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12, width: 2),
                    boxShadow: filamentFinishShadow(filament, color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filament.name.isEmpty ? 'Sin nombre' : filament.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '${filament.brand.isEmpty ? 'Marca desconocida' : filament.brand} · ${filament.material}',
                      ),
                      Text(
                        '${filament.quantity} ${filament.quantity == 1 ? 'bobina' : 'bobinas'}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                if (filament.nfcId != null) const Icon(Icons.nfc, size: 20),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'consume') {
                      onConsume();
                    }
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'consume',
                      child: Text('Restar 100 g'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filament.remaining.toStringAsFixed(0)} g restantes en total',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('${(progress * 100).toStringAsFixed(0)} %'),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

Color colorFromHex(String value) {
  final hex = value.replaceAll('#', '');
  final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return parsed == null ? Colors.grey : Color(parsed);
}

String filamentFinish(Filament filament) {
  final description = '${filament.name} ${filament.material}'.toLowerCase();
  if (description.contains('silk') || description.contains('seda')) {
    return 'silk';
  }
  if (description.contains('metal') ||
      description.contains('metallic') ||
      description.contains('bronce') ||
      description.contains('bronze')) {
    return 'metal';
  }
  if (description.contains('galaxy') ||
      description.contains('sparkle') ||
      description.contains('glitter')) {
    return 'galaxy';
  }
  if (description.contains('marble') || description.contains('mármol')) {
    return 'marble';
  }
  if (description.contains('glow') ||
      description.contains('fluorescent') ||
      description.contains('fosforescente')) {
    return 'glow';
  }
  if (description.contains('translucent') ||
      description.contains('translúcido') ||
      description.contains('translucido') ||
      description.contains('transparent') ||
      description.contains('transparente') ||
      description.contains('clear')) {
    return 'translucent';
  }
  return 'plain';
}

Gradient? filamentFinishGradient(Filament filament, Color color) {
  switch (filamentFinish(filament)) {
    case 'silk':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.42)!,
          color,
          Color.lerp(color, Colors.black, 0.18)!,
          Color.lerp(color, Colors.white, 0.28)!,
        ],
        stops: const [0, 0.3, 0.62, 1],
      );
    case 'metal':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.5)!,
          Color.lerp(color, Colors.black, 0.22)!,
          Color.lerp(color, Colors.white, 0.38)!,
          color,
        ],
        stops: const [0, 0.28, 0.5, 1],
      );
    case 'galaxy':
      return RadialGradient(
        center: const Alignment(-0.45, -0.5),
        radius: 1.15,
        colors: [
          Color.lerp(color, Colors.white, 0.32)!,
          color,
          Color.lerp(color, Colors.black, 0.3)!,
        ],
      );
    case 'marble':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.24)!,
          color,
          Color.lerp(color, Colors.black, 0.2)!,
          Color.lerp(color, Colors.white, 0.16)!,
        ],
        stops: const [0, 0.35, 0.58, 1],
      );
    case 'glow':
      return RadialGradient(
        colors: [Color.lerp(color, Colors.white, 0.3)!, color],
      );
    case 'translucent':
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(color, Colors.white, 0.62)!,
          Color.lerp(color, Colors.white, 0.18)!,
          Color.lerp(color, Colors.black, 0.08)!,
        ],
        stops: const [0, 0.45, 1],
      );
    default:
      return null;
  }
}

List<BoxShadow>? filamentFinishShadow(Filament filament, Color color) {
  if (filamentFinish(filament) != 'glow') return null;
  return [
    BoxShadow(
      color: color.withValues(alpha: 0.55),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];
}

class TrashPage extends StatelessWidget {
  const TrashPage({super.key, required this.store});
  final FilamentStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Papelera',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        if (store.trash.isEmpty) {
          return const Center(child: Text('La papelera está vacía'));
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          itemCount: store.trash.length,
          itemBuilder: (context, index) {
            final filament = store.trash[index];
            return Dismissible(
              key: ValueKey('trash-${filament.id}'),
              background: _TrashSwipeBackground(
                color: Colors.green,
                icon: Icons.restore,
                label: 'Restaurar',
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: _TrashSwipeBackground(
                color: Theme.of(context).colorScheme.error,
                icon: Icons.delete_forever,
                label: 'Eliminar',
                alignment: Alignment.centerRight,
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  store.restore(filament);
                } else {
                  store.deleteForever(filament);
                }
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorFromHex(filament.color),
                  ),
                  title: Text(
                    filament.name.isEmpty ? 'Sin nombre' : filament.name,
                  ),
                  subtitle: Text('${filament.brand} · ${filament.material}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'restore') store.restore(filament);
                      if (value == 'delete') store.deleteForever(filament);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'restore', child: Text('Restaurar')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar definitivamente'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

class _TrashSwipeBackground extends StatelessWidget {
  const _TrashSwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}

class PalettePage extends StatefulWidget {
  const PalettePage({super.key, required this.filaments});
  final List<Filament> filaments;

  @override
  State<PalettePage> createState() => _PalettePageState();
}

class _PalettePageState extends State<PalettePage> {
  String _materialFilter = 'Todos';

  List<String> get _materials {
    const materialOrder = ['PLA', 'PETG', 'ABS', 'TPU', 'ASA', 'Nylon'];
    final available = widget.filaments
        .map((filament) => filament.material)
        .where((value) => value.isNotEmpty)
        .toSet();
    final ordered = [
      ...materialOrder.where(available.contains),
      ...available.where((material) => !materialOrder.contains(material)),
    ];
    return ['Todos', ...ordered];
  }

  List<Filament> get _sortedFilaments {
    final filtered = _materialFilter == 'Todos'
        ? widget.filaments
        : widget.filaments
              .where((filament) => filament.material == _materialFilter)
              .toList();
    final sorted = [...filtered];
    sorted.sort((a, b) {
      if (_materialFilter == 'Todos') {
        final materialOrder = _materialRank(
          a.material,
        ).compareTo(_materialRank(b.material));
        if (materialOrder != 0) return materialOrder;
      }
      final aColor = colorFromHex(a.color);
      final bColor = colorFromHex(b.color);
      final aHsv = HSVColor.fromColor(aColor);
      final bHsv = HSVColor.fromColor(bColor);
      final hue = _paletteColorClass(a).compareTo(_paletteColorClass(b));
      if (hue != 0) return hue;
      return bHsv.saturation.compareTo(aHsv.saturation);
    });
    return sorted;
  }

  int _materialRank(String material) {
    const order = ['PLA', 'PETG', 'ABS', 'TPU', 'ASA', 'Nylon'];
    final index = order.indexOf(material);
    return index == -1 ? order.length : index;
  }

  double _paletteColorClass(Filament filament) {
    final namedHue = _namedPaletteHue(filament);
    if (namedHue != null) return namedHue;
    final hsv = HSVColor.fromColor(colorFromHex(filament.color));
    if (hsv.saturation < 0.18 || hsv.value < 0.18) return 400;
    return hsv.hue;
  }

  double? _namedPaletteHue(Filament filament) {
    final description = '${filament.name} ${filament.material}'.toLowerCase();
    const namedHues = {
      'red': 0.0,
      'rojo': 0.0,
      'orange': 30.0,
      'naranja': 30.0,
      'bronze': 34.0,
      'bronce': 34.0,
      'yellow': 55.0,
      'lemon': 55.0,
      'amarillo': 55.0,
      'green': 120.0,
      'verde': 120.0,
      'turquoise': 175.0,
      'cyan': 185.0,
      'blue': 210.0,
      'azul': 210.0,
      'purple': 275.0,
      'violet': 275.0,
      'morado': 275.0,
      'magenta': 315.0,
      'pink': 335.0,
      'rosa': 335.0,
    };
    for (final entry in namedHues.entries) {
      if (description.contains(entry.key)) return entry.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sortedFilaments = _sortedFilaments;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paleta de colores',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: widget.filaments.isEmpty
          ? const _EmptyPalette()
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: _materials.map((material) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(material),
                              selected: _materialFilter == material,
                              onSelected: (_) {
                                setState(() => _materialFilter = material);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (sortedFilaments.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text('No hay filamentos de este tipo'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 92,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                        itemCount: sortedFilaments.length,
                        itemBuilder: (context, index) {
                          final filament = sortedFilaments[index];
                          return _PaletteSwatch(
                            filament: filament,
                            onTap: () => _showDetails(context, filament),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _showDetails(BuildContext context, Filament filament) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilamentDetailsPage(filament: filament),
      ),
    );
  }
}

class FilamentDetailsPage extends StatelessWidget {
  const FilamentDetailsPage({super.key, required this.filament});
  final Filament filament;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(filament.color);
    final totalCapacity = filament.weight * filament.quantity;
    final progress = (filament.remaining / totalCapacity).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del filamento',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: color,
                    gradient: filamentFinishGradient(filament, color),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12, width: 2),
                    boxShadow: filamentFinishShadow(filament, color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filament.name.isEmpty ? 'Sin nombre' : filament.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${filament.brand.isEmpty ? 'Marca desconocida' : filament.brand} · ${filament.material}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filament.color.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailsSection(
              title: 'Stock',
              children: [
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Peso restante total',
                  value: '${filament.remaining.toStringAsFixed(0)} g',
                ),
                _DetailRow(
                  icon: Icons.layers_outlined,
                  label: 'Bobinas',
                  value:
                      '${filament.quantity} ${filament.quantity == 1 ? 'bobina' : 'bobinas'}',
                ),
                _DetailRow(
                  icon: Icons.scale_outlined,
                  label: 'Peso por bobina',
                  value: '${filament.weight.toStringAsFixed(0)} g',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
            _DetailsSection(
              title: 'Características',
              children: [
                _DetailRow(
                  icon: Icons.straighten,
                  label: 'Diámetro',
                  value: '${filament.diameter.toStringAsFixed(2)} mm',
                ),
                _DetailRow(
                  icon: Icons.thermostat,
                  label: 'Temperatura de boquilla',
                  value: filament.printTemperature.isEmpty
                      ? 'No indicada'
                      : '${filament.printTemperature} °C',
                ),
                _DetailRow(
                  icon: Icons.crop_square,
                  label: 'Temperatura de cama',
                  value: filament.bedTemperature.isEmpty
                      ? 'No indicada'
                      : '${filament.bedTemperature} °C',
                ),
              ],
            ),
            if (filament.price != null && filament.price! >= 0)
              _CostCalculator(filament: filament),
            _DetailsSection(
              title: 'Comparar precios y colores',
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PriceTrackerPage(filament: filament),
                    ),
                  ),
                  icon: const Icon(Icons.price_change_outlined),
                  label: const Text('Fuentes e historial de precios'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _openFilamentRadar(filament.color),
                  icon: const Icon(Icons.color_lens_outlined),
                  label: const Text('Comparar color en FilamentRadar'),
                ),
              ],
            ),
            if (filament.nfcId != null || filament.notes.isNotEmpty)
              _DetailsSection(
                title: 'Información adicional',
                children: [
                  if (filament.nfcId != null)
                    _DetailRow(
                      icon: Icons.nfc,
                      label: 'Identificador NFC',
                      value: filament.nfcId!,
                    ),
                  if (filament.notes.isNotEmpty)
                    _DetailRow(
                      icon: Icons.notes,
                      label: 'Notas',
                      value: filament.notes,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CostCalculator extends StatefulWidget {
  const _CostCalculator({required this.filament});
  final Filament filament;

  @override
  State<_CostCalculator> createState() => _CostCalculatorState();
}

class _CostCalculatorState extends State<_CostCalculator> {
  late final TextEditingController _grams = TextEditingController(text: '100');

  @override
  void dispose() {
    _grams.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filament = widget.filament;
    final price = filament.price!;
    final pricePerGram = filament.weight > 0 ? price / filament.weight : 0;
    final remainingValue = pricePerGram * filament.remaining;
    final printGrams = double.tryParse(_grams.text.replaceAll(',', '.')) ?? 0;
    final printCost = pricePerGram * printGrams;

    return _DetailsSection(
      title: 'Coste del filamento',
      children: [
        _DetailRow(
          icon: Icons.euro_outlined,
          label: 'Precio por bobina',
          value: '${price.toStringAsFixed(2)} €',
        ),
        _DetailRow(
          icon: Icons.scale_outlined,
          label: 'Coste por 100 g',
          value: '${(pricePerGram * 100).toStringAsFixed(2)} €',
        ),
        _DetailRow(
          icon: Icons.price_check_outlined,
          label: 'Coste por kg',
          value: '${(pricePerGram * 1000).toStringAsFixed(2)} €',
        ),
        _DetailRow(
          icon: Icons.inventory_2_outlined,
          label: 'Valor del stock restante',
          value: '${remainingValue.toStringAsFixed(2)} €',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _grams,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Gramos usados en la impresión',
            suffixText: 'g',
            prefixIcon: Icon(Icons.print_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          icon: Icons.calculate_outlined,
          label: 'Coste estimado de la impresión',
          value: '${printCost.toStringAsFixed(2)} €',
        ),
      ],
    );
  }
}

Future<void> _openFilamentRadar(String color) async {
  final uri = Uri.https('filamentradar.com', '/en/filament-picker', {
    'color': color.replaceFirst('#', ''),
  });
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String officialFilamentUrl(Filament filament) {
  final query = '${filament.brand} ${filament.name} ${filament.material}';
  return Uri.https('www.google.com', '/search', {'q': query}).toString();
}

class PriceTrackerPage extends StatefulWidget {
  const PriceTrackerPage({super.key, required this.filament});
  final Filament filament;

  @override
  State<PriceTrackerPage> createState() => _PriceTrackerPageState();
}

class _PriceTrackerPageState extends State<PriceTrackerPage> {
  List<Map<String, Object?>> _sources = [];
  List<Map<String, Object?>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await AppDatabase.instance.database;
    var sources = await db.query(
      'price_sources',
      where: 'filament_id = ?',
      whereArgs: [widget.filament.id],
      orderBy: 'store COLLATE NOCASE',
    );
    if (sources.isEmpty) {
      await db.insert('price_sources', {
        'filament_id': widget.filament.id,
        'store': '${widget.filament.brand} · búsqueda en Google',
        'url': officialFilamentUrl(widget.filament),
        'currency': 'EUR',
      });
      sources = await db.query(
        'price_sources',
        where: 'filament_id = ?',
        whereArgs: [widget.filament.id],
        orderBy: 'store COLLATE NOCASE',
      );
    } else {
      final officialSource = sources.firstWhere(
        (source) =>
            (source['store'] as String?)?.contains('búsqueda oficial') ==
                true ||
            (source['store'] as String?)?.contains('búsqueda en Google') ==
                true,
        orElse: () => <String, Object?>{},
      );
      if (officialSource.isNotEmpty) {
        await db.update(
          'price_sources',
          {
            'store': '${widget.filament.brand} · búsqueda en Google',
            'url': officialFilamentUrl(widget.filament),
          },
          where: 'id = ?',
          whereArgs: [officialSource['id']],
        );
        sources = await db.query(
          'price_sources',
          where: 'filament_id = ?',
          whereArgs: [widget.filament.id],
          orderBy: 'store COLLATE NOCASE',
        );
      }
    }
    final history = await db.rawQuery(
      '''
      SELECT price_history.*, price_sources.store
      FROM price_history
      INNER JOIN price_sources ON price_sources.id = price_history.source_id
      WHERE price_sources.filament_id = ?
      ORDER BY recorded_at DESC
      LIMIT 50
      ''',
      [widget.filament.id],
    );
    if (!mounted) return;
    setState(() {
      _sources = sources;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _addSource() async {
    final result = await showDialog<_PriceSourceDraft>(
      context: context,
      builder: (_) => const _PriceSourceDialog(),
    );
    if (result == null) return;
    final db = await AppDatabase.instance.database;
    await db.insert('price_sources', {
      'filament_id': widget.filament.id,
      'store': result.store,
      'url': result.url,
      'target_price': result.targetPrice,
      'currency': result.currency,
    });
    await _load();
  }

  Future<void> _recordPrice(Map<String, Object?> source) async {
    final price = await showDialog<double>(
      context: context,
      builder: (_) => _RecordPriceDialog(
        store: source['store']! as String,
        currency: source['currency']! as String,
      ),
    );
    if (price == null || price < 0) return;
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'price_sources',
      {'current_price': price, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [source['id']],
    );
    await db.insert('price_history', {
      'source_id': source['id'],
      'price': price,
      'recorded_at': now,
    });
    await _load();
  }

  Future<void> _deletePriceHistory(Map<String, Object?> entry) async {
    final db = await AppDatabase.instance.database;
    await db.delete('price_history', where: 'id = ?', whereArgs: [entry['id']]);
    final remaining = await db.query(
      'price_history',
      where: 'source_id = ?',
      whereArgs: [entry['source_id']],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );
    await db.update(
      'price_sources',
      {
        'current_price': remaining.isEmpty ? null : remaining.first['price'],
        'updated_at': remaining.isEmpty ? null : remaining.first['recorded_at'],
      },
      where: 'id = ?',
      whereArgs: [entry['source_id']],
    );
    await _load();
  }

  Future<void> _openSource(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Seguimiento de precios',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: _addSource,
          tooltip: 'Añadir tienda',
          icon: const Icon(Icons.add_link),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addSource,
      icon: const Icon(Icons.add),
      label: const Text('Añadir tienda'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Text(
                widget.filament.name.isEmpty
                    ? '${widget.filament.brand} ${widget.filament.material}'
                    : widget.filament.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Los precios se registran bajo demanda. No se usan credenciales ni scraping.',
              ),
              const SizedBox(height: 16),
              if (_sources.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Busca el producto en Google y añade la URL exacta de la página que quieras seguir.',
                    ),
                  ),
                )
              else
                ..._sources.map(
                  (source) => _PriceSourceCard(
                    source: source,
                    weight: widget.filament.weight,
                    onOpen: () => _openSource(source['url']! as String),
                    onRecord: () => _recordPrice(source),
                  ),
                ),
              if (_history.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Historial reciente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._history.map((entry) {
                  final price = (entry['price']! as num).toDouble();
                  final lowestPrice = _history
                      .map((item) => (item['price']! as num).toDouble())
                      .reduce((a, b) => a < b ? a : b);
                  final isLowest = price == lowestPrice;
                  return Dismissible(
                    key: ValueKey('price-history-${entry['id']}'),
                    direction: DismissDirection.horizontal,
                    background: _PriceHistorySwipeBackground(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerLeft,
                    ),
                    secondaryBackground: _PriceHistorySwipeBackground(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerRight,
                    ),
                    onDismissed: (_) => _deletePriceHistory(entry),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${price.toStringAsFixed(2)} € · ${entry['store']}',
                              ),
                            ),
                            if (isLowest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'MÁS BAJO',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          _formatDate(entry['recorded_at']! as String),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
  );
}

class _PriceHistorySwipeBackground extends StatelessWidget {
  const _PriceHistorySwipeBackground({
    required this.color,
    required this.alignment,
  });

  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    alignment: alignment,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.delete_outline, color: Colors.white),
        SizedBox(width: 8),
        Text('Eliminar', style: TextStyle(color: Colors.white)),
      ],
    ),
  );
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value;
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _PriceSourceCard extends StatelessWidget {
  const _PriceSourceCard({
    required this.source,
    required this.weight,
    required this.onOpen,
    required this.onRecord,
  });
  final Map<String, Object?> source;
  final double weight;
  final VoidCallback onOpen;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final price = (source['current_price'] as num?)?.toDouble();
    final target = (source['target_price'] as num?)?.toDouble();
    final currency = source['currency'] as String? ?? 'EUR';
    final goodPrice = price != null && target != null && price <= target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    source['store']! as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onOpen,
                  tooltip: 'Abrir tienda',
                  icon: const Icon(Icons.open_in_new),
                ),
              ],
            ),
            Text(
              price == null
                  ? 'Sin precio registrado'
                  : '$price $currency · ${(price / weight * 1000).toStringAsFixed(2)} $currency/kg',
            ),
            if (target != null)
              Text(
                goodPrice
                    ? 'Precio objetivo alcanzado'
                    : 'Objetivo: ${target.toStringAsFixed(2)} $currency',
                style: TextStyle(
                  color: goodPrice ? Colors.green : null,
                  fontWeight: goodPrice ? FontWeight.bold : null,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRecord,
                icon: const Icon(Icons.add_chart),
                label: const Text('Registrar precio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSourceDraft {
  const _PriceSourceDraft({
    required this.store,
    required this.url,
    required this.currency,
    required this.targetPrice,
  });
  final String store;
  final String url;
  final String currency;
  final double? targetPrice;
}

class _RecordPriceDialog extends StatefulWidget {
  const _RecordPriceDialog({required this.store, required this.currency});

  final String store;
  final String currency;

  @override
  State<_RecordPriceDialog> createState() => _RecordPriceDialogState();
}

class _RecordPriceDialogState extends State<_RecordPriceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Registrar precio · ${widget.store}'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio (${widget.currency})',
        border: const OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          double.tryParse(_controller.text.replaceAll(',', '.')),
        ),
        child: const Text('Guardar'),
      ),
    ],
  );
}

class _PriceSourceDialog extends StatefulWidget {
  const _PriceSourceDialog();

  @override
  State<_PriceSourceDialog> createState() => _PriceSourceDialogState();
}

class _PriceSourceDialogState extends State<_PriceSourceDialog> {
  final _store = TextEditingController();
  final _url = TextEditingController();
  final _target = TextEditingController();

  @override
  void dispose() {
    _store.dispose();
    _url.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Añadir fuente de precio'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _store,
            decoration: const InputDecoration(
              labelText: 'Tienda',
              hintText: 'Amazon, AliExpress, Anycubic...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL del producto',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio objetivo (€), opcional',
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          final store = _store.text.trim();
          final url = _url.text.trim();
          final uri = Uri.tryParse(url);
          if (store.isEmpty ||
              uri == null ||
              (uri.scheme != 'http' && uri.scheme != 'https')) {
            return;
          }
          Navigator.pop(
            context,
            _PriceSourceDraft(
              store: store,
              url: url,
              currency: 'EUR',
              targetPrice: double.tryParse(
                _target.text.trim().replaceAll(',', '.'),
              ),
            ),
          );
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.filament, required this.onTap});
  final Filament filament;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: filament.name,
    button: true,
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorFromHex(filament.color),
                gradient: filamentFinishGradient(
                  filament,
                  colorFromHex(filament.color),
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12, width: 2),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                  ...?filamentFinishShadow(
                    filament,
                    colorFromHex(filament.color),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _QuantityBadge(quantity: filament.quantity),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            filament.name.isEmpty ? filament.color : filament.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.quantity});
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xfff8f7f4),
        border: Border.all(color: Colors.grey, width: 0.8),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$quantity',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyPalette extends StatelessWidget {
  const _EmptyPalette();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Todavía no tienes colores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Añade bobinas para crear tu paleta de filamentos.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu biblioteca está vacía',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Añade una bobina manualmente o acerca una etiqueta NFC.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class FilamentFormPage extends StatefulWidget {
  const FilamentFormPage({
    super.key,
    this.nfcId,
    this.nfcText,
    this.nfcData,
    this.existing,
  });
  final String? nfcId;
  final String? nfcText;
  final NfcFilamentData? nfcData;
  final Filament? existing;

  @override
  State<FilamentFormPage> createState() => _FilamentFormPageState();
}

class _FilamentFormPageState extends State<FilamentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand = TextEditingController();
  late final TextEditingController _name = TextEditingController(text: '');
  late final TextEditingController _color = TextEditingController(
    text: '#EF6C43',
  );
  late final TextEditingController _weight = TextEditingController(
    text: '1000',
  );
  late final TextEditingController _remaining = TextEditingController(
    text: '1000',
  );
  late final TextEditingController _quantity = TextEditingController(text: '1');
  late final TextEditingController _diameter = TextEditingController(
    text: '1.75',
  );
  late final TextEditingController _printTemp = TextEditingController(
    text: '200-220',
  );
  late final TextEditingController _bedTemp = TextEditingController(
    text: '50-60',
  );
  late final TextEditingController _notes = TextEditingController();
  late final TextEditingController _location = TextEditingController();
  late final TextEditingController _purchaseDate = TextEditingController();
  late final TextEditingController _price = TextEditingController();
  String _material = 'PLA';
  String _selectedBrand = 'Anycubic';
  List<CatalogFilament> _suggestions = [];
  List<String> _manufacturerSuggestions = [];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _selectedBrand = _manufacturers.contains(existing.brand)
          ? existing.brand
          : 'Otro';
      _brand.text = existing.brand;
      _selectedBrand = existing.brand;
      _name.text = existing.name;
      _color.text = existing.color;
      _weight.text = existing.weight.toStringAsFixed(0);
      _remaining.text = (existing.remaining / existing.quantity)
          .toStringAsFixed(0);
      _quantity.text = existing.quantity.toString();
      _diameter.text = existing.diameter.toStringAsFixed(2);
      _printTemp.text = existing.printTemperature;
      _bedTemp.text = existing.bedTemperature;
      _notes.text = existing.notes;
      _location.text = existing.location;
      _purchaseDate.text = existing.purchaseDate ?? '';
      _price.text = existing.price?.toStringAsFixed(2) ?? '';
      _material =
          [
            'PLA',
            'PETG',
            'ABS',
            'TPU',
            'ASA',
            'Nylon',
            'Otro',
          ].contains(existing.material)
          ? existing.material
          : 'Otro';
      return;
    }
    final data = widget.nfcData;
    if (data != null) {
      _selectedBrand = data.brand ?? 'Anycubic';
      _brand.text = _selectedBrand;
      _name.text = data.name ?? '';
      _color.text = data.color ?? _color.text;
      _weight.text = data.weight?.toStringAsFixed(0) ?? _weight.text;
      _remaining.text = data.weight?.toStringAsFixed(0) ?? _remaining.text;
      _diameter.text = data.diameter?.toStringAsFixed(2) ?? _diameter.text;
      _printTemp.text = data.printTemperature ?? _printTemp.text;
      _bedTemp.text = data.bedTemperature ?? _bedTemp.text;
      if (data.material != null &&
          [
            'PLA',
            'PETG',
            'ABS',
            'TPU',
            'ASA',
            'Nylon',
            'Otro',
          ].contains(data.material)) {
        _material = data.material!;
      }
    } else if (widget.nfcText != null && widget.nfcText!.isNotEmpty) {
      _name.text = widget.nfcText!;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _brand,
      _name,
      _color,
      _weight,
      _remaining,
      _quantity,
      _diameter,
      _printTemp,
      _bedTemp,
      _notes,
      _location,
      _purchaseDate,
      _price,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Filament(
        id:
            widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        brand: _brand.text.trim().isEmpty ? _selectedBrand : _brand.text.trim(),
        name: _name.text.trim(),
        material: _material,
        color: _color.text.trim(),
        weight: double.parse(_weight.text.replaceAll(',', '.')),
        remaining:
            double.parse(_remaining.text.replaceAll(',', '.')) *
            int.parse(_quantity.text),
        quantity: int.parse(_quantity.text),
        diameter: double.parse(_diameter.text.replaceAll(',', '.')),
        printTemperature: _printTemp.text.trim(),
        bedTemperature: _bedTemp.text.trim(),
        notes: _notes.text.trim(),
        nfcId: widget.nfcId ?? widget.existing?.nfcId,
        location: _location.text.trim(),
        purchaseDate: _purchaseDate.text.trim().isEmpty
            ? null
            : _purchaseDate.text.trim(),
        price: _price.text.trim().isEmpty
            ? null
            : double.tryParse(_price.text.replaceAll(',', '.')),
      ),
    );
  }

  void _updateCatalogSuggestions(String value) {
    setState(() {
      _suggestions = catalogSuggestions(_selectedBrand, value);
    });
  }

  void _updateManufacturerSuggestions(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      _selectedBrand = value.trim();
      _manufacturerSuggestions = query.isEmpty
          ? []
          : _manufacturers
                .where((brand) => brand.toLowerCase().contains(query))
                .toList();
      _suggestions = catalogSuggestions(_selectedBrand, _name.text);
    });
  }

  void _applyManufacturer(String brand) {
    setState(() {
      _brand.text = brand;
      _selectedBrand = brand;
      _manufacturerSuggestions = [];
      _suggestions = catalogSuggestions(brand, _name.text);
    });
  }

  void _applyCatalogItem(CatalogFilament item) {
    setState(() {
      _name.text = item.name;
      _material = item.material;
      _color.text = item.color;
      _printTemp.text = item.nozzle;
      _bedTemp.text = item.bed;
      _suggestions = [];
    });
  }

  String? _numberValidator(String? value) {
    if (value == null || double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Introduce un número válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.nfcId == null ? 'Nueva bobina' : 'Bobina detectada'),
      actions: [
        IconButton(
          tooltip: 'Guardar filamento',
          onPressed: _submit,
          icon: const Icon(Icons.check),
        ),
      ],
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          32 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          if (widget.nfcId != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.nfc),
                title: const Text('Etiqueta NFC detectada'),
                subtitle: Text(widget.nfcId!),
              ),
            ),
          _section('Identificación'),
          _field(
            _brand,
            'Fabricante',
            Icons.business,
            required: true,
            onChanged: _updateManufacturerSuggestions,
          ),
          if (_manufacturerSuggestions.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: _manufacturerSuggestions
                    .map(
                      (brand) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.business_outlined),
                        title: Text(brand),
                        onTap: () => _applyManufacturer(brand),
                      ),
                    )
                    .toList(),
              ),
            ),
          _field(
            _name,
            'Nombre o color comercial',
            Icons.label_outline,
            required: true,
            onChanged: _updateCatalogSuggestions,
          ),
          if (_suggestions.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: _suggestions
                    .map(
                      (item) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: colorFromHex(item.color),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.material} · ${item.color} · ${item.nozzle} °C',
                        ),
                        onTap: () => _applyCatalogItem(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          DropdownButtonFormField<String>(
            initialValue: _material,
            decoration: const InputDecoration(
              labelText: 'Material',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: ['PLA', 'PETG', 'ABS', 'TPU', 'ASA', 'Nylon', 'Otro']
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) => setState(() => _material = value!),
          ),
          const SizedBox(height: 12),
          _field(
            _color,
            'Color hexadecimal',
            Icons.palette_outlined,
            required: true,
          ),
          _section('Stock y medidas'),
          Row(
            children: [
              Expanded(
                child: _field(
                  _weight,
                  'Peso inicial (g)',
                  Icons.scale,
                  validator: _numberValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  _remaining,
                  'Restante (g)',
                  Icons.inventory_2_outlined,
                  validator: _numberValidator,
                ),
              ),
            ],
          ),
          _field(
            _quantity,
            'Número de bobinas iguales',
            Icons.layers_outlined,
            validator: (value) {
              final count = int.tryParse(value ?? '');
              return count == null || count < 1
                  ? 'Introduce un número entero mayor que 0'
                  : null;
            },
          ),
          _field(
            _diameter,
            'Diámetro (mm)',
            Icons.straighten,
            validator: _numberValidator,
          ),
          _section('Características de impresión'),
          Row(
            children: [
              Expanded(
                child: _field(_printTemp, 'Boquilla (°C)', Icons.thermostat),
              ),
              const SizedBox(width: 12),
              Expanded(child: _field(_bedTemp, 'Cama (°C)', Icons.crop_square)),
            ],
          ),
          _field(_notes, 'Notas', Icons.notes, maxLines: 3),
          _section('Inventario'),
          _field(_location, 'Ubicación', Icons.location_on_outlined),
          Row(
            children: [
              Expanded(
                child: _field(
                  _purchaseDate,
                  'Fecha de compra',
                  Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  _price,
                  'Precio (€)',
                  Icons.euro_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return _numberValidator(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar en biblioteca'),
          ),
        ],
      ),
    ),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      validator:
          validator ??
          (required
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Campo obligatorio'
                    : null
              : null),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    ),
  );
}
