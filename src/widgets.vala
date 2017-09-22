namespace News {
    void new_tab() {
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
    }

    void add_page(string? url) {
        if(url == null) {
            url = "https://news.google.com/news/?ned=us&hl=en&output=rss";
        }
        try {
            var feed = News.parse_from_uri(url);

            if(feed == null) {
                throw new Error(Quark.from_string(""), 0, "Something went wrong.");
            }

            var list = new NewsList(feed);
            list.show_all();
            var tab = new Granite.Widgets.Tab(feed.title == "Top Stories - Google News" ? "Google News" : feed.title, null, list);
            notebook.insert_tab(tab, -1); 
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
}
