import { runtimeConfig } from "./config.ts";
import type { BookingRow, SessionRow } from "./types.ts";

export function isBookingHoldActive(booking: BookingRow) {
  if (booking.booking_status != "pending_payment") return false;
  if (!booking.expires_at) return true;
  return new Date(booking.expires_at).getTime() > Date.now();
}

export function sessionJoinAllowed(session: SessionRow, booking: BookingRow) {
  if (booking.booking_status !== "confirmed") return false;
  if (session.session_status === "canceled" || session.session_status === "failed") return false;

  const now = Date.now();
  const joinFrom = session.join_allowed_from ? new Date(session.join_allowed_from).getTime() : new Date(booking.scheduled_starts_at).getTime() - runtimeConfig.sessionJoinLeadMinutes * 60_000;
  const joinUntil = new Date(booking.scheduled_ends_at).getTime() + runtimeConfig.sessionJoinGraceMinutes * 60_000;
  return now >= joinFrom && now <= joinUntil;
}

export function buildSessionChannelName(bookingId: string) {
  return `${runtimeConfig.agoraChannelPrefix}-${bookingId}`;
}

export function computeJoinAllowedFrom(booking: BookingRow) {
  return new Date(new Date(booking.scheduled_starts_at).getTime() - runtimeConfig.sessionJoinLeadMinutes * 60_000).toISOString();
}
