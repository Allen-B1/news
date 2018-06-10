class NewsHeaderBar : Gtk.HeaderBar {
    public signal void search(string query);

    private Gtk.SearchEntry search_entry;

	public NewsHeaderBar() {
        this.title = "News";
        this.show_close_button = true;

        this.search_entry = new Gtk.SearchEntry();
        this.search_entry.activate.connect(() => {
            this.search(this.search_entry.text);
        });
        this.add(this.search_entry);
    }
}
