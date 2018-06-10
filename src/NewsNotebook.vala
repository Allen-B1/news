
class NewsNotebook : Granite.Widgets.DynamicNotebook {
	construct {
		this.new_tab_requested.connect(() => {
			var dialog = new Gtk.Dialog.with_buttons(null, (this.get_toplevel() is Gtk.Window) ? (Gtk.Window)this.get_toplevel() : null, Gtk.DialogFlags.MODAL, 
					"Add", Gtk.ResponseType.OK,	
					"Cancel", Gtk.ResponseType.CANCEL,
					null);

			dialog.get_content_area().add(new Gtk.Label("Add RSS feed"));

			var entry = new Gtk.Entry();
			entry.activate.connect(() => {
			    dialog.response(Gtk.ResponseType.OK);
			});
			entry.margin_start = entry.margin_end = entry.margin_top = 6;
			entry.placeholder_text = "Feed URL";
			dialog.get_content_area().add(entry);
			
			dialog.get_content_area().show_all();

			int result = dialog.run();
			string text = entry.text;
			dialog.destroy();
			switch(result) {
				case Gtk.ResponseType.OK:
					try {
						this.current = add_feed(new RssFeed.from_uri(text));
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

	public Granite.Widgets.Tab add_feed(Feed feed) {
		var tab = new Granite.Widgets.Tab(feed.title, null, new NewsPanel.from_feed(feed));
		this.insert_tab(tab, -1);
		return tab;
	}
}
