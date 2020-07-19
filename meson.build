project('ControlsForFake-gtk',
		'cpp',
		'c',
		license: 'MIT',
		default_options: ['cpp_std=c++17'])

subdir('po')

add_global_arguments('-DGETTEXT_LOCALES_DIR="'+get_option('prefix')+'/'+get_option('localedir')+'"', language : 'cpp')

gnome = import('gnome')

glade_resources = gnome.compile_resources(
    'glade-resources', 'glade.gresource.xml',
    source_dir: '.',
    c_name: 'as'
)

gtkmm_dep = dependency('gtkmm-3.0', version: '>= 3.18')

libFakeMicWavPlayer_dep = dependency('fakemicwavplayer', required: true)

inc = include_directories('include')
sources = [ 'main.cpp', 'PulseAudioColumn.cpp', 'SlideAnimation.cpp' ]

executable('ControlsForFake-gtk', sources,
  glade_resources,
  include_directories: inc,
  dependencies: [libFakeMicWavPlayer_dep, gtkmm_dep],
  export_dynamic: true,
  install: true)
