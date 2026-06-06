export const SHOOT_VISIBILITIES = ["friends"] as const;

export type ShootVisibility = (typeof SHOOT_VISIBILITIES)[number];

export const DEFAULT_SHOOT_VISIBILITY: ShootVisibility = "friends";

export const FEED_VISIBILITY_HOURS = 24;
