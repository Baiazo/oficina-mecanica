import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:oficina_mecanica/database/db_helper.dart';
import 'package:oficina_mecanica/models/servico.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DbHelper.nomeBanco = 'oficina_teste.db';
    // Começa de um banco limpo para o teste não depender de execuções antigas.
    final db = await DbHelper.banco;
    await db.delete(DbHelper.tabela);
  });

  test('CRUD completo e faturamento previsto', () async {
    final id = await DbHelper.inserir(
      Servico(
        placa: 'ABC1234',
        cliente: 'Maria',
        descricao: 'Troca de pastilha',
        valor: 200,
        status: StatusServico.aberta,
      ),
    );
    await DbHelper.inserir(
      Servico(
        placa: 'XYZ9A87',
        cliente: 'João',
        descricao: 'Alinhamento',
        valor: 80.5,
        status: StatusServico.concluida,
      ),
    );

    expect((await DbHelper.listar()).length, 2);
    expect((await DbHelper.listar(status: StatusServico.aberta)).length, 1);
    expect(await DbHelper.faturamentoPrevisto(), 280.5);
    expect(
      await DbHelper.faturamentoPrevisto(status: StatusServico.concluida),
      80.5,
    );

    await DbHelper.atualizar(
      Servico(
        id: id,
        placa: 'ABC1234',
        cliente: 'Maria',
        descricao: 'Troca de pastilha e disco',
        valor: 350,
        status: StatusServico.emAndamento,
      ),
    );
    final emAndamento = await DbHelper.listar(
      status: StatusServico.emAndamento,
    );
    expect(emAndamento.single.descricao, 'Troca de pastilha e disco');
    expect(await DbHelper.faturamentoPrevisto(), 430.5);

    final resumo = await DbHelper.resumoPorStatus();
    expect(resumo.length, 2);

    await DbHelper.excluir(id);
    expect((await DbHelper.listar()).length, 1);
  });
}
