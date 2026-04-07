const textEncoder = new TextEncoder();

const joinChannelPrivilege = 1;
const publishAudioPrivilege = 2;
const publishVideoPrivilege = 3;
const publishDataPrivilege = 4;
const tokenVersion = "006";

let crcTable: Uint32Array | null = null;

function getCrcTable() {
  if (crcTable) return crcTable;

  crcTable = new Uint32Array(256);
  for (let index = 0; index < 256; index += 1) {
    let value = index;
    for (let bit = 0; bit < 8; bit += 1) {
      value = (value & 1) ? (0xedb88320 ^ (value >>> 1)) : (value >>> 1);
    }
    crcTable[index] = value >>> 0;
  }

  return crcTable;
}

function crc32(input: string) {
  const table = getCrcTable();
  const bytes = textEncoder.encode(input);
  let crc = 0xffffffff;

  for (const byte of bytes) {
    crc = table[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  }

  return (crc ^ 0xffffffff) >>> 0;
}

function encodeBase64(bytes: Uint8Array) {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function concatBytes(...chunks: Uint8Array[]) {
  const totalLength = chunks.reduce((sum, chunk) => sum + chunk.length, 0);
  const output = new Uint8Array(totalLength);
  let offset = 0;

  for (const chunk of chunks) {
    output.set(chunk, offset);
    offset += chunk.length;
  }

  return output;
}

function uint16LE(value: number) {
  const bytes = new Uint8Array(2);
  new DataView(bytes.buffer).setUint16(0, value, true);
  return bytes;
}

function uint32LE(value: number) {
  const bytes = new Uint8Array(4);
  new DataView(bytes.buffer).setUint32(0, value >>> 0, true);
  return bytes;
}

function packBytes(bytes: Uint8Array) {
  return concatBytes(uint16LE(bytes.length), bytes);
}

function packString(value: string | Uint8Array) {
  return packBytes(typeof value === "string" ? textEncoder.encode(value) : value);
}

function packPrivileges(privileges: Record<number, number>) {
  const entries = Object.entries(privileges)
    .map(([key, value]) => [Number(key), value] as const)
    .sort(([left], [right]) => left - right);

  return concatBytes(
    uint16LE(entries.length),
    ...entries.map(([key, value]) => concatBytes(uint16LE(key), uint32LE(value))),
  );
}

async function hmacSha256(key: string, message: Uint8Array) {
  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    textEncoder.encode(key),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  return new Uint8Array(await crypto.subtle.sign("HMAC", cryptoKey, message));
}

export async function buildAgoraRtcPublisherToken(
  appId: string,
  appCertificate: string,
  channelName: string,
  account: string,
  privilegeExpiredTs: number,
) {
  const salt = crypto.getRandomValues(new Uint32Array(1))[0] >>> 0;
  const tokenTs = Math.floor(Date.now() / 1000) + 24 * 3600;
  const privileges = {
    [joinChannelPrivilege]: privilegeExpiredTs,
    [publishAudioPrivilege]: privilegeExpiredTs,
    [publishVideoPrivilege]: privilegeExpiredTs,
    [publishDataPrivilege]: privilegeExpiredTs,
  };

  const message = concatBytes(
    uint32LE(salt),
    uint32LE(tokenTs),
    packPrivileges(privileges),
  );

  const toSign = concatBytes(
    textEncoder.encode(appId),
    textEncoder.encode(channelName),
    textEncoder.encode(account),
    message,
  );

  const signature = await hmacSha256(appCertificate, toSign);
  const content = concatBytes(
    packBytes(signature),
    uint32LE(crc32(channelName)),
    uint32LE(crc32(account)),
    packBytes(message),
  );

  return `${tokenVersion}${appId}${encodeBase64(content)}`;
}
