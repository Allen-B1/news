class MainWindow : Gtk.ApplicationWindow {
    const string STYLESHEET = """
        @define-color colorPrimary #f20050;
        @define-color textColorPrimary #fafafa;
        @define-color colorAccent #68b723;""";

    private NewsNotebook notebook;
    private Granite.Widgets.Toast errortoast;

    public signal void source_add(string source);
    public signal void source_remove(string source);

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

        this.notebook = new NewsNotebook();
        box.add_overlay(notebook);

        this.errortoast = new Granite.Widgets.Toast("Something went wrong");
        box.add_overlay(errortoast);

        this.notebook.error.connect((error) => {
            this.show_error(error == null ? "Something went wrong" : error.message);
        });

        this.notebook.tab_removed.connect(() => {
            if(this.notebook.n_tabs == 0) {
                this.close();
            }
        });

        this.notebook.source_add.connect((src) => {
            debug("Added source: " + src);
            this.source_add(src); });
        this.notebook.source_remove.connect((src) => {
            debug("Removed source: " + src);
            this.source_remove(src); });

        headerbar.search.connect((query) => {
            try {
                var feed = Feed.from_uri("https://news.google.com/news/rss/search/section/q/" + query + "?ned=us&gl=US&hl=en");
                this.add_feed(feed);
                this.source_add(feed.source);
            } catch (Error err) {
                this.show_error("Couldn't reach Google News");
            }
        });
        headerbar.view_info_clicked.connect(() => {
            var dialog = new Gtk.Dialog.with_buttons("Feed information", this, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, "Close", Gtk.ResponseType.ACCEPT, null);
            dialog.border_width = 18;
            dialog.get_content_area().spacing = 12;

            var feed = this.notebook.get_active_feed();
            var title = new Granite.HeaderLabel(feed.title);
            dialog.get_content_area().add(title);

            var desc = new Gtk.Label(feed.about == null ? "No description provided." : feed.about);
            desc.use_markup = true;
            desc.set_line_wrap(true);
            desc.halign = Gtk.Align.START;
            desc.xalign = 0;
            desc.justify = Gtk.Justification.LEFT;
            desc.selectable = true;
            dialog.get_content_area().add(desc);

            if(feed.copyright != null) {
                var copyr = new Gtk.Label(feed.copyright);
                copyr.use_markup = true;
                copyr.selectable = true;
                copyr.set_line_wrap(true);
                copyr.halign = Gtk.Align.START;
                copyr.xalign = 0;
                copyr.justify = Gtk.Justification.LEFT;
                dialog.get_content_area().add(copyr);
            }

            if(feed.link != null) {
                var website = new Gtk.LinkButton.with_label(feed.link, "Website");
                dialog.get_content_area().add(website);
            }

            dialog.show_all();
            dialog.run();
            dialog.destroy();
        });

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
