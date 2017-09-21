struct RssItem {
    public string title;
    public string? text;
    public string link;
}

struct RssFeed {
    public string title;
    public RssItem[] data;
}

Gtk.Window window;
Granite.Widgets.DynamicNotebook notebook;

RssFeed? fetch_news(string? url) {
    File news_page;
    if(url == null) {
        url = "https://news.google.com/news/?ned=us&hl=en&output=rss";
    }

    news_page = File.new_for_uri(url);
    
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
    RssItem[] articles = new RssItem[0];

    while((itemIndex = (int)str.index_of("<item>", itemIndex + 1)) != -1) {
        var startIndex = str.index_of("<title>", itemIndex) + "<title>".length;
        var endIndex = str.index_of("</", startIndex);
        var s = str[startIndex:endIndex];
        
        // Find link;
        var uStartIndex = str.index_of("<link>", itemIndex) + "<link>".length;
        if(url.index_of("news.google.com") != -1)
            uStartIndex = str.index_of("url=", uStartIndex) + 4;
        var uEndIndex = str.index_of("</", uStartIndex);
        var uS = str[uStartIndex:uEndIndex];

        string? desc = "";

        if(url.index_of("news.google.com") != -1) {
            // Scrape description
            var dStartIndex = str.index_of("<description>", itemIndex) + "<description>".length;
            var dEndIndex = str.index_of("</", dStartIndex);
            var dS = str.slice(dStartIndex, dEndIndex).replace("&quot;", "\"").replace("&#39;", "'").replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&");
            
            // Find description inside of the html table inside of the description: look at the rss feed for yourself
            var eStartIndex = dS.index_of("</font><br><font size=\"-1\">") + "</font><br><font size=\"-1\">".length;
            var eEndIndex = dS.index_of("</font>", eStartIndex);
            desc = dS.slice(eStartIndex, eEndIndex).replace("&nbsp;", " ");  
            desc = desc.replace("&quot;", "\"").replace("&middot;", ".");
        } else {
            desc = null;
        }


        RssItem article = RssItem() {
            title = s,
            text = desc,
            link = uS
        };
        articles += article;
    }

    var titleStartIndex = str.index_of("<title>") + 7;
    var titleEndIndex = str.index_of("</title>", titleStartIndex);

    return RssFeed() {
        title = url == "https://news.google.com/news/?ned=us&hl=en&output=rss" ? "Google News" : str[titleStartIndex:titleEndIndex],
        data = articles
    };
}

int main (string args[]) {
    Gtk.init(ref args);

    window = new Gtk.Window();
    window.title = "News";
    window.set_position(Gtk.WindowPosition.CENTER);
    window.set_default_size(950, 950);
    window.destroy.connect(Gtk.main_quit);
    window.set_titlebar(News.create_headerbar(window));

    notebook = new Granite.Widgets.DynamicNotebook();
    window.add(notebook);

    // Create listbox
    News.add_page(null);

    window.show_all();

    window.resize(950, 950);

    Gtk.main();
    return 0;
}
