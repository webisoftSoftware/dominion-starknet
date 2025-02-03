import Big from 'big.js';

/**
 * Lifted straight from `viem`
 */
const charCodeMap = {
  // We use very optimized technique to convert hex string to byte array
  zero: 48,
  nine: 57,
  A: 65,
  F: 70,
  a: 97,
  f: 102,
} as const;

/**
 * Lifted straight from `viem`
 *
 * @param char
 */
function charCodeToBase16(char: number) {
  if (char >= charCodeMap.zero && char <= charCodeMap.nine) {
    return char - charCodeMap.zero;
  }
  if (char >= charCodeMap.A && char <= charCodeMap.F) {
    return char - (charCodeMap.A - 10);
  }
  if (char >= charCodeMap.a && char <= charCodeMap.f) {
    return char - (charCodeMap.a - 10);
  }
  return undefined;
}

/**
 * Lifted straight from `viem`
 *
 * Encodes a hex string into a byte array.
 *
 * - Docs: https://viem.sh/docs/utilities/toBytes#hextobytes
 *
 * @param hex string to encode.
 * @param opts Options.
 * @returns Byte array value.
 *
 * @example
 * import { hexToBytes } from 'viem'
 * const data = hexToBytes('0x48656c6c6f20776f726c6421')
 * // Uint8Array([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33])
 *
 * @example
 * import { hexToBytes } from 'viem'
 * const data = hexToBytes('0x48656c6c6f20776f726c6421', { size: 32 })
 * // Uint8Array([72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
 */
export function hexToBytes(hex: `0x${string}`): Uint8Array {
  let hexString = hex.slice(2) as string;
  if (hexString.length % 2) {
    hexString = `0${hexString}`;
  }

  const length = hexString.length / 2;
  const bytes = new Uint8Array(length);
  for (let index = 0, j = 0; index < length; index++) {
    const nibbleLeft = charCodeToBase16(hexString.charCodeAt(j++));
    const nibbleRight = charCodeToBase16(hexString.charCodeAt(j++));
    if (nibbleLeft === undefined || nibbleRight === undefined) {
      throw new Error(`Invalid byte sequence ("${hexString[j - 2]}${hexString[j - 1]}" in "${hexString}").`);
    }
    bytes[index] = nibbleLeft * 16 + nibbleRight;
  }
  return bytes;
}

export const toByteArray = (hexString: string) => {
  if (!hexString.startsWith('0x')) {
    hexString = '0x' + hexString;
  }

  return hexToBytes(hexString as `0x${string}`);
};

export function microToMacro(amount: string, decimals?: number) {
  if (!decimals) {
    decimals = 18;
  }
  const oneMacro = new Big(10).pow(decimals);
  return new Big(amount).div(oneMacro).toNumber();
}

export function macroToMicro(amount: number | string, decimals?: number) {
  if (!decimals) {
    decimals = 18;
  }
  const oneMacro = new Big(10).pow(decimals);
  return new Big(amount).mul(oneMacro).toNumber();
}
