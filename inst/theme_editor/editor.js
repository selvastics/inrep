/*
 * Enhanced Theme Editor JavaScript
 * Works with the comprehensive theme system
 */

document.addEventListener('DOMContentLoaded', () => {
  // Initialize ACE editor with comprehensive settings
  const editor = ace.edit('css_output', {
    mode: 'ace/mode/css',
    theme: 'ace/theme/monokai',
    fontSize: 14,
    showGutter: true,
    highlightActiveLine: true,
    enableBasicAutocompletion: true,
    enableLiveAutocompletion: true,
    wrap: true,
    autoScrollEditorIntoView: true,
    minLines: 15,
    maxLines: 50
  });

  // Default theme configuration
  const defaultTheme = {
    primary_color: '#007bff',
    secondary_color: '#6c757d',
    background_color: '#ffffff',
    text_color: '#212529',
    accent_color: '#6f42c1',
    error_color: '#dc3545',
    success_color: '#28a745',
    warning_color: '#ffc107',
    info_color: '#17a2b8',
    border_color: '#dee2e6',
    hover_color: '#f8f9fa',
    active_color: '#e9ecef',
    font_family: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
    font_size_base: '1rem',
    font_size_large: '1.25rem',
    font_size_small: '0.875rem',
    border_radius: '8px',
    shadow: '0 4px 12px rgba(0, 0, 0, 0.1)',
    container_width: '1200px',
    card_padding: '2rem',
    button_padding: '0.75rem 1.5rem',
    progress_bg_color: '#e9ecef'
  };

  // Populate form with default values
  Object.keys(defaultTheme).forEach(key => {
    const input = document.getElementById(key);
    if (input) {
      if (input.type === 'color') {
        input.value = defaultTheme[key];
      } else {
        input.value = defaultTheme[key];
      }
    }
  });

  // Generate comprehensive CSS
  function generateThemeCSS(theme) {
    return `:root {
  /* Core Colors */
  --primary-color: ${theme.primary_color};
  --secondary-color: ${theme.secondary_color};
  --success-color: ${theme.success_color};
  --info-color: ${theme.info_color};
  --warning-color: ${theme.warning_color};
  --danger-color: ${theme.error_color};
  --background-color: ${theme.background_color};
  --surface-color: ${theme.hover_color};
  --text-color: ${theme.text_color};
  --text-secondary-color: ${theme.secondary_color};
  --border-color: ${theme.border_color};

  /* Legacy aliases for compatibility */
  --color-primary: ${theme.primary_color};
  --color-secondary: ${theme.secondary_color};
  --color-success: ${theme.success_color};
  --color-info: ${theme.info_color};
  --color-warning: ${theme.warning_color};
  --color-danger: ${theme.error_color};
  --color-background: ${theme.background_color};
  --color-surface: ${theme.hover_color};
  --color-text: ${theme.text_color};
  --color-text-secondary: ${theme.secondary_color};
  --color-border: ${theme.border_color};

  /* Typography */
  --font-heading: ${theme.font_family};
  --font-body: ${theme.font_family};
  --font-mono: 'SF Mono', Monaco, 'Cascadia Code', monospace;

  /* Layout */
  --border-radius: ${theme.border_radius};
  --border-width: 1px;
  --border-style: solid;

  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;

  /* Shadows */
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 20px rgba(0,0,0,0.15);

  /* Transitions */
  --transition-fast: 0.15s ease;
  --transition-normal: 0.3s ease;
  --transition-slow: 0.5s ease;
}

body {
  font-family: var(--font-body);
  background-color: var(--background-color);
  color: var(--text-color);
  margin: 0;
  padding: 0;
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}

.btn, button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--border-radius);
  border-width: var(--border-width);
  font-weight: 500;
  padding: ${theme.button_padding};
  transition: all var(--transition-fast);
  font-size: ${theme.font_size_base};
  font-family: var(--font-body);
  cursor: pointer;
  background: var(--primary-color);
  color: white;
  min-height: 44px;
  box-sizing: border-box;
}

.btn:hover, button:hover {
  background: ${theme.secondary_color};
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.card, .assessment-card {
  background-color: var(--surface-color);
  border: var(--border-width) solid var(--border-color);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow-sm);
  padding: ${theme.card_padding};
  margin-bottom: var(--spacing-lg);
  transition: all var(--transition-fast);
}

.card:hover, .assessment-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}

input, select, textarea {
  width: 100%;
  border: var(--border-width) solid var(--border-color);
  border-radius: var(--border-radius);
  background: var(--background-color);
  color: var(--text-color);
  padding: 0.5rem 0.75rem;
  font-family: var(--font-body);
  font-size: ${theme.font_size_base};
  transition: all var(--transition-fast);
  box-sizing: border-box;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

.question-text {
  font-size: 1.25rem;
  font-weight: 500;
  margin-bottom: 1.5rem;
  line-height: 1.6;
  color: var(--text-color);
}

.response-option, .answer-option {
  border: var(--border-width) solid var(--border-color);
  padding: 1rem;
  margin: 0.5rem 0;
  cursor: pointer;
  transition: all var(--transition-fast);
  background: var(--background-color);
  border-radius: var(--border-radius);
}

.response-option:hover, .answer-option:hover {
  border-color: var(--primary-color);
  background: rgba(0, 123, 255, 0.05);
  transform: translateX(4px);
}

.response-option.selected, .answer-option.selected {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
  transform: translateX(8px);
}

.progress {
  height: 8px;
  background: var(--border-color);
  border-radius: var(--border-radius);
  overflow: hidden;
  margin: 1rem 0;
}

.progress-bar {
  background: var(--primary-color);
  height: 100%;
  border-radius: var(--border-radius);
  transition: width var(--transition-normal);
}

/* Responsive Design */
@media (max-width: 768px) {
  .card, .assessment-card {
    padding: 1rem;
    margin: 0.5rem;
  }

  .btn, button {
    width: 100%;
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
  }

  .question-text {
    font-size: 1.125rem;
  }
}

/* Accessibility */
*:focus {
  outline: 2px solid var(--primary-color);
  outline-offset: 2px;
}

.btn:focus, button:focus {
  outline: 2px solid var(--primary-color);
  outline-offset: 2px;
  box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.2);
}

/* High contrast mode */
@media (prefers-contrast: high) {
  :root {
    --border-width: 2px;
    --primary-color: #0000ff;
    --background-color: #ffffff;
    --text-color: #000000;
    --border-color: #000000;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Print styles */
@media print {
  body {
    background: white !important;
    color: black !important;
  }

  .btn, button {
    display: none !important;
  }

  .card, .assessment-card {
    border: 1px solid black !important;
    box-shadow: none !important;
  }
}`;
  }

  // Update preview and CSS
  function updatePreviewAndCSS() {
    const theme = {
      primary_color: document.getElementById('primary_color')?.value || defaultTheme.primary_color,
      secondary_color: document.getElementById('secondary_color')?.value || defaultTheme.secondary_color,
      background_color: document.getElementById('background_color')?.value || defaultTheme.background_color,
      text_color: document.getElementById('text_color')?.value || defaultTheme.text_color,
      error_color: document.getElementById('error_color')?.value || defaultTheme.error_color,
      success_color: document.getElementById('success_color')?.value || defaultTheme.success_color,
      warning_color: document.getElementById('warning_color')?.value || defaultTheme.warning_color,
      info_color: document.getElementById('info_color')?.value || defaultTheme.info_color,
      border_color: document.getElementById('border_color')?.value || defaultTheme.border_color,
      hover_color: document.getElementById('hover_color')?.value || defaultTheme.hover_color,
      active_color: document.getElementById('active_color')?.value || defaultTheme.active_color,
      font_family: document.getElementById('font_family')?.value || defaultTheme.font_family,
      font_size_base: document.getElementById('font_size_base')?.value || defaultTheme.font_size_base,
      font_size_large: document.getElementById('font_size_large')?.value || defaultTheme.font_size_large,
      font_size_small: document.getElementById('font_size_small')?.value || defaultTheme.font_size_small,
      border_radius: document.getElementById('border_radius')?.value || defaultTheme.border_radius,
      shadow: defaultTheme.shadow,
      container_width: defaultTheme.container_width,
      card_padding: document.getElementById('card_padding')?.value || defaultTheme.card_padding,
      button_padding: document.getElementById('button_padding')?.value || defaultTheme.button_padding,
      progress_bg_color: document.getElementById('progress_bg_color')?.value || defaultTheme.progress_bg_color
    };

    const css = generateThemeCSS(theme);
    editor.setValue(css);

    // Update preview styles
    const preview = document.getElementById('preview');
    if (preview) {
      preview.style.backgroundColor = theme.background_color;
      preview.style.color = theme.text_color;
      preview.style.fontFamily = theme.font_family;

      const title = preview.querySelector('.section-title');
      if (title) title.style.color = theme.text_color;

      const card = preview.querySelector('.assessment-card');
      if (card) {
        card.style.borderColor = theme.border_color;
        card.style.borderRadius = theme.border_radius;
        card.style.padding = theme.card_padding;
        card.style.boxShadow = theme.shadow;
      }

      const button = preview.querySelector('.btn-klee');
      if (button) {
        button.style.backgroundColor = theme.primary_color;
        button.style.padding = theme.button_padding;
        button.style.borderRadius = theme.border_radius;
      }
    }

    // Update CSS variables in real-time
    const root = document.documentElement;
    Object.keys(theme).forEach(key => {
      const cssKey = key.replace(/_/g, '-');
      root.style.setProperty(`--${cssKey}`, theme[key]);
    });
  }

  // Event listeners
  if (document.getElementById('apply_theme')) {
    document.getElementById('apply_theme').addEventListener('click', updatePreviewAndCSS);
  }

  if (document.getElementById('export_json')) {
    document.getElementById('export_json').addEventListener('click', () => {
      const theme = {
        primary_color: document.getElementById('primary_color')?.value || defaultTheme.primary_color,
        secondary_color: document.getElementById('secondary_color')?.value || defaultTheme.secondary_color,
        background_color: document.getElementById('background_color')?.value || defaultTheme.background_color,
        text_color: document.getElementById('text_color')?.value || defaultTheme.text_color,
        font_family: document.getElementById('font_family')?.value || defaultTheme.font_family,
        font_size_base: document.getElementById('font_size_base')?.value || defaultTheme.font_size_base,
        border_radius: document.getElementById('border_radius')?.value || defaultTheme.border_radius
      };
      const blob = new Blob([JSON.stringify(theme, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'theme_config.json';
      a.click();
      URL.revokeObjectURL(url);
    });
  }

  if (document.getElementById('export_css')) {
    document.getElementById('export_css').addEventListener('click', () => {
      const css = editor.getValue();
      const blob = new Blob([css], { type: 'text/css' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'custom_theme.css';
      a.click();
      URL.revokeObjectURL(url);
    });
  }

  // Real-time updates for all form inputs
  document.querySelectorAll('input, select').forEach(input => {
    input.addEventListener('input', updatePreviewAndCSS);
    input.addEventListener('change', updatePreviewAndCSS);
  });

  // Initial preview
  updatePreviewAndCSS();
});