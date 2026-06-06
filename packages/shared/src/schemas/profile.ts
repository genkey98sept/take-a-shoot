import { z } from "zod";

export const usernameSchema = z
  .string()
  .trim()
  .min(3, "Le pseudo doit contenir au moins 3 caracteres.")
  .max(24, "Le pseudo doit contenir au maximum 24 caracteres.")
  .regex(/^[a-zA-Z0-9_]+$/, "Le pseudo peut contenir uniquement lettres, chiffres et underscores.")
  .transform((value) => value.toLowerCase());

export const profileDraftSchema = z.object({
  firstName: z.string().trim().min(1).max(60),
  username: usernameSchema,
  countryCode: z.string().trim().length(2),
  city: z.string().trim().max(100).optional(),
  bio: z.string().trim().max(160).optional(),
});

export type ProfileDraft = z.infer<typeof profileDraftSchema>;
