namespace News.Widgets {
	class SourceList : Gtk.Box {
		public signal void feed_selected(Feed feed);
		public signal void feed_removed(Feed feed);
		public signal void feed_added(Feed feed);

		private Granite.Widgets.SourceList sourcelist;
		private Gtk.ActionBar toolbar;
		private HashTable<Granite.Widgets.SourceList.Item, Feed> sources;
		private AggregateFeed all_feed;

		public SourceList() {
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
			toolbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

			var rbtn = new Gtk.Button.from_icon_name("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
			this.toolbar.get_style_context().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

			var addbtn = new Gtk.MenuButton();
			addbtn.image = new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
			addbtn.always_show_image = true;
			addbtn.label = _("Add RSS Feed...");
			addbtn.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

			this.toolbar.pack_start(addbtn);
			this.toolbar.pack_start(rbtn);

			// Add button popover
			var popoverBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
			var popoverEntry = new Gtk.Entry();
			popoverEntry.placeholder_text = _("Feed URL");
			popoverBox.add(popoverEntry);
			var popoverBtn = new Gtk.Button.with_label(_("Add"));
			popoverBox.add(popoverBtn);
			popoverBox.margin = 12;
			var popover = new Gtk.Popover(null);
			popover.add(popoverBox);
			popoverBox.show_all();
			addbtn.popover = popover;

			popoverEntry.changed.connect(() => {
				if (popoverEntry.text.length == 0) {
					popoverEntry.get_style_context().remove_class("error");
				}
			});
			popoverEntry.activate.connect(() => {
				popoverBtn.clicked();
			});
			popoverBtn.clicked.connect(() => {
				try {
					var feed = new XmlFeed(popoverEntry.text);
					this.add_feed(feed);
					this.feed_added(feed);
					popover.popdown();
					popoverEntry.get_style_context().remove_class("error");
					popoverEntry.text = "";
				} catch(FeedError err) {
					warning(err.message);
					popoverEntry.get_style_context().add_class("error");
				}
			});

			rbtn.clicked.connect(() => {
				if (this.active_feed == this.all_feed) {
					return;
				}
				this.remove_feed(this.active_feed);
			});

			this.pack_start(this.sourcelist, true, true);
			this.pack_end(this.toolbar, false, false);
		}

		public void add_feed(Feed feed) {
			var item = new SourceItem(feed);
			item.remove.connect(() => {
				this.remove_feed(feed);
			});
			this.sources[item] = feed;
			this.sourcelist.root.add(item);
			this.sourcelist.selected = item;

			if (feed != this.all_feed) {
				var feeds = this.all_feed.feeds;
				feeds += feed;
				this.all_feed.feeds = feeds;
			}
		}

		private void remove_feed(Feed feed) {
			this.sources.remove(this.sourcelist.selected);
			this.sourcelist.root.remove(this.sourcelist.selected);
			this.feed_removed(feed);
			for (var i = 0; i < this.all_feed.feeds.length; i++) {
				if (feed == this.all_feed.feeds[i]) {
				 	Gee.ArrayList<Feed> feeds = new Gee.ArrayList<Feed>.wrap(this.all_feed.feeds);
					feeds.remove_at(i);
					this.all_feed.feeds = feeds.to_array();
					break;
				}
			}
		}

		public Feed? active_feed {
			get {
				return this.sources[this.sourcelist.selected];
			}
		}
	}

	class SourceItem : Granite.Widgets.SourceList.Item {
		public signal void remove();

		public Feed feed { get; protected set; }

		public SourceItem(Feed feed) {
			base(feed.title);
			this.feed = feed;
		}

		public override Gtk.Menu? get_context_menu() {
			var popup_menu = new Gtk.Menu();
			var item_delete = new Gtk.MenuItem.with_label(_("Remove"));
			var item_about = new Gtk.MenuItem.with_label(_("About"));
			popup_menu.append(item_about);
			item_about.activate.connect(show_about_dialog);
			popup_menu.append(item_delete);
			item_delete.activate.connect(() => {
				this.remove();
			});
			popup_menu.show_all();
			return popup_menu;
		}

		private void show_about_dialog() {
			var dialog = new Gtk.Dialog.with_buttons(_("Feed information"), null, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, _("Close"), Gtk.ResponseType.ACCEPT, null);
			dialog.border_width = 12;
			dialog.get_content_area().spacing = 12;

			var title = new Granite.HeaderLabel(feed.title);
			dialog.get_content_area().add(title);

			if (feed.about != null) {
				var desc = new Gtk.Label(feed.about);
				desc.use_markup = true;
				desc.set_line_wrap(true);
				desc.halign = Gtk.Align.START;
				desc.xalign = 0;
				desc.justify = Gtk.Justification.LEFT;
				desc.selectable = true;
				dialog.get_content_area().add(desc);
			}

			if(feed.copyright != null) {
				var copyr = new Gtk.Label(feed.copyright);
				copyr.use_markup = true;
				copyr.selectable = true;
				copyr.set_line_wrap(true);
				copyr.halign = Gtk.Align.START;
				copyr.xalign = 0;
				copyr.justify = Gtk.Justification.LEFT;
				dialog.get_content_area().add(copyr);
			}

			if(feed.link != null) {
				var website = new Gtk.LinkButton.with_label(feed.link, _("Website"));
				dialog.get_content_area().add(website);
			}

			dialog.show_all();
			dialog.run();
			dialog.destroy();
		}
	}
}
