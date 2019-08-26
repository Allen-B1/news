struct FeedItem {
	string? title;
	string? about;
	string? link;
	DateTime? pubDate;
	string? content;
}

errordomain FeedError {
	AUTODISCOVERY_FAILED,
	INVALID_DOCUMENT,
	IOERR,
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

	private XmlFeed.from_text(string text) throws FeedError {
	    var doc = Xml.Parser.parse_doc(text);
	    Xml.Node* root = doc->get_root_element();
	    if (root == null)
	        throw new FeedError.INVALID_DOCUMENT("Invalid document: no root element");
	    switch (root->name) {
	    case "rss":
	        this.parse_rss(root);
	        break;
	    case "feed":
			this.parse_atom(root);
	        break;
	    default:
	        throw new FeedError.INVALID_DOCUMENT("Invalid document: root tag is <" + root->name + ">");
	    }
	}

	public XmlFeed.from_file(File file) throws FeedError {
		// Read file into `text`
	    var text = new StringBuilder();
		try {
		    DataInputStream data_stream = new DataInputStream(file.read());
		    string line = null;
		    while((line = data_stream.read_line()) != null) {
		        text.append(line);
		        text.append_c('\n');
		    }
		} catch (Error e) {
			debug(e.message);
			throw new FeedError.IOERR("Error opening '" + file.get_basename() + "'");
		}

		this.from_text(text.str);
	}

	public XmlFeed(string uri) throws FeedError {
		var source = uri;
		var file = File.new_for_uri(uri);
		var stream = file.read();
	    var data_stream = new DataInputStream(stream);
		var html = false;
	    string line = null;
		var filetext = new StringBuilder();
    	while((line = data_stream.read_line()) != null) {
	        filetext.append(line);
	        filetext.append_c('\n');
			if (line.strip() != "") {
				if (line.contains("<!DOCTYPE html")) {
					html = true;
				}
			}
	    }

		var xmltext = "";
		if (html) {
			var doc = Html.Doc.read_doc(filetext.str, uri);

			var ctx = new Xml.XPath.Context(doc);
			var res = ctx.eval_expression(
				"//link");

			if (res != null && res->type == Xml.XPath.ObjectType.NODESET && res->nodesetval != null && res->nodesetval->length() != 0) {
				for (var i = 0; i < res->nodesetval->length(); i++) {
					var node = res->nodesetval->item(i);
					if (
						(node->get_prop("rel") == "alternate" && (node->get_prop("type") == "application/atom+xml" || node->get_prop("type") == "application/rss+xml"))
						|| node->get_prop("rel") == "feed") {
						var url = node->get_prop("href");
						if (!url.has_prefix("http://") && !url.has_prefix("https://")) {
							if (url.has_prefix("/")) {
								var start = uri.index_of("://") + 3;
								var end = uri.index_of("/", start);
								url = uri.slice(0, end) + url;
							} else {
								url = uri + "/" + url;
							}
						}
						source = url;
						debug("Feed URL = " + url);
						if (url != null) {
							var xmlfile = File.new_for_uri(url);
							var xml_data_stream = new DataInputStream(xmlfile.read());
							var xmltextbuilder = new StringBuilder();
							while((line = xml_data_stream.read_line()) != null) {
								xmltextbuilder.append(line);
								xmltextbuilder.append_c('\n');
							}
							xmltext = xmltextbuilder.str;
							break;
						}
					}
				}
				if (xmltext == "") {
					throw new FeedError.AUTODISCOVERY_FAILED("Autodiscovery failed: all <link> elements invalid");
				}
			} else {
				throw new FeedError.AUTODISCOVERY_FAILED("Autodiscovery failed: no <link> element found");
			}
		} else {
			xmltext = filetext.str;
		}

		this.from_text(xmltext);
		if (this.source == null || this.source == "") {
			this.source = source;
		}
	}
}
