import '../models/startup_model.dart';

const List<StartupModel> mockStartups = [
  StartupModel(
    id: 'visionai-health',
    name: 'VisionAI Health',
    sector: 'Saúde',
    categories: ['Saúde', 'Tecnologia'],
    stage: 'Em operação',
    description:
    'Plataforma de apoio à análise preventiva com foco em monitoramento inteligente e integração digital.',
    capital: 'R\$ 850 mil',
    tokens: '12.000',
  ),
  StartupModel(
    id: 'greenvolt-hub',
    name: 'GreenVolt Hub',
    sector: 'Energia',
    categories: ['Sustentabilidade', 'Tecnologia'],
    stage: 'Em expansão',
    description:
    'Solução para gestão e otimização de consumo energético com foco em eficiência e sustentabilidade.',
    capital: 'R\$ 1,2 mi',
    tokens: '20.000',
  ),
  StartupModel(
    id: 'agrolink-data',
    name: 'AgroLink Data',
    sector: 'Agrotech',
    categories: ['Agro', 'Tecnologia'],
    stage: 'Nova',
    description:
    'Ferramenta de dados para decisões agrícolas mais inteligentes, com foco em produtividade e previsibilidade.',
    capital: 'R\$ 430 mil',
    tokens: '8.500',
  ),
];