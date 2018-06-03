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
        window.add(new NewsPanel.from_feed(new GoogleNewsFeed()));

        // Contestual stylesheet
        string STYLESHEET = """
            @define-color colorPrimary #c6262e;
            @define-color textColorPrimary #fafafa;""";
        var provider = new Gtk.CssProvider();
        provider.load_from_data(STYLESHEET, -1);
        Gtk.StyleContext.add_provider_for_screen(window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        window.show_all();
    }

    private static void show_about_dialog() {
        Granite.Widgets.AboutDialog dialog = new Granite.Widgets.AboutDialog();
	    dialog.program_name = "News";
        dialog.title = "About " + dialog.program_name;
	    dialog.artists = {"mirkobromin"};
	    dialog.authors = {"Allen B"};
	    dialog.comments = "View the news easily & quickly";
	    dialog.website = "https://github.com/Allen-B1/news/";
        dialog.help = "https://github.com/Allen-B1/news/issues";
        dialog.bug = "https://github.com/Allen-B1/news/issues/new";
	    dialog.website_label = "Website";		
	    dialog.run();
	    dialog.destroy();
    }

    public static int main (string[] args) {
        if("--about" in args) {
            Gtk.init(ref args);
            show_about_dialog();
            return 0;
        } else {
            var app = new NewsApp();
            return app.run(args);
        }
    }
}
