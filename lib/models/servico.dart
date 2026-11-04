import 'package:flutter/material.dart';

/// Valores de status gravados no banco e como aparecem na tela.
class StatusServico {
  static const aberta = 'aberta';
  static const emAndamento = 'em_andamento';
  static const concluida = 'concluida';

  static const todos = [aberta, emAndamento, concluida];

  static String rotulo(String status) {
    switch (status) {
      case aberta:
        return 'Aberta';
      case emAndamento:
        return 'Em andamento';
      case concluida:
        return 'Concluída';
      default:
        return status;
    }
  }

  static Color cor(String status) {
    switch (status) {
      // Âmbar, aqua e lima: os acentos clássicos do Frutiger Aero.
      case aberta:
        return const Color(0xFFFFA726);
      case emAndamento:
        return const Color(0xFF14B8FF);
      case concluida:
        return const Color(0xFF6FD400);
      default:
        return Colors.grey;
    }
  }
}

/// Entidade principal: um serviço da oficina (uma linha da tabela servicos).
class Servico {
  final int? id;
  final String placa;
  final String cliente;
  final String descricao;
  final double valor;
  final String status;

  Servico({
    this.id,
    required this.placa,
    required this.cliente,
    required this.descricao,
    required this.valor,
    required this.status,
  });

  /// Converte para Map, que é o formato que o sqflite grava.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'placa': placa,
      'cliente': cliente,
      'descricao': descricao,
      'valor': valor,
      'status': status,
    };
  }

  /// Monta o objeto a partir de um Map (linha do banco ou retorno do cadastro).
  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'] as int?,
      placa: map['placa'] as String,
      cliente: map['cliente'] as String,
      descricao: map['descricao'] as String,
      valor: (map['valor'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}
