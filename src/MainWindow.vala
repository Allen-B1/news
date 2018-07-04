class MainWindow : Gtk.ApplicationWindow {
    const string STYLESHEET = """
        @define-color colorPrimary #f20050;
        @define-color textColorPrimary #fafafa;
        @define-color colorAccent #68b723;""";

    private NewsNotebook notebook;

    public MainWindow(Gtk.Application app) {
        Object (application: app,
            title: "News");
    }

    construct {
        this.default_width = 900;
        this.default_height = 700;

        var headerbar = new NewsHeaderBar();
        this.set_titlebar(headerbar);

        var box = new Gtk.Overlay();
        this.add(box);

        this.notebook = new NewsNotebook();
        box.add_overlay(notebook);

        var errortoast = new Granite.Widgets.Toast("Something went wrong");
        box.add_overlay(errortoast);
        this.notebook.error.connect(() => {
            errortoast.send_notification();
            stdout.printf("Log\n");
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
	        this.notebook.error();
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
