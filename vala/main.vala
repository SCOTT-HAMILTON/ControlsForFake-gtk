using Gtk;

int main (string[] args) {
    Gtk.init (ref args);

	if (!Thread.supported()) {
        stderr.printf("Cannot run without threads.\n");
        return 1;
    }

    Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GETTEXT_LOCALES_DIR);
    Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    Intl.textdomain (Config.GETTEXT_PACKAGE);
	
	MyApplication app;
	app =  new MyApplication ();
	return app.run (args);
	// Fake.clear_commands();
	// Fake.get_sink_input_list();
	// Fake.run_commands();

	// SinkInputInfos[] sink_input_list;	
	// var size = Fake.extract_sink_input_list(out sink_input_list);
	// stderr.printf("Size : %zu\n", size);
	// FakeUtils.print_sink_input_info_list(sink_input_list, size);

}
