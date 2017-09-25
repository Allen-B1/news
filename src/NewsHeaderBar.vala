class NewsHeaderBar : Gtk.HeaderBar {
	public NewsHeaderBar(Gtk.Window window) {
        this.title = "News";
        this.show_close_button = true;
        this.override_background_color(Gtk.StateFlags.NORMAL, {255,0,170,1});

        var search = new Gtk.Button.from_icon_name("edit-find", Gtk.IconSize.LARGE_TOOLBAR);
        search.tooltip_text = "Search...";
        search.halign = Gtk.Align.END;
        search.clicked.connect(() => {
            var dialog = new Gtk.Dialog.with_buttons("Search", window, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, 
                "Done", Gtk.ResponseType.ACCEPT, 
                "Cancel", Gtk.ResponseType.REJECT, null);

            var content_area = dialog.get_content_area();
            var label = new Gtk.Label("Search the news");
            content_area.add(label);

            var entry = new Gtk.Entry();
            entry.margin = 4;
            entry.activate.connect(() => {
                dialog.response(Gtk.ResponseType.ACCEPT);
            });
            content_area.add(entry);

            content_area.show_all();

		    int result = dialog.run();
            switch(result) {
                case Gtk.ResponseType.ACCEPT:
                    News.add_page("https://news.google.com/news/?ned=us&hl=en&output=rss&q=" + Uri.escape_string(entry.text));
                    break;
            }
            dialog.destroy();
        });
        this.pack_end(search);
      
    }
}
