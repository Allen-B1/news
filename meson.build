project('com.github.allen-b1.news',
		'vala', 'c',
		version: '1.3.0'
)

i18n = import('i18n')

add_global_arguments(
	'-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),
	language:'c'
)

executable(
	meson.project_name(),
	'src/Application.vala',
	'src/MainWindow.vala',
	'src/NewsHeaderBar.vala',
	'src/NewsList.vala',
	'src/NewsPanel.vala',
	'src/Feed.vala',
	'src/NewsSourceList.vala',
	'src/rfc822.vala',
    'src/Sources.vala',
	dependencies: [
		dependency('gtk+-3.0'),
		dependency('webkit2gtk-4.0'),
    	dependency('granite'),
    	dependency('libxml-2.0'),
		dependency('gee-0.8')
	],
	install: true
)

subdir('data')
subdir('po')
