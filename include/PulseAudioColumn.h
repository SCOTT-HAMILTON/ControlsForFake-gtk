#ifndef PULSEAUDIO_COLUMN_H
#define PULSEAUDIO_COLUMN_H

#include <gtkmm/treemodel.h>
#include <gtkmm/treemodelcolumn.h>

class PulseAudioColumn : public Gtk::TreeModel::ColumnRecord
{
public:
	PulseAudioColumn();
	Gtk::TreeModelColumn<Glib::ustring> description;
	Gtk::TreeModelColumn<Glib::ustring> name;
	Gtk::TreeModelColumn<int> index;
	Gtk::TreeModelColumn<bool> isChecked;
};

#endif //PULSEAUDIO_COLUMN_H
