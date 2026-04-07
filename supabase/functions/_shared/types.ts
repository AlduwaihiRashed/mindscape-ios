export type BookingRow = {
  id: string;
  user_id: string;
  therapist_id: string;
  availability_slot_id: string;
  booking_status: string;
  session_mode: string;
  price_fils: number;
  currency_code: string;
  scheduled_starts_at: string;
  scheduled_ends_at: string;
  expires_at: string | null;
};

export type PaymentRow = {
  id: string;
  booking_id: string;
  provider: string;
  provider_payment_id: string | null;
  payment_status: string;
  amount_fils: number;
  currency_code: string;
  raw_callback_payload: unknown;
  paid_at: string | null;
};

export type SessionRow = {
  id: string;
  booking_id: string;
  agora_channel_name: string;
  session_status: string;
  join_allowed_from: string | null;
  started_at: string | null;
  ended_at: string | null;
};
