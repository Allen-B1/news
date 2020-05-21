struct FeedItem {
	string? title;
	string? about;

	string? link;
	string? linkComments;

	DateTime? pubDate;
	string? content;
}

errordomain FeedError {
	AUTODISCOVERY_FAILED,
	INVALID_DOCUMENT,
	IOERR,
}

interface Feed : Object {
	public abstract FeedItem[] items { get; }
	[Description(nick = "Feed title", blurb = "This is the title of the feed.")]
	public abstract string? title { get; }
	[Description(nick = "Feed link", blurb = "The website of the news source.")]
	public abstract string? link { get; }
	[Description(nick = "Feed information", blurb = "This is the description of the feed.")]
	public abstract string? about { get; }
	[Description(nick = "Copyright", blurb = "This is the copyright information of the feed.")]
	public abstract string? copyright { get; }
	[Description(nick = "Feed source", blurb = "This is the source of the feed.")]
	public abstract string source { get; }
}

class XmlFeed: Object, Feed {
	private FeedItem[] _items = new FeedItem[0];

	public FeedItem[] items {
		get {
			return this._items;
		}
	}

	private string? _copyright;
	public string? copyright { get {
		return _copyright;
	}}
	private string? _about;
	public string? about { get {
		return _about;
	}}
	private string? _title = null;
	public string? title {
		get {
			if (this.source.contains("https://news.google.com/rss?hl")) {
				var dash_index = _title.index_of("-");
				if (dash_index >= 0) {
					_title = _title[dash_index+1:_title.length].strip();
				}
			}
			return _title;
		}
	}

	private string? _link;
	public string? link { get {
		return _link;
	}}

	private string _source;
	public string source { get {
			return _source;
	}}

	private void parse_rss(Xml.Node* root) {
	    // find channel element
	    var channel = root->children;
	    for(; channel->name != "channel"; channel = channel->next);

		var items = new FeedItem[0];

	    // loop through elements
	    for(var child = channel->children; child != null; child = child->next) {
	        switch(child->name) {
	        case "title":
	            this._title = child->get_content().replace("&", "&amp;").strip();
	            break;
	        case "description":
	            this._about = child->get_content().replace("&", "&amp;").strip();
	            break;
	        case "link":
	            this._link = child->get_content().strip();
	            break;
	        case "copyright":
	            this._copyright = child->get_content().replace("&", "&amp;").strip();
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
					case "comments":
						item.linkComments = childitem->get_content().strip();
						break;
	                case "description":
	                    item.about = childitem->get_content().replace("&", "&amp;").strip();
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
			this._items = items;
	    }
	}

	private void parse_atom(Xml.Node* root) {
	    FeedItem[] items = new FeedItem[0];
	    for(var child = root->children; child != null; child = child->next) {
	        switch (child->name) {
	        case "title":
	            this._title = child->get_content().replace("&", "&amp;").strip();
	            break;
	        case "subtitle":
	            this._about = child->get_content().replace("&", "&amp;").strip();
	            break;
	        case "link":
	            if (child->get_prop("rel") == "self") {
	                this._source = child->get_prop("href");
	            } else {
	                this._link = child->get_prop("href");
	            }
	            break;
	        case "entry":
	            FeedItem item = FeedItem();
	            for(var childitem = child->children; childitem != null; childitem = childitem->next) {
	                switch(childitem->name) {
	                case "title":
	                    item.title = childitem->get_content().replace("&", "&amp;").strip();
	                    break;
	                case "summary":
	                    item.about = childitem->get_content().replace("&", "&amp;").strip();
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
		this._items = items;
	}

	private XmlFeed.from_text(string text) throws FeedError {
	    var doc = Xml.Parser.parse_doc(text);
	    var root = doc->get_root_element();
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
		var filetext = new StringBuilder();
		var html = false;
		try {
			var file = File.new_for_uri(uri);
			var stream = file.read();
		    var data_stream = new DataInputStream(stream);
			string line = null;
	    	while((line = data_stream.read_line()) != null) {
		        filetext.append(line);
		        filetext.append_c('\n');
				if (line.strip() != "") {
					if (line.contains("<!DOCTYPE html") || line.contains("<!doctype html") || line.contains("<html")) {
						html = true;
					}
				}
		    }
		} catch (Error e) {
			throw new FeedError.IOERR("Couldn't open '" + uri + "': " + e.message);
		}

		var xmltext = "";
		if (html) {
			var filetext_str = filetext.str;
			var link_index = 0;
			while(true) {
				link_index = filetext_str.index_of("<link", link_index+1);
				if (link_index < 0) {
					break;
				}
				var rel_index = filetext_str.index_of("rel=", link_index);
				var href_index = filetext_str.index_of("href=", link_index);
				if (rel_index < 0 || href_index < 0) {
					continue;
				}
				var type_index = filetext_str.index_of("type=", link_index);
				if (
					(filetext_str.slice(rel_index, filetext_str.length).has_prefix("rel=\"alternate\"") &&
						type_index >= 0 &&
						(filetext_str.slice(type_index,filetext_str.length).has_prefix("type=\"application/atom+xml\"") ||
							filetext_str.slice(type_index,filetext_str.length).has_prefix("type=\"application/rss+xml\"")
						)
					) || filetext_str.slice(rel_index,filetext_str.length).has_prefix("rel=\"feed\"")
				) {
					var quote_index = filetext_str.index_of("\"", href_index);
					if (quote_index < 0) {
						continue;
					}
					var quote_index2 = filetext_str.index_of("\"", quote_index+1);
					if (quote_index2 < 0) {
						continue;
					}
					var url = filetext_str.slice(quote_index+1, quote_index2);
					debug("Relative Feed URL = " + url);
					if (!url.has_prefix("http://") && !url.has_prefix("https://")) {
						if (url.has_prefix("//")) {
							var start = uri.index_of("://");
							url = uri[0:start] + url;
						} else if (url.has_prefix("/")) {
							var start = uri.index_of("://") + 3;
							var end = uri.index_of("/", start);
							if (end < 0) {
								end = uri.length;
							}
							url = uri.slice(0, end) + url;
						} else {
							url = uri + (uri.has_suffix("/") ? "" : "/") + url;
						}
					}

					source = url;
					debug("Absolute Feed URL = " + url);

					// BUG: Hacker news responds with an HTTP error, probably due to the fact that there's 2 requests in a short time
					var xmlfile = File.new_for_uri(url);
					var xml_data_stream = new DataInputStream(xmlfile.read());
					var xmltextbuilder = new StringBuilder();
					string line = null;
					while((line = xml_data_stream.read_line()) != null) {
						xmltextbuilder.append(line);
						xmltextbuilder.append_c('\n');
					}
					xmltext = xmltextbuilder.str;
					break;
				}
			}
			if (xmltext == "") {
				throw new FeedError.AUTODISCOVERY_FAILED("Autodiscovery failed");
			}
		} else {
			xmltext = filetext.str;
		}

		this.from_text(xmltext);
		if (this._source == null || this._source == "") {
			this._source = source;
		}
	}
}

class AggregateFeed : Object, Feed {
	public Feed[] feeds { get; set; default = new Feed[0]; }

	public string? title { get {
		return "All";
	}}
	public string? link { get {return null;} }
	public string? about { get {return "Aggregates all of your feeds.";} }
	public string? copyright { get {return null;} }
	public string source { get {return "";} }

	private FeedItem[] _items;

	public FeedItem[] items {
		get {
			var items = new Gee.ArrayList<FeedItem?>();

			foreach (var feed in feeds) {
				foreach (var item in feed.items) {
					items.add(item);
				}
			}

			items.sort((a, b) => {
				// res < 0 == a < b
				if (a.pubDate == b.pubDate) return 0;
				if (a.pubDate == null) return -1;
				if (b.pubDate == null) return 1;
				return -a.pubDate.compare(b.pubDate);
			});

			var real = new FeedItem[0];
			for (var i = 0; i < items.size; i++) {
				real += items[i];
			}
			_items = real;

			return _items;
		}
	}

	public AggregateFeed() {}
}
