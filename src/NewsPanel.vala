/* NewsPanel
 * A panel with 2 sides, one side showing a NewsList, the other one showing a WebView
 */

class NewsPanel : Gtk.Paned {
	private Feed _feed;
	public Feed feed {
		get {
			return _feed;
		}
		set {
			var list = (NewsList)this.get_child1();
			var webview = (WebKit.WebView)this.get_child2();

			list.feed = value;
			webview.load_uri("about:blank");

			_feed = value;
		}
	}

	public NewsPanel() {
		this.orientation = Gtk.Orientation.HORIZONTAL;

		var webview = new WebKit.WebView();
		var list = new NewsList();
		list.item_selected.connect((item) => {
			webview.load_uri(item.link);
		});

		this.add1(list);
		this.add2(webview);
		this.set_position(300);
	}
}
