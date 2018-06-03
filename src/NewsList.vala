class NewsList : Gtk.ScrolledWindow {
    public Feed feed;
    private string[] contents;

    public signal void item_selected(FeedItem item);

	public NewsList(Feed feed) {
        this.feed = feed;
        this.vexpand = true;

        // disable horizontal scrollbar
        this.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        var list = new Gtk.ListBox();
        list.set_size_request(0,0);

        foreach(var item in feed.items) {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 12;
            box.halign = Gtk.Align.START;

            // Title
            var title = new Gtk.Label(null);
            title.set_markup("<span size=\"large\"><b>" + item.title + "</b></span>");

            // Align to start
            title.halign = Gtk.Align.END;
            title.hexpand = false;
            title.justify = Gtk.Justification.LEFT;
            title.set_line_wrap(true);
 
            box.pack_start(title, false, false, 0);

            list.add(box);
        }

        this.add(list);

        list.row_selected.connect((row) => {
            if(row != null) {
                this.item_selected(this.feed.items[row.get_index()]);
            }
        });
    }
}
