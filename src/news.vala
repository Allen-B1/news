Gtk.Window window;
Granite.Widgets.DynamicNotebook notebook;

Xml.Doc* fetch_news(string? url) {
    File news_page;

    news_page = File.new_for_uri(url);
    
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

    return Xml.Parser.parse_doc(text.str);
}

int main (string args[]) {
    Gtk.init(ref args);

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

    Gtk.main();
    return 0;
}
