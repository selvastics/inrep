# inrep Theme System - Complete Guide

## Overview

The inrep package features a comprehensive, enterprise-grade theme system designed for psychological assessments and research applications. This system provides 22 professionally designed themes with full accessibility support, responsive design, and seamless integration with Shiny applications.

## 🚀 Key Features

### ✅ **Comprehensive Theme Collection**
- **22 Professional Themes** covering various use cases
- **Accessibility-First Design** with WCAG 2.1 AA compliance
- **Responsive Layout** optimized for all screen sizes
- **Print-Optimized** styling for reports and documentation

### ✅ **Dual Variable System**
- **Modern Variables**: `--primary-color`, `--background-color`, etc.
- **Legacy Variables**: `--color-primary`, `--color-background`, etc.
- **Automatic Fallback** ensures compatibility across all themes

### ✅ **Advanced Theme Editor**
- **Live Preview** with real-time CSS generation
- **ACE Code Editor** with syntax highlighting
- **Export Options** (CSS, JSON, clipboard)
- **Custom Theme Creation** with visual feedback

## 🎨 Available Themes

### **Core Professional Themes**
1. **Light** - Clean, bright theme for daytime use
2. **Dark** - Eye-friendly dark mode
3. **Midnight** - Deep blue professional theme
4. **Professional** - Corporate-grade styling
5. **Clean** - Minimalist professional design

### **Accessibility Themes**
6. **Dyslexia-Friendly** - Enhanced readability with OpenDyslexic font
7. **High-Contrast** - Maximum contrast for visual impairments
8. **Colorblind-Safe** - Optimized for color vision deficiencies
9. **Large-Text** - Increased font sizes for readability

### **Specialized Themes**
10. **Clinical** - Medical and healthcare environments
11. **Educational** - Academic and learning contexts
12. **Research** - Scientific research applications
13. **Corporate** - Business and enterprise use

### **University Themes**
14. **Hildesheim** - University of Hildesheim branding
15. **Accessible-Blue** - University accessibility standards

### **Color Themes**
16. **Forest** - Natural green palette
17. **Ocean** - Calming blue tones
18. **Sunset** - Warm orange and pink
19. **Berry** - Rich purple and pink
20. **Vibrant** - High-energy colors

### **Technical Themes**
21. **Monochrome** - Black and white only
22. **Paper** - Print-like appearance
23. **Sepia** - Warm vintage tones

## 📖 Usage Guide

### Basic Usage

```r
# Using built-in themes
launch_study(config, theme = "Professional")
launch_study(config, theme = "Dyslexia-Friendly")
launch_study(config, theme = "Midnight")

# Using custom theme configuration
custom_theme <- list(
  colors = list(
    primary = "#2C3E50",
    background = "#FFFFFF",
    text = "#2C3E50"
  ),
  fonts = list(
    heading = "Georgia, serif",
    body = "Georgia, serif"
  )
)
launch_study(config, theme = custom_theme)
```

### Advanced Theme Configuration

```r
# Comprehensive theme configuration
theme_config <- list(
  colors = list(
    primary = "#667eea",
    secondary = "#764ba2",
    success = "#48bb78",
    info = "#4299e1",
    warning = "#ed8936",
    danger = "#f56565",
    background = "#f7fafc",
    surface = "#ffffff",
    text = "#2d3748",
    text_secondary = "#718096",
    border = "#e2e8f0"
  ),
  fonts = list(
    heading = "'Inter', system-ui, sans-serif",
    body = "'Inter', system-ui, sans-serif",
    mono = "'SF Mono', Monaco, monospace"
  ),
  borders = list(
    radius = "12px",
    width = "2px"
  )
)

launch_study(config, theme_config = theme_config)
```

## 🎯 CSS Variable Reference

### Color Variables
```css
/* Primary Colors */
--primary-color: #007bff;
--secondary-color: #6c757d;
--accent-color: #6f42c1;

/* Status Colors */
--success-color: #28a745;
--info-color: #17a2b8;
--warning-color: #ffc107;
--danger-color: #dc3545;

/* Background Colors */
--background-color: #ffffff;
--surface-color: #f8f9fa;
--background-secondary: #f8f9fa;
--background-tertiary: #e9ecef;

/* Text Colors */
--text-color: #212529;
--text-secondary: #6c757d;
--text-inverse: #ffffff;

/* Legacy Support */
--color-primary: #007bff;
--color-background: #ffffff;
--color-text: #212529;
```

### Typography Variables
```css
/* Font Families */
--font-heading: system-ui, sans-serif;
--font-body: system-ui, sans-serif;
--font-mono: monospace;

/* Font Sizes */
--font-size-base: 1rem;
--font-size-lg: 1.125rem;
--font-size-xl: 1.25rem;
--font-size-2xl: 1.5rem;

/* Font Weights */
--font-weight-normal: 400;
--font-weight-medium: 500;
--font-weight-bold: 700;

/* Line Heights */
--line-height-normal: 1.5;
--line-height-relaxed: 1.625;
```

### Layout Variables
```css
/* Spacing */
--spacing-sm: 0.5rem;
--spacing-md: 1rem;
--spacing-lg: 1.5rem;
--spacing-xl: 2rem;

/* Border */
--border-radius: 8px;
--border-width: 1px;
--border-style: solid;

/* Shadows */
--shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
--shadow-md: 0 4px 6px rgba(0,0,0,0.1);
--shadow-lg: 0 10px 20px rgba(0,0,0,0.15);

/* Transitions */
--transition-fast: 0.15s ease;
--transition-normal: 0.3s ease;
```

## 🔧 Theme Editor Usage

### Accessing the Theme Editor
```r
# Launch the theme editor
launch_theme_editor()
```

### Creating Custom Themes
1. Select a base theme from the theme selector
2. Adjust colors using the color pickers
3. Modify typography and layout settings
4. Preview changes in real-time
5. Export CSS or JSON configuration

### Export Options
- **Copy CSS**: Copy generated CSS to clipboard
- **Download CSS**: Save as `.css` file
- **Export JSON**: Save configuration as `.json` file

## ♿ Accessibility Features

### WCAG 2.1 AA Compliance
- ✅ **Color Contrast**: All themes meet 4.5:1 contrast ratio
- ✅ **Focus Indicators**: Clear, visible focus states
- ✅ **Keyboard Navigation**: Full keyboard accessibility
- ✅ **Screen Reader Support**: Semantic HTML and ARIA labels

### Specialized Accessibility
- **Dyslexia-Friendly**: OpenDyslexic font, enhanced spacing
- **High-Contrast**: Maximum contrast ratios
- **Colorblind-Safe**: Distinguishable colors without hue dependency
- **Large-Text**: Increased font sizes for readability

### Responsive Design
- **Mobile-First**: Optimized for mobile devices
- **Flexible Layout**: Adapts to all screen sizes
- **Touch-Friendly**: Minimum 44px touch targets

## 🖨️ Print Optimization

All themes include print-specific styling:
- Clean, distraction-free layouts
- Optimized typography for paper
- Hidden interactive elements
- Page break management

## 🔄 Theme Inheritance

Themes automatically inherit from base styles while providing customization:

```css
/* Base theme provides defaults */
body {
  font-family: var(--font-body);
  background: var(--background-color);
  color: var(--text-color);
}

/* Individual themes override specific variables */
[data-theme="dark"] {
  --background-color: #121212;
  --text-color: #ffffff;
}
```

## 🚀 Performance Features

### Optimized Loading
- **CSS Variables**: Efficient theme switching
- **Minimal Reflows**: Hardware-accelerated transitions
- **Font Loading**: Optimized web font delivery

### Memory Efficient
- **Shared Components**: Common styles across themes
- **Lazy Loading**: Theme resources loaded on demand
- **Caching**: Browser caching of theme assets

## 📱 Responsive Breakpoints

```css
/* Mobile First Approach */
@media (max-width: 480px) { /* Small phones */ }
@media (max-width: 768px) { /* Tablets */ }
@media (max-width: 1024px) { /* Small desktops */ }
@media (min-width: 1025px) { /* Large desktops */ }
```

## 🎛️ Customization Examples

### Corporate Branding
```css
[data-theme="corporate"] {
  --primary-color: #1B365D;
  --secondary-color: #4A6FA5;
  --font-heading: 'Your Brand Font', sans-serif;
}
```

### University Theme
```css
[data-theme="university"] {
  --primary-color: #003560;
  --accent-color: #0066A1;
  --background-color: #F5F5F5;
}
```

### High-Contrast Mode
```css
@media (prefers-contrast: high) {
  --primary-color: #0000ff;
  --background-color: #ffffff;
  --text-color: #000000;
  --border-width: 3px;
}
```

## 🔍 Troubleshooting

### Common Issues

**Theme not loading**: Ensure theme name matches exactly (case-sensitive)

**Variables not working**: Check for CSS parsing errors in browser console

**Mobile issues**: Verify responsive breakpoints are working

### Debug Mode
Enable debug logging to see theme loading information:
```r
options(inrep.debug = TRUE)
launch_study(config, theme = "Custom")
```

## 📚 API Reference

### Functions

- `get_theme_config(theme_name)` - Get theme configuration
- `get_theme_css(theme, custom_css, theme_config)` - Load theme CSS
- `generate_theme_css(theme_name)` - Generate CSS from theme
- `launch_theme_editor()` - Open theme customization interface

### Parameters

- `theme`: String name or configuration list
- `custom_css`: Additional CSS string
- `theme_config`: Named list of theme parameters

## 🤝 Contributing

To add new themes:

1. Create CSS file in `inst/themes/`
2. Follow the variable naming convention
3. Include comprehensive styling
4. Add documentation comments
5. Test accessibility compliance

## 📄 License

The theme system is part of the inrep package and follows the same license terms.

---

**Last Updated**: October 2024
**Version**: 1.0.0
**Compatibility**: R 4.0+, Shiny 1.7+




