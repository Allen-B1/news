namespace News {
    void add_page(string? url) {
        try {
            RssFeed? feed = fetch_news(url);

            if(feed == null) {
                throw new Error(Quark.from_string(""), 0, "Something went wrong.");
            }

            var list = News.create_list(feed);
            list.show_all();
            notebook.append_page(list, new Gtk.Label(feed.title)); 
            var size = notebook.page_num(list);
            for(var i = 0; i < size; i++)
                notebook.next_page();
            notebook.set_tab_reorderable(list, true);
        } catch(Error err) {
            var dialog = new Gtk.MessageDialog(window, Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.CLOSE,
                "%s", err.message);
            dialog.title = "Error";
            dialog.run();
            dialog.destroy();
            return;
        }
    }

    Gtk.HeaderBar create_headerbar(Gtk.Window window) {
        var headerbar = new Gtk.HeaderBar();
        headerbar.title = "News";
        headerbar.show_close_button = true;
  
        var headerbar_url = new Gtk.ToolButton(new Gtk.Image.from_icon_name
            ("list-add",
            Gtk.IconSize.SMALL_TOOLBAR),
            "RSS");
        headerbar_url.clicked.connect(() => {
            var dialog = new Gtk.Dialog.with_buttons("Add News Source", window, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, 
                "Done", Gtk.ResponseType.ACCEPT, 
                "Cancel", Gtk.ResponseType.REJECT, null);

            var content_area = dialog.get_content_area();
            var label = new Gtk.Label(null);
            label.set_markup("<b>Pick a news source</b>");
            content_area.add(label);

            var google_news = new Gtk.RadioButton.with_label(null, "Google News");
            var hacker_news = new Gtk.RadioButton.with_label_from_widget(google_news, "Hacker News");
            var other = new Gtk.RadioButton.with_label_from_widget(google_news, "Other");

            content_area.add(google_news);
            content_area.add(hacker_news);
            content_area.add(other);

            var entry = new Gtk.Entry();
            entry.margin = 4;
            content_area.add(entry);

            entry.focus_in_event.connect(() => {
                other.active = true;
                return true;
            });

            content_area.show_all();

		    int result = dialog.run();
            switch(result) {
            case Gtk.ResponseType.ACCEPT:
                Gtk.RadioButton active_button = null;
                foreach(Gtk.RadioButton radio in google_news.get_group()) {
                    if(radio.active) {
                        active_button = radio;
                        break;
                    }
                }

                string? url;
                if (active_button == google_news) 
                    url = null;
                else if (active_button == hacker_news)
                    url = "https://news.ycombinator.com/rss";
                else
                    url = entry.text;   
                News.add_page(url);
                break;
            }

            dialog.destroy();
        });
        headerbar.add(headerbar_url);

        var headerbar_search = new Gtk.Button.from_icon_name("edit-find", Gtk.IconSize.LARGE_TOOLBAR);
        headerbar_search.tooltip_text = "Search...";
        headerbar_search.halign = Gtk.Align.END;
        headerbar_search.clicked.connect(() => {
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
        headerbar.pack_end(headerbar_search);
      
        return headerbar;
    }

    Gtk.ScrolledWindow? create_list(RssFeed? s) {
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
}
