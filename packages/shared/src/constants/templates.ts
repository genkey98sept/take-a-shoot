export const SHOOT_TEMPLATES = ["take_shoot_classic_v1"] as const;

export type ShootTemplate = (typeof SHOOT_TEMPLATES)[number];

export const DEFAULT_SHOOT_TEMPLATE: ShootTemplate = "take_shoot_classic_v1";
