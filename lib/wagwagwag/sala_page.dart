import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/servico.dart';
import '../tema/aero.dart';
import '../tema/memes.dart';
import 'humor.dart';
import 'personagem.dart';

/// A sala do Wagwagwag: ele grandão na garagem, reagindo a toques e botões,
/// no estilo Talking Tom. Recebe os serviços já lidos do banco pela lista.
class SalaWagPage extends StatefulWidget {
  final List<Servico> servicos;

  const SalaWagPage({super.key, required this.servicos});

  @override
  State<SalaWagPage> createState() => _SalaWagPageState();
}

class _SalaWagPageState extends State<SalaWagPage> {
  final _sorteio = Random();

  /// Pose que passa por cima do humor por um instante.
  String? _poseTemporaria;
  bool _dormindo = false;
  late String _fala = falasDoWag(widget.servicos).first;
  int _indiceFala = 0;
  int _pulos = 0;
  int _toques = 0;

  Timer? _timerPose;
  Timer? _relogioOcioso;
  DateTime _ultimaInteracao = DateTime.now();

  @override
  void initState() {
    super.initState();
    // A cada poucos segundos sem ninguém mexer, ele faz alguma coisa sozinho.
    _relogioOcioso = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _ocioso(),
    );
  }

  @override
  void dispose() {
    _timerPose?.cancel();
    _relogioOcioso?.cancel();
    super.dispose();
  }

  String _sortear(List<String> frases) =>
      frases[_sorteio.nextInt(frases.length)];

  /// Mostra uma pose e uma fala por um tempo e depois volta ao normal.
  void _reagir(String pose, String fala, {int ms = 1600, bool pulo = true}) {
    _ultimaInteracao = DateTime.now();
    setState(() {
      _poseTemporaria = pose;
      _fala = fala;
      if (pulo) _pulos++;
    });
    _timerPose?.cancel();
    _timerPose = Timer(Duration(milliseconds: ms), () {
      if (mounted) setState(() => _poseTemporaria = null);
    });
  }

  void _ocioso() {
    if (!mounted || _dormindo) return;
    final parado = DateTime.now().difference(_ultimaInteracao).inSeconds;
    if (parado >= 30) {
      // Igual ao Talking Tom: largou ele sozinho, ele cochila.
      setState(() {
        _dormindo = true;
        _fala = 'Zzz...';
      });
    } else if (parado >= 8 && _sorteio.nextBool()) {
      setState(() {
        _fala = _sortear(falasTedio);
        _pulos++;
      });
    }
  }

  void _tocarNoBoneco(TapUpDetails detalhes, double tamanho) {
    _toques++;
    if (_dormindo) {
      setState(() => _dormindo = false);
      _reagir('cutucado', _sortear(falasAcordar), ms: 1200);
    } else if (detalhes.localPosition.dy < tamanho * 0.4) {
      _reagir('falando', _sortear(falasCabeca));
    } else {
      _reagir('cutucado', _sortear(falasBarriga), ms: 1100);
    }

    // Segredo: a cada 7 toques ele entrega o esquema.
    if (_toques % 7 == 0) {
      mostrarMeme(
        context,
        titulo: 'Wagwagwag contou um segredo',
        caminho: Memes.compramoOJuiz,
        texto: 'Shhh... isso fica entre nós.',
        botao: 'Esquece isso',
      );
    }
  }

  void _falar() {
    final falas = falasDoWag(widget.servicos);
    _indiceFala++;
    setState(() => _dormindo = false);
    _reagir('falando', falas[_indiceFala % falas.length]);
  }

  void _comemorar() {
    setState(() => _dormindo = false);
    _reagir('feliz', _sortear(falasComemorar), ms: 2000);
    // Três pulinhos seguidos.
    for (var i = 1; i <= 2; i++) {
      Timer(Duration(milliseconds: 400 * i), () {
        if (mounted) setState(() => _pulos++);
      });
    }
  }

  void _alternarSono() {
    _ultimaInteracao = DateTime.now();
    if (_dormindo) {
      setState(() => _dormindo = false);
      _reagir('cutucado', _sortear(falasAcordar), ms: 1200);
    } else {
      _timerPose?.cancel();
      setState(() {
        _poseTemporaria = null;
        _dormindo = true;
        _fala = 'Zzz... só cinco minutinhos...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final humor = calcularHumor(widget.servicos);
    final pose = _dormindo ? 'dormindo' : (_poseTemporaria ?? humor.name);

    return AeroPagina(
      titulo: 'Sala do Wagwagwag',
      fundo: const _FundoSala(),
      corpo: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AeroVidro(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  _fala,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: sombraTexto,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, area) {
                final tamanho = min(
                  area.maxWidth * 0.95,
                  area.maxHeight * 0.95,
                );
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTapUp: (d) => _tocarNoBoneco(d, tamanho),
                    child: WagPersonagem(
                      pose: pose,
                      tamanho: tamanho,
                      pulos: _pulos,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                AeroBotao(
                  onPressed: _falar,
                  icone: Icons.record_voice_over,
                  texto: 'Falar',
                  cor: AeroCores.aqua,
                  compacto: true,
                ),
                AeroBotao(
                  onPressed: _comemorar,
                  icone: Icons.celebration,
                  texto: 'Comemorar',
                  compacto: true,
                ),
                AeroBotao(
                  onPressed: _alternarSono,
                  icone: _dormindo ? Icons.wb_sunny : Icons.bedtime,
                  texto: _dormindo ? 'Acordar' : 'Dormir',
                  cor: AeroCores.ambar,
                  compacto: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Garagem ao fundo; enquanto a imagem não existir, usa o fundo Aero.
class _FundoSala extends StatelessWidget {
  const _FundoSala();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'lib/assets/wagwagwag/sala.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, erro, pilha) =>
              const AeroFundo(child: SizedBox.expand()),
        ),
        // Escurece embaixo para os botões aparecerem bem.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x99000000)],
            ),
          ),
        ),
      ],
    );
  }
}
