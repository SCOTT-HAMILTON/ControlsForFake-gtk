using Gtk;

public class SinkComboBoxHandler  {
	private Gtk.ListStore store;
	private Gtk.TreeView view;
	private CellRendererText textCell;
	private CellRendererToggle toggleCell;
	private Gtk.TreeViewColumn textColumn;
	private Gtk.TreeViewColumn toggleColumn;

	private Gtk.MenuButton button;
	private Gtk.Popover popover;
	private Gtk.Label label;

	public void onCellToggled(string path) {
		TreeIter row;
		store.get_iter_from_string(out row, path);
		Value isCheckedValue;
		store.get_value(row, 3, out isCheckedValue);
		isCheckedValue.set_boolean(!isCheckedValue.get_boolean());
		store.set_value(row, 3, isCheckedValue);
		// TODO: Update sink count for the label
		var selectedSinkCount = 0;
		store.foreach((model, path, row) => {
			Value isCheckedV;
			store.get_value(row, 3, out isCheckedV);
			if (isCheckedV.get_boolean())
				++selectedSinkCount;
			return false;
		});
		if (selectedSinkCount == 1)
			label.set_text(selectedSinkCount.to_string()+" "+_("sink selected"));
		else
			label.set_text(selectedSinkCount.to_string()+" "+_("sinks selected"));
	}

	public void textCellDataFunction (CellLayout cell_layout, CellRenderer cell, TreeModel tree_model, TreeIter row) {
		Value descriptionValue;
		store.get_value(row, 0, out descriptionValue);
		var description = descriptionValue.get_string();
		textCell.set_fixed_size(206, 30);
		textCell.text = description;
	}
	public void toggleCellDataFunction (CellLayout cell_layout, CellRenderer cell, TreeModel tree_model, TreeIter row) {
		Value isCheckedValue;
		store.get_value(row, 3, out isCheckedValue);
		var isChecked = isCheckedValue.get_boolean();
		toggleCell.set_fixed_size(30, 30);
		toggleCell.set_active(isChecked);
	}

	public SinkComboBoxHandler (ref Gtk.TreeView treeView, ref Gtk.MenuButton button, ref Gtk.Popover popover, ref Gtk.Label label) {
		store = new Gtk.ListStore(4, typeof(string),	// description
									 typeof(string),	// name
									 typeof(int),		// index
									 typeof(bool));		// isChecked
		this.view = treeView;	
		view.set_model(store);
		textCell = new CellRendererText();
		textCell.ellipsize = Pango.EllipsizeMode.END;
		toggleCell = new CellRendererToggle();
		toggleCell.toggled.connect(onCellToggled);
		this.textColumn = new Gtk.TreeViewColumn.with_attributes("", textCell);
		textColumn.set_cell_data_func(textCell, textCellDataFunction);
		this.toggleColumn = new Gtk.TreeViewColumn.with_attributes("", toggleCell);
		toggleColumn.set_cell_data_func(toggleCell, toggleCellDataFunction);
		view.append_column(toggleColumn);
		view.append_column(textColumn);

		this.button = button;
		this.popover = popover;
		this.label = label;
		this.button.set_popover(this.popover);
	}

	public void update() {
		Fake.clear_commands();
		Fake.get_sink_list();
		Fake.run_commands();
		SinkInfos[] list;	

		// TODO: check if this fails
		var size = Fake.extract_sink_list(out list);
		FakeUtils.print_sink_info_list(list, size);

		store.clear();
		if (size == 0) {
			// Nothing in the list
			TreeIter row;
			store.append(out row);
			store.set(row,
						0, _("No application available"),
						1, "",
						2, -1,
						3, false);
		}
		for (int ctr = 0; ctr < size; ++ctr) {
			TreeIter row;
			store.append(out row);
			store.set(row,
					0, list[ctr].description,
					1, list[ctr].name,
					2, list[ctr].index,
					3, ctr==0);
			if (ctr == 0) {
				label.set_text("1 "+_("sink selected"));
			}
		}
	}
}

