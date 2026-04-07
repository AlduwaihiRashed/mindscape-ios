export function json(body: unknown, init: ResponseInit = {}) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      "content-type": "application/json",
      ...(init.headers ?? {}),
    },
  });
}

export function errorResponse(
  code: string,
  message: string,
  status = 400,
  details?: Record<string, unknown>,
) {
  return json(
    {
      error: {
        code,
        message,
        ...(details ? { details } : {}),
      },
    },
    { status },
  );
}

export async function parseJson<T>(request: Request): Promise<T> {
  return (await request.json()) as T;
}
