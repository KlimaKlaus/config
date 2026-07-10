---
name: daisyui
description: Use when generating HTML/JSX with Tailwind CSS, building UI components, or user mentions daisyUI, components, themes, or Tailwind UI. The standard component library for Tailwind CSS — semantic class names for buttons, cards, modals, navbars, and 65+ other components.
---

# daisyUI 5

Component library for Tailwind CSS 4. Replaces piles of utility classes with semantic component classes (`btn`, `card`, `modal`, `navbar`, etc.) while staying compatible with all Tailwind utilities.

## Install

```bash
npm i -D daisyui@latest
```

```css
/* app.css — no tailwind.config.js needed (Tailwind v4) */
@import "tailwindcss";
@plugin "daisyui";
```

CDN alternative:
```html
<link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
<script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
```

## Usage Pattern

```html
<!-- daisyUI class alone -->
<button class="btn">Button</button>

<!-- daisyUI variant -->
<button class="btn btn-primary">Primary</button>

<!-- daisyUI + Tailwind utilities -->
<button class="btn w-64 rounded-full">Custom</button>
```

Components have three class-name categories: the **component** class (`btn`), optional **modifier** classes (`btn-primary`, `btn-outline`, `btn-sm`), and standard **Tailwind utilities** for further customization.

## Core Rules

1. **Always use daisyUI component classes when available** — don't rebuild components from raw Tailwind utilities.
2. **Use daisyUI semantic color names** (`primary`, `secondary`, `accent`, `neutral`, `base-100`, `info`, `success`, `warning`, `error`) over Tailwind palette colors like `red-500`. They auto-adapt to the active theme.
3. **Never use `dark:` prefix** with daisyUI colors — themes handle light/dark automatically.
4. **`*-content` colors** (`primary-content`, `base-content`) provide readable text on their parent color.
5. **Default variant preferred** — use `btn`, not `btn btn-primary`, unless the user asks for a specific color.
6. **Force-override sparingly**: `bg-red-500!` only as last resort when specificity blocks a Tailwind utility.
7. **Responsive layout** with Tailwind prefixes (`sm:`, `md:`, `lg:`) for flex/grid.
8. **Write no custom CSS** — daisyUI classes + Tailwind utilities should suffice.

## Component Discovery

Before writing daisyUI code:
1. Read intent, behavior, and shape — match on **meaning**, not literal words.
2. Scan the component list below for candidate components.
3. When ambiguous, read 3+ candidate docs before deciding.
4. State which component chosen and why.

## Config

```css
@plugin "daisyui" {
  themes: light --default, dark --prefersdark;
  root: ":root";
  prefix: "";         /* optional: e.g. "daisy-" */
  logs: true;
}
```

Custom theme via `@plugin "daisyui/theme"` with OKLCH CSS variables (`--color-primary`, `--color-base-100`, etc.) and border-radius scales (`--radius-selector`, `--radius-field`, `--radius-box`).

## Key Components

| Component | Class | Common Modifiers |
|-----------|-------|-----------------|
| Button | `btn` | `btn-primary`, `btn-outline`, `btn-ghost`, `btn-sm/lg/xl`, `btn-wide`, `btn-circle`, `btn-square` |
| Card | `card` | `card-border`, `card-dash`, `card-side`, `image-full` |
| Modal | `modal` | `modal-top/bottom/middle` |
| Navbar | `navbar` | `navbar-start/center/end` |
| Input | `input` | `input-bordered`, `input-ghost`, `input-sm/lg/xl` |
| Badge | `badge` | `badge-primary`, `badge-outline`, `badge-soft`, `badge-sm/lg/xl` |
| Alert | `alert` | `alert-info/success/warning/error`, `alert-outline/soft` |
| Avatar | `avatar` | `avatar-online/offline`, `avatar-placeholder` |
| Tabs | `tabs` | `tabs-lifted`, `tabs-bordered`, `tabs-box`, `tabs-sm/lg/xl` |
| Dropdown | `dropdown` | `dropdown-top/bottom/left/right`, `dropdown-hover`, `dropdown-open` |
| Menu | `menu` | `menu-vertical/horizontal`, `menu-sm/lg/xl` |
| Drawer | `drawer` | `drawer-open`, `drawer-end` |
| Tooltip | `tooltip` | `tooltip-top/bottom/left/right`, `tooltip-primary` |
| Loading | `loading` | `loading-spinner/dots/ring/ball/bars/infinity` |
| Toast | `toast` | `toast-top/bottom/center/start/end` |
| Toggle | `toggle` | `toggle-primary`, `toggle-sm/lg/xl` |
| Collapse | `collapse` | `collapse-arrow/plus`, `collapse-open` |
| Divider | `divider` | `divider-primary`, `divider-start/end` |
| Skeleton | `skeleton` | (shape via Tailwind: `w-32 h-8`) |
| Steps | `steps` | `steps-vertical` |
| Table | `table` | `table-zebra`, `table-pin-rows/cols`, `table-xs/sm/lg/xl` |
| Footer | `footer` | `footer-center`, `footer-vertical/horizontal` |
| Hero | `hero` | `hero-content`, `hero-overlay` |
| Diff | `diff` | `diff-item-1/2`, `diff-resizer` |
| Stat | `stat` | `stat-title/value/desc/actions` |
| Chat | `chat` | `chat-start/end` |
| Timeline | `timeline` | `timeline-start/end`, `timeline-vertical` |
| Status | `status` | `status-primary`, `status-sm/lg/xl` |

**68 components total.** For full syntax, class-name tables, and examples per component: `read https://daisyui.com/components/<name>/`

## Colors Reference

Semantic color names usable with any Tailwind color utility (`bg-`, `text-`, `border-`, `ring-`, etc.):

| Name | Use |
|------|-----|
| `primary` / `primary-content` | Main brand color |
| `secondary` / `secondary-content` | Optional second brand color |
| `accent` / `accent-content` | Optional accent |
| `neutral` / `neutral-content` | Dark surfaces |
| `base-100`, `base-200`, `base-300` / `base-content` | Page backgrounds (100=lightest) |
| `info` / `info-content` | Informational messages |
| `success` / `success-content` | Success/safe states |
| `warning` / `warning-content` | Warning/caution |
| `error` / `error-content` | Error/danger |

Reserve `primary` for the single most important element. Use `base-*` for the majority of the page.

## Built-in Themes

30+ themes: `light`, `dark`, `cupcake`, `bumblebee`, `emerald`, `corporate`, `synthwave`, `retro`, `cyberpunk`, `valentine`, `halloween`, `garden`, `forest`, `aqua`, `lofi`, `pastel`, `fantasy`, `wireframe`, `black`, `luxury`, `dracula`, `cmyk`, `autumn`, `business`, `acid`, `lemonade`, `night`, `coffee`, `winter`, `dim`, `nord`, `sunset`, `caramellatte`, `abyss`, `silk`.

Apply a theme: `data-theme="forest"` on `<html>`. Switch at runtime via `theme-controller` component.

## Design Principles

- Follow Refactoring UI best practices
- Don't add custom fonts unless necessary
- Don't add `bg-base-100 text-base-content` to `<body>` unless needed
- Use `https://picsum.photos/WIDTH/HEIGHT` for placeholder images
- Favor boring, standard layouts over novel ones

## Reference

- Docs: `https://daisyui.com`
- Component reference: `https://daisyui.com/components/<name>/`
- Theme generator: `https://daisyui.com/theme-generator/`
- Source: `https://github.com/saadeghi/daisyui`
