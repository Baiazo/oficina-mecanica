import 'dart:math';

import 'package:flutter/material.dart';

/// O desenho do Wagwagwag numa pose, "respirando" sem parar (idle)
/// e dando um pulinho sempre que [pulos] aumenta.
class WagPersonagem extends StatefulWidget {
  /// Nome da imagem em lib/assets/wagwagwag (dormindo, feliz, falando...).
  final String pose;
  final double tamanho;
  final int pulos;

  const WagPersonagem({
    super.key,
    required this.pose,
    required this.tamanho,
    this.pulos = 0,
  });

  @override
  State<WagPersonagem> createState() => _WagPersonagemState();
}

class _WagPersonagemState extends State<WagPersonagem>
    with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  late final AnimationController _pulo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void didUpdateWidget(WagPersonagem antigo) {
    super.didUpdateWidget(antigo);
    if (widget.pulos != antigo.pulos) _pulo.forward(from: 0);
  }

  @override
  void dispose() {
    _idle.dispose();
    _pulo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tamanho;
    return SizedBox(
      width: t,
      height: t,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Brilho no "chão", estilo Aero (fica parado, só o boneco mexe).
          Container(
            width: t * 0.8,
            height: t * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.elliptical(t * 0.4, t * 0.07),
              ),
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.45),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          _boneco(),
        ],
      ),
    );
  }

  Widget _boneco() {
    final dormindo = widget.pose == 'dormindo';
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _pulo]),
      builder: (context, child) {
        final onda = sin(_idle.value * 2 * pi);
        // Dormindo respira mais fundo e mais devagar; acordado balança de lado.
        final respira = onda * (dormindo ? 0.04 : 0.025);
        final balanco = dormindo ? 0.0 : sin(_idle.value * pi * 2) * 0.03;
        final p = _pulo.value;
        final pulo = Curves.easeOut.transform(p < 0.5 ? p * 2 : (1 - p) * 2);

        return Transform.translate(
          offset: Offset(0, -pulo * widget.tamanho * 0.2),
          child: Transform.rotate(
            angle: balanco,
            alignment: Alignment.bottomCenter,
            child: Transform(
              alignment: Alignment.bottomCenter,
              // Estica pra cima e afina um pouco: parece respiração.
              transform: Matrix4.diagonal3Values(
                1 - respira / 2,
                1 + respira,
                1,
              ),
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        'lib/assets/wagwagwag/${widget.pose}.webp',
        width: widget.tamanho,
        height: widget.tamanho,
        gaplessPlayback: true, // troca de pose sem piscar
      ),
    );
  }
}
