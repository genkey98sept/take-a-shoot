import "server-only";

import { createClient } from "@supabase/supabase-js";

import { serverEnv } from "@/env";

export const createAdminSupabaseClient = () =>
  createClient(serverEnv.NEXT_PUBLIC_SUPABASE_URL, serverEnv.SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
