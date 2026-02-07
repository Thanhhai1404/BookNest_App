/// Supabase configuration constants.
///
/// TODO: Thay thế bằng URL và Key thật từ Supabase Dashboard.
/// Vào https://supabase.com/dashboard -> Project Settings -> API
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project URL
  /// Tìm ở: Project Settings > API > Project URL
  static const String url = 'https://lckkixvzeykdxiahxweg.supabase.co';

  /// Supabase Anonymous Key (public)
  /// Tìm ở: Project Settings > API > Project API keys > anon public
  static const String anonKey =
      'sb_publishable_Hc28hTSw9w23NLYuesuy9Q_-f8rOgNT';
}
