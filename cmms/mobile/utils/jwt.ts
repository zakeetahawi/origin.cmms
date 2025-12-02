import { Buffer } from 'buffer';

export const JWT_EXPIRES_IN = 3600 * 24 * 2;

export const verify = async (token: string): Promise<boolean> => {
  try {
    const parts = token
      .split('.')
      .map((part) =>
        Buffer.from(
          part.replace(/-/g, '+').replace(/_/g, '/'),
          'base64'
        ).toString()
      );

    const payload = JSON.parse(parts[1]);
    const currentTime = new Date().getTime() / 1000;
    // @ts-ignore
    return currentTime <= payload.exp;
  } catch (error) {
    // Token is invalid or expired
    return false;
  }
};
