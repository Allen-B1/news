namespace News {
	void AboutDialog() {
		var dialog = new Gtk.AboutDialog();
		dialog.artists = {"mirkobromin"};
		dialog.authors = {"Allen B"};
		dialog.program_name = "News";
		dialog.comments = "View the news easily & quickly";
		dialog.version = "1.1";
		dialog.license = """This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.""";
		dialog.wrap_license = true;

		dialog.website = "https://github.com/Allen-B1/news/";
		dialog.website_label = "Website";		

		dialog.run();
		dialog.destroy();

		Process.exit(0);
	}
}
