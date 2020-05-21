class NewsHeaderBar : Gtk.HeaderBar {
	public signal void search(string query);

	private Gtk.SearchEntry search_entry;

	public NewsHeaderBar() {
		this.title = _("News");
		this.show_close_button = true;

		this.search_entry = new Gtk.SearchEntry();
		this.search_entry.placeholder_text = _("Search Google News");
		this.search_entry.activate.connect(() => {
			this.search(this.search_entry.text);
			this.search_entry.text = "";
		});
		this.pack_end(this.search_entry);
	}

	public void focus_search() {
		this.search_entry.grab_focus();
	}
}
