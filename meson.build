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
subdir('tests')
subdir('po')

# Lint tools are optional: tests are skipped when a tool is absent.
# vala-lint covers all hand-written Vala; clang-tidy covers hand-written C
# in src/c only (never valac-generated C).
vala_lint = find_program('io.elementary.vala-lint', required: false)
if vala_lint.found()
  test('lint-vala', vala_lint,
    args: [meson.project_source_root() / 'src',
           meson.project_source_root() / 'tests'])
endif

clang_tidy = find_program('clang-tidy', required: false)
if clang_tidy.found()
  test('lint-c', clang_tidy,
    args: [meson.project_source_root() / 'src/c/taglib-picture.c',
           '-p', meson.project_build_root()])
endif

run_target('lint',
  command: [find_program('sh'), '-c',
    'v="$1"; t="$2"; r="$3"; b="$4";'
    + ' [ -x "$v" ] && "$v" "$r/src" "$r/tests" || echo "skip: vala-lint not installed";'
    + ' [ -x "$t" ] && "$t" "$r/src/c/taglib-picture.c" -p "$b" || echo "skip: clang-tidy not installed";',
    'lint-shim',
    vala_lint.found() ? vala_lint.full_path() : 'missing-vala-lint',
    clang_tidy.found() ? clang_tidy.full_path() : 'missing-clang-tidy',
    meson.project_source_root(), meson.project_build_root()])
