/*
 * Copyright (c) 2020 Scott Hamilton <sgn.hamilton+vala@protonmail.com>
 * 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

// [SimpleType]
// [IntegerType (rank = 9)]
// [CCode (cname = "xcb_atom_t", has_type_id = false)]
// public struct AtomT {
// }
[CCode (cname = "int", cprefix = "PA_SUBSCRIPTION_EVENT_", has_type_id = false, cheader_filename = "pulse/subscribe.h")]
[Flags]
public enum PaSubscriptionEvent {
	SINK,
	SOURCE,
	SINK_INPUT,
	SOURCE_OUTPUT,
	MODULE,
	CLIENT,
	SAMPLE_CACHE,
	SERVER,
	AUTOLOAD,
	CARD,
	FACILITY_MASK,
	NEW,
	CHANGE,
	REMOVE,
	TYPE_MASK
}

[CCode (cname = "int", cprefix = "PA_SUBSCRIPTION_MASK_", has_type_id = false)]
[Flags]
public enum PaSubscriptionMask {
	NULL,
	SINK,
	SOURCE,
	SINK_INPUT,
	SOURCE_OUTPUT,
	MODULE,
	CLIENT,
	SAMPLE_CACHE,
	SERVER,
	AUTOLOAD,
	CARD,
	ALL
}

[CCode (cname = "move_source_output_port_t", destroy_function = "", has_type_id = false)]
public struct MoveSourceOutputPort {
    int success;
    uint32 index;
	uint32 sourceIndex;
}

[CCode (cname = "sink_infos_t", destroy_function = "free", has_type_id = false)]
public struct SinkInfos {
	int initialized;
	string name;
	uint32 index;
	string description;
}
[CCode (cname = "sink_input_infos_t", destroy_function = "free", has_type_id = false)]
public struct SinkInputInfos {
	int initialized;
	string name;
	uint32 index;
	uint32 owner_module;
	uint32 client;
	uint32 sink;
	string process_binary;
}
[CCode (cname = "source_infos_t", destroy_function = "free", has_type_id = false)]
public struct SourceInfos {
	int initialized;
	string name;
	uint32 index;
	string description;
}
[CCode (cname = "source_output_infos_t", destroy_function = "free", has_type_id = false)]
public struct SourceOutputInfos {
	int initialized;
	string name;
	uint32 index;
	uint32 source;
	string process_binary;
}

[CCode (cname = "user_subscribe_callback_t", has_target = false)]
public delegate void UserSubscribeCallback (PaSubscriptionEvent event);

[CCode (cheader_filename = "CFakeLib.h")]
namespace Fake {

	[CCode (cname = "info_list_size")]
	public const int info_list_size;

	public void move_source_output_port(uint32 index, uint32 sourceIndex);
	public void move_sink_input_port(uint32 index, uint32 sinkIndex);
	public void load_module(string name, 
								 string arguments,
								 string description);
	public void unload_module(uint32 index);
	public void set_sink_volume(uint32 index, double volume); // volume in percentage
	public void set_sink_input_volume(uint32 index, double volume); // volume in percentage
	public void get_module_list();
	public void get_sink_list();
	public void get_sink_input_list();
	public void get_source_list();
	public void get_source_output_list();
	public void get_module(uint32 index);
	public void get_sink(uint32 index);
	public void get_sink_input(uint32 index);
	public void get_source(uint32 index);
	public void get_source_output(uint32 index);
	public void enable_subscription(PaSubscriptionMask mask);
	public void run_commands();
	public void clear_commands();
	public void init_subscribtion(PaSubscriptionMask mask, UserSubscribeCallback callback);
	public void iterate_subscribtion_loop();
	public void clean_subscribtion_loop();
	
	public size_t extract_sink_list ([CCode (array_length = false)] out SinkInfos[] list);
	public size_t extract_sink_input_list ([CCode (array_length = false)] out SinkInputInfos[] list);
	public size_t extract_source_list ([CCode (array_length = false)] out SourceInfos[] list);
	public size_t extract_source_output_list ([CCode (array_length = false)] out SourceOutputInfos[] list);
	// public size_t extract_sink_list (sink_infos_t** list);
	// public size_t extract_source_list (source_infos_t** list);
	// public size_t extract_source_output_list (source_output_infos_t** list);
}

[CCode (cheader_filename = "CFakeLibUtils.h")]
namespace FakeUtils {
	public void print_sink_info_list(
		[CCode (array_length = false)] SinkInfos[] list, size_t size);
	public void print_sink_input_info_list(
		[CCode (array_length = false)] SinkInputInfos[] list, size_t size);
	public void print_source_info_list(
		[CCode (array_length = false)] SourceInfos[] list, size_t size);
	public void print_source_output_info_list(
		[CCode (array_length = false)] SourceOutputInfos[] list, size_t size);
}
