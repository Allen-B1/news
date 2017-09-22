struct RssItem {
    string title;
    string? about;
    string link;
    string pubDate;
    string? content;
}

struct RssFeed {
    string title;
    string about;
    string link;
    string? copyright;
    RssItem[] items;
}

namespace News {
    RssFeed? parse(string str, string? url=null) {
        var doc = Xml.Parser.parse_doc(str);
        RssFeed feed = {};
    
        Xml.Node* root = doc->get_root_element();
        if(root == null) {
            stderr.puts("Error parsing Xml.Doc: doc->get_root_element() is null");
            return null;
        }

        var channel = root->children;
        for(; channel->name != "channel"; channel = channel->next);
        for(var child = channel->children; child != null; child = child->next) {
            switch(child->name) {
            case "title":
                feed.title = child->get_content();
            break;
            case "description":
                feed.about = child->get_content();
            break;
            case "link":
                feed.link = child->get_content();
            break;
            case "item":
                RssItem item = RssItem();
                for(var childitem = child->children; childitem != null; childitem = childitem->next) {
                    switch(childitem->name) {
                    case "title":
                        item.title = childitem->get_content();
                    break;
                    case "link":
                        item.link = childitem->get_content();
                    break;
                    case "description":
                        item.about = childitem->get_content();
                    break;
                    case "encoded":
                        item.content = childitem->get_content();
                    break;
                    }
                }

                if(url != null && url.index_of("news.google.com") != -1) {                    
                    // Find description inside of the html table inside of the description: look at the rss feed for yourself
                    var eStartIndex = item.about.index_of("</font><br><font size=\"-1\">") + "</font><br><font size=\"-1\">".length;
                    var eEndIndex = item.about.index_of("</font>", eStartIndex);
                    var desc = item.about.slice(eStartIndex, eEndIndex).replace("&nbsp;", " ");  
                    desc = desc.replace("&quot;", "\"").replace("&middot;", ".");
                    item.about = desc;
                } else if(url != null && url.index_of("rss.cnn.com") != -1) {
                    var endIndex = item.about.index_of("<div");
                    item.about = item.about[0:endIndex].replace("&", "&amp;");
                    if(item.about == "") // if description is empty (sometimes is)
                        item.about = null;
                } else if(url != null && url.index_of("news.ycombinator.com") != -1 || item.about == "") {
                    item.about = null;
                } else; // do nothing, get <description>
                feed.items += item;
            break;
            }
        }
        return feed;
    }

    RssFeed? parse_from_uri(string uri) {
        var news_page = File.new_for_uri(uri);
    
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

        return News.parse(text.str, uri);
    }
}

