import { buildSessionChannelName, sessionJoinAllowed } from "../_shared/booking.ts";
import { buildAgoraRtcPublisherToken } from "../_shared/agora.ts";
import { runtimeConfig } from "../_shared/config.ts";
import { errorResponse, json, parseJson } from "../_shared/http.ts";
import { createAdminClient, requireUser } from "../_shared/supabase.ts";
import type { BookingRow, SessionRow } from "../_shared/types.ts";

type RequestBody = { bookingId?: string };

async function createAgoraToken(channelName: string, account: string) {
  if (!runtimeConfig.agoraAppId || !runtimeConfig.agoraAppCertificate) {
    return null;
  }

  const privilegeExpiredTs = Math.floor(Date.now() / 1000) + runtimeConfig.agoraTokenTtlSeconds;
  return await buildAgoraRtcPublisherToken(
    runtimeConfig.agoraAppId,
    runtimeConfig.agoraAppCertificate,
    channelName,
    account,
    privilegeExpiredTs,
  );
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return errorResponse("method_not_allowed", "Only POST is supported.", 405);
  }

  let user;
  try {
    user = await requireUser(request);
  } catch {
    return errorResponse("unauthorized", "Authentication required.", 401);
  }

  const body = await parseJson<RequestBody>(request).catch(() => null);
  const bookingId = body?.bookingId?.trim();
  if (!bookingId) {
    return errorResponse("invalid_request", "`bookingId` is required.");
  }

  const admin = createAdminClient();
  const { data: booking, error: bookingError } = await admin
    .from("bookings")
    .select("id,user_id,therapist_id,availability_slot_id,booking_status,session_mode,price_fils,currency_code,scheduled_starts_at,scheduled_ends_at,expires_at")
    .eq("id", bookingId)
    .limit(1)
    .maybeSingle<BookingRow>();

  if (bookingError || !booking) {
    return errorResponse("booking_not_found", "Booking was not found.", 404);
  }
  if (booking.user_id !== user.id) {
    return errorResponse("forbidden", "Booking does not belong to the signed-in user.", 403);
  }

  let { data: session, error: sessionError } = await admin
    .from("sessions")
    .select("id,booking_id,agora_channel_name,session_status,join_allowed_from,started_at,ended_at")
    .eq("booking_id", booking.id)
    .limit(1)
    .maybeSingle<SessionRow>();

  if (sessionError) {
    return errorResponse("session_lookup_failed", sessionError.message, 500);
  }

  if (!session && booking.booking_status === "confirmed") {
    const created = await admin.from("sessions")
      .insert({
        booking_id: booking.id,
        agora_channel_name: buildSessionChannelName(booking.id),
        session_status: "scheduled",
        join_allowed_from: new Date(new Date(booking.scheduled_starts_at).getTime() - runtimeConfig.sessionJoinLeadMinutes * 60_000).toISOString(),
      })
      .select("id,booking_id,agora_channel_name,session_status,join_allowed_from,started_at,ended_at")
      .single<SessionRow>();

    if (created.error) {
      return errorResponse("session_create_failed", created.error.message, 500);
    }
    session = created.data;
  }

  if (!session) {
    return errorResponse("session_not_ready", "Session is not ready for this booking yet.", 409);
  }
  if (!sessionJoinAllowed(session, booking)) {
    return errorResponse("join_not_allowed", "Session join is not allowed yet for this booking.", 409, {
      joinAllowedFrom: session.join_allowed_from,
      scheduledStartsAt: booking.scheduled_starts_at,
      scheduledEndsAt: booking.scheduled_ends_at,
    });
  }

  const expiresAt = new Date(Date.now() + runtimeConfig.agoraTokenTtlSeconds * 1000).toISOString();
  const token = runtimeConfig.agoraMode === "mock"
    ? `mock-agora-token:${session.id}:${expiresAt}`
    : await createAgoraToken(session.agora_channel_name, user.id);

  if (!token) {
    return errorResponse("agora_not_configured", "Live Agora token generation is not configured yet.", 501);
  }

  return json({
    bookingId: booking.id,
    sessionId: session.id,
    token,
    appId: runtimeConfig.agoraAppId || "mock-app-id",
    channelName: session.agora_channel_name,
    role: "publisher",
    expiresAt,
  });
});
