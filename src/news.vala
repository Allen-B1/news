struct Article {
    public string title;
    public string? text;
    public string link;
}

string? rss_url = null; // if null, defaults to google news
Gtk.ListBox current_list; // list changes, reference to current list
Gtk.ScrolledWindow list_scroll; // For scrolling

Article[]? fetch_news() {
    File news_page;
        if(rss_url != null)
            news_page = File.new_for_uri(rss_url);
        else
            news_page = File.new_for_uri("https://news.google.com/news/?ned=us&hl=en&output=rss");
    
    DataInputStream data_stream = null;
    try {
        data_stream = new DataInputStream(news_page.read());
    } catch(GLib.Error err) {
        stdout.puts(err.message);
        stdout.putc('\n');
        return null;
    }
    data_stream.set_byte_order(DataStreamByteOrder.LITTLE_ENDIAN);

    string line = null;
    var text = new StringBuilder();
    try {
        while((line = data_stream.read_line()) != null) {
            text.append(line);
            text.append_c('\n');
        }
    } catch(GLib.IOError err) {
        return null;
    }
    
    var str = text.str;

    int itemIndex = 0;
    Article[] articles = new Article[0];
    while((itemIndex = (int)str.index_of("<item>", itemIndex + 1)) != -1) {
        var startIndex = str.index_of("<title>", itemIndex) + "<title>".length;
        var endIndex = str.index_of("</", startIndex);
        var s = str[startIndex:endIndex];
        
        // Find link;
        var uStartIndex = str.index_of("<link>", itemIndex) + "<link>".length;
        if(rss_url == null)
            uStartIndex = str.index_of("url=", uStartIndex) + 4;
        var uEndIndex = str.index_of("</", uStartIndex);
        var uS = str[uStartIndex:uEndIndex];

        string? desc = "";

        if(rss_url == null) {
            // Scrape description
            var dStartIndex = str.index_of("<description>", itemIndex) + "<description>".length;
            var dEndIndex = str.index_of("</", dStartIndex);
            var dS = str.slice(dStartIndex, dEndIndex).replace("&quot;", "\"").replace("&#39;", "'").replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&");
            
            // Find description inside of the html table inside of the description: look at the rss feed for yourself
            var eStartIndex = dS.index_of("</font><br><font size=\"-1\">") + "</font><br><font size=\"-1\">".length;
            var eEndIndex = dS.index_of("</", eStartIndex);
            desc = dS.slice(eStartIndex, eEndIndex).replace("&nbsp;", " ").replace("<b>", "").replace("&#39;", "'");  
            desc = desc.replace("&quot;", "\"").replace("&middot;", ".");
        } else {
            desc = null;
        }


        Article article = Article() {
            title = s,
            text = desc,
            link = uS
        };
        articles += article;
    }
    return articles;
}

Gtk.ListBox update_list() {
    Article[] s = fetch_news();
    var list = new Gtk.ListBox();
    list.forall ((element) => list.remove (element));

    foreach (Article article in s) {
        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.margin = 12;

        // Title
        var label = new Gtk.Label(null);
        label.set_markup("<b>" + article.title + "</b>");
        label.set_line_wrap(true);
        box.add(label);

        if(article.text != null) {
            // Description
            var desc = new Gtk.TextView();
            desc.set_wrap_mode (Gtk.WrapMode.WORD);
            desc.buffer.text = article.text;
            desc.override_background_color(Gtk.StateFlags.NORMAL, {0,0,0,0});
            desc.editable = false;
            box.add(desc);
        }

        var row = new Gtk.ListBoxRow();
        row.add(box);

        list.add(row);
    }

    list.row_selected.connect((row) => {
        Pid child_pid = 0;
        if(list.get_selected_row() != null)
            Process.spawn_async("/",
                {"xdg-open", s[list.get_selected_row().get_index()].link},
                Environ.get(),
                SpawnFlags.SEARCH_PATH,
                null,
                out child_pid
            );   
    });
    list.show_all();

    if(current_list != null)
        current_list.destroy();
    return list;
}

int main (string args[]) {
    Gtk.init(ref args);

    var window = new Gtk.Window();
    window.title = "News";
    window.set_position(Gtk.WindowPosition.CENTER);
    window.set_default_size(950, 950);
    window.destroy.connect(Gtk.main_quit);

    var root = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
    root.pack_start(News.create_toolbar(window), false, false, 0);

    // Create listbox
    {
        list_scroll = new Gtk.ScrolledWindow(null, null);
        current_list = update_list();
        list_scroll.add(current_list);

        root.pack_start(list_scroll, true, true, 0);            
    }
    window.add(root);
    window.show_all();

    window.resize(950, 950);

    Gtk.main();
    return 0;
}
