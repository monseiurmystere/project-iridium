config_vala = configure_file(
  input: 'config.vala.in',
  output: 'config.vala',
  configuration: {'VERSION': meson.project_version()},
)

# Framework-free code: shared with the unit tests (see tests/meson.build).
core_inc = include_directories('c')

core_sources = files(
  'c/taglib-picture.c',
  'vapi/iridium-taglib.vapi',
  'models/cover-art.vala',
  'models/audio-tag.vala',
  'models/audio-file.vala',
  'services/app-logger.vala',
  'services/tag-error.vala',
  'services/tag-reader.vala',
  'services/tag-writer.vala',
  'services/cover-art-service.vala',
  'services/file-scanner.vala',
)

ui_sources = files(
  'main.vala',
  'application.vala',
  'dialogs/about-dialog.vala',
  'dialogs/open-dialogs.vala',
  'widgets/tag-field-row.vala',
  'widgets/cover-art-widget.vala',
  'views/iridium-window.vala',
  'views/empty-state-view.vala',
  'views/sidebar-view.vala',
  'views/file-list-row.vala',
  'views/tag-editor-view.vala',
  'views/tag-basic-group.vala',
  'views/tag-details-group.vala',
  'views/save-bar.vala',
)

blueprints = custom_target('blueprints',
  input: files(
    'widgets/cover-art-widget.blp',
    'views/iridium-window.blp',
    'views/empty-state-view.blp',
    'views/sidebar-view.blp',
    'views/file-list-row.blp',
    'views/tag-editor-view.blp',
    'views/tag-basic-group.blp',
    'views/tag-details-group.blp',
    'views/save-bar.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'), 'batch-compile',
    '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@',
  ],
)

resources = gnome.compile_resources('iridium-resources',
  'iridium.gresource.xml',
  dependencies: blueprints,
  source_dir: meson.current_build_dir(),
  c_name: 'iridium',
)

iridium_deps = [
  dependency('gtk4', version: '>= 4.12'),
  dependency('libadwaita-1', version: '>= 1.5'),
  dependency('taglib_c'),
  meson.get_compiler('vala').find_library('posix'),
]

executable('iridium',
  core_sources, ui_sources, config_vala, resources,
  dependencies: iridium_deps,
  include_directories: core_inc,
  install: true,
)
