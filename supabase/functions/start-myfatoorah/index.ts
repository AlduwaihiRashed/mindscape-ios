import { errorResponse, json, parseJson } from "../_shared/http.ts";
import { createAdminClient, requireUser } from "../_shared/supabase.ts";
import { isBookingHoldActive } from "../_shared/booking.ts";
import { runtimeConfig } from "../_shared/config.ts";
import type { BookingRow, PaymentRow } from "../_shared/types.ts";

type RequestBody = { bookingId?: string };

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
  if (!isBookingHoldActive(booking)) {
    return errorResponse("booking_not_payable", "Booking is not in an active pending-payment state.", 409);
  }

  const providerReference = `mf_mock_${booking.id}_${Date.now()}`;
  const { data: payment, error: paymentError } = await admin
    .from("payments")
    .insert({
      booking_id: booking.id,
      provider: "myfatoorah",
      provider_payment_id: providerReference,
      payment_status: "initiated",
      amount_fils: booking.price_fils,
      currency_code: booking.currency_code,
      raw_callback_payload: {
        source: runtimeConfig.myFatoorahMode,
        requested_at: new Date().toISOString(),
      },
    })
    .select("id,booking_id,provider,provider_payment_id,payment_status,amount_fils,currency_code,raw_callback_payload,paid_at")
    .single<PaymentRow>();

  if (paymentError || !payment) {
    return errorResponse("payment_init_failed", paymentError?.message ?? "Unable to initialize payment.", 500);
  }

  return json({
    paymentId: payment.id,
    paymentStatus: payment.payment_status,
    provider: payment.provider,
    providerReference,
    redirectUrl: runtimeConfig.myFatoorahMode === "mock"
      ? `${(runtimeConfig.myFatoorahCallbackUrl || `${runtimeConfig.supabaseUrl}/functions/v1/verify-myfatoorah`)}?payment_id=${payment.id}&status=paid`
      : null,
    requiresExternalVerification: runtimeConfig.myFatoorahMode !== "mock",
  });
});
