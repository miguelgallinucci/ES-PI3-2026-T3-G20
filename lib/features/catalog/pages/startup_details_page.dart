import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'investment_page.dart';

enum ChartPeriod {
  day,
  week,
  month,
  sixMonths,
  year,
}

class StartupDetailsPage extends StatefulWidget {
  final String name;
  final String sector;
  final String stage;
  final String description;
  final String capital;
  final String tokens;

  final List<double>? chartValues;
  final List<StartupSocietyMember>? societyMembers;
  final List<StartupSocietyMember>? mentors;
  final List<StartupQuestion>? questions;
  final List<StartupDocumentItem>? documents;

  const StartupDetailsPage({
    super.key,
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
    required this.capital,
    required this.tokens,
    this.chartValues,
    this.societyMembers,
    this.mentors,
    this.questions,
    this.documents,
  });

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
  final TextEditingController _questionController = TextEditingController();

  ChartPeriod _selectedPeriod = ChartPeriod.sixMonths;

  late final List<StartupSocietyMember> _societyMembers;
  late final List<StartupSocietyMember> _mentors;
  late final List<StartupDocumentItem> _documents;
  late List<StartupQuestion> _questions;

  @override
  void initState() {
    super.initState();

    _societyMembers = widget.societyMembers ??
        const [
          StartupSocietyMember(
            name: 'Ana Martins',
            role: 'CEO',
            percentage: '45%',
          ),
          StartupSocietyMember(
            name: 'Lucas Ferreira',
            role: 'CTO',
            percentage: '35%',
          ),
          StartupSocietyMember(
            name: 'Marina Souza',
            role: 'COO',
            percentage: '20%',
          ),
        ];

    _mentors = widget.mentors ??
        const [
          StartupSocietyMember(
            name: 'Carlos Almeida',
            role: 'Mentor em Estratégia',
          ),
          StartupSocietyMember(
            name: 'Fernanda Lima',
            role: 'Conselho Consultivo',
          ),
        ];

    _questions = List<StartupQuestion>.from(
      widget.questions ??
          const [
            StartupQuestion(
              question: 'Qual o principal diferencial da startup?',
              answer:
              'O diferencial está na integração entre tecnologia, escalabilidade e foco em eficiência operacional.',
            ),
            StartupQuestion(
              question: 'Em que estágio a operação se encontra?',
              answer:
              'A startup já possui operação estruturada e está em fase de crescimento dentro do ecossistema.',
            ),
          ],
    );

    _documents = widget.documents ??
        const [
          StartupDocumentItem(
            title: 'Sumário executivo',
            description: 'Resumo da proposta, mercado e modelo de negócio.',
            icon: Icons.description_rounded,
          ),
          StartupDocumentItem(
            title: 'Plano de negócios',
            description: 'Estratégia, projeções e visão de crescimento.',
            icon: Icons.insert_chart_rounded,
          ),
          StartupDocumentItem(
            title: 'Apresentação dos sócios',
            description: 'Equipe fundadora e funções principais.',
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
        return const [
          12.0,
          12.1,
          11.9,
          12.2,
          12.15,
          12.3,
          12.4,
          12.5,
        ];

      case ChartPeriod.week:
        return const [
          11.2,
          11.5,
          11.4,
          11.9,
          12.1,
          12.3,
          12.5,
        ];

      case ChartPeriod.month:
        return const [
          10.6,
          10.8,
          11.0,
          11.3,
          11.6,
          11.9,
          12.2,
          12.5,
        ];

      case ChartPeriod.sixMonths:
        return widget.chartValues ??
            const [
              8.2,
              8.9,
              8.6,
              9.4,
              10.8,
              12.5,
            ];

      case ChartPeriod.year:
        return const [
          7.8,
          8.1,
          8.4,
          8.9,
          9.3,
          9.8,
          10.2,
          10.7,
          11.1,
          11.6,
          12.0,
          12.5,
        ];
    }
  }

  List<String> get _selectedChartLabels {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return const [
          '8h',
          '10h',
          '12h',
          '14h',
          '16h',
          '18h',
          '20h',
          '22h',
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
          'S1',
          'S2',
          'S3',
          'S4',
          'S5',
          'S6',
          'S7',
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

  void _handleSendQuestion() {
    final text = _questionController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma pergunta antes de enviar.'),
        ),
      );
      return;
    }

    setState(() {
      _questions.insert(
        0,
        StartupQuestion(
          question: text,
          answer: null,
          createdAt: DateTime.now(),
        ),
      );
      _questionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pergunta enviada. Ela ficará aguardando resposta.'),
      ),
    );

    /*
      FIRESTORE DEPOIS:

      FirebaseFirestore.instance
          .collection('startups')
          .doc(startupId)
          .collection('questions')
          .add({
            'question': text,
            'answer': null,
            'createdAt': FieldValue.serverTimestamp(),
            'isPublic': true,
            'userId': currentUser.uid,
          });

      Depois vamos precisar adicionar:
      import 'package:cloud_firestore/cloud_firestore.dart';
    */
  }

  void _goToInvestmentPage(double currentPrice) {
    final tokenPrice =
        'R\$ ${currentPrice.toStringAsFixed(2).replaceAll('.', ',')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvestmentPage(
          startupName: widget.name,
          sector: widget.sector,
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
                      name: widget.name,
                      sector: widget.sector,
                      stage: widget.stage,
                      description: widget.description,
                    ),
                    const SizedBox(height: 22),
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
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Capital aportado',
                            value: widget.capital,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'Tokens emitidos',
                            value: widget.tokens,
                            icon: Icons.generating_tokens_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Sobre o projeto',
                      subtitle: 'Resumo da proposta da startup',
                      child: Text(
                        'A ${widget.name} atua no setor de ${widget.sector.toLowerCase()} e está classificada como ${widget.stage.toLowerCase()}. '
                            'O projeto busca solucionar uma dor real do mercado com uma solução escalável, tecnológica e com potencial de crescimento no ecossistema MesclaInvest.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
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
                    _QuestionsSection(
                      controller: _questionController,
                      questions: _questions,
                      onSend: _handleSendQuestion,
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
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_fill_rounded,
                                color: AppColors.primaryLight,
                                size: 52,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Área reservada para vídeo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Demonstração ou pitch da startup',
                                style: TextStyle(
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
          children: [
            _Badge(
              text: sector,
              icon: Icons.business_center_rounded,
              highlighted: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Badge(
                text: stage,
                icon: Icons.trending_up_rounded,
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

class _Badge extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool highlighted;

  const _Badge({
    required this.text,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.13)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlighted ? AppColors.primaryLight : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                highlighted ? AppColors.primaryLight : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
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

class _StartupLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _StartupLineChart({
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StartupLineChartPainter(
        values: values,
        labels: labels,
      ),
      child: Container(),
    );
  }
}

class _StartupLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _StartupLineChartPainter({
    required this.values,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) return;

    final itemCount = values.length < labels.length ? values.length : labels.length;

    if (itemCount == 0) return;

    final chartHeight = size.height - 42;
    final leftPadding = itemCount > 8 ? 10.0 : 16.0;
    final rightPadding = itemCount > 8 ? 10.0 : 16.0;
    final topPadding = 12.0;
    final bottomLabelTop = chartHeight + 12;
    final availableWidth = size.width - leftPadding - rightPadding;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3.2
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
          0,
          topPadding,
          size.width,
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

    for (int i = 1; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 5);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    final visibleValues = values.take(itemCount).toList();
    final minValue = visibleValues.reduce((a, b) => a < b ? a : b);
    final maxValue = visibleValues.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1.0 : (maxValue - minValue);

    final points = <Offset>[];

    for (int i = 0; i < itemCount; i++) {
      final x = itemCount == 1
          ? size.width / 2
          : leftPadding + (availableWidth / (itemCount - 1)) * i;

      final normalized = (values[i] - minValue) / range;

      final y = topPadding +
          chartHeight -
          (normalized * (chartHeight - 18)) -
          8;

      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, topPadding + chartHeight)
      ..lineTo(points.first.dx, topPadding + chartHeight)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 7, pointGlowPaint);
      canvas.drawCircle(point, 4.8, pointBorderPaint);
      canvas.drawCircle(point, 3.4, pointPaint);
    }

    for (int i = 0; i < itemCount; i++) {
      final label = labels[i];

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: itemCount > 8 ? 10.5 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      double x = points[i].dx - textPainter.width / 2;

      if (x < 0) x = 0;
      if (x + textPainter.width > size.width) {
        x = size.width - textPainter.width;
      }

      textPainter.paint(
        canvas,
        Offset(
          x,
          bottomLabelTop,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StartupLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.labels != labels;
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color:
                highlight ? AppColors.primaryLight : AppColors.textSecondary,
                size: 21,
              ),
              const SizedBox(height: 10),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: highlight ? AppColors.primaryLight : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
    return StartupQuestion(
      question: map['question'] ?? '',
      answer: map['answer'],
      createdAt: map['createdAt'] is DateTime ? map['createdAt'] : null,
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