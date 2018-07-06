class NewsApp : Gtk.Application {
    public NewsApp () {
        Object (
            application_id: "com.github.allen-b1.news",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    protected override void open(File[] files, string hint) {
        var window = this.get_active_window();
        if(window is MainWindow) {
            foreach (var file in files) {
                ((MainWindow)window).add_feed(new RssFeed.from_file(file));
                window.accept_focus = true;
            }
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
