errordomain NewsNotebookError {
	ADD_FEED_ERROR
}

class NewsTab : Granite.Widgets.Tab {
	private Feed _feed;
	public Feed feed { get { return _feed; }}
	public NewsTab(Feed feed) {
		base(feed.title, null, new NewsPanel.from_feed(feed));
		this._feed = feed;
	}
}

class NewsNotebook : Granite.Widgets.DynamicNotebook {
	construct {
		this.new_tab_requested.connect(() => {
			/* Show 'Add RSS Feed' dialog */
			var dialog = new Granite.MessageDialog.with_image_from_icon_name("Add feed",  "Enter the Atom or RSS feed url", "dialog-question", Gtk.ButtonsType.NONE);

			dialog.add_button("Cancel", Gtk.ResponseType.CANCEL);
			dialog.add_button("Add", Gtk.ResponseType.OK).get_style_context().add_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);

			/* Create Entry */
			var entry = new Gtk.Entry();
			entry.activate.connect(() => {
			    dialog.response(Gtk.ResponseType.OK);
			});
			entry.margin_start = entry.margin_end = entry.margin_top = 12;
			entry.placeholder_text = "Feed URL";
			dialog.get_content_area().add(entry);
			
			dialog.get_content_area().show_all();

			/* Collect response */
			int result = dialog.run();
			string text = entry.text;
			dialog.destroy();
			switch(result) {
				case Gtk.ResponseType.OK:
					try {
						var feed = Feed.from_uri(text);
						add_feed(feed);
                        this.source_add(feed.source);
					} catch(Error err) {
						this.error(new NewsNotebookError.ADD_FEED_ERROR("Could not fetch feed"));
					}
					break;
				case Gtk.ResponseType.CANCEL:
					break;
			}
		});

		this.tab_removed.connect((tab) => {
			this.source_remove(((NewsTab)tab).feed.source);
		});
	}

	// thrown when on new_tab_requested the new feed fails
	public signal void error(Error? error);

    // called when a source is added via the dialog
    public signal void source_add(string source);
    // called when a source is removed
    public signal void source_remove(string source);

	[Description(nick="adds feed", blurb="Adds a tab with the given feed and sets it as the current tab")]
	public NewsTab add_feed(Feed feed) {
		var tab = new NewsTab(feed);
		this.insert_tab(tab, -1);
		this.current = tab;
		return tab;
	}

	public Feed get_active_feed() {
		return ((NewsTab)this.current).feed;
	}
}
