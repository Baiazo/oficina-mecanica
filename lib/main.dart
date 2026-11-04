import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/lista_page.dart';
import 'tema/aero.dart';

void main() {
  // No Windows o sqflite precisa do FFI; no Android usa o SQLite nativo.
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const OficinaApp());
}

class OficinaApp extends StatelessWidget {
  const OficinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Mecânica',
      debugShowCheckedModeBanner: false,
      theme: temaAero(),
      home: const ListaServicosPage(),
    );
  }
}
