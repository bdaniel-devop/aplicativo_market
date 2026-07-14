import 'package:flutter/material.dart';
import 'legal_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Política de Privacidade',
      icon: Icons.shield_outlined,
      intro: 'O seu direito à privacidade é importante para nós. Esta política explica de forma clara quais dados recolhemos, como os usamos e quais os seus direitos enquanto titular dos dados.',
      sections: const [
        LegalSection('1. Responsável pelo Tratamento de Dados',
            'A AgroSuste, plataforma digital de comércio agrícola operada em Moçambique, é a responsável pelo tratamento dos dados pessoais recolhidos através da plataforma.\n\nContacto do responsável: renio.mole@agrosuste.org'),
        LegalSection('2. Dados Pessoais que Recolhemos',
            '• Identificação: nome completo, email, número de celular, fotografia de perfil, BI/NUIT.\n'
                '• Localização: país, província, distrito, posto administrativo e localidade/bairro.\n'
                '• Comerciais: tipo de entidade, nome comercial, documentos legais, categorias de produtos e histórico de transacções.\n'
                '• Utilização: endereço IP, tipo de dispositivo, páginas visitadas e interacções com a plataforma.\n'
                '• Pagamento: número associado a carteiras móveis (M-Pesa, e-Mola, Mkesh). Não armazenamos PINs nem dados de cartões.'),
        LegalSection('3. Finalidade do Tratamento',
            'Os seus dados são utilizados para criar e gerir a sua conta, processar transacções e pagamentos, facilitar a comunicação entre compradores, vendedores e transportadores, enviar notificações relevantes, melhorar a plataforma, prevenir fraudes, cumprir obrigações legais e, apenas com o seu consentimento, enviar comunicações de marketing.'),
        LegalSection('4. Partilha de Dados com Terceiros',
            'Os seus dados podem ser partilhados com parceiros de pagamento (PaysGator, Vodacom M-Pesa, Movitel e-Mola, Mcel Mkesh), transportadores registados, fornecedores de infraestrutura e autoridades competentes quando exigido por lei. Não vendemos os seus dados para fins publicitários a terceiros.'),
        LegalSection('5. Retenção e Segurança dos Dados',
            'Os dados são conservados enquanto a conta estiver activa. Após o encerramento, são anonimizados ou eliminados em até 90 dias, salvo obrigação legal de retenção. Implementamos encriptação em trânsito e em repouso, autenticação segura e monitorização de acessos.'),
        LegalSection('6. Os Seus Direitos',
            'Tem direito de acesso, rectificação, eliminação, portabilidade, oposição e limitação do tratamento dos seus dados. Para exercer estes direitos, contacte renio.mole@agrosuste.org — responderemos no prazo máximo de 30 dias.'),
        LegalSection('7. Contacto',
            'Email: renio.mole@agrosuste.org\nTelefone: +258 84 764 8242'),
      ],
    );
  }
}
