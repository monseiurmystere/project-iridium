desktop_file = configure_file(
  input: 'co.tylr.Iridium.desktop.in',
  output: 'co.tylr.Iridium.desktop',
  copy: true,
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

install_data('co.tylr.Iridium.metainfo.xml',
  install_dir: get_option('datadir') / 'metainfo')

install_data('icons/co.tylr.Iridium.svg',
  install_dir: get_option('datadir') / 'icons/hicolor/scalable/apps')

desktop_validate = find_program('desktop-file-validate', required: false)
if desktop_validate.found()
  test('validate-desktop', desktop_validate, args: [desktop_file])
endif

appstream_util = find_program('appstreamcli', required: false)
if appstream_util.found()
  # Only hard errors fail the test; warnings (e.g. missing homepage URL) do not.
  test('validate-metainfo', find_program('sh'),
    args: ['-c', '! appstreamcli validate --no-net "$0" | grep -q "^E:"',
           files('co.tylr.Iridium.metainfo.xml')])
endif

# about.json must parse and carry the required About dialog strings.
test('validate-about-json', find_program('python3'),
  args: ['-c',
         'import json,sys; d = json.load(open(sys.argv[1]));\n' +
         'assert all(isinstance(d[k], str) and d[k] for k in\n' +
         '         ["application-name", "developer-name", "comments"]), "missing key"',
         files('about.json')])
