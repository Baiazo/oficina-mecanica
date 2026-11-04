import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/servico.dart';
import '../tema/aero.dart';
import '../tema/memes.dart';
import '../util/formato.dart';
import '../wagwagwag/humor.dart';
import '../wagwagwag/wagwagwag.dart';
import 'cadastro_page.dart';
import 'resumo_page.dart';

/// Tela inicial: lista de serviços com filtro por status e faturamento previsto.
class ListaServicosPage extends StatefulWidget {
  const ListaServicosPage({super.key});

  @override
  State<ListaServicosPage> createState() => _ListaServicosPageState();
}

class _ListaServicosPageState extends State<ListaServicosPage> {
  /// Serviços do filtro atual (o que aparece na lista).
  List<Servico> _servicos = [];

  /// Todos os serviços, para o Wagwagwag saber como está a oficina.
  List<Servico> _todos = [];

  /// null = todos os status.
  String? _filtro;
  double _faturamento = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final servicos = await DbHelper.listar(status: _filtro);
    final todos = await DbHelper.listar();
    final faturamento = await DbHelper.faturamentoPrevisto(status: _filtro);
    if (!mounted) return;
    setState(() {
      _servicos = servicos;
      _todos = todos;
      _faturamento = faturamento;
      _carregando = false;
    });
  }

  void _mudarFiltro(String? status) {
    setState(() => _filtro = status);
    _carregar();
  }

  /// Abre o cadastro (novo ou edição) e grava o Map que voltar no Navigator.pop.
  Future<void> _abrirCadastro([Servico? servico]) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroServicoPage(servico: servico),
      ),
    );
    if (resultado == null) return; // voltou sem salvar

    if (servico == null) {
      await DbHelper.inserir(Servico.fromMap(resultado));
    } else {
      await DbHelper.atualizar(
        Servico.fromMap({...resultado, 'id': servico.id}),
      );
    }
    _carregar();
    if (!mounted) return;

    final placa = resultado['placa'] as String;
    // Comemora quando o serviço acabou de virar "concluída".
    final concluiuAgora =
        resultado['status'] == StatusServico.concluida &&
        servico?.status != StatusServico.concluida;

    if (concluiuAgora) {
      mostrarMeme(
        context,
        titulo: '$placa pronto!',
        caminho: Memes.saiDaFrente,
        texto: 'Serviço concluído. Pode liberar o carro!',
        cor: AeroCores.lima,
      );
    } else if (servico == null) {
      mostrarMeme(
        context,
        titulo: 'Serviço cadastrado!',
        caminho: Memes.vaiMengo,
        texto: '$placa entrou na oficina. Bora trabalhar!',
      );
    } else {
      _avisar('Serviço atualizado');
    }
  }

  Future<void> _excluir(Servico servico) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vai excluir mesmo?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MemeImagem(caminho: Memes.falaMal, altura: 220),
            const SizedBox(height: 12),
            Text('${servico.placa} - ${servico.descricao}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Foi mal',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          AeroBotao(
            onPressed: () => Navigator.pop(context, true),
            texto: 'Excluir',
            icone: Icons.delete,
            compacto: true,
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await DbHelper.excluir(servico.id!);
    _avisar('Serviço excluído');
    _carregar();
  }

  void _avisar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _abrirResumo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResumoPage()),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return AeroPagina(
      titulo: 'Oficina Mecânica',
      acoes: [
        IconButton(
          tooltip: 'Resumo',
          icon: const Icon(Icons.bar_chart, shadows: sombraTexto),
          onPressed: _abrirResumo,
        ),
      ],
      botao: AeroBotao(
        onPressed: () => _abrirCadastro(),
        icone: Icons.add,
        texto: 'Novo serviço',
      ),
      corpo: _carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Espaço do assistente: ele lê os mesmos dados do banco.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Wagwagwag(servicos: _todos, tamanho: 96),
                ),
                _cabecalhoFaturamento(),
                if (calcularHumor(_todos) == HumorWag.preocupado)
                  MemeAviso(
                    caminho: Memes.mengoPorra,
                    texto:
                        '${_pendentes()} serviços esperando! '
                        'Bora acelerar essa oficina!',
                  ),
                _filtros(),
                if (_filtro == StatusServico.concluida && _servicos.isNotEmpty)
                  const MemeAviso(
                    caminho: Memes.naoQuerendoGabar,
                    texto: 'Não é querendo me gabar, mas olha quanto carro pronto.',
                  ),
                const SizedBox(height: 8),
                Expanded(child: _lista()),
              ],
            ),
    );
  }

  int _pendentes() =>
      _todos.where((s) => s.status != StatusServico.concluida).length;

  Widget _cabecalhoFaturamento() {
    final rotulo = _filtro == null
        ? 'Faturamento previsto (todos)'
        : 'Faturamento previsto (${StatusServico.rotulo(_filtro!)})';
    return AeroVidro(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          const AeroOrbe(
            cor: AeroCores.lima,
            tamanho: 48,
            child: Icon(Icons.payments, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: const TextStyle(color: Colors.white70)),
                Text(
                  formatarReais(_faturamento),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    shadows: sombraTexto,
                  ),
                ),
              ],
            ),
          ),
          Text('${_servicos.length} serviço(s)'),
        ],
      ),
    );
  }

  Widget _filtros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AeroPilula(
            texto: 'Todos',
            selecionada: _filtro == null,
            onTap: () => _mudarFiltro(null),
          ),
          for (final status in StatusServico.todos) ...[
            const SizedBox(width: 8),
            AeroPilula(
              texto: StatusServico.rotulo(status),
              selecionada: _filtro == status,
              cor: StatusServico.cor(status),
              onTap: () => _mudarFiltro(status),
            ),
          ],
        ],
      ),
    );
  }

  Widget _lista() {
    if (_servicos.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: AeroVidro(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Oficina vazia de verdade: tranquilidade pura.
                if (_filtro == null) ...[
                  const MemeImagem(
                    caminho: Memes.tranquilidadePura,
                    altura: 200,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  _filtro == null
                      ? 'Nenhum serviço cadastrado.\nToque em "Novo serviço" para começar.'
                      : 'Nenhum serviço com status "${StatusServico.rotulo(_filtro!)}".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 96,
      ), // espaço para o botão flutuante
      itemCount: _servicos.length,
      itemBuilder: (context, index) {
        final servico = _servicos[index];
        final cor = StatusServico.cor(servico.status);
        return GestureDetector(
          onTap: () => _abrirCadastro(servico),
          child: AeroVidro(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                AeroOrbe(
                  cor: cor,
                  tamanho: 44,
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${servico.placa} - ${servico.cliente}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          shadows: sombraTexto,
                        ),
                      ),
                      Text(
                        servico.descricao,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        StatusServico.rotulo(servico.status),
                        style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatarReais(servico.valor),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  onPressed: () => _excluir(servico),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
