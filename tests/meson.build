test_deps = [dependency('glib-2.0'), dependency('gobject-2.0'), dependency('gio-2.0'),
             dependency('taglib_c'), meson.get_compiler('vala').find_library('posix')]

tag_roundtrip = executable('tag-roundtrip',
  ['tag-roundtrip.vala', core_sources],
  dependencies: test_deps,
  include_directories: core_inc,
)
test('tag-roundtrip', tag_roundtrip)
