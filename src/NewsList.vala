class NewsList : Gtk.ScrolledWindow {
	public NewsList(RssFeed? s) {
        var list = new Gtk.ListBox();
        list.forall ((element) => list.remove (element));

        foreach (RssItem article in s.data) {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 12;

            // Title
            var label = new Gtk.Label(null);
            label.set_markup("<b>" + article.title + "</b>");
            label.set_line_wrap(true);
            box.add(label);

            if(article.text != null) {
                // Description
                var desc = new Gtk.Label(null);
                desc.set_markup(article.text);
                desc.set_line_wrap (true);
                desc.override_background_color(Gtk.StateFlags.NORMAL, {0,0,0,0});
                box.add(desc);
            }

            var row = new Gtk.ListBoxRow();
            row.add(box);

            list.add(row);
        }

        list.row_activated.connect((row) => {
            Pid child_pid = 0;
            if(list.get_selected_row() != null)
                Process.spawn_async("/",
                    {"xdg-open", s.data[list.get_selected_row().get_index()].link},
                    Environ.get(),
                    SpawnFlags.SEARCH_PATH,
                    null,
                    out child_pid
                );   
        });

        var scrolled = new Gtk.ScrolledWindow(null, null);
        scrolled.add(list);

        return scrolled;
    }
