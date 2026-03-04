import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/chatgpt_service.dart';
import '../services/credit_service.dart';
import 'credit_store_screen.dart';

enum _QuestionInputMode { photo, text }

class QuestionShareScreen extends StatefulWidget {
  const QuestionShareScreen({super.key});

  @override
  State<QuestionShareScreen> createState() => _QuestionShareScreenState();
}

class _QuestionShareScreenState extends State<QuestionShareScreen> {
  final ImagePicker _picker = ImagePicker();
  final CreditService _creditService = CreditService();
  final ChatGptService _chatGptService = ChatGptService();
  final TextEditingController _questionController = TextEditingController();

  _QuestionInputMode _mode = _QuestionInputMode.photo;
  File? _imageFile;
  String _answer = '';
  int _credits = 1;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) {
      return;
    }
    setState(() => _imageFile = File(file.path));
  }

  Future<void> _showBuyCreditDialog() async {
    final bool? shouldOpenStore = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kredi bitti'),
          content: const Text('Soru sormak icin kredi satin alman gerekiyor.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgec'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Kredi Al'),
            ),
          ],
        );
      },
    );

    if (shouldOpenStore != true || !mounted) {
      return;
    }
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreditStoreScreen()));
    await _loadCredits();
  }

  Future<void> _sendQuestion() async {
    if (_credits <= 0) {
      await _showBuyCreditDialog();
      return;
    }

    if (_mode == _QuestionInputMode.photo && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Once soru fotografi cek veya galeriden sec.'),
        ),
      );
      return;
    }

    if (_mode == _QuestionInputMode.text &&
        _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Once soru metni yaz.')));
      return;
    }

    setState(() => _sending = true);
    try {
      final String answer = _mode == _QuestionInputMode.photo
          ? await _chatGptService.askImage(_imageFile!)
          : await _chatGptService.askText(_questionController.text);

      final int updatedCredits = await _creditService.spendOneCredit();

      if (!mounted) {
        return;
      }
      setState(() {
        _answer = answer;
        _credits = updatedCredits;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $error')));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Paylas'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreditStoreScreen(),
                ),
              );
              await _loadCredits();
            },
            icon: const Icon(Icons.bolt),
            label: Text('$_credits kredi'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SegmentedButton<_QuestionInputMode>(
            segments: const <ButtonSegment<_QuestionInputMode>>[
              ButtonSegment<_QuestionInputMode>(
                value: _QuestionInputMode.photo,
                label: Text('Foto'),
                icon: Icon(Icons.camera_alt_outlined),
              ),
              ButtonSegment<_QuestionInputMode>(
                value: _QuestionInputMode.text,
                label: Text('Yazi'),
                icon: Icon(Icons.edit_outlined),
              ),
            ],
            selected: <_QuestionInputMode>{_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          const SizedBox(height: 16),
          if (_mode == _QuestionInputMode.photo) ...<Widget>[
            SizedBox(
              height: 250,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: _imageFile == null
                    ? const Center(child: Text('Soru fotografi secilmedi.'))
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sending
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sending
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            TextField(
              controller: _questionController,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Sorunu yaz',
                hintText: 'Ornek: x^2 + 5x + 6 = 0 denklemini coz.',
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '1 kredi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _sending ? null : _sendQuestion,
            icon: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_sending ? 'Gonderiliyor...' : 'Soruyu Gonder'),
          ),
          const SizedBox(height: 12),
          if (_answer.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_answer),
              ),
            ),
        ],
      ),
    );
  }
}
