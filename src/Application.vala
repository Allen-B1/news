class NewsApp : Gtk.Application { 
	public NewsApp () {
		Object (
			application_id: "com.github.allen-b1.news",
			flags: ApplicationFlags.HANDLES_OPEN
		);
	}

	private SourceKeeper sources;
	construct {
		this.sources = new SourceKeeper();
	}

	private void add_sources(MainWindow window) {
		foreach (var url in this.sources.list()) {
			try {
				window.add_feed(new XmlFeed(url));
			} catch(FeedError err) {
				window.show_error("Couldn't load '" + url + "'");
			}
		}
	}

	private void init_window(MainWindow window) {
		window.source_add.connect((source) => {
			this.sources.add(source);
		});
		window.source_remove.connect((source) => {
			this.sources.remove(source);
		});

		this.add_sources(window);
	}

	protected override void open(File[] files, string hint) {
		var window = this.get_active_window();
		if(window == null || !(window is MainWindow)) {
			window = new MainWindow(this);
			this.add_window(window);
			window.show_all();
		}

		this.init_window((MainWindow)window);

		foreach (var file in files) {
			try {
				((MainWindow)window).add_feed(new XmlFeed.from_file(file));
			} catch(FeedError err) {
				stderr.puts("Could not open file: " + file.get_basename() + "\n");
				((MainWindow)window).show_error("Could not open file: " + file.get_basename());
			}
		}
		window.present();
	}

	protected override void activate() {
		var window = new MainWindow(this);
		this.add_window(window);
		this.init_window(window);
		window.show_all();

		var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = (
            granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
        );

        granite_settings.notify["prefers-color-scheme"].connect (() => {
	        gtk_settings.gtk_application_prefer_dark_theme = (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
            );
        });
	}

	public static int main (string[] args) {
		return new NewsApp().run(args);
	}
}
