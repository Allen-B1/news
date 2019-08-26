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
		try {
			foreach (var url in this.sources.list()) {
				window.add_feed(new XmlFeed(url));
			}
		} catch(Error err) {
			window.show_error("Couldn't load sources");
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
			} catch(Error err) {
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
	}

	public static int main (string[] args) {
		return new NewsApp().run(args);
	}
}
