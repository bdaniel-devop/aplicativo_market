import 'package:flutter/material.dart';
import 'legal_page.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPage(
      title: 'Termos de Uso',
      icon: Icons.description_outlined,
      intro: 'Leia atentamente. Ao criar uma conta ou utilizar a plataforma AgroSuste, confirma que leu, compreendeu e aceita estes Termos de Uso na íntegra.',
      sections: const [
        LegalSection('1. Identificação da Plataforma',
            'A AgroSuste é uma plataforma digital de comércio agrícola, desenvolvida e operada em Moçambique, com o propósito de conectar produtores agrícolas, compradores, transportadores, extensionistas e parceiros estratégicos no ecossistema agroalimentar nacional.'),
        LegalSection('2. Cadastro e Conta de Utilizador',
            'Para aceder às funcionalidades completas da plataforma, deve criar uma conta com informações verdadeiras e actualizadas. É responsável por manter a confidencialidade das suas credenciais. Cada pessoa ou entidade pode registar apenas uma conta. Empresas, cooperativas e associações devem fornecer documentação legal válida (NUIT, alvará, estatuto) para activação completa.'),
        LegalSection('3. Responsabilidades do Utilizador',
            'Compromete-se a fornecer informações verídicas, não publicar produtos falsificados ou ilegais, respeitar os demais utilizadores, cumprir as obrigações fiscais decorrentes das transacções e notificar a AgroSuste em caso de uso não autorizado da sua conta.'),
        LegalSection('4. Transacções, Pagamentos e Comissões',
            'As transacções são facilitadas através dos métodos de pagamento disponíveis (M-Pesa, e-Mola, Mkesh, transferência bancária). A AgroSuste cobra uma comissão sobre as transacções, publicada na plataforma. Os pagamentos são processados por parceiros certificados; não armazenamos dados bancários ou de cartões.'),
        LegalSection('5. Entrega e Logística',
            'A AgroSuste pode facilitar a ligação entre vendedores e transportadores registados, mas não assume responsabilidade directa pela entrega. Prazos e custos são acordados entre as partes envolvidas.'),
        LegalSection('6. Limitação de Responsabilidade',
            'A AgroSuste não se responsabiliza por danos resultantes do uso da plataforma, disputas entre utilizadores, informações incorrectas fornecidas por terceiros, interrupções por força maior, ou atrasos em sistemas de pagamento de terceiros.'),
        LegalSection('7. Lei Aplicável',
            'Estes Termos de Uso são regidos pela legislação da República de Moçambique. Qualquer litígio será submetido ao tribunal competente da cidade de Maputo, salvo acordo em contrário.'),
        LegalSection('8. Contacto',
            'Email: administration@agrosuste.org\nTelefone: +258 84 764 8242'),
      ],
    );
  }
}
