import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/servico.dart';
import '../tema/aero.dart';
import '../tema/memes.dart';
import '../util/formato.dart';
import '../wagwagwag/humor.dart';
import '../wagwagwag/wagwagwag.dart';

/// Terceira tela: resumo que lê o banco (GROUP BY status) e o Wagwagwag grande.
class ResumoPage extends StatefulWidget {
  const ResumoPage({super.key});

  @override
  State<ResumoPage> createState() => _ResumoPageState();
}

class _ResumoPageState extends State<ResumoPage> {
  List<Servico> _servicos = [];
  final Map<String, int> _quantidade = {};
  final Map<String, double> _total = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final servicos = await DbHelper.listar();
    final linhas = await DbHelper.resumoPorStatus();
    if (!mounted) return;
    setState(() {
      _servicos = servicos;
      for (final linha in linhas) {
        final status = linha['status'] as String;
        _quantidade[status] = linha['quantidade'] as int;
        _total[status] = (linha['total'] as num).toDouble();
      }
      _carregando = false;
    });
  }

  double get _totalGeral => _total.values.fold(0, (soma, v) => soma + v);

  double get _aReceber =>
      (_total[StatusServico.aberta] ?? 0) +
      (_total[StatusServico.emAndamento] ?? 0);

  @override
  Widget build(BuildContext context) {
    return AeroPagina(
      titulo: 'Resumo da oficina',
      corpo: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wagwagwag(servicos: _servicos, tamanho: 170),
                const SizedBox(height: 16),
                // Oficina em dia ganha a águia; senão, o Mengão esmaga.
                Center(
                  child: MemeImagem(
                    caminho: calcularHumor(_servicos) == HumorWag.feliz
                        ? Memes.aguiaPisando
                        : Memes.mengaoEsmaga,
                    altura: 200,
                  ),
                ),
                const SizedBox(height: 16),
                _cartao(
                  'Faturamento previsto',
                  formatarReais(_totalGeral),
                  Icons.payments,
                  AeroCores.vermelho,
                ),
                _cartao(
                  'Já concluído',
                  formatarReais(_total[StatusServico.concluida] ?? 0),
                  Icons.check_circle,
                  AeroCores.lima,
                ),
                _cartao(
                  'Ainda a receber (aberta + em andamento)',
                  formatarReais(_aReceber),
                  Icons.hourglass_bottom,
                  AeroCores.ambar,
                ),
                const SizedBox(height: 16),
                AeroVidro(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Por status',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              shadows: sombraTexto,
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (final status in StatusServico.todos)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              AeroOrbe(
                                cor: StatusServico.cor(status),
                                tamanho: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${StatusServico.rotulo(status)}: '
                                  '${_quantidade[status] ?? 0} serviço(s)',
                                ),
                              ),
                              Text(
                                formatarReais(_total[status] ?? 0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _cartao(String titulo, String valor, IconData icone, Color cor) {
    return AeroVidro(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AeroOrbe(
            cor: cor,
            tamanho: 52,
            child: Icon(icone, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white70)),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    shadows: sombraTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
