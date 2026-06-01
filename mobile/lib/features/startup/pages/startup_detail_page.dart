import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../services/startup_questions_service.dart';
import '../models/startup_model.dart';
import '../models/startup_detail_models.dart';
import 'token_purchase_page.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../widgets/startup_documents_section.dart';
import '../widgets/startup_partners_section.dart';
import '../widgets/startup_about_section.dart';
import '../widgets/startup_metrics_section.dart';
import '../widgets/startup_questions_section.dart';
import '../widgets/startup_intro_section.dart';
import '../widgets/startup_token_overview_card.dart';
import '../../catalog/widgets/private_info_tab.dart';

enum ChartPeriod {
  day,
  week,
  month,
  sixMonths,
  year,
}

class StartupDetailPage extends StatefulWidget {
  final StartupModel startup;

  final List<double>? chartValues;
  final List<StartupSocietyMember>? societyMembers;
  final List<StartupSocietyMember>? mentors;
  final List<StartupQuestion>? questions;
  final List<StartupDocumentItem>? documents;

  const StartupDetailPage({
    super.key,
    required this.startup,
    this.chartValues,
    this.societyMembers,
    this.mentors,
    this.questions,
    this.documents,
  });

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {
  final TextEditingController _questionController = TextEditingController();
  final StartupQuestionsService _questionsService = StartupQuestionsService();

  ChartPeriod _selectedPeriod = ChartPeriod.sixMonths;

  late List<StartupSocietyMember> _societyMembers;
  late final List<StartupSocietyMember> _mentors;
  late final List<StartupDocumentItem> _documents;

  @override
  void initState() {
    super.initState();

    _societyMembers = widget.societyMembers ??
        widget.startup.equityList.map((item) {
          final percentageMatch = RegExp(r'\((.*?)\)').firstMatch(item);
          final percentage = percentageMatch?.group(1);

          final name = item.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();

          return StartupSocietyMember(
            name: name.isEmpty ? item : name,
            role: 'Sócio fundador',
            percentage: percentage,
          );
        }).toList();

    if (_societyMembers.isEmpty && widget.startup.partnersList.isNotEmpty) {
      _societyMembers = widget.startup.partnersList.map((partner) {
        return StartupSocietyMember(
          name: partner,
          role: 'Sócio fundador',
        );
      }).toList();
    }

    _mentors = widget.mentors ??
        widget.startup.mentorsList.map((mentor) {
          return StartupSocietyMember(
            name: mentor,
            role: 'Mentor / Conselho',
          );
        }).toList();

    _documents = widget.documents ??
        [
          StartupDocumentItem(
            title: 'Sumário executivo',
            description: widget.startup.executiveSummary.trim().isNotEmpty
                ? widget.startup.executiveSummary
                : 'Sumário executivo ainda não cadastrado.',
            icon: Icons.description_rounded,
          ),
          StartupDocumentItem(
            title: 'Plano de negócios',
            description: widget.startup.businessPlanUrl.trim().isNotEmpty
                ? 'Documento disponível para consulta.'
                : 'Plano de negócios ainda não cadastrado.',
            icon: Icons.insert_chart_rounded,
            url: widget.startup.businessPlanUrl,
          ),
          StartupDocumentItem(
            title: 'Apresentação dos sócios',
            description: widget.startup.partners.trim().isNotEmpty
                ? widget.startup.partners
                : 'Apresentação dos sócios ainda não cadastrada.',
            icon: Icons.groups_rounded,
          ),
        ];
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  /// desenvolvido por Miguel Gallinucci - le o historico de precos salvo na startup.
  Stream<List<_TokenPricePoint>> _watchTokenPriceHistory() {
    if (widget.startup.id.trim().isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection('startups')
        .doc(widget.startup.id)
        .collection('priceHistory')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _TokenPricePoint.fromMap(doc.data()))
          .where((point) => point.price > 0)
          .toList();
    });
  }

  /// desenvolvido por Miguel Gallinucci - transforma o historico real no grafico do token.
  _TokenChartData _buildTokenChartData(List<_TokenPricePoint> history) {
    final fallbackValues = _selectedChartValues;
    final fallbackLabels = _selectedChartLabels;

    if (history.isEmpty) {
      return _TokenChartData(
        values: fallbackValues,
        labels: fallbackLabels,
        subtitle: _selectedChartSubtitle,
      );
    }

    final filteredHistory = _filterHistoryBySelectedPeriod(history);
    final visibleHistory = filteredHistory.isEmpty ? history : filteredHistory;
    final values = <double>[];
    final labels = <String>[];
    final firstPoint = visibleHistory.first;

    if (firstPoint.previousPrice != null && firstPoint.previousPrice! > 0) {
      values.add(firstPoint.previousPrice!);
      labels.add(_formatChartLabel(firstPoint.createdAt, isInitialPoint: true));
    }

    for (final point in visibleHistory) {
      values.add(point.price);
      labels.add(_formatChartLabel(point.createdAt));
    }

    if (values.length == 1) {
      final currentPrice = widget.startup.tokenPrice?.toDouble() ?? values.first;
      values.insert(0, currentPrice);
      labels.insert(0, 'Inicio');
    }

    return _TokenChartData(
      values: values,
      labels: labels,
      subtitle: _selectedRealChartSubtitle,
    );
  }

  List<_TokenPricePoint> _filterHistoryBySelectedPeriod(
    List<_TokenPricePoint> history,
  ) {
    final now = DateTime.now();
    final cutoff = now.subtract(_selectedPeriodDuration);

    return history.where((point) {
      final createdAt = point.createdAt;
      if (createdAt == null) return true;

      return createdAt.isAfter(cutoff) || createdAt.isAtSameMomentAs(cutoff);
    }).toList();
  }

  Duration get _selectedPeriodDuration {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return const Duration(hours: 24);
      case ChartPeriod.week:
        return const Duration(days: 7);
      case ChartPeriod.month:
        return const Duration(days: 30);
      case ChartPeriod.sixMonths:
        return const Duration(days: 183);
      case ChartPeriod.year:
        return const Duration(days: 365);
    }
  }

  String get _selectedRealChartSubtitle {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return 'Historico real das ultimas 24h';
      case ChartPeriod.week:
        return 'Historico real dos ultimos 7 dias';
      case ChartPeriod.month:
        return 'Historico real dos ultimos 30 dias';
      case ChartPeriod.sixMonths:
        return 'Historico real dos ultimos 6 meses';
      case ChartPeriod.year:
        return 'Historico real do ultimo ano';
    }
  }

  String _formatChartLabel(DateTime? date, {bool isInitialPoint = false}) {
    if (date == null) {
      return isInitialPoint ? 'Inicio' : 'Agora';
    }

    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return '${date.hour.toString().padLeft(2, '0')}h';
      case ChartPeriod.week:
      case ChartPeriod.month:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      case ChartPeriod.sixMonths:
      case ChartPeriod.year:
        return '${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
    }
  }

  List<double> get _selectedChartValues {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return _scaleValuesToCurrentPrice(
          const [
            0.96,
            0.98,
            0.97,
            1.01,
            0.99,
            1.03,
            1.00,
          ],
        );

      case ChartPeriod.week:
        return _scaleValuesToCurrentPrice(
          const [
            0.93,
            0.95,
            0.94,
            0.97,
            0.98,
            1.01,
            1.00,
          ],
        );

      case ChartPeriod.month:
        return _scaleValuesToCurrentPrice(
          const [
            0.86,
            0.88,
            0.91,
            0.93,
            0.96,
            0.97,
            0.99,
            1.00,
          ],
        );

      case ChartPeriod.sixMonths:
        return _scaleValuesToCurrentPrice(
          widget.chartValues ??
              const [
                0.72,
                0.78,
                0.75,
                0.84,
                0.92,
                1.00,
              ],
        );

      case ChartPeriod.year:
        return _scaleValuesToCurrentPrice(
          const [
            0.62,
            0.65,
            0.67,
            0.71,
            0.74,
            0.78,
            0.82,
            0.86,
            0.89,
            0.93,
            0.96,
            1.00,
          ],
        );
    }
  }

  List<double> _scaleValuesToCurrentPrice(List<double> values) {
    if (values.isEmpty) return values;

    final currentPrice = widget.startup.tokenPrice?.toDouble();

    if (currentPrice == null || currentPrice <= 0) {
      return values;
    }

    final lastValue = values.last;

    if (lastValue <= 0) {
      return values;
    }

    final scale = currentPrice / lastValue;

    return values.map((value) => value * scale).toList();
  }

  List<String> get _selectedChartLabels {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return const [
          '00h',
          '04h',
          '08h',
          '12h',
          '16h',
          '20h',
          '24h',
        ];

      case ChartPeriod.week:
        return const [
          'Seg',
          'Ter',
          'Qua',
          'Qui',
          'Sex',
          'Sáb',
          'Dom',
        ];

      case ChartPeriod.month:
        return const [
          '1',
          '5',
          '10',
          '15',
          '20',
          '25',
          '30',
          'Hoje',
        ];

      case ChartPeriod.sixMonths:
        return const [
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
        ];

      case ChartPeriod.year:
        return const [
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez',
        ];
    }
  }

  String get _selectedChartSubtitle {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return 'Variação estimada ao longo do dia';

      case ChartPeriod.week:
        return 'Variação estimada da semana';

      case ChartPeriod.month:
        return 'Variação estimada do mês';

      case ChartPeriod.sixMonths:
        return 'Variação estimada dos últimos 6 meses';

      case ChartPeriod.year:
        return 'Variação estimada do ano';
    }
  }

  Future<void> _handleSendQuestion() async {
    final text = _questionController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma pergunta antes de enviar.'),
        ),
      );
      return;
    }

    try {
      await _questionsService.sendQuestion(
        startupId: widget.startup.id,
        startupName: widget.startup.name,
        question: text,
      );

      _questionController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pergunta enviada. Ela ficará aguardando resposta.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar pergunta: $error'),
        ),
      );
    }
  }

  void _goToInvestmentPage(double currentPrice) {
    final availableTokens = widget.startup.availableTokens?.toInt() ?? 0;

    if (availableTokens <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta startup nao possui tokens disponiveis.'),
          backgroundColor: Color(0xFF102235),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final tokenPrice =
        'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TokenPurchasePage(
          startup: widget.startup,
          tokenPrice: tokenPrice,
          availableBalance: 'R\$ 5.000,00',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: StreamBuilder<List<_TokenPricePoint>>(
          stream: _watchTokenPriceHistory(),
          builder: (context, snapshot) {
            final chartData = _buildTokenChartData(snapshot.data ?? const []);
            final currentPrice = chartData.values.last;
            final availableTokens = widget.startup.availableTokens?.toInt() ?? 0;
            final hasAvailableTokens = availableTokens > 0;

            return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF04111D).withValues(alpha: 0.96),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: hasAvailableTokens
                      ? () => _goToInvestmentPage(currentPrice)
                      : null,
                  icon: Icon(
                    hasAvailableTokens
                        ? Icons.rocket_launch_rounded
                        : Icons.block_rounded,
                  ),
                  label: Text(
                    hasAvailableTokens
                        ? 'Investir nesta startup'
                        : 'Tokens esgotados',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
                    disabledForegroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF04111D),
              Color(0xFF071A2B),
              Color(0xFF0A2235),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StartupIntroSection(
                      name: widget.startup.name,
                      sector: widget.startup.displaySector,
                      stage: widget.startup.stage,
                      description: widget.startup.description,
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 22),

                    StartupAboutSection(aboutText: widget.startup.aboutText),

                    const SizedBox(height: 18),

                    StartupMetricsSection(
                      capital: widget.startup.capital,
                      tokens: widget.startup.tokens,
                      availableTokens: widget.startup.availableTokensText,
                      status: widget.startup.status.trim().isNotEmpty
                          ? widget.startup.status
                          : widget.startup.stage,
                    ),

                    const SizedBox(height: 18),

                    StreamBuilder<List<_TokenPricePoint>>(
                      stream: _watchTokenPriceHistory(),
                      builder: (context, snapshot) {
                        final chartData =
                            _buildTokenChartData(snapshot.data ?? const []);
                        final currentPrice = chartData.values.last;
                        final firstPrice = chartData.values.first;
                        final variation = firstPrice > 0
                            ? ((currentPrice - firstPrice) / firstPrice) * 100
                            : 0.0;
                        final isPositive = variation >= 0;

                        return StartupTokenOverviewCard(
                          currentPrice: currentPrice,
                          variation: variation,
                          isPositive: isPositive,
                          chartValues: chartData.values,
                          chartLabels: chartData.labels,
                          subtitle: chartData.subtitle,
                          selectedPeriod: _selectedPeriod,
                          onPeriodChanged: (period) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    StartupPartnersSection(
                      societyMembers: _societyMembers,
                      mentors: _mentors,
                    ),
                    const SizedBox(height: 18),
                    StartupDocumentsSection(documents: _documents),
                    const SizedBox(height: 18),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _questionsService.watchQuestions(
                        startupId: widget.startup.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return AppSectionCard(
                            title: 'Perguntas públicas',
                            subtitle: 'Dúvidas dos usuários e respostas da startup',
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryLight,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return AppSectionCard(
                            title: 'Perguntas públicas',
                            subtitle: 'Dúvidas dos usuários e respostas da startup',
                            child: Text(
                              'Não foi possível carregar as perguntas desta startup.\n\nErro: ${snapshot.error}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final questions = docs.map((doc) {
                          return StartupQuestion.fromMap(doc.data());
                        }).toList();

                        questions.sort((a, b) {
                          final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                          final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

                          return dateB.compareTo(dateA);
                        });

                        return StartupQuestionsSection(
                          controller: _questionController,
                          questions: questions,
                          onSend: _handleSendQuestion,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    PrivateInfoTab(
                      startupId: widget.startup.id,
                    ),
                    const SizedBox(height: 18),
                    AppSectionCard(
                      title: 'Vídeo demonstrativo',
                      subtitle: 'Pitch ou demonstração do produto',
                      child: StartupDemoVideo(
                        videoUrl: widget.startup.demoVideoUrl,
                      ),
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StartupDemoVideo extends StatefulWidget {
  final String videoUrl;

  const StartupDemoVideo({
    super.key,
    required this.videoUrl,
  });

  @override
  State<StartupDemoVideo> createState() => _StartupDemoVideoState();
}

class _StartupDemoVideoState extends State<StartupDemoVideo> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideo;
  double _volume = 1;

  bool get _hasVideo => widget.videoUrl.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  @override
  void didUpdateWidget(covariant StartupDemoVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _setupVideo();
    }
  }

  void _setupVideo() {
    final String source = widget.videoUrl.trim();

    if (source.isEmpty) {
      _controller = null;
      _initializeVideo = null;
      return;
    }

    final bool isAsset = source.startsWith('assets/');
    _controller = isAsset
        ? VideoPlayerController.asset(source)
        : VideoPlayerController.networkUrl(Uri.parse(source));
    _initializeVideo = _controller!.initialize().then((_) {
      _controller!
        ..setLooping(false)
        ..setVolume(_volume);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void _seekRelative(Duration offset) {
    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    final Duration duration = controller.value.duration;
    final Duration current = controller.value.position;
    final int targetMs = (current + offset).inMilliseconds.clamp(
          0,
          duration.inMilliseconds,
        );

    controller.seekTo(Duration(milliseconds: targetMs));
  }

  void _seekToProgress(double progress) {
    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    final Duration duration = controller.value.duration;
    controller.seekTo(
      Duration(
        milliseconds: (duration.inMilliseconds * progress).round(),
      ),
    );
  }

  void _setVolume(double volume) {
    final VideoPlayerController? controller = _controller;

    setState(() {
      _volume = volume.clamp(0, 1);
      controller?.setVolume(_volume);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    if (duration.inHours > 0) {
      return '${duration.inHours}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '$minutes:${twoDigits(seconds)}';
  }

  Future<void> _openExpandedPlayer() async {
    final VideoPlayerController? controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Video demonstrativo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildVideoPlayer(controller, expanded: true),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildVideoPlayer(
    VideoPlayerController controller, {
    required bool expanded,
  }) {
    return _VideoFrame(
      height: expanded ? 430 : 260,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final VideoPlayerValue value = controller.value;
          final Duration duration = value.duration;
          final Duration position = value.position;
          final double progress = duration.inMilliseconds == 0
              ? 0
              : (position.inMilliseconds / duration.inMilliseconds).clamp(0, 1);

          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _togglePlayback,
                  child: ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  tooltip: expanded ? 'Janela aberta' : 'Abrir em janela',
                  onPressed: expanded ? null : _openExpandedPlayer,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    disabledBackgroundColor:
                        Colors.black.withValues(alpha: 0.25),
                  ),
                  icon: const Icon(
                    Icons.open_in_full_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (!value.isPlaying)
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _togglePlayback,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.primaryLight,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                              ),
                              child: Slider(
                                value: progress.toDouble(),
                                min: 0,
                                max: 1,
                                activeColor: AppColors.primaryLight,
                                inactiveColor:
                                    Colors.white.withValues(alpha: 0.2),
                                onChanged: _seekToProgress,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _VideoIconButton(
                            tooltip: 'Voltar 10 segundos',
                            icon: Icons.replay_10_rounded,
                            onPressed: () =>
                                _seekRelative(const Duration(seconds: -10)),
                          ),
                          _VideoIconButton(
                            tooltip: value.isPlaying ? 'Pausar' : 'Reproduzir',
                            icon: value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            onPressed: _togglePlayback,
                          ),
                          _VideoIconButton(
                            tooltip: 'Avancar 10 segundos',
                            icon: Icons.forward_10_rounded,
                            onPressed: () =>
                                _seekRelative(const Duration(seconds: 10)),
                          ),
                          const Spacer(),
                          _VideoIconButton(
                            tooltip: _volume == 0 ? 'Ativar som' : 'Mutar',
                            icon: _volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            onPressed: () => _setVolume(_volume == 0 ? 1 : 0),
                          ),
                          SizedBox(
                            width: expanded ? 120 : 82,
                            child: Slider(
                              value: _volume,
                              min: 0,
                              max: 1,
                              activeColor: AppColors.primaryLight,
                              inactiveColor:
                                  Colors.white.withValues(alpha: 0.2),
                              onChanged: _setVolume,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasVideo) {
      return const _VideoPlaceholder();
    }

    return FutureBuilder<void>(
      future: _initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _VideoFrame(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
              ),
            ),
          );
        }

        if (snapshot.hasError || _controller == null) {
          return const _VideoPlaceholder(
            title: 'Nao foi possivel carregar o video',
            subtitle: 'Verifique o arquivo ou URL cadastrado.',
          );
        }

        final VideoPlayerController controller = _controller!;

        return _buildVideoPlayer(controller, expanded: false);
      },
    );
  }
}

class _VideoFrame extends StatelessWidget {
  final Widget child;
  final double height;

  const _VideoFrame({
    required this.child,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class _VideoIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _VideoIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _VideoPlaceholder({
    this.title = 'Area reservada para video',
    this.subtitle = 'Demonstracao ou pitch da startup',
  });

  @override
  Widget build(BuildContext context) {
    return _VideoFrame(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.primaryLight,
              size: 52,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenPricePoint {
  final double price;
  final double? previousPrice;
  final DateTime? createdAt;

  const _TokenPricePoint({
    required this.price,
    this.previousPrice,
    this.createdAt,
  });

  factory _TokenPricePoint.fromMap(Map<String, dynamic> data) {
    return _TokenPricePoint(
      price: _toDouble(data['price']),
      previousPrice: _toNullableDouble(data['previousPrice']),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }

    return 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }

    return null;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }
}

class _TokenChartData {
  final List<double> values;
  final List<String> labels;
  final String subtitle;

  const _TokenChartData({
    required this.values,
    required this.labels,
    required this.subtitle,
  });
}
