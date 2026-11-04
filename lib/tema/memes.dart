import 'package:flutter/material.dart';

import 'aero.dart';

/// Caminhos dos memes rubro-negros (registrados no pubspec.yaml).
class Memes {
  static const _pasta = 'lib/assets/memes';
  static const falaMal = '$_pasta/fala_mal.jpg';
  static const saiDaFrente = '$_pasta/sai_da_frente.jpg';
  static const mengaoEsmaga = '$_pasta/mengao_esmaga.jpg';
  static const vaiMengo = '$_pasta/vai_mengo.webp';
  static const tranquilidadePura = '$_pasta/tranquilidade_pura.webp';
  static const mengoPorra = '$_pasta/mengo_porra.webp';
  static const aguiaPisando = '$_pasta/aguia_pisando.webp';
  static const naoQuerendoGabar = '$_pasta/nao_querendo_gabar.webp';
  static const issoAquiEFlamengo = '$_pasta/isso_aqui_e_flamengo.webp';
  static const aquiEMengaoPorra = '$_pasta/aqui_e_mengao_porra.webp';
  static const compramoOJuiz = '$_pasta/compramo_o_juiz.webp';
}

/// Diálogo com meme grande, texto e um botão para fechar.
Future<void> mostrarMeme(
  BuildContext context, {
  required String titulo,
  required String caminho,
  required String texto,
  String botao = 'Vamo!',
  Color cor = AeroCores.vermelho,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MemeImagem(caminho: caminho, altura: 240),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        AeroBotao(
          onPressed: () => Navigator.pop(context),
          texto: botao,
          cor: cor,
          compacto: true,
        ),
      ],
    ),
  );
}

/// Faixa de vidro com meme pequeno ao lado de um recado.
class MemeAviso extends StatelessWidget {
  final String caminho;
  final String texto;

  const MemeAviso({super.key, required this.caminho, required this.texto});

  @override
  Widget build(BuildContext context) {
    return AeroVidro(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          MemeImagem(caminho: caminho, altura: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: sombraTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Meme com cantos arredondados e borda de vidro, para combinar com o Aero.
class MemeImagem extends StatelessWidget {
  final String caminho;
  final double altura;

  const MemeImagem({super.key, required this.caminho, this.altura = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Fundo branco: algumas figurinhas são transparentes com texto preto.
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AeroCores.vermelho.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Image.asset(caminho, height: altura, fit: BoxFit.contain),
      ),
    );
  }
}
