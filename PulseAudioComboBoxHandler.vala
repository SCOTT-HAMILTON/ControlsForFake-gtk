using Gtk;

public class PulseAudioComboBoxHandler {
	protected Gtk.ListStore store;
	protected Gtk.ComboBox combo;
	protected CellRendererText textCell;
	public PulseAudioComboBoxHandler (ref Gtk.ComboBox comboBox) {
		store = new Gtk.ListStore(4, typeof(string),	// description
									 typeof(string),	// name
									 typeof(int),		// index
									 typeof(bool));		// isChecked
		this.combo = comboBox;
		combo.set_model(store);
		textCell = new CellRendererText();
		textCell.ellipsize = Pango.EllipsizeMode.END;
		combo.set_cell_data_func(textCell, textCellDataFunction);
		combo.pack_start(textCell, false);
	}
	public void textCellDataFunction (CellLayout cell_layout, CellRenderer cell, TreeModel tree_model, TreeIter row) {
		Value descriptionValue, indexValue, isCheckedValue;
		store.get_value(row, 0, out descriptionValue);
		store.get_value(row, 2, out indexValue);
		store.get_value(row, 3, out isCheckedValue);
		var description = descriptionValue.get_string();
		var index = indexValue.get_int();
		textCell.set_fixed_size(206, 30);
		textCell.text = description;
		textCell.foreground = (index==-1) ? "gray" : "black";
	}
}
