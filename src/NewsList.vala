struct RssFeed {
    string title;
    string about;
    string link;
    string? copyright;
}

class NewsList : Gtk.ScrolledWindow {
    private Xml.Doc* doc;
    public RssFeed feed;
    private string[] links;

	public NewsList(Xml.Doc* doc) {
        assert(doc != null);

        this.doc = doc;
        var list = new Gtk.ListBox();

        Xml.Node* root = doc->get_root_element();
        if(root == null) {
            stderr.puts("Error parsing Xml.Doc: doc->get_root_element() is null");
            var dialog = new Gtk.MessageDialog(null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE, "An error occured");
            Process.exit(1);
        }

        var channel = root->children;
        for(var child = channel->children; child != null; child = child->next) {
            switch(child->name) {
            case "title":
                this.feed.title = child->get_content();
            break;
            case "description":
                this.feed.about = child->get_content();
            break;
            case "link":
                this.feed.link = child->get_content();
            break;
            case "item":
                stdout.puts("Found item");
                string title = "Unknown Title";
                string? about = null;
                string link = "about:blank";
                for(var childitem = child->children; childitem != null; childitem = childitem->next) {
                    switch(childitem->name) {
                    case "title":
                        title = childitem->get_content();
                    break;
                    }
                }
                var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
                box.margin = 12;

                // Title
                var label = new Gtk.Label(null);
                label.set_markup("<b>" + title + "</b>");
                label.set_line_wrap(true);
                box.add(label);

                if(about != null) {
                    // Description
                    var desc = new Gtk.Label(null);
                    desc.set_markup(about);
                    desc.set_line_wrap (true);
                    desc.override_background_color(Gtk.StateFlags.NORMAL, {0,0,0,0});
                    box.add(desc);
                }

                list.add(box);
            break;
            }
        }

        list.row_activated.connect((row) => {
            Pid child_pid = 0;
            if(list.get_selected_row() != null)
                Process.spawn_async("/",
                    {"xdg-open", links[row.get_index()]},
                    Environ.get(),
                    SpawnFlags.SEARCH_PATH,
                    null,
                    out child_pid
                );   
        });

        this.add(list);
        this.show_all();
    }
}
