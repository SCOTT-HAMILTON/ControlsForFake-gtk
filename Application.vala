using Gtk;


public class MyApplication : Gtk.Application {
	private enum InputStreamMethod {
		AUDIO_FILE,
		APPLICATION
	}
	private InputStreamMethod inputStreamMethod;
	private Builder builder;
	private static ApplicationWindow window;
	private static Gtk.Fixed canvas;

	private static Gtk.TreeView sinkTreeView;
	private static Gtk.MenuButton sinkMenuButton;
	private static Gtk.Popover sinkPopover;
	private static Gtk.Label sinksMenuButtonLabel;

	private static Gtk.ComboBox sinkInputCombo;
	private static Gtk.ComboBox sourceCombo;
	private static Gtk.ComboBox sourceOutputCombo;
	private static Gtk.Entry audioFileEntry;
	private static Gtk.FileChooserButton openAudioFileButton;

	private static GLib.MenuModel switchAudioStreamMenuModel;
	private static Gtk.MenuButton switchAudioStreamButton;

	private static Gtk.Button runButton;

	private static string oggFile;

	private SinkComboBoxHandler sinkComboBoxHandler;
	private SinkInputComboBoxHandler sinkInputComboBoxHandler;
	private SourceComboBoxHandler sourceComboBoxHandler;
	private SourceOutputComboBoxHandler sourceOutputComboBoxHandler;
	private SubscribeAndListenThread subscribtionThread;

	public MyApplication () {
		Object(application_id: "org.scotthamilton.controlsforfake-gtk",
				flags: ApplicationFlags.FLAGS_NONE);
		this.subscribtionThread = new SubscribeAndListenThread();
		SubscribeAndListenThread.singleton = this.subscribtionThread;
		this.subscribtionThread.newEvent.connect(onNewPulseAudioEvent);
		subscribtionThread.start();
		this.shutdown.connect(() => {
			stderr.printf("[log] Stopping subscribtion thread...\n");
			subscribtionThread.stop();
			stderr.printf("[log] Subscribtion thread stopped\n");
		});
	}

	private void onNewPulseAudioEvent(PaSubscriptionEvent event) {
		if ((event in PaSubscriptionEvent.MODULE) ||
			(event in PaSubscriptionEvent.NEW) ||
			(event in PaSubscriptionEvent.REMOVE) ||
			(event in PaSubscriptionEvent.SOURCE_OUTPUT) ||
			(event in PaSubscriptionEvent.SINK_INPUT)
		   ) {
			updateModels();
		}
	}

	private void updateModels() {
		if (sinkComboBoxHandler != null)
			sinkComboBoxHandler.update();
		if (sinkInputComboBoxHandler != null)
			sinkInputComboBoxHandler.update();
		if (sourceComboBoxHandler != null)
			sourceComboBoxHandler.update();
		if (sourceOutputComboBoxHandler != null)
			sourceOutputComboBoxHandler.update();
	}

	public void switchToAudioFileStream () {
		inputStreamMethod = AUDIO_FILE;
		audioFileEntry.set_visible(true);
		openAudioFileButton.set_visible(true);
		sinkInputCombo.set_visible(false);
		updateRunButtonSensitivity();
	}
	public void switchToApplicationStream () {
		inputStreamMethod = APPLICATION;
		audioFileEntry.set_visible(false);
		openAudioFileButton.set_visible(false);
		sinkInputCombo.set_visible(true);
		updateRunButtonSensitivity();
	}

	private void setupSwitchStreamMenu () {
		canvas.move(audioFileEntry, -550, 18);
		var switchToAudioFileStreamAction = new GLib.SimpleAction("switch-to-audio-file-stream", null);
		switchToAudioFileStreamAction.activate.connect(switchToAudioFileStream);
		var switchToApplicationStreamAction = new GLib.SimpleAction("switch-to-application-stream", null);
		switchToApplicationStreamAction.activate.connect(switchToApplicationStream);
		this.add_action(switchToAudioFileStreamAction);
		this.add_action(switchToApplicationStreamAction);
		this.activate_action("app.switch-to-audio-file_stream", null);
		this.activate_action("app.switch-to-application-stream", null);
		this.set_accels_for_action("app.switch-to-audio-file-stream", {"<Primary>f"});
		this.set_accels_for_action("app.switch-to-application-stream", {"<Primary>a"});
		
		var menuBuilder = new Gtk.Builder();
		try {
			menuBuilder.add_from_resource ("/ui/menus-common.ui");
		} catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
			return;
		}
		switchAudioStreamMenuModel =  menuBuilder.get_object("switcherMenu") as GLib.MenuModel;
		switchAudioStreamButton.set_menu_model(switchAudioStreamMenuModel);
		switchAudioStreamButton.set_active(true);
	}

	void updateRunButtonSensitivity () {
		switch (inputStreamMethod) {
			case AUDIO_FILE:
				runButton.set_sensitive(audioFileEntry.get_text() != "");
				// stderr.printf("Sensitive : %s\n", runButton.get_sensitive().to_string());
				break;
			case APPLICATION:
				runButton.set_sensitive(this.sinkInputComboBoxHandler.getSinkInputCount() > 0);
				break;
		}
	}

	private void setupComboBoxes () {
		this.sinkComboBoxHandler = new SinkComboBoxHandler(
										ref sinkTreeView,
										ref sinkMenuButton,
										ref sinkPopover,
										ref sinksMenuButtonLabel);
		this.sinkInputComboBoxHandler = new SinkInputComboBoxHandler(ref sinkInputCombo);
		this.sourceComboBoxHandler = new SourceComboBoxHandler(ref sourceCombo);
		this.sourceOutputComboBoxHandler = new SourceOutputComboBoxHandler(ref sourceOutputCombo);
		updateModels();
	}

	protected override void activate () {
		// Create the window of this application and show it
		try {
			window = build_ui();
		} catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
			return;
		}
		setupSwitchStreamMenu();
		setupComboBoxes();
		switchToAudioFileStream();
		audioFileEntry.notify.connect ((s, p) => {
			if (p.name == "text") {
				updateRunButtonSensitivity();
			}
		});
		this.add_window(window);
		window.show_all();
	}

	[CCode (cname = "on_openAudioFileButton_file_set")]
	public static void on_openAudioFileButton_file_set(Gtk.FileChooserButton button) {
		var file = button.get_file().get_path();
		oggFile = file;
		stderr.printf("Audio File Set file : `%s`\n", oggFile);
		audioFileEntry.set_text(oggFile);
		canvas.move(audioFileEntry, -550, 10);
		audioFileEntry.set_visible(true);
		var animation1 = new Animation(330, 560, 1000, window);
		animation1.update.connect((value) => {
			canvas.move(openAudioFileButton, (int)value, 18);
			canvas.move(sinkInputCombo, (int)value, 18);
			canvas.move(switchAudioStreamButton, (int)value+250, 18);
		});
		animation1.finished.connect(() => {
			window.remove_tick_callback(animation1.id());
		});
		var animation2 = new Animation(-550, 30, 1000, window);
		animation2.update.connect((value) => {
			canvas.move(audioFileEntry, (int)value, 18);
		});
		animation2.finished.connect(() => {
			window.remove_tick_callback(animation2.id());
		});
	}

	private ApplicationWindow build_ui() throws Error {
		builder = new Builder();
        builder.add_from_resource ("/ui/main-fixed.glade");
        builder.connect_signals (this);
        var window = builder.get_object ("window") as ApplicationWindow;
		canvas = builder.get_object("canvas") as Gtk.Fixed;

		sinkTreeView = builder.get_object("sinkTreeView") as Gtk.TreeView;
		sinkMenuButton = builder.get_object("sinkMenuButton") as Gtk.MenuButton;
		sinkPopover = builder.get_object("sinkPopover") as Gtk.Popover;
		sinksMenuButtonLabel = builder.get_object("sinksMenuButtonLabel") as Gtk.Label;

		sinkInputCombo = builder.get_object("sinkInputCombo") as Gtk.ComboBox;
		sourceCombo  = builder.get_object("sourceCombo") as Gtk.ComboBox;
		sourceOutputCombo  = builder.get_object("sourceOutputCombo") as Gtk.ComboBox;
		switchAudioStreamButton = builder.get_object("switchAudioStreamButton") as Gtk.MenuButton;
		audioFileEntry = builder.get_object("audioFileEntry") as Gtk.Entry;
		openAudioFileButton = builder.get_object("openAudioFileButton") as Gtk.FileChooserButton;

		runButton = builder.get_object("runButton") as Gtk.Button;

		return window;
	}
}
