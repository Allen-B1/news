class MainWindow : Gtk.ApplicationWindow {
    private Granite.Widgets.Toast errortoast;
    private NewsSourceList newssourcelist;

    public signal void source_add(string source);
    public signal void source_remove(string source);

    public MainWindow(Gtk.Application app) {
        Object (application: app,
            title: _("News"));
    }

    public void show_error(string msg = _("Something went wrong")) {
        this.errortoast.title = msg;
        this.errortoast.send_notification();
    }

    protected Feed? add_feed_dialog() {
        var dialog = new Granite.MessageDialog.with_image_from_icon_name(_("Add feed"),  _("Enter the Atom or RSS feed url"), "dialog-question", Gtk.ButtonsType.NONE);

		dialog.add_button(_("Cancel"), Gtk.ResponseType.CANCEL);
		dialog.add_button(_("Add"), Gtk.ResponseType.OK).get_style_context().add_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);

		/* Create Entry */
		var entry = new Gtk.Entry();
		entry.activate.connect(() => {
		    dialog.response(Gtk.ResponseType.OK);
		});
		entry.margin_start = entry.margin_end = entry.margin_top = 12;
		entry.placeholder_text = _("Feed URL");
		dialog.get_content_area().add(entry);
		
		dialog.get_content_area().show_all();

		/* Collect response */
		int result = dialog.run();
		string text = entry.text;
		dialog.destroy();
		switch(result) {
			case Gtk.ResponseType.OK:
				try {
					var feed = Feed.from_uri(text);
                    return feed;
				} catch(Error err) {
					this.show_error("Couldn't add feed");
				}
				break;
			case Gtk.ResponseType.CANCEL:
				break;
		}
        return null;
    }

    protected void show_feed_info(Feed feed) {
        var dialog = new Gtk.Dialog.with_buttons(_("Feed information"), this, Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT, _("Close"), Gtk.ResponseType.ACCEPT, null);
        dialog.border_width = 18;
        dialog.get_content_area().spacing = 12;

        var title = new Granite.HeaderLabel(feed.title);
        dialog.get_content_area().add(title);

        var desc = new Gtk.Label(feed.about == null ? _("No description provided.") : feed.about);
        desc.use_markup = true;
        desc.set_line_wrap(true);
        desc.halign = Gtk.Align.START;
        desc.xalign = 0;
        desc.justify = Gtk.Justification.LEFT;
        desc.selectable = true;
        dialog.get_content_area().add(desc);

        if(feed.copyright != null) {
            var copyr = new Gtk.Label(feed.copyright);
            copyr.use_markup = true;
            copyr.selectable = true;
            copyr.set_line_wrap(true);
            copyr.halign = Gtk.Align.START;
            copyr.xalign = 0;
            copyr.justify = Gtk.Justification.LEFT;
            dialog.get_content_area().add(copyr);
        }

        if(feed.link != null) {
            var website = new Gtk.LinkButton.with_label(feed.link, _("Website"));
            dialog.get_content_area().add(website);
        }

        dialog.show_all();
        dialog.run();
        dialog.destroy();
    }

    construct {
        this.default_width = 900;
        this.default_height = 700;

        var headerbar = new NewsHeaderBar();
        this.set_titlebar(headerbar);

        var box = new Gtk.Overlay();
        this.add(box);

        this.errortoast = new Granite.Widgets.Toast(_("Something went wrong"));
        box.add_overlay(errortoast);

        this.newssourcelist = new NewsSourceList();
        var newspanel = new NewsPanel();
        var paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
        paned.pack1(this.newssourcelist, false, false);
        paned.add2(newspanel);
        box.add(paned);

        headerbar.search.connect((query) => {
            try {
                var feed = Feed.from_uri("https://news.google.com/news/rss/search/section/q/" + query + "?ned=us&gl=US&hl=en");
                this.add_feed(feed);
                this.source_add(feed.source);
            } catch (Error err) {
                this.show_error("Couldn't reach Google News");
            }
        });

        headerbar.view_info_clicked.connect(() => {
            this.show_feed_info(this.newssourcelist.active_feed);
        });

        this.newssourcelist.feed_selected.connect((feed) => {
            newspanel.feed = feed;
        });
        this.newssourcelist.feed_removed.connect((feed) => {
            this.source_remove(feed.source);
        });
        this.newssourcelist.feed_added.connect(() => {
            var feed = this.add_feed_dialog();
            if (feed != null) {
    			this.add_feed(feed);
                this.source_add(feed.source);
            }
        });

        var provider = new Gtk.CssProvider();
        provider.load_from_data("""
        @define-color colorPrimary #f20050;
        @define-color textColorPrimary #fafafa;
        @define-color colorAccent #68b723;""", -1);
        Gtk.StyleContext.add_provider_for_screen(this.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // Ctrl+F shortcut
        var accel_group = new Gtk.AccelGroup();
        accel_group.connect(Gdk.Key.f,  Gdk.ModifierType.CONTROL_MASK,  Gtk.AccelFlags.VISIBLE,  () => {
            headerbar.focus_search();
            return true;
        });
        this.add_accel_group(accel_group);
    }

    public void add_feed(Feed feed) {
        this.newssourcelist.add_feed(feed);
   }
}
