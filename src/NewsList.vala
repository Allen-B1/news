class NewsList : Gtk.ScrolledWindow {
    public Feed feed;

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
            title.set_markup("<b>" + Markup.escape_text(item.title) + "</b>");

            // Align to start
            title.set_line_wrap(true);
            title.halign = Gtk.Align.START;
            title.xalign = 0;
            title.justify = Gtk.Justification.LEFT;

            box.pack_start(title, false, false, 0);

            if(item.pubDate != null) {
                var pub_date_label = new Gtk.Label(item.pubDate);
                pub_date_label.halign = Gtk.Align.START;
                pub_date_label.xalign = 0;
                pub_date_label.ellipsize = Pango.EllipsizeMode.END;
                box.pack_end(pub_date_label, false, false, 0);
            }

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
