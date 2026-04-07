function getEnv(name: string, fallback?: string): string {
  const value = Deno.env.get(name) ?? fallback;
  if (!value) throw new Error(`Missing environment variable: ${name}`);
  return value;
}

function getNumberEnv(name: string, fallback: number): number {
  const value = Deno.env.get(name);
  if (!value) return fallback;
  const parsed = Number(value);
  if (Number.isNaN(parsed)) throw new Error(`Invalid numeric environment variable: ${name}`);
  return parsed;
}

function getFirstEnv(names: string[], fallback = ""): string {
  for (const name of names) {
    const value = Deno.env.get(name);
    if (value && value.trim()) return value;
  }
  return fallback;
}

export const runtimeConfig = {
  supabaseUrl: getEnv("SUPABASE_URL"),
  anonKey: getEnv("SUPABASE_ANON_KEY"),
  serviceRoleKey: getEnv("SUPABASE_SERVICE_ROLE_KEY"),
  myFatoorahMode: Deno.env.get("MYFATOORAH_MODE") ?? "mock",
  myFatoorahApiBaseUrl: Deno.env.get("MYFATOORAH_API_BASE_URL") ?? "https://api.myfatoorah.com",
  myFatoorahApiKey: Deno.env.get("MYFATOORAH_API_KEY") ?? "",
  myFatoorahCallbackUrl: Deno.env.get("MYFATOORAH_CALLBACK_URL") ?? "",
  myFatoorahReturnUrl: Deno.env.get("MYFATOORAH_RETURN_URL") ?? "",
  agoraMode: Deno.env.get("AGORA_MODE") ?? (Deno.env.get("TOKEN_AUTH") === "true" ? "live" : "mock"),
  agoraAppId: getFirstEnv(["AGORA_APP_ID", "APP_ID"]),
  agoraAppCertificate: getFirstEnv(["AGORA_APP_CERTIFICATE", "APP_CERTIFICATE"]),
  agoraTokenTtlSeconds: getNumberEnv(
    Deno.env.get("AGORA_TOKEN_TTL_SECONDS") ? "AGORA_TOKEN_TTL_SECONDS" : "TOKEN_EXPIRY_SECONDS",
    3600,
  ),
  agoraChannelPrefix: getFirstEnv(["AGORA_CHANNEL_PREFIX", "CHANNEL_NAMING"], "booking"),
  sessionJoinLeadMinutes: getNumberEnv("SESSION_JOIN_LEAD_MINUTES", 15),
  sessionJoinGraceMinutes: getNumberEnv("SESSION_JOIN_GRACE_MINUTES", 30),
};
