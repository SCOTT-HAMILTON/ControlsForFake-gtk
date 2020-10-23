using Gtk;

public class Handler {
	public Builder builder;
	public Window window;
	public Gtk.Fixed canvas;
	public Gtk.ComboBox sinkInputCombo;
	public Gtk.Entry audioFileEntry;
	public Gtk.FileChooserButton openAudioFileButton;

	public GLib.MenuModel switchAudioStreamMenuModel;
	public Gtk.MenuButton switchAudioStreamButton;

	public void switchToAudioFileStream () {
		canvas.move(audioFileEntry, -550, 18);
		audioFileEntry.set_visible(true);
		openAudioFileButton.set_visible(true);
		sinkInputCombo.set_visible(false);
	}
	public void switchToApplicationStream () {
		audioFileEntry.set_visible(false);
		openAudioFileButton.set_visible(false);
		sinkInputCombo.set_visible(true);
	}

	public Handler() throws Error {
		this.window = build_ui();

		var actionGroup = new SimpleActionGroup();
		var switchToAudioFileStream = new GLib.SimpleAction("switchToAudioFileStream", null);
		switchToAudioFileStream.activate.connect(() => {
			stderr.printf("switching to audio file stream");
		});
		var switchToApplicationStream = new GLib.SimpleAction("switchToApplicationStream", null);
		switchToApplicationStream.activate.connect(() => {
			stderr.printf("switching to application stream");
		});
		actionGroup.insert(switchToAudioFileStream);
		actionGroup.insert(switchToApplicationStream);
		switchToAudioFileStream.set_accel_path("controlsforfake.switchToAudioFileStream", "");
		switchToApplicationStream.set_accel_path("controlsforfake.switchToApplicationStream", "");
		// window.insert_action_group("controlsforfake", actionGroup);
		// var menu = builder.get_object("switcherMenu") as Gtk.Menu;
		
		var menuBuilder = new Gtk.Builder();
		menuBuilder.add_from_resource ("/ui/menus-common.ui");
		switchAudioStreamMenuModel =  menuBuilder.get_object("switcherMenu") as GLib.MenuModel;
		switchAudioStreamButton.set_menu_model(switchAudioStreamMenuModel);
		switchAudioStreamButton.set_active(true);
		switchAudioStreamButton.insert_action_group("controlsforfake", actionGroup);
		// menu.append("Audio Ogg _File", "controlsforfake.switchToAudioFileStream");
		// menu.append("_Application", "controlsforfake.switchToApplicationStream");
	}
	[CCode (cname = "on_window_delete_event")]
	public void on_window_delete_event() {
		stderr.printf("Window deleted\n");
		// wait for thread to finish
		// subscribeThreadCanRun = false;
		// if (subscribeThread)
		// 	subscribeThread->join();
		Gtk.main_quit();
	}
	private Window build_ui() throws Error {
		builder = new Builder();
        builder.add_from_resource ("/ui/main-fixed.glade");
        builder.connect_signals (this);
        var window = builder.get_object ("window") as Window;
		canvas = builder.get_object("canvas") as Gtk.Fixed;
		sinkInputCombo = builder.get_object("sinkInputCombo") as Gtk.ComboBox;
		switchAudioStreamButton = builder.get_object("switchAudioStreamButton") as Gtk.MenuButton;
		audioFileEntry = builder.get_object("audioFileEntry") as Gtk.Entry;
		openAudioFileButton = builder.get_object("openAudioFileButton") as Gtk.FileChooserButton;
		switchToAudioFileStream();

		return window;
	}
}
