/// Configuração do cliente Supabase — mesmo projecto usado pelo site
/// (agrosuste_market/lib/supabase.ts), para que o app e o site partilhem
/// exactamente os mesmos dados (profiles/products/orders).
///
/// A anon key do Supabase é uma "publishable key": foi desenhada para ser
/// embebida em clientes públicos (já está exposta no bundle JS do site);
/// a segurança real é garantida pelas políticas RLS no Postgres, não pelo
/// sigilo desta chave.
class SupabaseConfig {
  static const String url = 'https://gagtrlmtofcywziufplo.supabase.co';
  static const String anonKey = 'sb_publishable_DnM0Qmp-ECeqLeaFlQOA0Q_5JoMhg69';
}
