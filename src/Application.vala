class NewsApp : Gtk.Application {
    public NewsApp () {
        Object (
            application_id: "com.github.allen-b1.news",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var window = new MainWindow(this);
        window.show_all();
    }

    public static int main (string[] args) {
        return new NewsApp().run(args);
    }
}
