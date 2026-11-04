import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/servico.dart';

/// Toda a conversa com o SQLite fica aqui. As telas só chamam estes métodos.
class DbHelper {
  /// Os testes trocam o nome para não mexer no banco de verdade.
  static String nomeBanco = 'oficina.db';
  static const tabela = 'servicos';

  static Database? _db;

  /// Abre o banco uma vez só e reaproveita a conexão.
  static Future<Database> get banco async {
    _db ??= await _abrir();
    return _db!;
  }

  static Future<Database> _abrir() async {
    final caminho = join(await _pastaDoBanco(), nomeBanco);
    return openDatabase(
      caminho,
      version: 1,
      // onCreate roda só na primeira vez, quando o arquivo do banco não existe.
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tabela (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            placa TEXT NOT NULL,
            cliente TEXT NOT NULL,
            descricao TEXT NOT NULL,
            valor REAL NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// No Windows o FFI salvaria o banco na pasta de onde o app foi aberto;
  /// usar o AppData garante que os dados fiquem sempre no mesmo lugar.
  static Future<String> _pastaDoBanco() async {
    final appData = Platform.environment['APPDATA'];
    if (Platform.isWindows && appData != null) {
      final pasta = Directory(join(appData, 'OficinaMecanica'));
      await pasta.create(recursive: true);
      return pasta.path;
    }
    return getDatabasesPath();
  }

  // ---------- CRUD ----------

  static Future<int> inserir(Servico servico) async {
    final db = await banco;
    return db.insert(tabela, servico.toMap());
  }

  /// Lista os serviços. Se [status] vier preenchido, filtra com WHERE.
  static Future<List<Servico>> listar({String? status}) async {
    final db = await banco;
    final linhas = await db.query(
      tabela,
      where: status == null ? null : 'status = ?',
      whereArgs: status == null ? null : [status],
      orderBy: 'id DESC',
    );
    return linhas.map((linha) => Servico.fromMap(linha)).toList();
  }

  static Future<int> atualizar(Servico servico) async {
    final db = await banco;
    return db.update(
      tabela,
      servico.toMap(),
      where: 'id = ?',
      whereArgs: [servico.id],
    );
  }

  static Future<int> excluir(int id) async {
    final db = await banco;
    return db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Regra própria do tema ----------

  /// Faturamento previsto: soma do valor dos serviços (do filtro, se houver).
  static Future<double> faturamentoPrevisto({String? status}) async {
    final db = await banco;
    final resultado = await db.rawQuery(
      status == null
          ? 'SELECT SUM(valor) AS total FROM $tabela'
          : 'SELECT SUM(valor) AS total FROM $tabela WHERE status = ?',
      status == null ? null : [status],
    );
    // SUM devolve null quando a tabela está vazia.
    return (resultado.first['total'] as num?)?.toDouble() ?? 0;
  }

  /// Quantidade e soma de valores agrupadas por status (tela de resumo).
  static Future<List<Map<String, Object?>>> resumoPorStatus() async {
    final db = await banco;
    return db.rawQuery(
      'SELECT status, COUNT(*) AS quantidade, SUM(valor) AS total '
      'FROM $tabela GROUP BY status',
    );
  }
}
