#include <gtkmm.h>
#include <pangomm.h>
#include <FakeLib.h>
#include <FakeLibUtils.hpp>
#include <glib/gi18n.h>
#include <clocale>

#include "PulseAudioColumn.h"
#include "SlideAnimation.h"

#include <iostream>

static std::string oggFile;
static Glib::RefPtr<Gtk::Builder> builderRef;
static Gtk::CellRendererText cell;
static Gtk::Window* windowPtr = nullptr;
static Gtk::Fixed* canvasPtr = nullptr;
static Gtk::FileChooserButton* openAudioFileButtonPtr = nullptr;
static Gtk::ComboBox* sinkInputComboPtr = nullptr;
static Gtk::MenuButton* switchAudioStreamButtonPtr = nullptr;
static Gtk::Menu* switchAudioStreamMenuPtr = nullptr;
static Gtk::Entry* audioFileEntryPtr = nullptr;
static Gtk::MenuButton* sinkMenuButtonPtr = nullptr;
static Gtk::Label* sinksMenuButtonLabelPtr = nullptr;
static Gtk::CellRendererToggle* sinkCellTogglePtr = nullptr;
static Gtk::TreeViewColumn* sinkToggleColumnPtr = nullptr;
static Gtk::TreeViewColumn* sinkTextColumnPtr = nullptr;
static Gtk::Button* runButtonPtr = nullptr;
static Glib::RefPtr<Gtk::ListStore> sinkStoreRef;
static Glib::RefPtr<Gtk::ListStore> sinkInputStoreRef;
static PulseAudioColumn columns;

static SlideAnimation* fileChooserAnimPtr = nullptr;
static SlideAnimation* fileEntryAnimPtr = nullptr;

static guint sinkInputCount = 0;

void on_fileChooserAnim_update(float newValue) {
	canvasPtr->move(*openAudioFileButtonPtr, newValue, 18);
	canvasPtr->move(*sinkInputComboPtr, newValue, 18);
	canvasPtr->move(*switchAudioStreamButtonPtr, newValue+250, 18);
}
void on_fileEntryAnim_update(float newValue) {
	canvasPtr->move(*audioFileEntryPtr, newValue, 18);
}
void on_fileChooserAnim_ended() {
	windowPtr->remove_tick_callback(fileChooserAnimPtr->id());
}
void on_fileEntryAnim_ended() {
	windowPtr->remove_tick_callback(fileEntryAnimPtr->id());
}

void updateRunButtonSensitiveness() {
	const auto state = switchAudioStreamMenuPtr->property_active();
	switch (state) {
		// Audio File
		case 0: {
			runButtonPtr->set_sensitive(
				audioFileEntryPtr->get_text() != ""
			);
			break;
		}
		// Application
		case 1: {
			runButtonPtr->set_sensitive(
				sinkInputCount > 0
			);
			break;
		}
	}
}

extern "C" {
void on_openAudioFileButton_file_set(GtkFileChooserButton* button) {
	auto selectedFile = gtk_file_chooser_get_filename((GtkFileChooser*)button);
	if (selectedFile) {
		oggFile = selectedFile;
		std::cerr << "ogg file : `" << oggFile << "`\n";
		audioFileEntryPtr->set_text(oggFile.c_str());
		g_free(selectedFile);
	}
	canvasPtr->move(*audioFileEntryPtr, -550, 18);
	audioFileEntryPtr->show();

	fileChooserAnimPtr = SlideAnimation::startNewAnimation(330, 570, 1000, windowPtr);
	fileEntryAnimPtr = SlideAnimation::startNewAnimation(-550, 30, 1000, windowPtr);

	fileChooserAnimPtr->signal_update().connect(sigc::ptr_fun(on_fileChooserAnim_update));
	fileEntryAnimPtr->signal_update().connect(sigc::ptr_fun(on_fileEntryAnim_update));

	fileChooserAnimPtr->signal_finished().connect(sigc::ptr_fun(on_fileChooserAnim_ended));
	fileEntryAnimPtr->signal_finished().connect(sigc::ptr_fun(on_fileEntryAnim_ended));
}
}

void on_sink_toggled(const Glib::ustring& path) {
	auto row = *sinkStoreRef->get_iter(path);	
	row[columns.isChecked] = !row[columns.isChecked];
	if (row[columns.isChecked]) {
		sinksMenuButtonLabelPtr->set_text(row[columns.description]);
	}
}

void on_cell_data_extra(const Gtk::TreeModel::const_iterator& iter)
{
	auto row = *iter;
	const Glib::ustring description = row[columns.description];
	const int index = row[columns.index];
	const bool isChecked = row[columns.isChecked];
	cell.set_fixed_size(206, 30);
	cell.property_text() = description;
	cell.property_foreground() = (index==-1) ? "gray" : "black";
}
void on_treecell_data_extra(Gtk::CellRenderer*, const Gtk::TreeModel::iterator& iter)
{
	auto row = *iter;
	const Glib::ustring description = row[columns.description];
	const int index = row[columns.index];
	const bool isChecked = row[columns.isChecked];
	cell.set_fixed_size(206, 30);
	cell.property_text() = description;
	cell.property_foreground() = (index==-1) ? "gray" : "black";
}

static void updateSourceOutputs (Gtk::ComboBox* combo)
{
	FakeLib fakeLib;
	auto result = fakeLib
		.clear_commands()
		.get_source_output_list()
		.run_commands();
	info_list<source_output_infos_t> source_output_list;
	try {
		source_output_list = FakeLibUtils::extract<info_list<source_output_infos_t>>(result);
		FakeLibUtils::print_source_output_list(source_output_list);
	} catch (ObjectNotFoundError&) {
		std::cerr << "[error] Couldn't fetch source output list, cancelling";
		return;
	}
	auto store = Gtk::ListStore::create(columns);
	combo->set_model(store);
	cell.property_ellipsize() = Pango::ELLIPSIZE_END;
	cell.property_ellipsize_set() = true;

	store->clear();
	combo->clear();
	if (!source_output_list[0].initialized) {
		// Nothing in the list
		auto row = *(store->append());
		row[columns.description] = _("No application available");
		row[columns.index] = -1;
		combo->set_active(row);
	}
    for (int ctr = 0; ctr < info_list_size; ++ctr) {
		// We assume that as soon as we hit initialized source outputs, we've reached the 
		// end of the initialized source outputs
        if (!source_output_list[ctr].initialized) {
                break;
        }
		auto row = *(store->append());
		row[columns.description] = source_output_list[ctr].process_binary;
		row[columns.name] = source_output_list[ctr].name;
		row[columns.index] = source_output_list[ctr].index;
		row[columns.isChecked] = false;
		if (ctr == 0)combo->set_active(row);
	}
	combo->set_cell_data_func(cell, sigc::ptr_fun(on_cell_data_extra));
	combo->pack_start(cell, false);
}
static void updateSources (Gtk::ComboBox* combo)
{
	FakeLib fakeLib;
	auto result = fakeLib
		.clear_commands()
		.get_source_list()
		.run_commands();
	info_list<source_infos_t> source_list;
	try {
		source_list = FakeLibUtils::extract<info_list<source_infos_t>>(result);
		FakeLibUtils::print_source_list(source_list);
	} catch (ObjectNotFoundError&) {
		std::cerr << "[error] Couldn't fetch source list, cancelling";
		return;
	}
	PulseAudioColumn columns;
	auto store = Gtk::ListStore::create(columns);
	combo->set_model(store);
	cell.property_ellipsize() = Pango::ELLIPSIZE_END;
	cell.property_ellipsize_set() = true;

	store->clear();
	combo->clear();
	if (!source_list[0].initialized) {
		// Nothing in the list
		auto row = *(store->append());
		row[columns.description] = _("No input device available");
		combo->set_active(row);
	}
    for (int ctr = 0; ctr < info_list_size; ++ctr) {
		// We assume that as soon as we hit initialized sources, we've reached the 
		// end of the initialized sources
        if (!source_list[ctr].initialized) {
                break;
        }
		auto row = *(store->append());
		row[columns.description] = source_list[ctr].description;
		row[columns.name] = source_list[ctr].name;
		row[columns.index] = source_list[ctr].index;
		row[columns.isChecked] = false;
		if (ctr == 0)combo->set_active(row);
	}
	combo->set_cell_data_func(cell, sigc::ptr_fun(on_cell_data_extra));
	combo->pack_start(cell, false);
}
static void updateSinks (Gtk::TreeView* treeView)
{
	FakeLib fakeLib;
	auto result = fakeLib
		.clear_commands()
		.get_sink_list()
		.run_commands();
	info_list<sink_infos_t> sink_list;
	try {
		sink_list = FakeLibUtils::extract<info_list<sink_infos_t>>(result);
		FakeLibUtils::print_sink_list(sink_list);
	} catch (ObjectNotFoundError&) {
		std::cerr << "[error] Couldn't fetch sink list, cancelling";
		return;
	}
	PulseAudioColumn columns;
	auto store = Gtk::ListStore::create(columns);
	sinkStoreRef = store;
	treeView->set_model(store);
	cell.property_ellipsize() = Pango::ELLIPSIZE_END;
	cell.property_ellipsize_set() = true;

	store->clear();
	treeView->remove_all_columns();
	if (!sink_list[0].initialized) {
		// Nothing in the list
		auto row = *(store->append());
		row[columns.description] = _("No output device available");
		row[columns.isChecked] = false;
	}
    for (int ctr = 0; ctr < info_list_size; ++ctr) {
		// We assume that as soon as we hit initialized sinks we've reached the 
		// end of the initialized sinks
		if (!sink_list[ctr].initialized) {
                break;
        }
		auto row = *(store->append());
		row[columns.description] = sink_list[ctr].description;
		row[columns.name] = sink_list[ctr].name;
		row[columns.index] = sink_list[ctr].index;
		row[columns.isChecked] = false;
		if (ctr == 0) {
			sinksMenuButtonLabelPtr->set_text(sink_list[ctr].description);
			row[columns.isChecked] = true;
		}
	}

	sinkCellTogglePtr = new Gtk::CellRendererToggle();
	sinkCellTogglePtr->set_radio(true);
	sinkCellTogglePtr->set_activatable(true);
	sinkCellTogglePtr->signal_toggled().connect(sigc::ptr_fun(on_sink_toggled));
	sinkToggleColumnPtr = new Gtk::TreeViewColumn("", *sinkCellTogglePtr);
	sinkToggleColumnPtr->add_attribute(*sinkCellTogglePtr, "active", columns.isChecked);
	sinkTextColumnPtr = new Gtk::TreeViewColumn("", cell);
	sinkTextColumnPtr->set_cell_data_func(cell, sigc::ptr_fun(on_treecell_data_extra));

	treeView->append_column(*sinkToggleColumnPtr);
	treeView->append_column(*sinkTextColumnPtr);
}
static void updateSinkInputs (Gtk::ComboBox* combo)
{
	FakeLib fakeLib;
	auto result = fakeLib
		.clear_commands()
		.get_sink_input_list()
		.run_commands();
	info_list<sink_input_infos_t> sink_input_list;
	try {
		sink_input_list = FakeLibUtils::extract<info_list<sink_input_infos_t>>(result);
		FakeLibUtils::print_sink_input_list(sink_input_list);
	} catch (ObjectNotFoundError&) {
		std::cerr << "[error] Couldn't fetch sink input list, cancelling";
		return;
	}
	sinkInputStoreRef = Gtk::ListStore::create(columns);
	combo->set_model(sinkInputStoreRef);
	cell.property_ellipsize() = Pango::ELLIPSIZE_END;
	cell.property_ellipsize_set() = true;

	sinkInputStoreRef->clear();
	combo->clear();
	if (!sink_input_list[0].initialized) {
		// Nothing in the list
		auto row = *(sinkInputStoreRef->append());
		row[columns.description] = _("No application available");
		row[columns.index] = -1;
		combo->set_active(row);
	}
	sinkInputCount = 0;
    for (int ctr = 0; ctr < info_list_size; ++ctr) {
		// We assume that as soon as we hit initialized sink inputs, we've reached the 
		// end of the initialized sink inputs
        if (!sink_input_list[ctr].initialized) {
                break;
        }
		auto row = *(sinkInputStoreRef->append());
		row[columns.description] = sink_input_list[ctr].process_binary;
		row[columns.name] = sink_input_list[ctr].name;
		row[columns.index] = sink_input_list[ctr].index;
		row[columns.isChecked] = false;
		++sinkInputCount;
		if (ctr == 0)combo->set_active(row);
	}
	combo->set_cell_data_func(cell, sigc::ptr_fun(on_cell_data_extra));
	combo->pack_start(cell, false);
	updateRunButtonSensitiveness();
}

static void on_switch_to_audio_file_stream () {
	/* std::cerr << "Switching to audio file stream\n"; */
	Gtk::FileChooserButton* openAudioFileButton;
	Gtk::ComboBox* sinkInputCombo;
	builderRef->get_widget("openAudioFileButton", openAudioFileButton);
	builderRef->get_widget("sinkInputCombo", sinkInputCombo);
	openAudioFileButton->show();
	sinkInputCombo->hide();
}
static void on_switch_to_application_stream () {
	/* std::cerr << "Switching to audio file stream\n"; */
	Gtk::FileChooserButton* openAudioFileButton;
	Gtk::ComboBox* sinkInputCombo;
	builderRef->get_widget("openAudioFileButton", openAudioFileButton);
	builderRef->get_widget("sinkInputCombo", sinkInputCombo);
	openAudioFileButton->hide();
	sinkInputCombo->show();
}

int main (int argc, char **argv)
{
	setlocale (LC_ALL, "");
	std::cerr << "text domain : " << GETTEXT_LOCALES_DIR << '\n';
	bindtextdomain (GETTEXT_PACKAGE, GETTEXT_LOCALES_DIR);
	bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
	textdomain (GETTEXT_PACKAGE);

	auto app = Gtk::Application::create(argc, argv, "org.scotthamilton.controlsforfake-gtk");

	//Load the GtkBuilder file and instantiate its widgets:
	
	auto builder = Gtk::Builder::create();
	builderRef = builder;
	try
	{
		builder->add_from_resource("/ui/main-fixed.glade");
	}
	catch(const Glib::FileError& ex)
	{
		std::cerr << "FileError: " << ex.what() << std::endl;
		return 1;
	}
	catch(const Glib::MarkupError& ex)
	{
		std::cerr << "MarkupError: " << ex.what() << std::endl;
		return 1;
	}
	catch(const Gtk::BuilderError& ex)
	{
		std::cerr << "BuilderError: " << ex.what() << std::endl;
		return 1;
	}
	catch(const Gio::ResourceError& ex)
	{
		std::cerr << "ResourceError: " << ex.what() << std::endl;
		return 1;
	}

	//Get the GtkBuilder-instantiated Dialog:
	Gtk::Window* window = nullptr;
	builder->get_widget("window", window);
	windowPtr = window;

	builder->get_widget("canvas", canvasPtr);
	builder->get_widget("openAudioFileButton", openAudioFileButtonPtr);
	builder->get_widget("audioFileEntry", audioFileEntryPtr);

	auto actionGroup = Gio::SimpleActionGroup::create();
	actionGroup->add_action("switchToAudioFileStream", sigc::ptr_fun(on_switch_to_audio_file_stream));
	actionGroup->add_action("switchToApplicationStream", sigc::ptr_fun(on_switch_to_application_stream));
	window->insert_action_group("controlsforfake", actionGroup);
	Glib::ustring menu_info =
	  "<interface>"
	  "  <menu id='switchAudioStreamMenu'>"
	  "    <section>"
	  "      <item>"
	  "        <attribute name='label' translatable='yes'>"+std::string(_("Audio OGG _File"))+"</attribute>"
	  "        <attribute name='action'>controlsforfake.switchToAudioFileStream</attribute>"
	  "      </item>"
	  "      <item>"
	  "        <attribute name='label' translatable='yes'>"+std::string(_("_Application"))+"</attribute>"
	  "        <attribute name='action'>controlsforfake.switchToApplicationStream</attribute>"
	  "      </item>"
	  "    </section>"
	  "  </menu>"
	  "</interface>";
	builder->add_from_string(menu_info);
	auto object = builder->get_object("switchAudioStreamMenu");
	auto gmenu = Glib::RefPtr<Gio::Menu>::cast_dynamic(object);
	auto menu = new Gtk::Menu(gmenu);
	switchAudioStreamMenuPtr = menu;
	
	Gtk::MenuButton* menuButton;
	builder->get_widget("switchAudioStreamButton", menuButton);
	switchAudioStreamButtonPtr = menuButton;
	menuButton->set_menu(*menu);

	Gtk::ComboBox* sourceOutputCombo = nullptr;
	builder->get_widget("sourceOutputCombo", sourceOutputCombo);
	Gtk::ComboBox* sourceCombo = nullptr;
	builder->get_widget("sourceCombo", sourceCombo);
	Gtk::TreeView* sinkTreeView = nullptr;
	builder->get_widget("sinkTreeView", sinkTreeView);
	Gtk::ComboBox* sinkInputCombo = nullptr;
	builder->get_widget("sinkInputCombo", sinkInputCombo);
	sinkInputComboPtr = sinkInputCombo;
	
	Gtk::MenuButton* sinkMenuButton = nullptr;
	builder->get_widget("sinkMenuButton", sinkMenuButton);
	Gtk::Label* sinksMenuButtonLabel = nullptr;
	builder->get_widget("sinksMenuButtonLabel", sinksMenuButtonLabel);
	sinksMenuButtonLabelPtr = sinksMenuButtonLabel;
	sinksMenuButtonLabel->set_ellipsize(Pango::ELLIPSIZE_END);
	sinksMenuButtonLabel->property_ellipsize() = Pango::ELLIPSIZE_END;
	
	sinkMenuButtonPtr = sinkMenuButton;
	Gtk::Popover* sinkPopover = nullptr;
	builder->get_widget("sinkPopover", sinkPopover);
	sinkMenuButton->set_popover(*sinkPopover);

	builder->get_widget("runButton", runButtonPtr);
	runButtonPtr->set_sensitive(false);
	
	updateSourceOutputs(sourceOutputCombo);
	updateSources(sourceCombo);
	updateSinks(sinkTreeView);
	updateSinkInputs(sinkInputCombo);

	switchAudioStreamMenuPtr->signal_selection_done().connect(sigc::ptr_fun(updateRunButtonSensitiveness));
	audioFileEntryPtr->property_text().signal_changed().connect(sigc::ptr_fun(updateRunButtonSensitiveness));

    gtk_builder_connect_signals(builder->gobj(), NULL);

	app->run(*window);
	delete menu;
	if (sinkCellTogglePtr) 
		delete sinkCellTogglePtr;
	if (sinkToggleColumnPtr) 
		delete sinkToggleColumnPtr;
	if (sinkTextColumnPtr) 
		delete sinkTextColumnPtr;

	return 0;
}
