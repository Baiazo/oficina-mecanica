import 'package:flutter/material.dart';

import '../models/servico.dart';
import '../tema/aero.dart';
import '../tema/memes.dart';
import '../util/formato.dart';

/// Tela de cadastro e edição. Não grava no banco: devolve um Map com
/// Navigator.pop e quem grava é a tela de lista.
class CadastroServicoPage extends StatefulWidget {
  /// Quando vem preenchido, a tela está editando esse serviço.
  final Servico? servico;

  const CadastroServicoPage({super.key, this.servico});

  @override
  State<CadastroServicoPage> createState() => _CadastroServicoPageState();
}

class _CadastroServicoPageState extends State<CadastroServicoPage> {
  final _formKey = GlobalKey<FormState>();

  final _placaController = TextEditingController();
  final _clienteController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  String _status = StatusServico.aberta;

  bool get _editando => widget.servico != null;

  /// Fica true quando a validação falha, para trocar o meme do topo.
  bool _temErro = false;

  @override
  void initState() {
    super.initState();
    // Edição: preenche os campos com os dados do serviço escolhido.
    final servico = widget.servico;
    if (servico != null) {
      _placaController.text = servico.placa;
      _clienteController.text = servico.cliente;
      _descricaoController.text = servico.descricao;
      _valorController.text = servico.valor
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _status = servico.status;
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    _clienteController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    final valido = _formKey.currentState!.validate();
    setState(() => _temErro = !valido);
    if (!valido) return;

    Navigator.pop(context, {
      'placa': _normalizarPlaca(_placaController.text),
      'cliente': _clienteController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'valor': lerValor(_valorController.text)!,
      'status': _status,
    });
  }

  String _normalizarPlaca(String texto) {
    return texto.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  // ---------- Validações ----------

  String? _validarPlaca(String? valor) {
    final placa = _normalizarPlaca(valor ?? '');
    if (placa.isEmpty) return 'Informe a placa';
    // Aceita o modelo antigo (ABC1234) e o Mercosul (ABC1D23).
    if (!RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$').hasMatch(placa)) {
      return 'Placa inválida (ex.: ABC1234 ou ABC1D23)';
    }
    return null;
  }

  String? _validarObrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Informe $campo';
    if (valor.trim().length < 3) return 'Mínimo de 3 letras';
    return null;
  }

  String? _validarValor(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o valor';
    final numero = lerValor(valor);
    if (numero == null) return 'Valor inválido';
    if (numero <= 0) return 'O valor deve ser maior que zero';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AeroPagina(
      titulo: _editando ? 'Editar serviço' : 'Novo serviço',
      corpo: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: MemeImagem(
                caminho: _temErro
                    ? Memes.aquiEMengaoPorra
                    : Memes.issoAquiEFlamengo,
                altura: 160,
              ),
            ),
            if (_temErro)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Preenche direito, rapaz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: sombraTexto,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            AeroVidro(
              padding: const EdgeInsets.all(16),
              child: Column(children: _campos()),
            ),
            const SizedBox(height: 24),
            Center(
              child: AeroBotao(
                onPressed: _salvar,
                icone: Icons.save,
                texto: _editando ? 'Salvar alterações' : 'Cadastrar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _campos() {
    return [
      TextFormField(
        controller: _placaController,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Placa',
          hintText: 'ABC1D23',
          prefixIcon: Icon(Icons.directions_car),
          border: OutlineInputBorder(),
        ),
        validator: _validarPlaca,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _clienteController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Cliente',
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
        validator: (v) => _validarObrigatorio(v, 'o cliente'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _descricaoController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Descrição do serviço',
          hintText: 'Troca de óleo e filtro',
          prefixIcon: Icon(Icons.build),
          border: OutlineInputBorder(),
        ),
        validator: (v) => _validarObrigatorio(v, 'a descrição'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _valorController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Valor',
          prefixText: 'R\$ ',
          prefixIcon: Icon(Icons.attach_money),
          border: OutlineInputBorder(),
        ),
        validator: _validarValor,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: _status,
        dropdownColor: AeroCores.vermelhoEscuro,
        borderRadius: BorderRadius.circular(16),
        decoration: const InputDecoration(
          labelText: 'Status',
          prefixIcon: Icon(Icons.flag),
          border: OutlineInputBorder(),
        ),
        items: StatusServico.todos
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(StatusServico.rotulo(s)),
              ),
            )
            .toList(),
        onChanged: (valor) => setState(() => _status = valor!),
      ),
    ];
  }
}
