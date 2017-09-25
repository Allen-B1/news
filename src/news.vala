Gtk.Window window;
Granite.Widgets.DynamicNotebook notebook;



int main (string args[]) {
    Gtk.init(ref args);

    if(args.length > 1) {
        News.AboutDialog();
    } else {
        window = new Gtk.Window();
        window.title = "News";
        window.set_position(Gtk.WindowPosition.CENTER);
        window.set_default_size(950, 950);
        window.destroy.connect(Gtk.main_quit);
        window.set_titlebar(new NewsHeaderBar(window));

        notebook = new Granite.Widgets.DynamicNotebook();
        notebook.new_tab_requested.connect(News.new_tab);
        window.add(notebook);

        // Create listbox
        News.add_page(null);

        window.show_all();

        window.resize(950, 950);
    }
    Gtk.main();
    return 0;
}
