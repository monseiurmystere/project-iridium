project('iridium', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.62.0',
  license: 'GPL-3.0-or-later',
)

app_id = 'co.tylr.Iridium'
resource_prefix = '/co/tylr/Iridium'

i18n = import('i18n')
gnome = import('gnome')

# Vala's _() expands to g_dgettext (GETTEXT_PACKAGE, ...).
add_project_arguments('-DGETTEXT_PACKAGE="iridium"', language: 'c')

subdir('data')
subdir('src')
subdir('po')
subdir('tests')
