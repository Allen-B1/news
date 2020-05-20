class NewsSourceList : Gtk.Box {
	public signal void feed_selected(Feed feed);
	public signal void feed_removed(Feed feed);
	public signal void feed_added();

	private Granite.Widgets.SourceList sourcelist;
	private Gtk.ActionBar toolbar;
	private HashTable<Granite.Widgets.SourceList.Item, Feed> sources;
	private AggregateFeed all_feed;

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

		this.all_feed = new AggregateFeed();
		this.add_feed(this.all_feed);

		this.toolbar = new Gtk.ActionBar();
		var addbtn = new Gtk.Button.from_icon_name("list-add-symbolic", Gtk.IconSize.BUTTON);
		var rbtn = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.BUTTON);
		this.toolbar.pack_start(addbtn);
		this.toolbar.pack_start(rbtn);
		this.toolbar.get_style_context().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

		addbtn.clicked.connect(() => {
			this.feed_added();
		});
		rbtn.clicked.connect(() => {
			if (this.active_feed == this.all_feed) {
				return;
			}
			this.feed_removed(this.active_feed);
			this.sources.remove(this.sourcelist.selected);
			this.sourcelist.root.remove(this.sourcelist.selected);
			for (var i = 0; i < this.all_feed.feeds.length; i++) {
				if (this.active_feed == this.all_feed.feeds[i]) {
				 	Gee.ArrayList<Feed> feeds = new Gee.ArrayList<Feed>.wrap(this.all_feed.feeds);
					feeds.remove_at(i);
					this.all_feed.feeds = feeds.to_array();
					break;
				}
			}
		});

		this.pack_start(this.sourcelist, true, true);
		this.pack_end(this.toolbar, false, false);
	}

	public void add_feed(Feed feed) {
		var item = new Granite.Widgets.SourceList.Item(feed.title);
		this.sources[item] = feed;
		this.sourcelist.root.add(item);
		this.sourcelist.selected = item;

		if (feed != this.all_feed) {
			var feeds = this.all_feed.feeds;
			feeds += feed;
			this.all_feed.feeds = feeds;
		}
	}

	public Feed? active_feed {
		get {
			return this.sources[this.sourcelist.selected];
		}
	}
}
