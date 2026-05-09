import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../services/startup_questions_service.dart';
import '../models/startup_model.dart';
import 'token_purchase_page.dart';

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
                    _Header(
                      name: widget.startup.name,
                      sector: widget.startup.displaySector,
                      stage: widget.startup.stage,
                      description: widget.startup.description,
                    ),
                    const SizedBox(height: 22),

                    _SectionCard(
                      title: 'Sobre o projeto',
                      subtitle: 'Resumo da proposta da startup',
                      child: Text(
                        widget.startup.aboutText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Capital aportado',
                            value: widget.startup.capital,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'Tokens emitidos',
                            value: widget.startup.tokens,
                            icon: Icons.generating_tokens_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Tokens disponíveis',
                            value: widget.startup.availableTokensText,
                            icon: Icons.confirmation_number_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'Status',
                            value: widget.startup.status.trim().isNotEmpty
                                ? widget.startup.status
                                : widget.startup.stage,
                            icon: Icons.verified_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _TokenOverviewCard(
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
                    _SectionCard(
                      title: 'Estrutura societária',
                      subtitle: 'Participação dos sócios no projeto',
                      child: Column(
                        children: [
                          for (int i = 0; i < _societyMembers.length; i++) ...[
                            _MemberRow(member: _societyMembers[i]),
                            if (i != _societyMembers.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Mentores e conselho',
                      subtitle: 'Apoio estratégico da startup',
                      child: Column(
                        children: [
                          for (int i = 0; i < _mentors.length; i++) ...[
                            _MemberRow(member: _mentors[i]),
                            if (i != _mentors.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Documentos públicos',
                      subtitle: 'Materiais essenciais para análise do investidor',
                      child: Column(
                        children: [
                          for (int i = 0; i < _documents.length; i++) ...[
                            _DocumentRow(item: _documents[i]),
                            if (i != _documents.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _questionsService.watchQuestions(
                        startupId: widget.startup.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _SectionCard(
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
                          return _SectionCard(
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

                        return _QuestionsSection(
                          controller: _questionController,
                          questions: questions,
                          onSend: _handleSendQuestion,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
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

class _Header extends StatelessWidget {
  final String name;
  final String sector;
  final String stage;
  final String description;

  const _Header({
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _SimpleHeaderTag(
                    text: sector,
                    icon: Icons.work_rounded,
                    highlighted: true,
                  ),
                  _SimpleHeaderTag(
                    text: stage,
                    icon: Icons.show_chart_rounded,
                    highlighted: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _SimpleHeaderTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool highlighted;

  const _SimpleHeaderTag({
    required this.text,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: highlighted
              ? AppColors.primaryLight
              : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlighted
                ? AppColors.primaryLight
                : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TokenOverviewCard extends StatelessWidget {
  final double currentPrice;
  final double variation;
  final bool isPositive;
  final List<double> chartValues;
  final List<String> chartLabels;
  final String subtitle;
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const _TokenOverviewCard({
    required this.currentPrice,
    required this.variation,
    required this.isPositive,
    required this.chartValues,
    required this.chartLabels,
    required this.subtitle,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumo do token',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _ChartPeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Preço atual',
                  value:
                  'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  highlight: true,
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  label: 'Variação',
                  value:
                  '${isPositive ? '+' : ''}${variation.toStringAsFixed(1)}%',
                  highlight: true,
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 230,
            child: _StartupLineChart(
              values: chartValues,
              labels: chartLabels,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPeriodSelector extends StatelessWidget {
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onPeriodChanged;

  const _ChartPeriodSelector({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Dia',
            period: ChartPeriod.day,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Semana',
            period: ChartPeriod.week,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Mês',
            period: ChartPeriod.month,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: '6M',
            period: ChartPeriod.sixMonths,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
          _PeriodButton(
            label: 'Ano',
            period: ChartPeriod.year,
            selectedPeriod: selectedPeriod,
            onTap: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final ChartPeriod period;
  final ChartPeriod selectedPeriod;
  final ValueChanged<ChartPeriod> onTap;

  const _PeriodButton({
    required this.label,
    required this.period,
    required this.selectedPeriod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionsSection extends StatelessWidget {
  final TextEditingController controller;
  final List<StartupQuestion> questions;
  final VoidCallback onSend;

  const _QuestionsSection({
    required this.controller,
    required this.questions,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Perguntas públicas',
      subtitle: 'Dúvidas dos usuários e respostas da startup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Digite uma pergunta para os empreendedores...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Enviar pergunta',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (questions.isEmpty)
            const Text(
              'Ainda não há perguntas públicas para esta startup.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < questions.length; i++) ...[
                  _QuestionItem(item: questions[i]),
                  if (i != questions.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _StartupLineChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels;

  const _StartupLineChart({
    required this.values,
    required this.labels,
  });

  @override
  State<_StartupLineChart> createState() => _StartupLineChartState();
}

class _StartupLineChartState extends State<_StartupLineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _StartupLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.values != widget.values || oldWidget.labels != widget.labels) {
      _selectedIndex = null;
    }
  }

  void _selectNearestPoint(Offset localPosition, double width) {
    final itemCount = widget.values.length < widget.labels.length
        ? widget.values.length
        : widget.labels.length;

    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    final availableWidth = width - leftPadding - rightPadding;

    if (availableWidth <= 0) return;

    final rawIndex = itemCount == 1
        ? 0
        : ((localPosition.dx - leftPadding) / availableWidth * (itemCount - 1))
            .round();

    setState(() {
      _selectedIndex = rawIndex.clamp(0, itemCount - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragStart: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          onHorizontalDragUpdate: (details) {
            _selectNearestPoint(details.localPosition, constraints.maxWidth);
          },
          child: CustomPaint(
            painter: _StartupLineChartPainter(
              values: widget.values,
              labels: widget.labels,
              selectedIndex: _selectedIndex,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _StartupLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int? selectedIndex;

  _StartupLineChartPainter({
    required this.values,
    required this.labels,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount = values.length < labels.length ? values.length : labels.length;

    if (itemCount == 0) return;

    const leftPadding = 64.0;
    const rightPadding = 22.0;
    const topPadding = 14.0;
    const bottomPadding = 34.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final chartBottom = topPadding + chartHeight;
    final availableWidth = size.width - leftPadding - rightPadding;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.2;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x3334D399),
          Color(0x0034D399),
        ],
      ).createShader(
        Rect.fromLTWH(
          leftPadding,
          topPadding,
          availableWidth,
          chartHeight,
        ),
      );

    final pointGlowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = const Color(0xFF04111D)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final visibleValues = values.take(itemCount).toList();
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = maxValue - minValue;
    final padding = rawRange == 0 ? maxValue.abs() * 0.08 : rawRange * 0.18;
    final chartMin = minValue - padding;
    final chartMax = maxValue + padding;
    final range = (chartMax - chartMin) == 0 ? 1.0 : (chartMax - chartMin);

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final value = chartMax - (range * i / 4);
      _paintText(
        canvas: canvas,
        text: 'R\$ ${_formatPriceAxisValue(value)}',
        x: 0,
        y: y - 8,
        maxWidth: leftPadding - 8,
        color: AppColors.textSecondary,
        fontSize: 10.5,
        textAlign: TextAlign.right,
      );
    }

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, chartBottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, chartBottom),
      Offset(size.width - rightPadding, chartBottom),
      axisPaint,
    );

    final points = <Offset>[];

    for (int i = 0; i < itemCount; i++) {
      final x = itemCount == 1
          ? leftPadding + availableWidth / 2
          : leftPadding + (availableWidth / (itemCount - 1)) * i;

      final normalized = (values[i] - chartMin) / range;

      final y = chartBottom - (normalized * chartHeight);

      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartBottom)
      ..lineTo(points.first.dx, chartBottom)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final activeIndex = (selectedIndex ?? itemCount - 1).clamp(0, itemCount - 1);
    final activePoint = points[activeIndex];

    canvas.drawLine(
      Offset(activePoint.dx, chartBottom),
      activePoint,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.28)
        ..strokeWidth = 1.2,
    );

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isActive = i == activeIndex;

      canvas.drawCircle(point, isActive ? 8 : 6.5, pointGlowPaint);
      canvas.drawCircle(point, isActive ? 5.4 : 4.6, pointBorderPaint);
      canvas.drawCircle(point, isActive ? 3.8 : 3.2, pointPaint);
    }

    _paintValueBubble(
      canvas: canvas,
      text:
          '${labels[activeIndex]}  R\$ ${_formatSelectedPriceValue(values[activeIndex])}',
      anchor: activePoint,
      size: size,
    );

    final labelStep = itemCount > 8 ? 2 : 1;
    for (int i = 0; i < itemCount; i++) {
      if (i != itemCount - 1 && i % labelStep != 0) continue;
      if (itemCount > 8 && i == itemCount - 2) continue;

      final label = labels[i];
      final point = points[i];
      const labelWidth = 48.0;
      final labelX = (point.dx - labelWidth / 2)
          .clamp(0.0, size.width - labelWidth);

      _paintText(
        canvas: canvas,
        text: label,
        x: labelX,
        y: chartBottom + 12,
        maxWidth: labelWidth,
        color: i == activeIndex ? AppColors.primaryLight : AppColors.textSecondary,
        fontSize: 11,
        textAlign: TextAlign.center,
      );
    }
  }

  void _paintValueBubble({
    required Canvas canvas,
    required String text,
    required Offset anchor,
    required Size size,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    const horizontalPadding = 8.0;
    const verticalPadding = 5.0;
    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;

    var left = anchor.dx - width / 2;
    var top = anchor.dy - height - 10;

    if (left < 0) left = 0;
    if (left + width > size.width) left = size.width - width;
    if (top < 0) top = anchor.dy + 10;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      const Radius.circular(12),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF102235),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
  }

  void _paintText({
    required Canvas canvas,
    required String text,
    required double x,
    required double y,
    required double maxWidth,
    required Color color,
    required double fontSize,
    TextAlign textAlign = TextAlign.left,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);

    var paintX = x;

    if (textAlign == TextAlign.center) {
      paintX = x + (maxWidth - textPainter.width) / 2;
    } else if (textAlign == TextAlign.right) {
      paintX = x + maxWidth - textPainter.width;
    }

    textPainter.paint(canvas, Offset(paintX, y));
  }

  String _formatPriceAxisValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    if (value.abs() < 1) {
      return value.toStringAsFixed(2).replaceAll('.', ',');
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _formatSelectedPriceValue(double value) {
    if (value.abs() < 0.1) {
      return value.toStringAsFixed(3).replaceAll('.', ',');
    }

    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  bool shouldRepaint(covariant _StartupLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final IconData? icon;

  const _InfoCard({
    required this.label,
    required this.value,
    this.highlight = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        icon,
                        color: highlight
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                height: 34,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        color: highlight ? AppColors.primaryLight : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final StartupSocietyMember member;

  const _MemberRow({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter =
    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.16),
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (member.percentage != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                member.percentage!,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final StartupQuestion item;

  const _QuestionItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnswer = item.answer != null && item.answer!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAnswer
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppColors.primaryLight,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasAnswer)
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Text(
                item.answer!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Aguardando resposta da startup',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final StartupDocumentItem item;

  const _DocumentRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
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
