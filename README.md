# Oficina Mecânica

Trabalho final de Programação para Dispositivos Móveis (IFSC): app Flutter de uma
oficina mecânica com SQLite, no visual Frutiger Aero rubro-negro e com o
**Wagwagwag**, um assistente estilo Talking Tom que reage aos dados da oficina.

## O que o app faz

- **Lista de serviços** (placa, cliente, descrição, valor e status) com
  `ListView.builder`, mensagem de lista vazia e filtro por status
  (aberta, em andamento, concluída).
- **Cadastro e edição** com `TextFormField`, `TextEditingController` e validação
  (placa antiga e Mercosul, valor numérico). A tela devolve os dados num `Map`
  pelo `Navigator.pop`.
- **CRUD completo no SQLite** (`sqflite`, com `sqflite_common_ffi` no Windows),
  numa única tabela `servicos`.
- **Regra do tema:** faturamento previsto (`SUM` no banco) por filtro e resumo
  por status (`GROUP BY`).
- **Resumo:** terceira tela com faturamento total, concluído e a receber.
- **Wagwagwag:** muda de humor conforme o banco (dormindo, tranquilo, feliz,
  preocupado). Tocar nele abre a sala dele, uma garagem onde ele respira, reage a
  toques na cabeça e na barriga, fala, comemora e cochila se ficar sozinho.

## Baixar pronto

Na aba [Releases](https://github.com/Baiazo/oficina-mecanica/releases) estão os
arquivos para rodar sem instalar o Flutter:

- `OficinaMecanica_Windows.zip`: extraia e abra `oficina_mecanica.exe`. O banco fica
  em `%APPDATA%\OficinaMecanica\oficina.db`.
- `OficinaMecanica.apk`: instalação direta no Android.

## Apresentação

`apresentacao/apresentacao.html` é a apresentação do trabalho: 17 slides num arquivo
só, com imagens e fontes embutidas (funciona sem internet). Baixe o arquivo e abra no
Chrome ou no Edge. Setas ou espaço mudam de slide, `N` mostra o roteiro de cada
slide, `P` abre a janela do apresentador e `F` é tela cheia.

## Estrutura

```
lib/
  main.dart              inicia o FFI no Windows e o tema
  models/servico.dart    entidade Servico e status
  database/db_helper.dart  toda a conversa com o SQLite
  screens/               lista, cadastro e resumo
  wagwagwag/             humor, falas, personagem e sala
  tema/                  visual Aero e memes
  assets/                imagens (dentro de lib para irem no .zip da entrega)
test/                    testes do modelo, do humor e do CRUD
apresentacao/            slides da apresentação (um HTML só, funciona offline)
```

## Como rodar

```bash
flutter pub get
flutter run -d windows
```

No Windows é preciso o Visual Studio Build Tools com "Desenvolvimento para desktop
com C++". No Android, `flutter run` com o celular ou o emulador conectado.

Testes:

```bash
flutter test
```

## Créditos das imagens

- Wagwagwag, expressões e garagem: geradas com IA (Higgsfield / GPT Image).
- Memes e figurinhas do Flamengo: conteúdo de fãs encontrado na internet
  (Lovecell, Pinterest e outros), usado só como piada neste trabalho acadêmico.
  Os direitos pertencem aos autores originais.
