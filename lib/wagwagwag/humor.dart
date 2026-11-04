import '../models/servico.dart';

/// Humores do Wagwagwag. Cada um vai ganhar uma imagem/animação própria.
enum HumorWag { dormindo, tranquilo, feliz, preocupado }

/// A partir de quantos serviços pendentes ele fica preocupado.
const limitePreocupado = 5;

/// O humor sai dos dados do banco: o pet não tem tabela própria.
HumorWag calcularHumor(List<Servico> servicos) {
  if (servicos.isEmpty) return HumorWag.dormindo;

  final pendentes = servicos
      .where((s) => s.status != StatusServico.concluida)
      .length;
  final concluidos = servicos.length - pendentes;

  if (pendentes >= limitePreocupado) return HumorWag.preocupado;
  if (concluidos >= pendentes) return HumorWag.feliz;
  return HumorWag.tranquilo;
}

// Falas da sala, para quando alguém mexe com ele.
const falasBarriga = [
  'Ei! Isso aí é investimento, viu?',
  'Para que eu tenho cócegas!',
  'Cuidado, tem churrasco de domingo aí dentro!',
  'Barriga de mecânico de respeito!',
];

const falasCabeca = [
  'Opa! Tá precisando de quê, chefe?',
  'Cuidado com o topete, deu trabalho!',
  'Pensando aqui no próximo conserto...',
];

const falasComemorar = [
  'Golaço do Mengão!',
  'É campeão! Wag wag wag!',
  'Oficina rubro-negra não perde uma!',
];

const falasTedio = [
  'Alguém aí? Cadê os carros?',
  'Vou dar uma apertada nesse parafuso aqui...',
  'Que tédio... bora trabalhar!',
];

const falasAcordar = [
  'Ahn?! Tô acordado, tô acordado!',
  'Eu não tava dormindo, tava pensando!',
];

/// Falas do balão, montadas com os números da oficina.
List<String> falasDoWag(List<Servico> servicos) {
  int contar(String status) => servicos.where((s) => s.status == status).length;

  final abertas = contar(StatusServico.aberta);
  final andamento = contar(StatusServico.emAndamento);
  final concluidas = contar(StatusServico.concluida);
  final pendentes = abertas + andamento;

  switch (calcularHumor(servicos)) {
    case HumorWag.dormindo:
      return [
        'Zzz... nenhum carro na oficina.',
        'Cadastra um serviço que eu acordo!',
      ];
    case HumorWag.preocupado:
      return [
        'Socorro! $pendentes carros esperando!',
        '$abertas em aberto e $andamento em andamento. Bora acelerar!',
        'Acho que vou precisar de mais um mecânico...',
      ];
    case HumorWag.feliz:
      return [
        'Já concluímos $concluidas serviço(s)! Wag wag wag!',
        'Oficina em dia, chefe! Hoje tem Mengão!',
        'Rubro-negro trabalhando é outra coisa!',
        if (pendentes > 0) 'Só faltam $pendentes. Moleza!',
      ];
    case HumorWag.tranquilo:
      return [
        '$abertas em aberto, $andamento em andamento.',
        'Tudo sob controle por aqui. Vamos, Mengo!',
        'Me toca que eu conto as novidades!',
      ];
  }
}
