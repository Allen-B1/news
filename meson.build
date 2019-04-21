project('com.github.allen-b1.news', 'vala', 'c')

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/NewsHeaderBar.vala',
    'src/NewsList.vala',
    'src/NewsPanel.vala',
    'src/NewsParse.vala',
    'src/NewsNotebook.vala',
    'src/MainWindow.vala',
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('glib-2.0'),
        dependency('webkit2gtk-4.0'),
        dependency('granite'),
        dependency('libxml-2.0')
    ]
)

install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(
    join_paths('data', meson.project_name() + '.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)
