/// Formata um valor como moeda: 1234.5 -> "R$ 1.234,50".
String formatarReais(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'R\$ $inteiro,${partes[1]}';
}

/// Lê o valor digitado aceitando "1.234,50", "1234,50" ou "1234.50".
double? lerValor(String texto) {
  var limpo = texto.trim();
  if (limpo.contains(',')) {
    limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(limpo);
}
