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

        var headerbar = new NewsHeaderBar();
        window.set_titlebar(headerbar);

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        window.add(box);

        var notebook = new NewsNotebook();
        notebook.error.connect(() => {
            var info_bar = new Gtk.InfoBar();
            info_bar.set_message_type(Gtk.MessageType.ERROR);
            info_bar.get_content_area().add(new Gtk.Label("Something went wrong."));
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
                window.close();
            }
        });

        headerbar.search.connect((query) => {
            notebook.add_gnews(query);
        });

        box.add(notebook);

        // Contestual stylesheet
        string STYLESHEET = """
            @define-color colorPrimary #f20050;
            @define-color textColorPrimary #fafafa;
            @define-color colorAccent #68b723;""";
        var provider = new Gtk.CssProvider();
        provider.load_from_data(STYLESHEET, -1);
        Gtk.StyleContext.add_provider_for_screen(window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        window.show_all();
    }

    public static int main (string[] args) {
        return new NewsApp().run(args);
    }
}
