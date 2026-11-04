import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Kit visual do app: Frutiger Aero (vidro, brilho, bolhas) em rubro-negro.
class AeroCores {
  static const vermelho = Color(0xFFD7141A);
  static const vermelhoEscuro = Color(0xFF6E0A0D);
  static const preto = Color(0xFF0A0A0A);

  // Acentos clássicos do Aero para os status.
  static const ambar = Color(0xFFFFA726);
  static const aqua = Color(0xFF14B8FF);
  static const lima = Color(0xFF6FD400);

  static Color clarear(Color cor, [double quanto = 0.35]) =>
      Color.lerp(cor, Colors.white, quanto)!;

  static Color escurecer(Color cor, [double quanto = 0.35]) =>
      Color.lerp(cor, Colors.black, quanto)!;
}

/// Sombra leve para o texto branco continuar legível sobre o fundo.
const sombraTexto = [
  Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
];

ThemeData temaAero() {
  final base = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AeroCores.vermelho,
      brightness: Brightness.dark,
      primary: AeroCores.vermelho,
    ),
  );
  final bordaVidro = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AeroCores.preto,
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.10),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIconColor: Colors.white70,
      border: bordaVidro,
      enabledBorder: bordaVidro,
      focusedBorder: bordaVidro.copyWith(
        borderSide: const BorderSide(color: Colors.white, width: 1.6),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFFB4B4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xF21A0A0B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AeroCores.vermelhoEscuro,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

/// Estrutura padrão das telas: barra de vidro escuro + fundo Aero.
class AeroPagina extends StatelessWidget {
  final String titulo;
  final List<Widget>? acoes;
  final Widget corpo;
  final Widget? botao;

  /// Fundo próprio da tela (ex.: a garagem da sala). Sem ele, usa o Aero.
  final Widget? fundo;

  const AeroPagina({
    super.key,
    required this.titulo,
    required this.corpo,
    this.acoes,
    this.botao,
    this.fundo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: sombraTexto,
          ),
        ),
        actions: acoes,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: botao,
      body: fundo == null
          ? AeroFundo(child: SafeArea(child: corpo))
          : Stack(
              children: [
                Positioned.fill(child: fundo!),
                SafeArea(child: corpo),
              ],
            ),
    );
  }
}

/// Fundo rubro-negro listrado, com brilho, ondas de luz e bolhas subindo.
class AeroFundo extends StatefulWidget {
  final Widget child;

  const AeroFundo({super.key, required this.child});

  @override
  State<AeroFundo> createState() => _AeroFundoState();
}

class _AeroFundoState extends State<AeroFundo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tempo = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _tempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PintorFundo(_tempo), child: widget.child);
  }
}

class _Bolha {
  final double x, y, raio, velocidade;
  _Bolha(this.x, this.y, this.raio, this.velocidade);
}

class _PintorFundo extends CustomPainter {
  final Animation<double> tempo;

  // Semente fixa: as bolhas ficam sempre no mesmo lugar ao reabrir o app.
  static final List<_Bolha> _bolhas = () {
    final aleatorio = Random(10);
    return List.generate(
      14,
      (_) => _Bolha(
        aleatorio.nextDouble(),
        aleatorio.nextDouble(),
        12 + aleatorio.nextDouble() * 38,
        0.5 + aleatorio.nextDouble(),
      ),
    );
  }();

  _PintorFundo(this.tempo) : super(repaint: tempo);

  @override
  void paint(Canvas canvas, Size size) {
    final tela = Offset.zero & size;

    // 1. Degradê do vermelho para o preto.
    canvas.drawRect(
      tela,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AeroCores.vermelho,
            AeroCores.vermelhoEscuro,
            AeroCores.preto,
          ],
          stops: [0, 0.45, 1],
        ).createShader(tela),
    );

    // 2. Listras horizontais da camisa, bem suaves.
    final listra = Paint()..color = Colors.black.withValues(alpha: 0.22);
    for (double y = 40; y < size.height; y += 110) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 55), listra);
    }

    // 3. Brilho de "sol" no canto superior esquerdo.
    canvas.drawRect(
      tela,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.9, -1),
          radius: 0.9,
          colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
        ).createShader(tela),
    );

    // 4. Ondas de luz atravessando a tela, estilo papel de parede do Vista.
    _onda(canvas, size, 0.62, 0.10);
    _onda(canvas, size, 0.72, 0.06);

    // 5. Bolhas subindo devagar.
    for (final bolha in _bolhas) {
      final subida = (bolha.y - tempo.value * bolha.velocidade) % 1.0;
      final centro = Offset(
        bolha.x * size.width,
        subida * (size.height + 2 * bolha.raio) - bolha.raio,
      );
      _desenharBolha(canvas, centro, bolha.raio);
    }
  }

  void _onda(Canvas canvas, Size size, double altura, double opacidade) {
    final y = size.height * altura;
    final caminho = Path()
      ..moveTo(0, y)
      ..cubicTo(
        size.width * 0.3,
        y - 120,
        size.width * 0.7,
        y + 60,
        size.width,
        y - 80,
      )
      ..lineTo(size.width, y - 20)
      ..cubicTo(size.width * 0.7, y + 120, size.width * 0.3, y - 40, 0, y + 50)
      ..close();
    canvas.drawPath(
      caminho,
      Paint()..color = Colors.white.withValues(alpha: opacidade),
    );
  }

  void _desenharBolha(Canvas canvas, Offset centro, double raio) {
    final area = Rect.fromCircle(center: centro, radius: raio);
    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.white.withValues(alpha: 0.18)],
          stops: const [0.6, 1],
        ).createShader(area),
    );
    canvas.drawCircle(
      centro,
      raio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    // Reflexo pequeno no alto da bolha.
    canvas.drawOval(
      Rect.fromCenter(
        center: centro + Offset(-raio * 0.35, -raio * 0.45),
        width: raio * 0.6,
        height: raio * 0.3,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_PintorFundo antigo) => false;
}

/// Painel de vidro: desfoca o fundo e tem brilho na metade de cima.
class AeroVidro extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double raio;

  const AeroVidro({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.raio = 20,
  });

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(raio);
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: borda,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borda,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: _BrilhoDeCima(opacidade: 0.22)),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Faixa brilhante na metade de cima, que dá o efeito "plástico polido".
class _BrilhoDeCima extends StatelessWidget {
  final double opacidade;

  const _BrilhoDeCima({required this.opacidade});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          widthFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: opacidade),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão em pílula brilhante (o "gel" do Aero).
class AeroBotao extends StatelessWidget {
  final VoidCallback? onPressed;
  final String texto;
  final IconData? icone;
  final Color cor;
  final bool compacto;

  const AeroBotao({
    super.key,
    required this.onPressed,
    required this.texto,
    this.icone,
    this.cor = AeroCores.vermelho,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final borda = BorderRadius.circular(40);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borda,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borda,
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AeroCores.clarear(cor), cor, AeroCores.escurecer(cor)],
              stops: const [0, 0.5, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: cor.withValues(alpha: 0.55),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borda,
            child: Stack(
              children: [
                const Positioned.fill(child: _BrilhoDeCima(opacidade: 0.55)),
                Padding(
                  padding: compacto
                      ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                      : const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icone != null) ...[
                        Icon(
                          icone,
                          color: Colors.white,
                          size: compacto ? 18 : 22,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        texto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: sombraTexto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opção de filtro: vira gel colorido quando selecionada, vidro quando não.
class AeroPilula extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final Color cor;
  final VoidCallback onTap;

  const AeroPilula({
    super.key,
    required this.texto,
    required this.selecionada,
    required this.onTap,
    this.cor = AeroCores.vermelho,
  });

  @override
  Widget build(BuildContext context) {
    if (selecionada) {
      return AeroBotao(
        onPressed: onTap,
        texto: texto,
        cor: cor,
        compacto: true,
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AeroVidro(
        raio: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          texto,
          style: const TextStyle(color: Colors.white, shadows: sombraTexto),
        ),
      ),
    );
  }
}

/// Esfera brilhante, usada nos ícones e no corpo do Wagwagwag.
class AeroOrbe extends StatelessWidget {
  final Color cor;
  final double tamanho;
  final Widget? child;

  const AeroOrbe({
    super.key,
    required this.cor,
    required this.tamanho,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.2,
        ),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [
            AeroCores.clarear(cor, 0.45),
            cor,
            AeroCores.escurecer(cor, 0.5),
          ],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.6),
            blurRadius: tamanho * 0.3,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Reflexo oval no topo da esfera.
          Positioned(
            top: tamanho * 0.06,
            child: Container(
              width: tamanho * 0.62,
              height: tamanho * 0.36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.elliptical(tamanho * 0.31, tamanho * 0.18),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
