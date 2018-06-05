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

        var notebook = new NewsNotebook();
        notebook.add_feed(new RssFeed.from_uri("https://news.google.com/news/rss/?ned=us&gl=US&hl=e"));
        notebook.add_feed(new RssFeed.from_uri("https://news.ycombinator.com/rss"));


        window.add(notebook);

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
