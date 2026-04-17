import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const requiredSupabaseEnv = {
  VITE_SUPABASE_URL: Boolean(supabaseUrl),
  VITE_SUPABASE_ANON_KEY: Boolean(supabaseAnonKey)
} as const;

const missingSupabaseEnvKeys = Object.entries(requiredSupabaseEnv)
  .filter(([, present]) => !present)
  .map(([key]) => key);

export const supabaseConfigError =
  missingSupabaseEnvKeys.length > 0
    ? `Missing required environment variables: ${missingSupabaseEnvKeys.join(', ')}. Ensure these are defined in Cloudflare Pages for the active environment (Production/Preview) and redeploy.`
    : null;

export const supabase =
  supabaseConfigError === null
    ? createClient(supabaseUrl, supabaseAnonKey, {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: true
        }
      })
    : null;

if (supabaseConfigError) {
  console.error('[supabase] configuration error', {
    error: supabaseConfigError,
    mode: import.meta.env.MODE,
    missingKeys: missingSupabaseEnvKeys
  });
}
<<<<<<< codex/build-production-mvp-for-wms-f06avj
=======
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  }
});
>>>>>>> main
