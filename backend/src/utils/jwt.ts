import jwt from "jsonwebtoken";
import { env } from "../config/env";

export type JwtPayload = {
  id: string;
  role: string;
};

export const generateAccessToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, env.JWT_SECRET, { expiresIn: "1d" }); // 1 day for access in dev/mobile
};

export const generateRefreshToken = (payload: JwtPayload): string => {
  return jwt.sign(payload, env.JWT_REFRESH_SECRET || env.JWT_SECRET, { expiresIn: "30d" }); // 30 days for refresh
};

export const verifyToken = (token: string): JwtPayload => {
  return jwt.verify(token, env.JWT_SECRET) as JwtPayload;
};

export const verifyRefreshToken = (token: string): JwtPayload => {
  return jwt.verify(token, env.JWT_REFRESH_SECRET || env.JWT_SECRET) as JwtPayload;
};
