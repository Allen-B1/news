class NewsHeaderBar : Gtk.HeaderBar {
    public signal void search(string query);

    private Gtk.SearchEntry search_entry;

	public NewsHeaderBar() {
        this.title = "News";
        this.show_close_button = true;

        this.search_entry = new Gtk.SearchEntry();
        this.search_entry.placeholder_text = "Search Google News";
        this.search_entry.activate.connect(() => {
            this.search(this.search_entry.text);
			this.search_entry.text = "";
        });
        this.pack_end(this.search_entry);

        // Ctrl+F code is not working
        var window = this.get_window();
        if(window != null)
            window.set_events(window.get_events() | Gdk.EventMask.KEY_PRESS_MASK);
        this.get_toplevel().key_press_event.connect((event) => {
            stdout.puts("Cnonect");
            stdout.flush();

            if(event.state == Gdk.ModifierType.CONTROL_MASK && (event.keyval == Gdk.Key.f || event.keyval == Gdk.Key.F)) {
                this.search_entry.grab_focus();
                return true;
            }
            return false;
        }); 
    }
}
