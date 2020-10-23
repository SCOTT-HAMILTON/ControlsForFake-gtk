using Gtk;

public class SourceOutputComboBoxHandler : PulseAudioComboBoxHandler {

	public SourceOutputComboBoxHandler (ref Gtk.ComboBox comboBox) {
		base(ref comboBox);
	}

	public void update() {
		Fake.clear_commands();
		Fake.get_source_output_list();
		Fake.run_commands();
		SourceOutputInfos[] list;	

		// TODO: check if this fails
		var size = Fake.extract_source_output_list(out list);
		FakeUtils.print_source_output_info_list(list, size);

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
			combo.set_active_iter(row);
		}
		for (int ctr = 0; ctr < size; ++ctr) {
			TreeIter row;
			store.append(out row);
			store.set(row,
					0, list[ctr].process_binary,
					1, list[ctr].name,
					2, list[ctr].index,
					3, ctr==0);
			if (ctr == 0)combo.set_active_iter(row);
		}
	}
}
