import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_mecanica/models/servico.dart';
import 'package:oficina_mecanica/util/formato.dart';
import 'package:oficina_mecanica/wagwagwag/humor.dart';

Servico _servico(String status) => Servico(
  placa: 'ABC1D23',
  cliente: 'Fulano',
  descricao: 'Troca de óleo',
  valor: 150,
  status: status,
);

void main() {
  test('Servico vai e volta do Map sem perder dados', () {
    final original = _servico(StatusServico.emAndamento);
    final copia = Servico.fromMap({...original.toMap(), 'id': 7});
    expect(copia.id, 7);
    expect(copia.placa, original.placa);
    expect(copia.valor, original.valor);
    expect(copia.status, original.status);
  });

  test('formata e lê valores em reais', () {
    expect(formatarReais(1234.5), 'R\$ 1.234,50');
    expect(lerValor('1.234,50'), 1234.5);
    expect(lerValor('99.90'), 99.9);
    expect(lerValor('abc'), isNull);
  });

  test('humor do Wagwagwag segue os dados', () {
    expect(calcularHumor([]), HumorWag.dormindo);
    expect(
      calcularHumor(List.generate(5, (_) => _servico(StatusServico.aberta))),
      HumorWag.preocupado,
    );
    expect(
      calcularHumor([
        _servico(StatusServico.concluida),
        _servico(StatusServico.aberta),
      ]),
      HumorWag.feliz,
    );
    expect(
      calcularHumor([
        _servico(StatusServico.aberta),
        _servico(StatusServico.emAndamento),
      ]),
      HumorWag.tranquilo,
    );
  });
}
