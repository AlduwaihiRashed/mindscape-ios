import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";
import { runtimeConfig } from "./config.ts";

export function createAdminClient() {
  return createClient(runtimeConfig.supabaseUrl, runtimeConfig.serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

export function createAuthedClient(accessToken: string) {
  return createClient(runtimeConfig.supabaseUrl, runtimeConfig.anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      headers: {
        Authorization: accessToken,
      },
    },
  });
}

export async function requireUser(request: Request) {
  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    throw new Error("Missing bearer token.");
  }

  const client = createAuthedClient(authorization);
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) {
    throw new Error("Authentication required.");
  }

  return data.user;
}
