class SourceKeeper {
	private string path;

	public SourceKeeper() {
		this.path = Environment.get_home_dir() + "/.config/com.github.allen-b1.news.txt";

		try {
			var f = File.new_for_path(this.path);
			if (f.query_exists()) {
				// Return if not empty
				var line = new DataInputStream(f.read()).read_line();
				if (line != null && line.strip().length != 0) {
					debug("SourceKeeper / line: " + line);
					return;
				} else {
					f.delete();
				}
			}

			var langs = Intl.get_language_names();
			string lang = langs.length > 0 ? langs[0] : "en_US";

			// Spanish site is down
			if (lang == "es_ES") {
				lang = "es_MX";
			}

			f.create(FileCreateFlags.NONE).write(("https://news.ycombinator.com/rss\nhttps://news.google.com/rss?hl=" + lang.replace("_", "-")).data);
		} catch (Error err) {
			warning("SourceKeeper: " + err.message);
		}
	}

	public string[] list() {
		var o = new string[0];
		var f = File.new_for_path(this.path);

		try {
			var s = new DataInputStream(f.read());
			for (string? line = ""; line != null; line = s.read_line()) {
				if (line.length > 0)
					o += line;
			}
		} catch(Error err) {
			warning("SourceKeeper.list: " + err.message);
		}
		return o;
	}

	public void add(string url) {
		try {
			var f = File.new_for_path(this.path);
			f.append_to(FileCreateFlags.NONE).write((url + "\n").data);
		} catch(Error err) {
			warning("SourceKeeper.add: " + err.message);
		}
	}

	public void remove(string url) {
		var o = "";

		var f = File.new_for_path(this.path);

		try {
			var s = new DataInputStream(f.read());
			for (string? line = ""; line != null; line = s.read_line()) {
				if (line.length > 0 && line != url)
					o += line + "\n";
			}

			if (f.query_exists()) {
				f.delete();
			}

			f.create(FileCreateFlags.NONE).write(o.data);
		} catch(Error err) {
			warning("SourceKeeper.remove: " + err.message);
		}
	}
}
