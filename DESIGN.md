## 1) Visual Identity / Tokens

Source: `apps/main/static/main/css/base.css` (:root)

Color tokens (CSS vars):
- --primary-black: #0a0a0a
- --secondary-black: #1a1a1a
- --accent-gray: #2a2a2a
- --light-gray: #a0a0a0
- --ultra-light: #f5f5f5
- --accent-gold: #d4af37
- --accent-blue: #0066ff
- --gradient-start: #0a0a0a
- --gradient-end: #1a1a1a
- --success-green: #10b981
- --danger-red: #ef4444
- --warning-orange: #f59e0b

Typography:
- Font: Inter (300–700 weights). Loaded via Google Fonts in `base.html` and `base_catalog.html`.
- Global base font/line-height set in `base.css` (body { font-family: 'Inter'; line-height: 1.6; }).

Layout tokens:
- Container max-width: 1400px (class: `.container` / `.catalog-container`).
- Reusable spacing paddings: 3rem default container padding; 1.5–3rem in header/footer/sections.

Design effects:
- Glassmorphism: `backdrop-filter: blur(..)` used widely in nav, headers, modals, and cards.
- Main background: dark gradient using `--gradient-start` / `--gradient-end` with subtle radial overlays (body::before).
- Subtle borders: `rgba(255,255,255,0.05)` on many containers.
- Hover transitions: `transition: all 0.3s ease` across interactive elements.

---

## 2) Files & Where to Add/Find Styles

Primary locations (per-app static structure):
- main: `apps/main/static/main/css/` — `base.css`, `home.css`, `product_detail.css`, `hero.css`, `notifications.css`
- catalog: `apps/catalog/static/catalog/css/catalog.css`
- cart: `apps/cart/static/cart/css/cart.css`
- order: `apps/order/static/order/css/checkout.css` / `order_detail.css` / `checkout_success.css`
- profiles: `apps/profiles/static/profiles/css/*.css`
- stores: `apps/stores/static/stores/css/stores.css`

Templates that import CSS:
- `apps/main/templates/main/base.html` — imports `base.css` globally and Bootstrap (CDN).
- `apps/catalog/templates/catalog/base_catalog.html` — imports `catalog.css` + `base.css`.

Rule: Add new app-specific CSS under the app's `static/<app>/css/` and import in the relevant base/template with `{% static ... %}`.

---

## 3) Layout Pattern & Breakpoints

Grids & Containers:
- Use `.container` for global max-width enforcement (1400px). Use `.catalog-container` for catalog pages.
- Catalog split layout: `.catalog-wrapper` grid with `grid-template-columns: 280px 1fr` for sidebar + content. On narrower screens, it collapses to single-column via `@media (max-width: 1024px)`.
- Product grids: `.products-grid` uses dynamic `repeat(auto-fill, minmax(280px, 1fr))`—use the `minmax(280px, 1fr)` convention.

Breakpoints:
- Desktop: >= 1024px (layout as grid with sidebars). 
- Tablet: `@media (max-width: 1024px)` — sidebar collapses, product detail becomes single column.
- Mobile: `@media (max-width: 768px)` — nav becomes column layout, reduce padding, adjust grids (repeat for 200–280px columns).
- Small devices: `@media (max-width: 480px)` — collapse to 1 column for product cards.

Spacing:
- Default paddings: `.container` 3rem; app-specific sections use 1–4rem; cards use 1–2rem.

---

## 4) Component Catalog (classes & usage)

Key UI components and minimal HTML snips.

Buttons:
- `.btn` — base styling (uppercase, letter spacing, rounded). Use `btn-primary` for primary CTAs and `btn-secondary` for secondary actions.
- Variants found: `.btn-view`, `.btn-quick-view`, `.btn-add-cart`, `.btn-wishlist`, `.btn-logout`, `.btn-danger`.

Example:
- `<button class="btn btn-primary">Buy now</button>`

Form controls:
- `.form-control`, `.form-group`, `.form-label`, `.form-errors`.
- Inputs use visual focus styles (border-color: var(--accent-gold) or --accent-blue). Use `.input[type=file]` special styling with `::file-selector-button`.

Cards:
- `.product-card` — card container.
- `.product-image` — image panel; `.product-image img` inside.
- `.product-info` — product details: `.product-name` / `.product-price` / `.product-stock`.
- `product-badge` & `stock-badge` (positioned absolute in image).

Product Grid:
- Wrap in `.products-grid`, each item is `.product-card`.
- Hover: scale image & lift card with shadow.

Product Detail:
- `.product-detail-grid` — two columns (gallery, info)
- `.product-gallery` + `.main-image` (set `object-fit: cover`)
- `.thumbnail-gallery` with `.thumbnail` active class toggling.
- `.product-info-panel` for title, price, metadata, add-to-cart buttons (`.btn-add-cart`), stock status.

Cart UI:
- `.cart-container`, `.cart-items`, `.cart-item` layout grid.
- `.cart-summary` for totals and CTA buttons.

Modals & Notifications:
- `.modal` and `.modal.active` — set `display` flex; `.modal-content`, `.modal-close`.
- `.notification`, `.notification.*` — toasts (`success`, `error`, `warning`, `info`) with `::before` color markers and fade/slide animations.

Other UI:
- `.sidebar` with `.sidebar-section`, `.category-list`, `.filter-checkbox`.
- `.breadcrumb`, `.pagination` (in catalog), `.related-products-section`.
- Utilities: `.hidden`, `.inline`, `.relative`, `.link-plain`, `.loading`.

-- JS Hooks & State Classes (toggled by UI scripts):
- `.expanded` on `.category-filters-wrapper` & `.category-toggle-btn` (collapsing behavior)
- `.active` on `.modal`, `.thumbnail`, `.page-current` on pagination
- `.cart-badge` toggles between `hidden` & visible (display controlled via JS)
- `btn-add-cart:disabled` — style for disabled / OOS
- `product-image.ambient-active` — used with `--ambient-glow` variables

---

## 5) Visual & Interaction Patterns

- Glassmorphism: header, cards, modal, and sections use transparent backgrounds + `backdrop-filter: blur(...)` for depth. Keep borders light `rgba(255,255,255,0.03–0.05)`.
- Hover and elevation: use `transform: translateY(-2px/-4px)` and `box-shadow` for lift on hover; prefer small numbers for subtlety.
- Focus states: form inputs and interactive elements have visible focus with border-color set to `--accent-blue` or `--accent-gold` and a soft box-shadow.
- Disabled states: buttons use a dimmed gradient and `cursor: not-allowed` plus `opacity` reduction.
- Toasts/Alerts: standardized animation patterns `slideIn`, `slideInRight`, and `fadeOut`; use dedicated `.notification` class and `::before` color marker.

Accessibility & semantics:
- Use semantic elements: `<header>`, `<nav>`, `<main>`, `<footer>`.
- Always attach `aria-label`s to icon-only buttons and interactive components like quantity controls.
- Provide `alt` attributes for images and graceful fallbacks (placeholder images used across site templates).
- Animations should be respectful of `prefers-reduced-motion` where possible; prefer `transform` and opacity for smoother, lower-cost animations.

JS interaction patterns and integration:
- Global config: `window.becathlon.isAuthenticated` and `window.becathlon.loginUrl` are injected in base templates; use these in front-end scripts.
- Data attributes: product buttons include `data-product-id` (see product template), used by `cart/js/cart.js`.
- State toggles: scripts toggle `.expanded`, `.active`, `.thumbnail.active`, `.modal.active`, `.category-toggle-btn.expanded` classes.

Design constraints & best practices:
- All new components should use CSS variables from `base.css` for colors & shared tokens.
- Keep responsive behavior consistent with existing grid/flex patterns and breakpoints (1024/768/480). 
- Avoid overriding global `body::before` background unless the page intentionally disables it (product detail page already hides it).
- Favor `repeat(auto-fill, minmax(...))` for grid layouts to keep responsiveness robust.
- Prefer small, atomic classes for utilities (`.hidden`, `.inline`, `.relative`) rather than inlining styles across templates.

Component naming conventions:
- Follow hyphenated class names `kebab-case` (e.g., `.product-card`, `.product-info`).
- Prefer descriptive classes over BEM unless logical grouping requires nested naming.

How to add a new component (quick guide):
1. Add CSS to `apps/<app>/static/<app>/css/<component>.css` and import it in the related base template.
2. Use tokens in `:root` and add any new token to `base.css` if it will be reused globally.
3. Add corresponding template file in `apps/<app>/templates/<app>/` (or partial include under `templates/includes/`) and call it from appropriate page.
4. Use `data-` attributes for JS hooks and keep class names consistent with existing patterns.

Snippets — minimal HTML:
- Product card:
```html
<article class="product-card">
	<div class="product-image">
		<img src="..." alt="..."/>
		<span class="product-badge">New</span>
		<span class="stock-badge low-stock">Low</span>
	</div>
	<div class="product-info">
		<h3 class="product-name">Product</h3>
		<div class="product-price">$199</div>
		<div class="product-actions">
			<a class="btn btn-view" href="#">View</a>
			<button class="btn btn-quick-view" data-product-id="1">Quick View</button>
		</div>
	</div>
</article>
```

- Modal / Toast use:
```html
<div class="modal" id="quickViewModal" role="dialog" aria-modal="true">
	<div class="modal-content">
		<button class="modal-close" aria-label="Close">×</button>
		<!-- content -->
	</div>
</div>

<div class="notification success">Item added to cart</div>
```

Warnings & Gotchas:
- `backdrop-filter` is not supported in older browsers — provide fallback without blur where necessary.
- Do not hardcode colors (use CSS variables). This keeps theme switching or variable updates consistent.
- Avoid adding extra fonts; use Inter from the base templates.
- Keep heavy animations to a minimum to preserve responsiveness, particularly on mobile.

Small migration recommendations:
- Consider breaking out a `tokens.css` or `theme.css` that defines variables and import it where necessary to reduce duplication.
- If many components reuse card/section patterns, create a shared `components/` CSS file and import it.

