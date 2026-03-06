import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/config/env.dart';
import '../core/constants/math_topic_catalog.dart';
import '../services/avatar_tutor_service.dart';
import '../widgets/question_share_fab.dart';

class MathTutorScreen extends StatefulWidget {
  const MathTutorScreen({
    super.key,
    required this.examName,
    required this.subjectName,
  });

  final String examName;
  final String subjectName;

  @override
  State<MathTutorScreen> createState() => _MathTutorScreenState();
}

class _MathTutorScreenState extends State<MathTutorScreen> {
  final AvatarTutorService _avatarTutorService = AvatarTutorService();
  final TextEditingController _topicController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_TutorMessage> _messages = <_TutorMessage>[];

  late final List<String> _topics;

  VideoPlayerController? _videoController;
  bool _sending = false;
  bool _videoPreparing = false;
  bool _chalkMode = true;
  String? _activeTopic;
  String? _lastApiError;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _topics = MathTopicCatalog.topicsForExam(widget.examName);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _topicController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt({String? presetTopic}) async {
    final String input = (presetTopic ?? _topicController.text).trim();
    if (input.isEmpty || _sending) {
      return;
    }

    if (presetTopic != null) {
      _activeTopic = presetTopic;
    }

    setState(() {
      _sending = true;
      _videoPreparing = true;
      _videoError = null;
      _messages.add(_TutorMessage(role: 'user', text: input));
      if (presetTopic != null) {
        _topicController.text = presetTopic;
      }
    });
    _scrollToBottom();

    try {
      if (!Env.hasSupabaseConfig) {
        throw StateError(
          'Supabase baglantisi eksik. Run icin SUPABASE_URL ve SUPABASE_PUBLISHABLE_KEY ver.',
        );
      }

      final List<Map<String, String>> conversationHistory = _messages
          .map((m) => <String, String>{'role': m.role, 'content': m.text})
          .toList();

      final job = await _avatarTutorService.createVideo(
        examName: widget.examName,
        subjectName: widget.subjectName,
        activeTopic: _activeTopic,
        userMessage: input,
        conversationHistory: conversationHistory,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_TutorMessage(role: 'assistant', text: job.answerText));
        _lastApiError = null;
        _topicController.clear();
        _sending = false;
      });
      _scrollToBottom();

      final status = await _avatarTutorService.waitUntilDone(job.jobId);
      if (!mounted) {
        return;
      }

      if (status.isDone && status.videoUrl != null) {
        await _loadVideo(status.videoUrl!);
        return;
      }

      setState(() {
        _videoPreparing = false;
        _videoError =
            status.errorMessage ?? 'Avatar videosu hazirlanamadi. Tekrar dene.';
      });
    } catch (error) {
      final String fallback = _buildOfflineTutorResponse(input);

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_TutorMessage(role: 'assistant', text: fallback));
        _lastApiError = '$error';
        _videoError = 'D-ID avatar videosu olusturulamadi.';
        _videoPreparing = false;
        _sending = false;
        _topicController.clear();
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadVideo(String videoUrl) async {
    final VideoPlayerController? previousController = _videoController;

    if (previousController != null) {
      await previousController.pause();
    }

    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _videoPreparing = false;
        _videoError = null;
      });
      await previousController?.dispose();
    } catch (error) {
      await controller.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _videoPreparing = false;
        _videoError = 'Video oynatilamadi: $error';
      });
    }
  }

  String _buildOfflineTutorResponse(String topic) {
    final String normalizedInput = topic.trim().toLowerCase();
    final String scopedTopic = (_activeTopic ?? topic).trim();
    final bool looksLikeQuestion =
        normalizedInput.contains('?') ||
        RegExp(
          r'^(neden|nasil|niye|kac|ne|hangi|coz|cozer|hesapla|bul)\b',
          caseSensitive: false,
        ).hasMatch(normalizedInput);

    if (looksLikeQuestion) {
      return 'Soru: $topic\n'
          'Konu: $scopedTopic\n\n'
          'Hizli yontem:\n'
          '- Verilenleri yaz.\n'
          '- Hangi kurali kullanacagini belirle.\n'
          '- Islem sirasini koru.\n'
          '- Sonucu kontrol et.\n\n'
          'Supabase function deploy edilince avatar bunu video olarak da anlatacak.';
    }

    return 'Konu secildi: $scopedTopic\n\n'
        'Alt basliklar:\n'
        '1) Temel kavramlar\n'
        '2) Cikis soru tipleri\n'
        '3) Sik yapilan hatalar\n'
        '4) Yeni nesil soru yaklasimi\n\n'
        'Functionlar deploy edilince bu metin Gemini ile uretilecek ve D-ID avatari sesli anlatacak.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 180,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  TextStyle _chalkTextStyle({
    double size = 15,
    FontWeight weight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: size,
      fontWeight: weight,
      color: const Color(0xFFF4F8EE),
      letterSpacing: 0.3,
      height: 1.32,
      shadows: const <Shadow>[
        Shadow(color: Color(0x66FFFFFF), blurRadius: 0.8, offset: Offset(0, 0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examName} Matematik Egitmeni'),
        actions: <Widget>[
          IconButton(
            tooltip: _chalkMode ? 'Normal gorunum' : 'Tebesir modu',
            onPressed: () => setState(() => _chalkMode = !_chalkMode),
            icon: Icon(_chalkMode ? Icons.dark_mode : Icons.edit_note),
          ),
        ],
      ),
      floatingActionButton: const QuestionShareFab(heroTag: 'fab_math_tutor'),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double videoHeight = math.min(
            270,
            math.max(150, constraints.maxHeight * 0.33),
          );
          const double composerHeight = 140;

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: _BoardBackground(
                  chalkMode: _chalkMode,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (_lastApiError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _chalkMode
                                  ? const Color(0x2AE7C56A)
                                  : const Color(0xFFFFF4D6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _chalkMode
                                    ? const Color(0x77EEDC9A)
                                    : const Color(0xFFE4C978),
                              ),
                            ),
                            child: Text(
                              _lastApiError!,
                              style: TextStyle(
                                color: _chalkMode
                                    ? const Color(0xFFFFF6D1)
                                    : const Color(0xFF6E5A18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _topics.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, int index) {
                              final String topic = _topics[index];
                              return _TopicPill(
                                label: topic,
                                chalkMode: _chalkMode,
                                selected: _activeTopic == topic,
                                onPressed: _sending
                                    ? null
                                    : () => _sendPrompt(presetTopic: topic),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.only(
                              bottom: videoHeight + composerHeight + 24,
                            ),
                            itemCount: _messages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, int index) {
                              final _TutorMessage message = _messages[index];
                              final bool isUser = message.role == 'user';
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: _chalkMode
                                          ? (isUser
                                                ? const Color(0x2A80CBC4)
                                                : const Color(0x22000000))
                                          : (isUser
                                                ? const Color(0xFFEAF4FF)
                                                : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _chalkMode
                                            ? const Color(0x6699E2CC)
                                            : const Color(0xFFD8DFE8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        message.text,
                                        style: _chalkMode
                                            ? _chalkTextStyle(size: 14)
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: composerHeight + 16,
                child: _AvatarVideoCard(
                  height: videoHeight,
                  chalkMode: _chalkMode,
                  videoController: _videoController,
                  preparing: _videoPreparing,
                  errorText: _videoError,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ComposerBar(
                  controller: _topicController,
                  sending: _sending,
                  chalkMode: _chalkMode,
                  onSubmit: () => _sendPrompt(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BoardBackground extends StatelessWidget {
  const _BoardBackground({required this.child, required this.chalkMode});

  final Widget child;
  final bool chalkMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: chalkMode
              ? const <Color>[Color(0xFF0E4E43), Color(0xFF0B3D35)]
              : const <Color>[Color(0xFFF6FAFF), Color(0xFFE9F2FC)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(chalkMode), child: child),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.chalkMode);

  final bool chalkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = chalkMode ? const Color(0x22E4F8EB) : const Color(0xFFD8E4F1)
      ..strokeWidth = 1;
    const double gap = 34;
    final Paint dustPaint = Paint()
      ..color = chalkMode ? const Color(0x22FFFFFF) : const Color(0x0A000000);

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (double x = 0; x < size.width; x += 120) {
      canvas.drawCircle(
        Offset(x + 20, (x * 1.7) % size.height),
        2.2,
        dustPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AvatarVideoCard extends StatelessWidget {
  const _AvatarVideoCard({
    required this.height,
    required this.chalkMode,
    required this.videoController,
    required this.preparing,
    required this.errorText,
  });

  final double height;
  final bool chalkMode;
  final VideoPlayerController? videoController;
  final bool preparing;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final double width = height * 0.66;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: chalkMode ? 0 : 3,
        color: chalkMode ? const Color(0x44102823) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: chalkMode ? const Color(0x66C4E6D6) : const Color(0xFFD8DFE8),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (videoController != null && videoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController!.value.size.width,
                  height: videoController!.value.size.height,
                  child: VideoPlayer(videoController!),
                ),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: chalkMode
                        ? const <Color>[
                            Color(0xFF163B35),
                            Color(0xFF0F2622),
                          ]
                        : const <Color>[
                            Color(0xFFF0F5FB),
                            Color(0xFFE0E8F3),
                          ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      preparing
                          ? 'Alyssa avatar videosu hazirlaniyor...'
                          : 'Avatar yaniti burada oynatilacak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: chalkMode
                            ? const Color(0xFFF4FAF1)
                            : const Color(0xFF223647),
                        fontWeight: FontWeight.w700,
                        fontFamily: chalkMode ? 'monospace' : null,
                      ),
                    ),
                  ),
                ),
              ),
            if (preparing)
              const Center(child: CircularProgressIndicator()),
            if ((errorText ?? '').isNotEmpty)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xD8452323),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.sending,
    required this.chalkMode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool sending;
  final bool chalkMode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: chalkMode ? const Color(0xCC0A322D) : Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: chalkMode
                  ? const Color(0x33000000)
                  : const Color(0x22000000),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    hintStyle: TextStyle(
                      color: chalkMode ? const Color(0xB3E7F7EC) : null,
                    ),
                    filled: true,
                    fillColor: chalkMode
                        ? const Color(0x3330A89A)
                        : const Color(0xFFF5F8FC),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: chalkMode
                            ? const Color(0x66A6DDC8)
                            : const Color(0xFFD8E1ED),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: chalkMode
                            ? const Color(0xFFBDF2DC)
                            : const Color(0xFF8AB8E6),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(
                    color: chalkMode ? const Color(0xFFF0FAF2) : null,
                    fontFamily: chalkMode ? 'monospace' : null,
                    letterSpacing: chalkMode ? 0.25 : null,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                  decoration: const InputDecoration(
                    hintText: 'Calismak istedigin konuyu yaz',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: sending ? null : onSubmit,
              icon: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(sending ? '...' : 'Sor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorMessage {
  const _TutorMessage({required this.role, required this.text});

  final String role;
  final String text;
}

class _TopicPill extends StatelessWidget {
  const _TopicPill({
    required this.label,
    required this.chalkMode,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool chalkMode;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color bg = chalkMode
        ? (selected ? const Color(0xAA40AFA0) : const Color(0x8823554D))
        : (selected ? const Color(0xFFD8ECFF) : const Color(0xFFECF3FB));
    final Color fg = chalkMode
        ? const Color(0xFFF4FAF1)
        : const Color(0xFF18324D);
    final Color border = chalkMode
        ? const Color(0x88CEF1E2)
        : const Color(0xFFD0DEEC);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontFamily: chalkMode ? 'monospace' : null,
              letterSpacing: chalkMode ? 0.2 : 0,
            ),
          ),
        ),
      ),
    );
  }
}
