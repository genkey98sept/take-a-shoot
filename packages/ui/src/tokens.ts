// Source de verite design Take@Shoot — alignee sur les mockups (echantillonnage pixel par pixel).
// Voir docs/design/design-system.md pour la documentation complete.
//
// DEUX roses coexistent volontairement :
//   - `accent` (#FA195E) : actions / UI (boutons, FAB, etats actifs, badges).
//   - `brand`  (#E6215A) : signature de marque uniquement (logo "Take@Shoot", le "@").
//
// L'app mobile est verrouillee en dark (userInterfaceStyle: "dark") — pas de variante light.

export const colors = {
  // Fonds & surfaces
  background: "#000000", // noir OLED, fond global
  bgElevated: "#0D0E0F", // sous header / sous nav
  surface: "#1D1D1E", // cartes, sheets, dialogs
  surfaceElevated: "#262626", // pill inactive, surface secondaire
  surfaceInput: "#1A1A1B", // champs de formulaire, barre commentaire
  surfaceSheet: "#141416", // bottom sheets

  // Bordures
  border: "#3E3D3F", // contour cartes/champs/outline (defaut)
  borderSubtle: "#2A2A2C", // hairlines internes, separateurs
  borderStrong: "#525155", // focus leger, contour avatar

  // Texte
  text: "#F4F2F0", // titres, noms (blanc chaud)
  textSecondary: "#A8A6A8", // sous-titres, meta, labels inactifs
  textMuted: "#6E6C70", // legendes, placeholders, timestamps
  textOnAccent: "#FFFFFF", // texte sur bouton rose plein

  // Accent (UI/actions) vs Brand (signature logo) — NE PAS FUSIONNER
  accent: "#FA195E",
  accentPressed: "#C5164E",
  accentSoftBg: "rgba(250,25,94,0.12)", // pill actif, item selectionne, halo
  accentGlow: "rgba(250,25,94,0.40)", // glow FAB / CTA / degrades bas d'ecran
  brand: "#E6215A", // "Take@Shoot", le "@", soulignes d'annotation

  // Carte photobooth (contraste inverse : sombre sur creme)
  cardFrame: "#ECE9E6", // cadre creme (PAS blanc pur)
  cardFrameText: "#2A2A2A", // texte fonce du footer de carte

  // Semantiques — back-office / cas explicites (la DA mobile exprime succes & destructif en rose)
  success: "#35D07F",
  warning: "#FFB84D",
  danger: "#FF4D4D",
} as const;

// Couleurs intrinseques des reactions (emoji + compteur).
export const reactionColors = {
  love: "#FF3B5C",
  fire: "#FF7A1A",
  wow: "#FFC83D",
  // haha / cool : emoji natifs, pas de couleur de marque dediee.
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
  sm: 8, // photos internes carte, petites puces
  md: 15, // cartes, champs, cadre photobooth, dialogs
  lg: 23, // bottom sheets (coins sup.), grands conteneurs
  pill: 999, // boutons, onglets filtres, switch
  full: 9999, // avatars, FAB, pastilles reactions, badge notif
} as const;

export const typography = {
  // SF Pro Display sur iOS ; slot pour Inter/Satoshi custom plus tard.
  fontFamily: { sans: "System" },
  size: {
    caption: 11,
    meta: 12,
    label: 13,
    body: 15,
    h3: 18,
    h2: 22,
    h1: 30,
    display: 44,
    countdown: 72,
  },
  weight: {
    regular: "400",
    medium: "500",
    semibold: "600",
    bold: "700",
    black: "900",
  },
  // wide = meta carte en MAJUSCULES.
  letterSpacing: { tight: -0.2, normal: 0, wide: 0.6 },
} as const;

// Profondeur : pas d'ombres dures (fond noir) -> contraste de surface + glow rose.
export const elevation = {
  card: "0 8px 24px rgba(0,0,0,0.50)",
  accentGlow: "0 0 24px rgba(250,25,94,0.40)",
} as const;

export const tokens = {
  colors,
  reactionColors,
  spacing,
  radii,
  typography,
  elevation,
} as const;
