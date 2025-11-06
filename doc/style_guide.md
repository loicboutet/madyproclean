# Style Guide - Mady ProClean Design System

## Color Palette

### Primary Colors

| Color | Hex | RGB | Usage |
|-------|-----|-----|-------|
| **Cyan Electric** | `#00D4FF` | `0, 212, 255` | Primary, CTA, links |
| **Turquoise** | `#00FFE0` | `0, 255, 224` | Accents, highlights |
| **Bleu Nuit** | `#1a1a2e` | `26, 26, 46` | Main background, text |
| **White** | `#FFFFFF` | `255, 255, 255` | Text on dark, cards |

### Secondary Colors

| Color | Hex | Usage |
|-------|-----|-------|
| **Cyan Clair** | `#66e3ff` | Hover states |
| **Bleu Profond** | `#0f3460` | Alternate sections |
| **Cyan 10%** | `rgba(0,212,255,0.1)` | Subtle backgrounds |
| **Cyan 30%** | `rgba(0,212,255,0.3)` | Borders |

---

## Gradients

### Primary Gradient
```css
background: linear-gradient(135deg, #00D4FF, #00FFE0);
```
**Usage:** Primary buttons, CTA

### Dark Gradient
```css
background: linear-gradient(180deg, #1a1a2e 0%, #0f3460 100%);
```
**Usage:** Hero sections, backgrounds

---

## Typography

### Font Family
```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

### Type Scale

| Element | Size | Weight | CSS |
|---------|------|--------|-----|
| **H1** | 3rem (48px) | 700 (Bold) | `text-5xl font-bold` |
| **H2** | 2.25rem (36px) | 700 (Bold) | `text-4xl font-bold` |
| **H3** | 1.5rem (24px) | 700 (Bold) | `text-2xl font-bold` |
| **Body Large** | 1.125rem (18px) | 400 (Regular) | `text-lg` |
| **Body Regular** | 1rem (16px) | 400 (Regular) | `text-base` |

---

## Buttons

### Primary Button
```html
<button class="px-8 py-4 rounded-full font-bold text-white bg-gradient-to-r from-cyan-400 to-cyan-300">
    Bouton Primaire
</button>
```

**CSS:**
```css
background: linear-gradient(135deg, #00D4FF, #00FFE0);
border-radius: 9999px;
padding: 1rem 2rem;
font-weight: 700;
```

**Tailwind Classes:**
```
px-8 py-4 rounded-full font-bold text-white
```

### Secondary Button
```html
<button class="px-8 py-4 rounded-full font-bold border-2 border-[#00D4FF] text-[#00D4FF] hover:bg-[#00D4FF]/10">
    Bouton Secondaire
</button>
```

**CSS:**
```css
border: 2px solid #00D4FF;
color: #00D4FF;
border-radius: 9999px;
padding: 1rem 2rem;
font-weight: 700;
```

---

## Cards

### Glass Card
```html
<div class="p-8 rounded-2xl bg-white/5 backdrop-blur-lg border border-[#00D4FF]/20">
    <p class="text-white">Card content</p>
</div>
```

**CSS:**
```css
background: rgba(255, 255, 255, 0.05);
backdrop-filter: blur(10px);
border: 1px solid rgba(0, 212, 255, 0.2);
border-radius: 1rem;
padding: 2rem;
```

---

## Effects & Animations

### Glow Effect
```css
box-shadow: 0 0 20px rgba(0, 212, 255, 0.5);
```

**Tailwind (custom config needed):**
```css
shadow-[0_0_20px_rgba(0,212,255,0.5)]
```

### Hover Effect
```css
transition: all 0.3s ease;
transform: translateY(-2px);
box-shadow: 0 10px 30px rgba(0, 212, 255, 0.4);
```

**Tailwind:**
```
transition-all duration-300 hover:-translate-y-0.5 hover:shadow-[0_10px_30px_rgba(0,212,255,0.4)]
```

### Sparkle Animation
```css
@keyframes sparkle {
    0%, 100% { 
        opacity: 0.3; 
        transform: scale(1); 
    }
    50% { 
        opacity: 1; 
        transform: scale(1.2); 
    }
}

.sparkle {
    animation: sparkle 2s ease-in-out infinite;
}
```

---

## Spacing

| Name | Value | Tailwind |
|------|-------|----------|
| **xs** | 0.25rem (4px) | `1` |
| **sm** | 0.5rem (8px) | `2` |
| **md** | 1rem (16px) | `4` |
| **lg** | 1.5rem (24px) | `6` |
| **xl** | 2rem (32px) | `8` |
| **2xl** | 3rem (48px) | `12` |

---

## Border Radius

| Size | Value | Tailwind | Usage |
|------|-------|----------|-------|
| Small | 0.25rem | `rounded` | Small elements |
| Medium | 0.5rem | `rounded-lg` | Cards, containers |
| Large | 1rem | `rounded-2xl` | Large cards |
| Full | 50% | `rounded-full` | Buttons, avatars |

---

## Iconography

Recommended icons from Lucide or Heroicons:

| Icon | Usage |
|------|-------|
| **droplet** | Water/Cleaning |
| **zap** | Sparkle/Shine |
| **truck** | Vehicles |
| **star** | Quality |
| **shield-check** | Security |
| **clock** | Time tracking |
| **users** | Team/Staff |
| **calendar** | Planning |

**Size Guidelines:**
- Small: `w-4 h-4` (16px)
- Medium: `w-6 h-6` (24px)
- Large: `w-8 h-8` (32px)
- XL: `w-12 h-12` (48px)

---

## CSS Variables

### Setup
```css
:root {
    --cyan-electric: #00D4FF;
    --turquoise: #00FFE0;
    --dark-blue: #1a1a2e;
    --deep-blue: #0f3460;
    --light-cyan: #66e3ff;
}
```

### Utility Classes
```css
/* Backgrounds */
.bg-cyan { 
    background-color: var(--cyan-electric); 
}

/* Text */
.text-cyan { 
    color: var(--cyan-electric); 
}

/* Borders */
.border-cyan { 
    border-color: var(--cyan-electric); 
}

/* Gradients */
.gradient-cyan {
    background: linear-gradient(135deg, var(--cyan-electric), var(--turquoise));
}

/* Effects */
.glow-cyan {
    box-shadow: 0 0 20px rgba(0, 212, 255, 0.5);
}
```

---

## Tailwind Configuration

### Custom Colors (tailwind.config.js)
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        'cyan-electric': '#00D4FF',
        'turquoise': '#00FFE0',
        'dark-blue': '#1a1a2e',
        'deep-blue': '#0f3460',
        'light-cyan': '#66e3ff',
      },
      backgroundImage: {
        'gradient-cyan': 'linear-gradient(135deg, #00D4FF, #00FFE0)',
        'gradient-dark': 'linear-gradient(180deg, #1a1a2e 0%, #0f3460 100%)',
      },
      boxShadow: {
        'glow-cyan': '0 0 20px rgba(0, 212, 255, 0.5)',
        'glow-cyan-lg': '0 10px 30px rgba(0, 212, 255, 0.4)',
      },
    },
  },
}
```

---

## Component Examples

### Primary Button Component
```html
<!-- Tailwind -->
<button class="px-8 py-4 rounded-full font-bold text-white bg-gradient-to-r from-[#00D4FF] to-[#00FFE0] hover:shadow-glow-cyan-lg transition-all duration-300 hover:-translate-y-0.5">
    Click Me
</button>

<!-- With custom classes -->
<button class="btn-primary">
    Click Me
</button>
```

```css
/* Custom CSS */
.btn-primary {
    background: linear-gradient(135deg, #00D4FF, #00FFE0);
    border-radius: 9999px;
    padding: 1rem 2rem;
    font-weight: 700;
    color: white;
    transition: all 0.3s ease;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 30px rgba(0, 212, 255, 0.4);
}
```

### Card Component
```html
<!-- Dark Background Card -->
<div class="bg-[#1a1a2e] rounded-2xl p-8">
    <div class="bg-white/5 backdrop-blur-lg border border-[#00D4FF]/20 rounded-2xl p-8">
        <h3 class="text-white text-2xl font-bold mb-4">Card Title</h3>
        <p class="text-gray-300">Card content goes here...</p>
    </div>
</div>
```

### Hero Section
```html
<section class="bg-gradient-to-b from-[#1a1a2e] to-[#0f3460] py-20">
    <div class="container mx-auto px-4">
        <h1 class="text-5xl font-bold text-white text-center mb-6">
            Welcome to Mady ProClean
        </h1>
        <p class="text-xl text-gray-300 text-center mb-8">
            Professional cleaning services
        </p>
        <div class="flex justify-center">
            <button class="btn-primary">
                Get Started
            </button>
        </div>
    </div>
</section>
```

---

## Accessibility Guidelines

### Color Contrast
- Always ensure text has sufficient contrast against backgrounds
- Minimum contrast ratio: 4.5:1 for normal text
- Minimum contrast ratio: 3:1 for large text (18px+ or 14px+ bold)

### Interactive Elements
- All interactive elements must be keyboard accessible
- Focus states should be clearly visible
- Use `focus:ring-2 focus:ring-cyan-electric` for focus indicators

### Example Focus State
```html
<button class="btn-primary focus:ring-2 focus:ring-[#00D4FF] focus:ring-offset-2 focus:ring-offset-[#1a1a2e]">
    Accessible Button
</button>
```

---

## Responsive Design

### Breakpoints
```css
/* Tailwind default breakpoints */
sm: 640px   /* @media (min-width: 640px) */
md: 768px   /* @media (min-width: 768px) */
lg: 1024px  /* @media (min-width: 1024px) */
xl: 1280px  /* @media (min-width: 1280px) */
2xl: 1536px /* @media (min-width: 1536px) */
```

### Mobile-First Example
```html
<div class="px-4 md:px-8 lg:px-12">
    <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold">
        Responsive Title
    </h1>
</div>
```

---

## Best Practices

1. **Use Tailwind utilities first**, custom CSS only when necessary
2. **Keep glass morphism subtle** - use sparingly for special elements
3. **Glow effects** should be used primarily for CTAs and important elements
4. **Maintain consistent spacing** using the spacing scale
5. **Use gradients for primary actions** (buttons, CTAs)
6. **Dark backgrounds** should use the provided blues, not pure black
7. **Test all designs on mobile devices** - mobile-first approach
8. **Ensure sufficient contrast** for accessibility
9. **Use rounded-full for buttons**, rounded-2xl for cards
10. **Animate with purpose** - transitions should be smooth (300ms)

---

## Common Patterns

### Section Divider
```html
<div class="w-full h-px bg-gradient-to-r from-transparent via-[#00D4FF]/50 to-transparent"></div>
```

### Badge
```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-[#00D4FF]/10 text-[#00D4FF] border border-[#00D4FF]/30">
    New
</span>
```

### Input Field
```html
<input 
    type="text" 
    class="w-full px-4 py-3 rounded-lg bg-white/5 border border-[#00D4FF]/30 text-white placeholder-gray-400 focus:border-[#00D4FF] focus:ring-2 focus:ring-[#00D4FF]/50 outline-none transition-all"
    placeholder="Enter text..."
>
```

---

*Mady ProClean Design System - Version 1.0*  
*Reference document for web development*
