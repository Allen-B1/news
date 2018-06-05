class NewsNotebook : Granite.Widgets.DynamicNotebook {
	public NewsNotebook() {
		this.new_tab_requested.connect(() => {
			var dialog = new Gtk.Dialog.with_buttons(null, (this.get_toplevel() is Gtk.Window) ? (Gtk.Window)this.get_toplevel() : null, Gtk.DialogFlags.MODAL, 
					"Add", Gtk.ResponseType.OK,	
					"Cancel", Gtk.ResponseType.CANCEL,
					null);

			dialog.get_content_area().add(new Gtk.Label("Add RSS feed"));

			var entry = new Gtk.Entry();
			entry.activate.connect(() => {
			    dialog.response(Gtk.ResponseType.ACCEPT);
			});
			entry.margin_start = entry.margin_end = entry.margin_top = 6;
			dialog.get_content_area().add(entry);
			
			dialog.get_content_area().show_all();

			int result = dialog.run();
			string text = entry.text;
			dialog.destroy();
			switch(result) {
				case Gtk.ResponseType.OK:
					add_feed(new RssFeed.from_uri(text));
					break;
				case Gtk.ResponseType.CANCEL:
					break;
			}
		});
	}

	public void add_feed(Feed feed) {
		var tab = new Granite.Widgets.Tab(feed.title, null, new NewsPanel.from_feed(feed));
		this.insert_tab(tab, -1);
	}			
}
