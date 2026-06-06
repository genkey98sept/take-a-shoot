export const colors = {
  background: "#050608",
  surface: "#101216",
  surfaceElevated: "#181B21",
  border: "#2A2E37",
  text: "#FFFFFF",
  textMuted: "#A5A8B1",
  textSubtle: "#6F737C",
  brand: "#FF2D6F",
  brandPressed: "#D91E59",
  success: "#35D07F",
  warning: "#FFB84D",
  danger: "#FF4D4D",
} as const;

export const spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
} as const;

export const radii = {
  sm: 6,
  md: 8,
  lg: 12,
  xl: 20,
  pill: 999,
} as const;

export const typography = {
  fontFamily: {
    sans: "System",
  },
  size: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 20,
    xl: 28,
    display: 36,
  },
  weight: {
    regular: "400",
    medium: "500",
    semibold: "600",
    bold: "700",
  },
} as const;

export const tokens = {
  colors,
  spacing,
  radii,
  typography,
} as const;
