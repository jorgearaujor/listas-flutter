import 'package:flutter/material.dart';

void main() {
  runApp(const CatalogoApp());
}

/// Categorias disponíveis no catálogo, cada uma associada a um ícone.
enum Categoria {
  eletronicos('Eletrônicos', Icons.devices),
  alimentos('Alimentos', Icons.fastfood),
  vestuario('Vestuário', Icons.checkroom),
  livros('Livros', Icons.menu_book),
  moveis('Móveis', Icons.chair),
  esportes('Esportes', Icons.sports_soccer);

  const Categoria(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}

/// Modelo de um produto do catálogo.
class Produto {
  Produto({
    required this.nome,
    required this.preco,
    required this.categoria,
  });

  final String nome;
  final double preco;
  final Categoria categoria;
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CatalogoPage(),
    );
  }
}

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  // Lista (List) de produtos exibida dinamicamente pelo ListView.builder.
  final List<Produto> _produtos = [
    Produto(nome: 'Notebook', preco: 3499.90, categoria: Categoria.eletronicos),
    Produto(nome: 'Café em grãos', preco: 29.90, categoria: Categoria.alimentos),
    Produto(nome: 'Camiseta', preco: 59.90, categoria: Categoria.vestuario),
    Produto(nome: 'O Senhor dos Anéis', preco: 89.90, categoria: Categoria.livros),
  ];

  // Itens que o usuário adicionou ao carrinho.
  final List<Produto> _carrinho = [];

  String _formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _abrirCadastro() async {
    final novoProduto = await Navigator.push<Produto>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroProdutoPage()),
    );

    // Inclui o novo produto na lista sem substituir os existentes.
    if (novoProduto != null) {
      setState(() => _produtos.add(novoProduto));
    }
  }

  void _comprar(Produto produto) {
    setState(() => _carrinho.add(produto));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${produto.nome} foi adicionado ao carrinho!'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _abrirCarrinho() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarrinhoPage(itens: _carrinho),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        actions: [
          IconButton(
            tooltip: 'Carrinho',
            onPressed: _abrirCarrinho,
            icon: Badge(
              isLabelVisible: _carrinho.isNotEmpty,
              label: Text('${_carrinho.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          final produto = _produtos[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: InkWell(
              // Ao clicar no produto, exibe um SnackBar de "adicionado ao carrinho".
              onTap: () => _comprar(produto),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      child: Icon(produto.categoria.icone),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produto.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            produto.categoria.rotulo,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarPreco(produto.preco),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _comprar(produto),
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: const Text('Comprar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}

class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key, required this.itens});

  final List<Produto> itens;

  String _formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final total = itens.fold<double>(0, (soma, item) => soma + item.preco);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: itens.isEmpty
          ? const Center(
              child: Text(
                'Seu carrinho está vazio.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                return ListTile(
                  leading: Icon(item.categoria.icone),
                  title: Text(item.nome),
                  subtitle: Text(item.categoria.rotulo),
                  trailing: Text(
                    _formatarPreco(item.preco),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: itens.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatarPreco(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({super.key});

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  Categoria _categoriaSelecionada = Categoria.eletronicos;

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final preco = double.parse(
      _precoController.text.trim().replaceAll(',', '.'),
    );

    final produto = Produto(
      nome: _nomeController.text.trim(),
      preco: preco,
      categoria: _categoriaSelecionada,
    );

    // Retorna à tela principal entregando o produto cadastrado.
    Navigator.pop(context, produto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do produto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'Ex: 49,90',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o preço';
                  }
                  final preco = double.tryParse(valor.trim().replaceAll(',', '.'));
                  if (preco == null || preco <= 0) {
                    return 'Informe um preço válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categoria>(
                initialValue: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: Categoria.values
                    .map(
                      (categoria) => DropdownMenuItem(
                        value: categoria,
                        child: Row(
                          children: [
                            Icon(categoria.icone, size: 20),
                            const SizedBox(width: 10),
                            Text(categoria.rotulo),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _categoriaSelecionada = valor);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar cadastro'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
