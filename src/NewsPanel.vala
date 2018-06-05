/* NewsPanel
 * A panel with 2 sides, one side showing a NewsList, the other one showing a WebView
 */

class NewsPanel : Gtk.Paned {
    protected NewsPanel(NewsList list, WebKit.WebView webview) {
        this.orientation = Gtk.Orientation.HORIZONTAL;
        this.add1(list);
        this.add2(webview);
        this.set_position(200);
    }

    
    public NewsPanel.from_feed(Feed feed) throws Error {
        var webview = new WebKit.WebView();

        var list = new NewsList(feed);
        list.item_selected.connect((item) => {
            webview.load_uri(item.link);
        });

        this(list, webview);
    }
}
