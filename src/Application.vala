class NewsApp : Gtk.Application {
    public NewsApp () {
        Object (
            application_id: "com.github.allen-b1.news",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    protected override void open(File[] files, string hint) {
        var window = this.get_active_window();
        if(window == null || !(window is MainWindow)) {
            window = new MainWindow(this);
            this.add_window(window);
        }

        foreach (var file in files) {
            try {
                ((MainWindow)window).add_feed(new RssFeed.from_file(file));
            } catch(Error err) {
                stderr.puts("Could not open file\n");
                ((MainWindow)window).show_error("Could not open file");
            }
            window.accept_focus = true;
        }
    }

    protected override void activate() {
        var window = new MainWindow(this);
        this.add_window(window);
        window.show_all();
    }

    public static int main (string[] args) {
        return new NewsApp().run(args);
    }
}
