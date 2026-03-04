import 'package:flutter/material.dart';

import '../services/credit_service.dart';

class CreditStoreScreen extends StatefulWidget {
  const CreditStoreScreen({super.key});

  @override
  State<CreditStoreScreen> createState() => _CreditStoreScreenState();
}

class _CreditStoreScreenState extends State<CreditStoreScreen> {
  final CreditService _creditService = CreditService();
  int _credits = 1;
  bool _loading = true;
  bool _buying = false;

  static const List<int> _packages = <int>[100, 200, 500];

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final int credits = await _creditService.getCredits();
    if (!mounted) {
      return;
    }
    setState(() {
      _credits = credits;
      _loading = false;
    });
  }

  Future<void> _buyPackage(int amount) async {
    setState(() => _buying = true);
    final int updated = await _creditService.addCredits(amount);
    if (!mounted) {
      return;
    }
    setState(() {
      _credits = updated;
      _buying = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$amount kredi hesabina eklendi.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kredi Satin Al')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.bolt, size: 30),
                  const SizedBox(width: 12),
                  Text(
                    'Mevcut Kredi: $_credits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._packages.map((pack) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('$pack Kredi'),
                subtitle: const Text('Paket'),
                trailing: FilledButton(
                  onPressed: _buying ? null : () => _buyPackage(pack),
                  child: const Text('Satin Al'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
