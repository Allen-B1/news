class NewsList : Gtk.ScrolledWindow {
    public RssFeed feed;
    private string[] contents;
    private string url;
    private WebKit.WebView webview; // to store the contents

	public NewsList(RssFeed feed, WebKit.WebView webview) {
        this.feed = feed;
        this.webview = webview;
        this.vexpand = true;

        // disable horizontal scrollbar
        this.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

        var list = new Gtk.ListBox();
        list.set_size_request(0,0);

        foreach(var item in feed.items) {
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 12;
            box.halign = Gtk.Align.START;

            // Title
            var title = new Gtk.Label(null);
            title.set_markup("<span size=\"large\"><b>" + item.title + "</b></span>");

            // Align to start
            title.halign = Gtk.Align.START;
            title.hexpand = false;
            title.justify = Gtk.Justification.LEFT;
            title.set_line_wrap(true);
 
            box.pack_start(title, false, false, 0);

            if(item.about != null) {
                // Description
                item.about = item.about.replace("<p>", "\n").replace("</p>", "\n").replace("</span>", "").replace("<span>", "");
                var desc = new Gtk.Label(item.about);

                // Align to left
                desc.halign = Gtk.Align.START;
                desc.justify = Gtk.Justification.LEFT;
                desc.hexpand = false;
                desc.margin = 0;
               
                desc.set_markup(item.about);
                desc.set_line_wrap (true);
                
                desc.override_background_color(Gtk.StateFlags.NORMAL, {0,0,0,0});
                box.pack_start(desc, false, false, 0);
            }

            list.add(box);
        }

        this.add(list);

        list.row_selected.connect((row) => {
            if(row != null) {
                var data = this.feed.items[row.get_index()];
                this.webview.load_uri(data.link);
            }
        });
    }
}
