import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/startup_questions_service.dart';
import '../models/startup_model.dart';
import 'token_purchase_page.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../widgets/startup_documents_section.dart';
import '../widgets/startup_partners_section.dart';
import '../widgets/startup_about_section.dart';
import '../widgets/startup_metrics_section.dart';
import '../widgets/startup_questions_section.dart';
import '../widgets/startup_intro_section.dart';
import '../widgets/startup_token_overview_card.dart';

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
        return 'Variação simulada ao longo do dia';

      case ChartPeriod.week:
        return 'Variação simulada da semana';

      case ChartPeriod.month:
        return 'Variação simulada do mês';

      case ChartPeriod.sixMonths:
        return 'Variação simulada dos últimos 6 meses';

      case ChartPeriod.year:
        return 'Variação simulada do ano';
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
    final tokenPrice = widget.startup.tokenPriceText != '-'
        ? widget.startup.tokenPriceText
        : 'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}';

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
    final chartValues = _selectedChartValues;
    final chartLabels = _selectedChartLabels;

    final currentPrice = chartValues.last;
    final firstPrice = chartValues.first;
    final variation = ((currentPrice - firstPrice) / firstPrice) * 100;
    final isPositive = variation >= 0;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
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
              onPressed: () => _goToInvestmentPage(currentPrice),
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text(
                'Investir nesta startup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
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

                    StartupTokenOverviewCard(
                      currentPrice: currentPrice,
                      variation: variation,
                      isPositive: isPositive,
                      chartValues: chartValues,
                      chartLabels: chartLabels,
                      subtitle: _selectedChartSubtitle,
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _selectedPeriod = period;
                        });
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
                    AppSectionCard(
                      title: 'Vídeo demonstrativo',
                      subtitle: 'Pitch ou demonstração do produto',
                      child: Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.border),
                        ),
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
                                widget.startup.demoVideoUrl.trim().isNotEmpty
                                    ? 'Vídeo demonstrativo disponível'
                                    : 'Área reservada para vídeo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.startup.demoVideoUrl.trim().isNotEmpty
                                    ? widget.startup.demoVideoUrl
                                    : 'Demonstração ou pitch da startup',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
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







class StartupSocietyMember {
  final String name;
  final String role;
  final String? percentage;

  const StartupSocietyMember({
    required this.name,
    required this.role,
    this.percentage,
  });

  factory StartupSocietyMember.fromMap(Map<String, dynamic> map) {
    return StartupSocietyMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      percentage: map['percentage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'percentage': percentage,
    };
  }
}

class StartupQuestion {
  final String question;
  final String? answer;
  final DateTime? createdAt;

  const StartupQuestion({
    required this.question,
    this.answer,
    this.createdAt,
  });

  factory StartupQuestion.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;

    final createdAt = map['createdAt'];

    if (createdAt is Timestamp) {
      parsedDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      parsedDate = createdAt;
    }

    return StartupQuestion(
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'createdAt': createdAt,
    };
  }
}

class StartupDocumentItem {
  final String title;
  final String description;
  final IconData icon;
  final String? url;

  const StartupDocumentItem({
    required this.title,
    required this.description,
    required this.icon,
    this.url,
  });

  factory StartupDocumentItem.fromMap(Map<String, dynamic> map) {
    return StartupDocumentItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: Icons.description_rounded,
      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
    };
  }
}
