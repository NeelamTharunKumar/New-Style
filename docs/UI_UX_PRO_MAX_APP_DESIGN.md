# BharatFit AI UI/UX Design Based on UI/UX Pro Max

This design direction is based on reviewing the separately cloned repository:

```text
/home/user/ui-ux-pro-max-skill
```

The design system generator was run for:

```text
India fashion wardrobe AI stylist mobile app outfit planner privacy
```

## Recommended design system

### Pattern

**App Store Style Landing / Mobile Product Showcase** adapted inside the app.

For BharatFit, this means:

- strong first-run onboarding
- clear privacy promise above the fold
- screenshot/card-like visual previews
- repeated primary actions
- trust-building copy around local image privacy

### Style

**Exaggerated Minimalism** for fashion/lifestyle.

Why it fits:

- fashion products benefit from bold typography and editorial whitespace
- wardrobe/outfit cards should feel premium, not technical
- privacy and AI explanations need simple high-contrast layouts
- Indian ethnic + western styling needs visual breathing room

### Colors

Derived from UI/UX Pro Max fashion palette:

| Role | Hex | Usage |
|---|---:|---|
| Primary | `#BE185D` | main CTAs, active states, key highlights |
| Secondary | `#EC4899` | gradients, brand accents |
| Accent | `#D97706` | premium/gold moments, score highlights |
| Background | `#FDF2F8` | app canvas |
| Foreground | `#0F172A` | primary text |
| Muted | `#FBF1F5` | soft surfaces |
| Border | `#F7E3EB` | card/input borders |
| Success | `#15803D` | privacy/safe local processing badge |

Implemented in:

```text
flutter_app/lib/core/design_tokens.dart
```

### Typography

UI/UX Pro Max recommended:

```text
Heading: Syne
Body: Manrope
```

Current implementation uses the `Manrope` family name in ThemeData as a placeholder. Actual bundled fonts are not added yet.

Before release, either:

1. add local font files under `flutter_app/assets/fonts/`, or
2. remove explicit fontFamily and use platform fonts.

### Effects

Applied direction:

- soft premium cards
- high whitespace
- large bold headings
- pill badges
- rose/gold gradient brand mark
- no noisy decoration
- visible privacy badge

### Accessibility/UX rules from UI/UX Pro Max

Applied or documented:

- onboarding can be skipped
- large touch targets
- clear empty states
- clear status/error banners
- predictable navigation
- no image-upload ambiguity

Still to do:

- screen reader semantics pass
- large font testing
- Flutter widget tests
- real device safe-area testing

## Implemented UI changes

### Shared UI components

```text
flutter_app/lib/presentation/widgets/app_components.dart
```

Includes:

- `AppGradientScaffold`
- `PremiumCard`
- `SectionHeader`
- `StatPill`
- `EmptyState`
- `PrivacyBadge`

### Brand mark

```text
flutter_app/lib/presentation/widgets/brand_mark.dart
```

Now uses fashion rose/pink/gold gradients.

### App theme

```text
flutter_app/lib/main.dart
```

Changed from dark tech-style UI to light fashion/lifestyle UI:

- warm rose canvas
- white premium cards
- rose primary color
- gold accent
- rounded inputs/buttons
- softer shadows

### Screens touched

```text
flutter_app/lib/presentation/screens/onboarding_screen.dart
flutter_app/lib/presentation/screens/home_dashboard.dart
flutter_app/lib/presentation/screens/wardrobe_screen.dart
flutter_app/lib/presentation/screens/your_outfits_screen.dart
```

## Product UX principles going forward

1. **Visual first, text second**
   - Outfit cards should lead with local item images.
   - Explanations should be concise and scannable.

2. **Privacy visible everywhere**
   - Use badges and microcopy to repeat: photos stay on-device.

3. **India-first occasion shortcuts**
   - College, office, date, Haldi, Sangeet, wedding guest should be one-tap contexts.

4. **Fashion editorial feeling**
   - Bigger titles, fewer borders, more whitespace.

5. **Do not look like a generic AI chatbot**
   - Chat is secondary. Wardrobe and outfits are primary.

## Remaining UI work

- Add bottom tab navigation.
- Add outfit detail page.
- Add wardrobe item detail/edit page.
- Add camera/gallery flow polish.
- Add skeleton loading states.
- Add screenshot generation screens for app stores.
- Add accessibility labels/semantics.
- Add real fonts or remove placeholder font name.
