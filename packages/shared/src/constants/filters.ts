export const SHOOT_FILTERS = ["vintage", "black_and_white"] as const;

export type ShootFilter = (typeof SHOOT_FILTERS)[number];

export const SHOOT_FILTER_LABELS: Record<ShootFilter, string> = {
  vintage: "Vintage",
  black_and_white: "Noir & Blanc",
};
