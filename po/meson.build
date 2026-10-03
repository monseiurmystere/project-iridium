langs = ['fr', 'es', 'de']

# Maintainer command: meson compile -C build iridium-pot
# then: for l in fr es de; do msgmerge -U po/$l.po build/po/iridium.pot; done
pot = custom_target('iridium-pot',
  output: 'iridium.pot',
  depends: blueprints,
  command: [find_program('python3'), files('extract-pot.py'),
            meson.project_source_root(), meson.project_build_root() / 'src', '@OUTPUT@'],
  build_by_default: false,
)

# .mo files are compiled at install time (same-named outputs cannot come
# from sibling custom targets).
meson.add_install_script('install-mo.py', get_option('localedir'), langs)

msgfmt = find_program('msgfmt')
foreach lang : langs
  test('po-' + lang, msgfmt, args: ['--check', files(lang + '.po')])
endforeach
