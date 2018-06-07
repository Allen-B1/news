class NewsApp : Gtk.Application {
    public NewsApp () {
        Object (
            application_id: "com.github.allen-b1.news",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var window = new Gtk.ApplicationWindow(this);
        window.title = "News";
        window.default_width = 900;
        window.default_height = 700;

        window.set_titlebar(new NewsHeaderBar(window));

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        window.add(box);

        var notebook = new NewsNotebook();
        notebook.error.connect(() => {
            var info_bar = new Gtk.InfoBar();
            info_bar.set_message_type(Gtk.MessageType.ERROR);
            info_bar.get_content_area().add(new Gtk.Label("Something went wrong."));
            info_bar.set_show_close_button(true);

            box.add(info_bar);
        });
        try {
            notebook.add_feed(new GoogleNewsFeed());
            notebook.add_feed(new RssFeed.from_uri("https://news.ycombinator.com/rss"));
        } catch(Error err) {
            notebook.error();
        }

        box.add(notebook);


        // Contestual stylesheet
        string STYLESHEET = """
            @define-color colorPrimary #c6262e;
            @define-color textColorPrimary #fafafa;""";
        var provider = new Gtk.CssProvider();
        provider.load_from_data(STYLESHEET, -1);
        Gtk.StyleContext.add_provider_for_screen(window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        window.show_all();
    }

    public static int main (string[] args) {
        var app = new NewsApp();
        return app.run(args);
    }
}
