/* Shows all entries of a Feed in a vertical list. */
class NewsList : Gtk.ScrolledWindow {
	private Gtk.ListBox list;
	private Gtk.ToggleButton?[] comments;

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

			this.comments = new Gtk.ToggleButton[_feed.items.length];

			for (var i = 0; i < _feed.items.length; i++) {
				var item = _feed.items[i];
				var box = new Gtk.Grid();
				box.margin = 12;
				box.hexpand = true;
				box.hexpand_set = true;
				box.column_homogeneous = true;

				// Title
				var title = new Gtk.Label(null);
				title.set_markup("<b>" + Markup.escape_text(item.title).replace("&amp;", "&") + "</b>");

				// Align to start
				title.set_line_wrap(true);
				title.halign = Gtk.Align.START;
				title.xalign = 0;
				title.justify = Gtk.Justification.LEFT;
				title.hexpand = true;

				box.attach(title, 0, 0, 2, 1);

				if(item.pubDate != null) {
					var pub_date_label = new Gtk.Label(Granite.DateTime.get_relative_datetime(item.pubDate));
					pub_date_label.halign = Gtk.Align.START;
					pub_date_label.xalign = 0;
					pub_date_label.ellipsize = Pango.EllipsizeMode.END;
					box.attach(pub_date_label, 0, 1);
				}

				if (item.linkComments != null) {
					var comment = new Gtk.ToggleButton.with_label(_("Comments"));
					comment.toggled.connect(() => {
						if (comment.active) {
							this.item_selected(item.linkComments);
						} else {
							this.item_selected(item.link);
						}
						this.list.select_row((Gtk.ListBoxRow)box.parent);
					});
					comments[i] = comment;
					box.attach(comment, 1, 1);
				}

				this.list.add(box);
			}
			this.list.show_all();
		}
	}

	public signal void item_selected(string url);

	public NewsList() {
		this.vexpand = true;

		// disable horizontal scrollbar
		this.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

		this.list = new Gtk.ListBox();
		this.list.set_size_request(0,0);
		this.add(this.list);

		list.row_selected.connect((row) => {
			if(row != null) {
				if (comments[row.get_index()] == null || !comments[row.get_index()].active) {
					this.item_selected(this.feed.items[row.get_index()].link);
				} else {
					this.item_selected(this.feed.items[row.get_index()].linkComments);
				}
			}
		});
	}
}
