/* File: inst/theme_editor/editor.js */
document.addEventListener('DOMContentLoaded', () => {
  const editor = ace.edit('css_output', {
    mode: 'ace/mode/css',
    theme: 'ace/theme/monokai',
    readOnly: true,
    fontSize: 14
  });

  const defaultTheme = {
    primary_color: '#212529',
    secondary_color: '#343a40',
    background_color: '#f8f9fa',
    text_color: '#212529',
    accent_color: '#495057',
    error_color: '#dc3545',
    success_color: '#28a745',
    border_color: '#dee2e6',
    hover_color: '#f1f3f5',
    active_color: '#e9ecef',
    font_family: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
    font_size_base: '1rem',
    font_size_large: '1.2rem',
    font_size_small: '0.9rem',
    border_radius: '8px',
    shadow: '0 4px 12px rgba(0, 0, 0, 0.05)',
    container_width: '900px',
    card_padding: '2rem',
    button_padding: '0.75rem 2rem',
    progress_bg_color: '#dee2e6'
  };

  // Populate form with default values
  Object.keys(defaultTheme).forEach(key => {
    const input = document.getElementById(key);
    if (input && input.type === 'color') {
      input.value = defaultTheme[key];
    } else if (input) {
      input.value = defaultTheme[key];
    }
  });

  function updatePreviewAndCSS() {
    const theme = {
      primary_color: document.getElementById('primary_color').value,
      secondary_color: document.getElementById('secondary_color').value,
      background_color: document.getElementById('background_color').value,
      text_color: document.getElementById('text_color').value,
      accent_color: defaultTheme.accent_color,
      error_color: defaultTheme.error_color,
      success_color: defaultTheme.success_color,
      border_color: defaultTheme.border_color,
      hover_color: defaultTheme.hover_color,
      active_color: defaultTheme.active_color,
      font_family: document.getElementById('font_family').value,
      font_size_base: document.getElementById('font_size_base').value,
      font_size_large: defaultTheme.font_size_large,
      font_size_small: defaultTheme.font_size_small,
      border_radius: document.getElementById('border_radius').value,
      shadow: defaultTheme.shadow,
      container_width: defaultTheme.container_width,
      card_padding: defaultTheme.card_padding,
      button_padding: defaultTheme.button_padding,
      progress_bg_color: defaultTheme.progress_bg_color
    };

    const css = `
      :root {
        --primary-color: ${theme.primary_color};
        --secondary-color: ${theme.secondary_color};
        --background-color: ${theme.background_color};
        --text-color: ${theme.text_color};
        --accent-color: ${theme.accent_color};
        --error-color: ${theme.error_color};
        --success-color: ${theme.success_color};
        --border-color: ${theme.border_color};
        --hover-color: ${theme.hover_color};
        --active-color: ${theme.active_color};
        --font-family: ${theme.font_family};
        --font-size-base: ${theme.font_size_base};
        --font-size-large: ${theme.font_size_large};
        --font-size-small: ${theme.font_size_small};
        --border-radius: ${theme.border_radius};
        --shadow: ${theme.shadow};
        --container-width: ${theme.container_width};
        --card-padding: ${theme.card_padding};
        --button-padding: ${theme.button_padding};
        --progress-bg-color: ${theme.progress_bg_color};
      }
      body {
        font-family: ${theme.font_family};
        background-color: ${theme.background_color};
        color: ${theme.text_color};
      }
      .section-title {
        font-size: ${theme.font_size_large};
        color: ${theme.text_color};
      }
      .assessment-card {
        background: #ffffff;
        border: 1px solid ${theme.border_color};
        border-radius: ${theme.border_radius};
        padding: ${theme.card_padding};
        box-shadow: ${theme.shadow};
      }
      .btn-klee {
        background: ${theme.primary_color};
        color: #ffffff;
        padding: ${theme.button_padding};
        border-radius: ${theme.border_radius};
      }
      .btn-klee:hover {
        background: ${theme.secondary_color};
      }
    `;
    editor.setValue(css.trim());

    const preview = document.getElementById('preview');
    preview.style.backgroundColor = theme.background_color;
    preview.style.color = theme.text_color;
    preview.style.fontFamily = theme.font_family;
    preview.querySelector('.section-title').style.color = theme.text_color;
    preview.querySelector('.assessment-card').style.borderColor = theme.border_color;
    preview.querySelector('.assessment-card').style.borderRadius = theme.border_radius;
    preview.querySelector('.assessment-card').style.padding = theme.card_padding;
    preview.querySelector('.assessment-card').style.boxShadow = theme.shadow;
    preview.querySelector('.btn-klee').style.backgroundColor = theme.primary_color;
    preview.querySelector('.btn-klee').style.padding = theme.button_padding;
    preview.querySelector('.btn-klee').style.borderRadius = theme.border_radius;
  }

  document.getElementById('apply_theme').addEventListener('click', updatePreviewAndCSS);

  document.getElementById('export_json').addEventListener('click', () => {
    const theme = {
      primary_color: document.getElementById('primary_color').value,
      secondary_color: document.getElementById('secondary_color').value,
      background_color: document.getElementById('background_color').value,
      text_color: document.getElementById('text_color').value,
      font_family: document.getElementById('font_family').value,
      font_size_base: document.getElementById('font_size_base').value,
      border_radius: document.getElementById('border_radius').value
    };
    const blob = new Blob([JSON.stringify(theme, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'theme_config.json';
    a.click();
    URL.revokeObjectURL(url);
  });

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

  // Initial preview
  updatePreviewAndCSS();
});