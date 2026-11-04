import 'dart:async';

import 'package:flutter/material.dart';

import '../models/servico.dart';
import '../tema/aero.dart';
import 'humor.dart';
import 'personagem.dart';
import 'sala_page.dart';

/// Assistente da oficina. Recebe os serviços já lidos do banco e reage a eles.
///
/// As poses ficam em lib/assets/wagwagwag (geradas no Higgsfield): uma por
/// humor, mais "cutucado" e "falando". Tocar no boneco abre a sala dele;
/// tocar no balão troca a frase.
///
/// Próximas fases:
/// - Fase 2: botão de microfone que grava (pacote record) e toca de volta
///   acelerado (audioplayers, setPlaybackRate(1.5)) para a voz fininha,
///   mostrando a pose "falando" enquanto o áudio toca.
class Wagwagwag extends StatefulWidget {
  final List<Servico> servicos;
  final double tamanho;

  const Wagwagwag({super.key, required this.servicos, this.tamanho = 80});

  @override
  State<Wagwagwag> createState() => _WagwagwagState();
}

class _WagwagwagState extends State<Wagwagwag> {
  int _indiceFala = 0;
  int _pulos = 0;

  /// Pose que passa por cima do humor por um instante.
  String? _poseDoToque;
  Timer? _timerPose;

  @override
  void dispose() {
    _timerPose?.cancel();
    super.dispose();
  }

  /// Toque no balão: fala a próxima frase.
  void _proximaFala() {
    setState(() {
      _indiceFala++;
      _pulos++;
      _poseDoToque = 'falando';
    });
    _timerPose?.cancel();
    _timerPose = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _poseDoToque = null);
    });
  }

  /// Toque no boneco: entra na sala dele.
  void _abrirSala() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalaWagPage(servicos: widget.servicos),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final humor = calcularHumor(widget.servicos);
    // Cada humor tem uma imagem com o mesmo nome: dormindo, feliz...
    final pose = _poseDoToque ?? humor.name;
    final falas = falasDoWag(widget.servicos);
    final fala = falas[_indiceFala % falas.length];

    return Row(
      children: [
        GestureDetector(
          onTap: _abrirSala,
          child: Tooltip(
            message: 'Entrar na sala do Wagwagwag',
            child: WagPersonagem(
              pose: pose,
              tamanho: widget.tamanho,
              pulos: _pulos,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _proximaFala,
            child: AeroVidro(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Wagwagwag',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD0D0),
                      shadows: sombraTexto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(fala, style: const TextStyle(shadows: sombraTexto)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
