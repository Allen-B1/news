project('com.github.allen-b1.news', 'vala', 'c')

executable(
	meson.project_name(),
	'src/Application.vala',
	'src/MainWindow.vala',
	'src/NewsHeaderBar.vala',
	'src/NewsList.vala',
	'src/NewsPanel.vala',
	'src/NewsParse.vala',
	'src/NewsNotebook.vala',
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

install_data(
	'data/' + meson.project_name() + '.desktop',
	install_dir: join_paths(get_option('datadir'), 'applications'))

install_data(
	'data/' + meson.project_name() + '.appdata.xml',
	install_dir: join_paths(get_option('datadir'), 'metainfo'))

install_data(
	'data/' +  meson.project_name() + '.svg',
	install_dir: join_paths(get_option('datadir'), 'icons/hicolor/128x128/apps'))
