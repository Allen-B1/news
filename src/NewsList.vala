/* Shows all entries of a Feed in a vertical list. */
class NewsList : Gtk.ScrolledWindow {
	private Gtk.ListBox list;
	private Feed _feed;
	public Feed feed {
		get {
			return _feed;
		}
		set {
			_feed = value;

			this.list.foreach((item) => {
				this.list.remove(item);
			});

			for (var i = 0; i < _feed.items.length; i++) {
				var item = _feed.items[i];
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
					var pub_date_label = new Gtk.Label(Granite.DateTime.get_relative_datetime(item.pubDate));
					pub_date_label.halign = Gtk.Align.START;
					pub_date_label.xalign = 0;
					pub_date_label.ellipsize = Pango.EllipsizeMode.END;
					box.pack_end(pub_date_label, false, false, 0);
				}

				this.list.add(box);
			}
			this.list.show_all();
		}
	}

	public signal void item_selected(FeedItem item);

	public NewsList() {
		this.vexpand = true;

		// disable horizontal scrollbar
		this.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

		this.list = new Gtk.ListBox();
		this.list.set_size_request(0,0);
		this.add(this.list);

		list.row_selected.connect((row) => {
			if(row != null) {
				this.item_selected(this.feed.items[row.get_index()]);
			}
		});
	}
}
