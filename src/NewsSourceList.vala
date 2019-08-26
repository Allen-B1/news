class NewsSourceList : Gtk.Box {
	public signal void feed_selected(Feed feed);
	public signal void feed_removed(Feed feed);
	public signal void feed_added();

	private Granite.Widgets.SourceList sourcelist;
	private Gtk.Toolbar toolbar;
	private HashTable<Granite.Widgets.SourceList.Item, Feed> sources;

	public NewsSourceList() {
		this.orientation = Gtk.Orientation.VERTICAL;

		this.sourcelist = new Granite.Widgets.SourceList();
		this.sourcelist.set_size_request(150, 0);
		this.sources = new HashTable<Granite.Widgets.SourceList.Item, Feed>(
			(a) => { return str_hash(a.name); },
			(a, b) => { return a == b; }
		);

		this.sourcelist.item_selected.connect((item) => {
			if (item == null) return;
			var feed = sources[item];
			if (feed != null)
				this.feed_selected(feed);
		});

		this.toolbar = new Gtk.Toolbar();
		var addbtn = new Gtk.ToolButton(null, _("Add"));
		addbtn.icon_name = "list-add-symbolic";
		var rbtn = new Gtk.ToolButton(null, _("Remove"));
		rbtn.icon_name = "list-remove-symbolic";
		this.toolbar.insert(addbtn, 1);
		this.toolbar.insert(rbtn, 1);

		addbtn.clicked.connect(() => {
			this.feed_added();
		});
		rbtn.clicked.connect(() => {
			this.feed_removed(this.active_feed);
			this.sourcelist.root.remove(this.sourcelist.selected);
		});

		this.pack_start(this.sourcelist, true, true);
		this.pack_end(this.toolbar, false, false);
	}

	public void add_feed(Feed feed) {
		var item = new Granite.Widgets.SourceList.Item(feed.title);
		this.sources[item] = feed;
		this.sourcelist.root.add(item);
		this.sourcelist.selected = item;
	}

	public Feed? active_feed {
		get {
			return this.sources[this.sourcelist.selected];
		}
	}
}
