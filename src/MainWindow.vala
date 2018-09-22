class MainWindow : Gtk.ApplicationWindow {
    const string STYLESHEET = """
        @define-color colorPrimary #f20050;
        @define-color textColorPrimary #fafafa;
        @define-color colorAccent #68b723;""";

    private NewsNotebook notebook;
    private Granite.Widgets.Toast errortoast;

    public MainWindow(Gtk.Application app) {
        Object (application: app,
            title: "News");
    }

    public void show_error(string msg = "Something went wrong") {
        this.errortoast.title = msg;
        this.errortoast.send_notification();
    }

    construct {
        this.default_width = 900;
        this.default_height = 700;

        var headerbar = new NewsHeaderBar();
        this.set_titlebar(headerbar);

        var box = new Gtk.Overlay();
        this.add(box);

        this.errortoast = new Granite.Widgets.Toast("Something went wrong");
        box.add_overlay(errortoast);

        this.notebook = new NewsNotebook();
        box.add_overlay(notebook);

        this.notebook.error.connect((error) => {
            this.show_error(error == null ? "Something went wrong" : error.message);
        });

        this.notebook.tab_removed.connect(() => {
            if(this.notebook.n_tabs == 0) {
                this.close();
            }
        });

        headerbar.search.connect((query) => {
            this.notebook.add_gnews(query);
        });

	    try {
		    this.notebook.add_feed(new GoogleNewsFeed());
	        this.notebook.add_feed(new RssFeed.from_uri("https://news.ycombinator.com/rss"));
	    } catch(Error err) {
	        this.show_error();
		}

        var provider = new Gtk.CssProvider();
        provider.load_from_data(STYLESHEET, -1);
        Gtk.StyleContext.add_provider_for_screen(this.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Ctrl+F shortcut
        var accel_group = new Gtk.AccelGroup();
        accel_group.connect(Gdk.Key.f,  Gdk.ModifierType.CONTROL_MASK,  Gtk.AccelFlags.VISIBLE,  () => {
            headerbar.focus_search();
            return true;
        });
        this.add_accel_group(accel_group);
    }

    public void add_feed(Feed feed) {
        this.notebook.add_feed(feed);
    }
}
