class NewsSourceList : Granite.Widgets.SourceList {
    public signal void feed_selected(Feed feed);

    private HashTable<Granite.Widgets.SourceList.Item, Feed> sources;

    public NewsSourceList() {
        this.set_size_request(150, 0);
        this.sources = new HashTable<Granite.Widgets.SourceList.Item, Feed>(
            (a) => { return str_hash(a.name); },
            (a, b) => { return a == b; }
        );

        this.item_selected.connect((item) => {
            if (item == null) return;
            var feed = sources[item];
            if (feed != null)
                this.feed_selected(feed);
        });
    }

    public void add_feed(Feed feed) {
        var item = new Granite.Widgets.SourceList.Item(feed.title);
        this.sources[item] = feed;
        this.root.add(item);
    }

    public Feed? active_feed {
        get {
            return this.sources[this.selected];
        }
    }
}
