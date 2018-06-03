void show_about_dialog() {
    Granite.Widgets.AboutDialog dialog = new Granite.Widgets.AboutDialog();
	dialog.program_name = "News";
    dialog.title = dialog.program_name;
	dialog.artists = {"mirkobromin"};
	dialog.authors = {"Allen B"};
	dialog.comments = "View the news easily & quickly";
	dialog.website = dialog.help = "https://github.com/Allen-B1/news/";
    dialog.bug = "https://github.com/Allen-B1/news/issues";    
	dialog.website_label = "Website";		
	dialog.run();
	dialog.destroy();
}

static Gtk.Window window;
static Granite.Widgets.DynamicNotebook notebook;

int main (string[] args) {
    stdout.printf("%d\n", args.length);
    stdout.printf("%s\n", args[0]);

    Gtk.init(ref args);

    if(args.length >= 2) {
        show_about_dialog();
        Process.exit(0);
    } else {
        window = new Gtk.Window();
        window.title = "News";
        window.set_default_size(950, 950);
        window.destroy.connect(Gtk.main_quit);

        window.set_titlebar(new NewsHeaderBar(window, notebook));
        window.add(new NewsPanel.from_feed(new GoogleNewsFeed()));

        // Contestual stylesheet
        string STYLESHEET = """
            @define-color colorPrimary #ff8c82;""";
        var provider = new Gtk.CssProvider();
        provider.load_from_data(STYLESHEET, -1);
        Gtk.StyleContext.add_provider_for_screen(window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        window.show_all();

        window.resize(950, 950);
    }
    Gtk.main();

    return 0;
}
