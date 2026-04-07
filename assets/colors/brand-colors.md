# Brand Colors

Official Mindscape brand color palette from the 2022 Brand Manual Guideline.

## Core Brand Colors

| Role | Name | HEX | CMYK | Pantone |
| --- | --- | --- | --- | --- |
| Primary | Emerald Green | `#44aa87` | 69 0 55 8 | p 136-13 c |
| Secondary | Sunshine Yellow | `#fff15f` | 0 19 72 0 | p 1-6 c |

## Extended Palette

These colors appear in the brand manual as approved logo and identity color variants:

| Name | HEX | Usage |
| --- | --- | --- |
| Navy | `#0d2347` | dark background, navy logo variant |
| Coral | `#e8614a` | accent logo variant, energy states |
| Sky Blue | `#0099cc` | bright logo variant, informational |

## Color Tones

Each core color is used at 100%, 80%, 60%, 40%, and 20% opacity for surfaces and containers.

### Primary Tones (Emerald Green `#44aa87`)

| Tone | Usage |
| --- | --- |
| 100% | primary actions, logo mark, key UI elements |
| 80% | hover and pressed states |
| 60% | secondary surfaces and chips |
| 40% | subtle highlights |
| 20% | very light backgrounds and tinted surfaces |

### Secondary Tones (Yellow `#fff15f`)

| Tone | Usage |
| --- | --- |
| 100% | accent details on dark/primary backgrounds |
| 80%–20% | reduced for decorative fills only |

## Semantic Roles (App Implementation)

| Role | HEX | Suggested Token |
| --- | --- | --- |
| Primary | `#44aa87` | `primary` |
| On Primary | `#ffffff` | `onPrimary` |
| Primary Container | `#44aa87` at 20% | `primaryContainer` |
| Secondary | `#fff15f` | `secondary` |
| Background | `#f5faf8` | `background` |
| Surface | `#ffffff` | `surface` |
| Text Primary | `#182033` | `textPrimary` |
| Text Secondary | `#59637A` | `textSecondary` |
| Error | `#C94A4A` | `error` |
| Success | `#1E9E6A` | `success` |
| Warning | `#C98612` | `warning` |

## Usage Rules

- primary green is the dominant color — use it for logo, primary CTAs, headers, and key surfaces
- yellow is an accent only — use exclusively on dark or green backgrounds where contrast is sufficient
- never place yellow on white or light backgrounds (insufficient contrast)
- on light backgrounds use the green logo variant (`logo-light.png`)
- on dark or green backgrounds use the yellow-on-green variant (`logo-dark.png`)
- the navy, coral, and sky blue variants are approved for identity collateral only (business cards, envelopes) — not for UI

## Source Files

- `source/color.ai` — Illustrator color palette source
- `source/color.pdf` — print-ready color reference
- `brand-manual-colors.pdf` — color page extracted from brand manual
