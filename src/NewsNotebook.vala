
class NewsNotebook : Granite.Widgets.DynamicNotebook {
	construct {
		this.new_tab_requested.connect(() => {
			/* Show 'Add RSS Feed' dialog */
			var dialog = new Granite.MessageDialog.with_image_from_icon_name("Add RSS feed",  "Enter the RSS feed url", "dialog-question", Gtk.ButtonsType.NONE);

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
						add_feed(new RssFeed.from_uri(text));
					} catch(Error err) {
						this.error();
					}
					break;
				case Gtk.ResponseType.CANCEL:
					break;
			}
		});
	}

	// thrown when on new_tab_requested the new feed fails
	public signal void error();

	[Description(nick="adds feed", blurb="Adds a tab with the given feed and sets it as the current tab")]
	public Granite.Widgets.Tab add_feed(Feed feed) {
		var tab = new Granite.Widgets.Tab(feed.title, null, new NewsPanel.from_feed(feed));
		this.insert_tab(tab, -1);
		if(feed is RssFeed) {
			tab.restore_data = ((RssFeed)feed).source;
		}
		this.current = tab;
		return tab;
	}

	public Granite.Widgets.Tab? add_gnews(string query) {
		try {
			return this.add_feed(new GoogleNewsFeed.with_search(query));
		} catch(Error err) {
			this.error();
			return null;
		}
	}
}
