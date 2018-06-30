class MainWindow : Gtk.ApplicationWindow {
    const string STYLESHEET = """
        @define-color colorPrimary #f20050;
        @define-color textColorPrimary #fafafa;
        @define-color colorAccent #68b723;""";

    public MainWindow(Gtk.Application app) {
        Object (application: app,
            title: "News");
    }

    construct {
        this.default_width = 900;
        this.default_height = 700;

        var headerbar = new NewsHeaderBar();
        this.set_titlebar(headerbar);

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        this.add(box);

        var notebook = new NewsNotebook();
        notebook.error.connect(() => {
            var info_bar = new Gtk.InfoBar();
            info_bar.set_message_type(Gtk.MessageType.ERROR);
            info_bar.get_content_area().add(new Gtk.Label("Something went wrong."));
            if(notebook.n_tabs > 0)
                info_bar.set_show_close_button(true);
            info_bar.response.connect((res) => { 
                if(res == Gtk.ResponseType.CLOSE)
                    info_bar.destroy();
            });
            info_bar.show_all();

            box.add(info_bar);
        });
        notebook.tab_removed.connect(() => {
            if(notebook.n_tabs == 0) {
                this.close();
            }
        });

        headerbar.search.connect((query) => {
            notebook.add_gnews(query);
        });

	    try {
		    notebook.add_feed(new GoogleNewsFeed());
	        notebook.add_feed(new RssFeed.from_uri("https://news.ycombinator.com/rss"));
	    } catch(Error err) {
	        notebook.error();
		}

        box.add(notebook);

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
}
