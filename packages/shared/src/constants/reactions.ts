export const SHOOT_REACTIONS = ["love", "fire", "wow", "haha", "cool"] as const;

export type ShootReaction = (typeof SHOOT_REACTIONS)[number];

export const SHOOT_REACTION_LABELS: Record<ShootReaction, string> = {
  love: "J'adore",
  fire: "Feu",
  wow: "Wow",
  haha: "Haha",
  cool: "Cool",
};
