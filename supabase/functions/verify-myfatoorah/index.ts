import { computeJoinAllowedFrom, buildSessionChannelName } from "../_shared/booking.ts";
import { errorResponse, json, parseJson } from "../_shared/http.ts";
import { createAdminClient } from "../_shared/supabase.ts";
import type { BookingRow, PaymentRow, SessionRow } from "../_shared/types.ts";

type RequestBody = {
  paymentId?: string;
  paymentStatus?: "paid" | "failed" | "canceled";
  providerReference?: string;
  callbackPayload?: unknown;
};

function mapBookingStatus(paymentStatus: string) {
  switch (paymentStatus) {
    case "paid":
      return "confirmed";
    case "canceled":
      return "canceled";
    default:
      return "payment_failed";
  }
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return errorResponse("method_not_allowed", "Only POST is supported.", 405);
  }

  const body = await parseJson<RequestBody>(request).catch(() => null);
  const paymentId = body?.paymentId?.trim();
  const paymentStatus = body?.paymentStatus ?? "paid";

  if (!paymentId) {
    return errorResponse("invalid_request", "`paymentId` is required.");
  }

  const admin = createAdminClient();
  const { data: payment, error: paymentError } = await admin
    .from("payments")
    .select("id,booking_id,provider,provider_payment_id,payment_status,amount_fils,currency_code,raw_callback_payload,paid_at")
    .eq("id", paymentId)
    .limit(1)
    .maybeSingle<PaymentRow>();

  if (paymentError || !payment) {
    return errorResponse("payment_not_found", "Payment was not found.", 404);
  }

  const { data: booking, error: bookingError } = await admin
    .from("bookings")
    .select("id,user_id,therapist_id,availability_slot_id,booking_status,session_mode,price_fils,currency_code,scheduled_starts_at,scheduled_ends_at,expires_at")
    .eq("id", payment.booking_id)
    .limit(1)
    .maybeSingle<BookingRow>();

  if (bookingError || !booking) {
    return errorResponse("booking_not_found", "Linked booking was not found.", 404);
  }

  const nextBookingStatus = mapBookingStatus(paymentStatus);
  const { error: updatePaymentError } = await admin.from("payments").update({
    provider_payment_id: body?.providerReference ?? payment.provider_payment_id,
    payment_status: paymentStatus,
    raw_callback_payload: body?.callbackPayload ?? { source: "edge-function", received_at: new Date().toISOString() },
    paid_at: paymentStatus === "paid" ? new Date().toISOString() : null,
  }).eq("id", payment.id);

  if (updatePaymentError) {
    return errorResponse("payment_update_failed", updatePaymentError.message, 500);
  }

  const { error: updateBookingError } = await admin.from("bookings").update({
    booking_status: nextBookingStatus,
  }).eq("id", booking.id);

  if (updateBookingError) {
    return errorResponse("booking_update_failed", updateBookingError.message, 500);
  }

  let session: SessionRow | null = null;
  if (paymentStatus === "paid") {
    const { data: existingSession } = await admin
      .from("sessions")
      .select("id,booking_id,agora_channel_name,session_status,join_allowed_from,started_at,ended_at")
      .eq("booking_id", booking.id)
      .limit(1)
      .maybeSingle<SessionRow>();

    if (existingSession) {
      session = existingSession;
    } else {
      const { data: createdSession, error: createSessionError } = await admin
        .from("sessions")
        .insert({
          booking_id: booking.id,
          agora_channel_name: buildSessionChannelName(booking.id),
          session_status: "scheduled",
          join_allowed_from: computeJoinAllowedFrom(booking),
        })
        .select("id,booking_id,agora_channel_name,session_status,join_allowed_from,started_at,ended_at")
        .single<SessionRow>();

      if (createSessionError) {
        return errorResponse("session_create_failed", createSessionError.message, 500);
      }
      session = createdSession;
    }
  }

  return json({
    paymentId: payment.id,
    paymentStatus,
    bookingId: booking.id,
    bookingStatus: nextBookingStatus,
    session,
  });
});
