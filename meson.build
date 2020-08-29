project('ControlsForFake-gtk',
		'vala',
		'c',
		license: 'MIT')

subdir('po')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')
add_project_arguments(['-DGETTEXT_PACKAGE="'+meson.project_name()+'"'], language: 'c')

gnome = import('gnome')

glade_resources = gnome.compile_resources(
    'glade-resources', 'glade.gresource.xml',
    source_dir: '.',
    c_name: 'as'
)

cc = meson.get_compiler('c')
dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gtk+-3.0'),
  dependency('threads'),
  dependency('cfake'),
  dependency('gee-0.8'),
  cc.find_library('m', required : false)
]


sources =  [
  'main.vala',
  'Application.vala',
  'Animation.vala',
  'PulseAudioComboBoxHandler.vala',
  'SinkComboBoxHandler.vala',
  'SinkInputComboBoxHandler.vala',
  'SourceComboBoxHandler.vala',
  'SourceOutputComboBoxHandler.vala',
  'SubscribeAndListenThread.vala',
  'vapi/config.vapi'
]

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('GETTEXT_LOCALES_DIR', get_option('prefix')+'/'+get_option('localedir'))
configure_file(output: 'config.h', configuration: conf)

executable('ControlsForFake-gtk', sources,
  glade_resources,
  dependencies: dependencies,
  export_dynamic: true,
  install: true)
