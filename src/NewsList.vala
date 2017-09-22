class NewsList : Gtk.ScrolledWindow {
    public RssFeed feed;
    private string[] links;
    private string url;

	public NewsList(RssFeed feed) {
        this.feed = feed;
        var list = new Gtk.ListBox();
       
        foreach(var item in feed.items) {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 12;

            // Title
            var label = new Gtk.Label(null);
            label.set_markup("<b>" + item.title.replace("&", "&amp;") + "</b>");
            label.set_line_wrap(true);
            box.add(label);

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

        list.row_activated.connect((row) => {
            Pid child_pid = 0;
            if(list.get_selected_row() != null)
                Process.spawn_async("/",
                    {"xdg-open", "goo.gl"},
                    Environ.get(),
                    SpawnFlags.SEARCH_PATH,
                    null,
                    out child_pid
                );   
        });

        this.add(list);
        this.show_all();
    }
}
