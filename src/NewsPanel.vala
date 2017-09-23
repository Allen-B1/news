/* NewsPanel
 * A panel with 2 sides, one side showing a NewsList, the other one showing a WebView
 */

class NewsPanel : Gtk.Paned {
    public NewsPanel(NewsList list, WebKit.WebView webview) {
        this.orientation = Gtk.Orientation.HORIZONTAL;
        this.add1(list);
        this.add2(webview);
        this.set_position(500);
    }

    public NewsPanel.from_feed(RssFeed feed) throws Error {
        var webview = new WebKit.WebView();

        var list = new NewsList(feed, webview);

        this(list, webview);
    }
}
