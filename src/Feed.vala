struct FeedItem {
	string? title;
	string? about;
	string? link;
	DateTime? pubDate;
	string? content;
}

errordomain FeedError {
	INVALID_DOCUMENT,
	UNKNOWN_FORMAT
}

interface Feed : Object {
	[Description(nick = "Feed items", blurb = "This is the list of feed entries.")]
	public abstract FeedItem[] items { get; protected set; }
	[Description(nick = "Feed title", blurb = "This is the title of the feed.")]
	public abstract string? title { get; protected set; }
	[Description(nick = "Feed link", blurb = "The website of the news source.")]
	public abstract string? link { get; protected set; }
	[Description(nick = "Feed information", blurb = "This is the description of the feed.")]
	public abstract string? about { get; protected set; }
	[Description(nick = "Copyright", blurb = "This is the copyright information of the feed.")]
	public abstract string? copyright { get; protected set; }
	[Description(nick = "Feed source", blurb = "This is the source of the feed.")]
	public abstract string source { get; protected set; }
}

class XmlFeed: Object, Feed {
	public string? copyright { get; protected set; default = null; }
	public string? about { get; protected set; default = null; }
	public string? title { get; protected set; default = null; }
	public string? link { get; protected set; default = null; }
	public FeedItem[] items { get; protected set; default = new FeedItem[0]; }

	public string source { get; protected set; }

	private void parse_rss(Xml.Node* root) {
	    // find channel element
	    var channel = root->children;
	    for(; channel->name != "channel"; channel = channel->next);

	    FeedItem[] items = new FeedItem[0];

	    // loop through elements
	    for(var child = channel->children; child != null; child = child->next) {
	        switch(child->name) {
	        case "title":
	            this.title = child->get_content().strip();
	            break;
	        case "description":
	            this.about = child->get_content().strip();
	            break;
	        case "link":
	            this.link = child->get_content().strip();
	            break;
	        case "copyright":
	            this.copyright = child->get_content().strip();
	            break;
	        case "item":
	            FeedItem item = FeedItem();
	            for(var childitem = child->children; childitem != null; childitem = childitem->next) {
	                switch(childitem->name) {
	                case "title":
	                    item.title = childitem->get_content().replace("&", "&amp;").strip();
	                    break;
	                case "link":
	                    item.link = childitem->get_content().strip();
	                    break;
	                case "description":
	                    item.about = childitem->get_content().strip();
	                    if(item.about.length == 0)
	                        item.about = null;
	                    break;
	                case "encoded":
	                    item.content = childitem->get_content().strip();
	                    break;
	                case "pubDate":
	                    item.pubDate = parse_rfc822_date(childitem->get_content().strip());
	                    break;
	                }
	            }
	            items += item;
	            break;
	        }
	    }
	    this.items = items;
	}

	private void parse_atom(Xml.Node* root) {
	    FeedItem[] items = new FeedItem[0];
	    for(var child = root->children; child != null; child = child->next) {
	        switch (child->name) {
	        case "title":
	            this.title = child->get_content();
	            break;
	        case "subtitle":
	            this.about = child->get_content();
	            break;
	        case "link":
	            if (child->get_prop("rel") == "self") {
	                this.source = child->get_prop("href");
	            } else {
	                this.link = child->get_prop("href");
	            }
	            break;
	        case "entry":
	            FeedItem item = FeedItem();
	            for(var childitem = child->children; childitem != null; childitem = childitem->next) {
	                switch(childitem->name) {
	                case "title":
	                    item.title = childitem->get_content();
	                    break;
	                case "summary":
	                    item.about = childitem->get_content();
	                    break;
	                case "link":
	                    if (item.link == null) {
	                        item.link = childitem->get_prop("href");
	                    }
	                    break;
	                case "published":
	                case "updated":
	                    item.pubDate = new DateTime.from_iso8601(childitem->get_content(), new TimeZone.utc());
	                    break;
	                }
	            }
	            items += item;
	            break;
	        }
	    }
	    this.items = items;
	}

	public XmlFeed.from_file(File file) {
		// Read file into `text`
	    DataInputStream data_stream = new DataInputStream(file.read());
	    string line = null;
	    var text = new StringBuilder();
	    while((line = data_stream.read_line()) != null) {
	        text.append(line);
	        text.append_c('\n');
	    }

	    var doc = Xml.Parser.parse_doc(text.str);
	    Xml.Node* root = doc->get_root_element();
	    if (root == null)
	        throw new FeedError.INVALID_DOCUMENT("No root element");
	    switch (root->name) {
	    case "rss":
	        this.parse_rss(root);
	        break;
	    case "feed":
			this.parse_atom(root);
	        break;
	    default:
	        throw new FeedError.UNKNOWN_FORMAT("root tag is <" + root->name + ">");
	    }
	}

	public XmlFeed(string uri) {
		var file = File.new_for_uri(uri);
		this.from_file(file);
		if (this.source == null || this.source == "") {
			this.source = uri;
		}
	}
}
