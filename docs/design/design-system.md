# Design System — Take@Shoot

Source de vérité visuelle, dérivée des mockups produit (échantillonnage pixel par pixel).
Implémentation : [`packages/ui/src/tokens.ts`](../../packages/ui/src/tokens.ts) (`@take-a-shoot/ui`).

> Les mockups bruts vivent en local dans `_BRAIN/Project/visu/` (non suivi par Git). Ce document
> est la version **versionnée** et fait foi pour l'implémentation. Toute évolution du design se
> répercute ici **et** dans les tokens.

## 0. Direction artistique

Application sociale photo « photobooth nocturne ». Ambiance **sombre, premium, nocturne/fête**.
Fond noir profond, surfaces gris très foncé, **un accent rose/magenta vif**, photos traitées en
**noir & blanc** dans la carte signature. Esthétique d'un tirage photomaton imprimé (cadre crème,
signature de marque, géolocalisation estampillée).

Règles produit gravées dans l'UI (planche « FEED PRINCIPAL ») :

- Feed **strictement chronologique** — **aucun algorithme, aucune suggestion, aucune publicité**.
- Toute publication s'affiche en **carte photobooth** (grand visuel, aspect premium).
- Réactions limitées à **5 emojis nommés**.
- Chaque Shoot porte **lieu + date + heure**.
- Éphémérité : les Shoots **disparaissent du feed après 24h** mais restent dans les Souvenirs.

App mobile **verrouillée en mode sombre** (`userInterfaceStyle: "dark"`) — pas de variante claire.

## 1. Couleurs

### Fonds & surfaces
| Token | Hex | Usage |
|---|---|---|
| `background` | `#000000` | Fond global (noir OLED). |
| `bgElevated` | `#0D0E0F` | Sous header / sous nav. |
| `surface` | `#1D1D1E` | Cartes, sheets, dialogs. |
| `surfaceElevated` | `#262626` | Pill inactive, surface secondaire. |
| `surfaceInput` | `#1A1A1B` | Champs de formulaire, barre commentaire. |
| `surfaceSheet` | `#141416` | Bottom sheets. |

### Bordures
| Token | Hex | Usage |
|---|---|---|
| `borderSubtle` | `#2A2A2C` | Séparateurs internes, hairlines. |
| `border` | `#3E3D3F` | Contour cartes/champs, boutons outline. |
| `borderStrong` | `#525155` | Focus léger, contour avatar. |

### Texte
| Token | Hex | Usage |
|---|---|---|
| `text` | `#F4F2F0` | Titres, noms, compteurs (blanc chaud). |
| `textSecondary` | `#A8A6A8` | Sous-titres, méta, labels inactifs. |
| `textMuted` | `#6E6C70` | Légendes, placeholders, timestamps. |
| `textOnAccent` | `#FFFFFF` | Texte sur bouton rose plein. |

### Accent & marque — **deux roses distincts, à ne jamais fusionner**
| Token | Hex | Usage |
|---|---|---|
| `accent` | `#FA195E` | **UI/actions** : bouton primaire, FAB caméra, switch ON, badge notif, item de nav actif, « Ajouter ». |
| `accentPressed` | `#C5164E` | État pressé des éléments roses. |
| `accentSoftBg` | `rgba(250,25,94,0.12)` | Pill actif, item sélectionné, halo. |
| `accentGlow` | `rgba(250,25,94,0.40)` | Glow FAB/CTA, dégradés bas d'écran. |
| `brand` | `#E6215A` | **Signature de marque uniquement** : logo « Take@Shoot », le « @ », soulignés d'annotation. |

### Carte photobooth (contraste inversé)
| Token | Hex | Usage |
|---|---|---|
| `cardFrame` | `#ECE9E6` | Cadre crème (PAS blanc pur). |
| `cardFrameText` | `#2A2A2A` | Texte foncé du footer de carte. |

### Sémantiques
La DA mobile exprime **succès et destructif en rose** (pas de vert/rouge dédié). `success` `#35D07F`,
`warning` `#FFB84D`, `danger` `#FF4D4D` sont réservés au **back-office admin** ou aux cas explicites.

### Réactions (`reactionColors`)
❤️ `love #FF3B5C` · 🔥 `fire #FF7A1A` · 😮 `wow #FFC83D` · 😂 `haha` / 😎 `cool` : emoji natifs.

## 2. Typographie

Famille sans-serif géométrique (SF Pro Display sur iOS ; slot pour Inter/Satoshi custom plus tard).

| Rôle | `size` | Poids | Casse |
|---|---|---|---|
| Countdown 3-2-1 | `countdown` 72 | black 900 | — |
| Logo splash | `display` 44 | black 900 | mixte, « @ » en `brand` |
| Titre écran (« Feed ») / headline onboarding | `h1` 30 | bold 700 | capitale initiale |
| Titre annotation (« FEED PRINCIPAL ») | `h2` 22 | bold 700 | MAJUSCULES bicolore (mot 1 `brand`) |
| Nom utilisateur, légende de carte | `h3` 18 / `body` 15 | semibold 600 / medium 500 | capitale initiale |
| Boutons, onglets filtres | `body` 15 / `label` 13 | semibold 600 / medium 500 | capitale initiale |
| Méta carte (`PARIS, FRANCE`, `14 MAI 2025 • 22:14`) | `meta` 12 | medium 500 | **MAJUSCULES** + `letterSpacing.wide` |
| Timestamp, légende | `caption` 11 | regular 400 | normal |

## 3. Marque « Take@Shoot »

- Écrit en un mot, casse mixte, le **`@` en `brand` `#E6215A`**, « Take » et « Shoot » en `text`.
- Splash : empilé `Take` / `@Shoot` en black, avec un petit **`+` rose** flottant.
- Signature de carte : « Take@Shoot » en `brand`, coin inférieur droit, avec un **`+`** discret
  (tampon de marque imitant un tirage photomaton).
- Le **`+`** est un élément transversal : splash, signature des cartes, et **FAB caméra central**.

## 4. Carte photobooth (composant signature)

Cadre crème `cardFrame`, coins `radii.md` (~15px), marge intérieure ~12px. Photos traitées en N&B
dans le template signature.

```
┌──────────────────────────────────┐  ← cadre crème, radii.md
│  ┌───────────────┐  ┌────┐        │
│  │   GRANDE      │  │ p2 │        │  Colonne droite :
│  │   PHOTO       │  ├────┤        │  3 photos verticales
│  │   (≈ 66% L)   │  │ p3 │        │  empilées, gap ~6px,
│  │               │  ├────┤        │  radii.sm internes
│  └───────────────┘  │ p4 │        │
│                     └────┘        │
│  📍 PARIS, FRANCE      Take@Shoot │  ← footer crème (texte cardFrameText)
│  14 MAI 2025 • 22:14          +   │     signature en brand, méta en MAJUSCULES
└──────────────────────────────────┘
```

Footer : pin rose + ville/pays (MAJ) + ligne date • heure à gauche ; signature `brand` + `+` à droite.
Badges template/filtre (`📷 TEMPLATE`, `🎞 FILTRE N&B`) sous la carte.

## 5. Inventaire des composants

**Primitifs (`packages/ui`)** : `Button` (primary rose plein pill + glow / outline / ghost),
`Pill`/`Tag`, `Avatar` (rond, bordure, ring rose optionnel), `Icon` (outline 1.5–2px, rempli rose si
actif), `Sheet`/`BottomSheet`, `Dialog`, `TextField`, `Switch`, `Badge`.

**Signature & feed (`apps/mobile`)** : `PhotoboothCard` (central), `FeedHeader` (titre + 🔍 + 🔔 badge),
`FilterTabs` (Tous/Amis/Proches), `BottomNav` (**5 items** : Feed / Recherche / FAB + / Souvenirs / Profil),
`CameraFab` (rose central glow), `ReactionBar` (J'adore/Feu/Wow/Haha/Cool), `ReactionCounters`,
`CommentThread` (profondeur 1), `CountdownRing`, `VisibilityPicker`, `EmptyState`, `NewShootBanner`,
`ProfileHeader`/`ProfileStats`, `MemoriesCalendar`, `TemplateFilterPicker`.

## 6. Écrans (MVP)

Splash · Créer compte · Compléter profil · Countdown bienvenue · Carte d'identité · Recherche d'ami ·
**Feed** · Détail Shoot · Caméra/capture · Génération · Prévisualisation/retouche · Visibilité ·
Commentaires · Profil (soi / ami) · Confirmation destructive · Souvenirs/Calendrier · Shoot publié ·
États vides · Notifications.

> Décision produit : l'onglet **« Proches » est hors MVP** (feed = Tous / Amis uniquement). Le schéma
> de données ne pose qu'une visibilité `friends`.

## 7. Formes, espacement, profondeur

- **Rayons** (`radii`) : `sm 8` (photos internes), `md 15` (cartes/champs/dialogs), `lg 23` (bottom
  sheets), `pill 999` (boutons/onglets/switch), `full 9999` (avatars/FAB/pastilles).
- **Espacement** (`spacing`, échelle 4px) : padding carte ~16, gap entre cartes ~16–20, marge écran ~20,
  gap photos internes ~6.
- **Profondeur** (`elevation`) : pas d'ombres dures (fond noir) → contraste de surface + **glow rose**.
  `card` `0 8px 24px rgba(0,0,0,0.5)` ; `accentGlow` `0 0 24px rgba(250,25,94,0.4)` sur FAB/CTA.
- **Iconographie** : outline/line fin (1.5–2px), rempli rose seulement à l'état actif.
- **Photos** : N&B = filtre par défaut du template signature, pas une contrainte sur toutes les photos.

## 8. Points de vigilance d'implémentation

1. Deux roses : `accent #FA195E` (UI) vs `brand #E6215A` (marque) — ne pas fusionner.
2. Cadre de carte **crème `#ECE9E6`**, pas blanc pur, texte foncé (contraste inversé).
3. Pas de vert/rouge sémantique en mobile : succès et destructif passent par le rose.
4. BottomNav = **5 items** (variante des écrans réels).
5. App **dark-only** : ne pas réintroduire de thème clair côté mobile.
