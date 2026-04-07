# Typography Guide

Official Mindscape typography from the 2022 Brand Manual Guideline.

## Logo Fonts (Brand Identity — Do Not Substitute)

| Use | Font | File |
| --- | --- | --- |
| English logotype | **Myriad Variable Concept** | `fonts/MyriadVariableConcept-Roman.otf` |
| Arabic logotype | **GE SS Two Light** | `fonts/ArbFONTS-GE-SS-Two-Light_28.otf` |

These two fonts are locked to the logo. Do not change font placement or use any other font for the wordmark. Maintain the relative distance between font and icon exactly as constructed.

## Brand Font Family

All font files are in `fonts/`:

### English / Latin

| Font | Weight | File | Use |
| --- | --- | --- | --- |
| Myriad Pro | Regular | `MyriadPro-Regular.otf` | body, UI text |
| Myriad Variable Concept | Regular/Condensed/Black | `MyriadVariableConcept-Roman.otf` | logo, display |
| Roboto Slab | Regular | `RobotoSlab-Regular.ttf` | headings, editorial |
| Roboto Slab | Medium | `RobotoSlab-Medium.ttf` | subheadings, emphasis |
| Roboto Slab | Bold | `RobotoSlab-Bold.ttf` | strong headings |
| Roboto Slab | Black | `RobotoSlab-Black.ttf` | display/hero text |
| Kufam | ExtraBold | `Kufam-ExtraBold.ttf` | accent display only |

### Arabic

| Font | Weight | File | Use |
| --- | --- | --- | --- |
| GE SS Two | Light | `ArbFONTS-GE-SS-Two-Light_28.otf` | logo, Arabic logotype |
| Tajawal | Regular | `Tajawal-Regular.ttf` | Arabic body text |
| Tajawal | Light | `Tajawal-Light.ttf` | secondary Arabic text |
| Tajawal | Bold | `Tajawal-Bold.ttf` | Arabic headings |
| Ara Hamah 1964 R | Regular | `AraHamah1964R-Regular.otf` / `.ttf` | decorative Arabic |

## Role-Based Usage (UI)

| Role | Recommended Font | Weight |
| --- | --- | --- |
| Display / Hero | Roboto Slab or Myriad Variable Concept | Black / ExtraBold |
| Heading | Roboto Slab | Bold |
| Subheading / Title | Roboto Slab | Medium |
| Body | Myriad Pro or system font | Regular |
| Label / Button | Myriad Pro | Regular or Medium (via variable) |
| Caption / Meta | Myriad Pro | Light/Regular at smaller size |
| Arabic Body | Tajawal | Regular |
| Arabic Heading | Tajawal | Bold |

## App Typography Guidance

- map typography to shared app text roles rather than hardcoding styles screen by screen
- keep font sizes, weights, and line heights in one design-token layer
- the brand recommends Roboto Slab for headings and Myriad Pro for body copy
- Kufam ExtraBold is reserved for splash or hero moments only and should not be used in recurring UI elements

## Localization — Arabic Support

- Tajawal is the primary Arabic UI font (covers Regular, Light, Bold)
- GE SS Two Light is logo-only in Arabic — it is not intended for body copy
- test line height and truncation behavior when Arabic UI work begins
- avoid tight letter-spacing rules that will not translate across RTL scripts
- all chosen fonts support both LTR (Latin) and RTL (Arabic) contexts

## Source Files

- `source/mindscape.ai` — Illustrator master (includes font usage in context)
- `source/mindscape.pdf` — Brand manual PDF with typography specification pages
