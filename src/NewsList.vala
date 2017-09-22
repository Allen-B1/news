class NewsList : Gtk.ScrolledWindow {
    public RssFeed feed;
    private string[] contents;
    private string url;

	public NewsList(RssFeed feed) {
        this.feed = feed;
        var list = new Gtk.ListBox();
       
        foreach(var item in feed.items) {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 12;

            // Title
            var title = new Gtk.LinkButton.with_label(item.link, item.title);
            box.add(title);

            if(item.about != null) {
                // Description
                var desc = new Gtk.Label(null);
                desc.set_markup(item.about);
                desc.set_line_wrap (true);
                desc.override_background_color(Gtk.StateFlags.NORMAL, {0,0,0,0});
                box.add(desc);
            }

            list.add(box);
        }

        this.add(list);
        this.show_all();
    }
}
