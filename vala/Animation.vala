using Gtk;

public class Animation {
	private int startValue;
	private int endValue;
	private int duration;
	private uint m_id;
	private bool first;
	private int64 startTime;

	public signal void update(float value);
	public signal void finished();

	public uint id() {
		return m_id;
	}

	public Animation(int start, int end, int duration, Gtk.Window window) {
		this.start(start, end, duration, window);
	}

	private void start(int start, int end, int duration, Gtk.Window window) {
		this.startValue = start;
		this.endValue = end;
		this.duration = duration;
		this.first = true;
		this.m_id = window.add_tick_callback((widget, clock) =>
		{
			return timeoutHandler(clock);
		});
	}

	private bool timeoutHandler(Gdk.FrameClock clock) {
		var time = clock.get_frame_time();
		if (first) {
			first = false;
			startTime = time;
		}
		var deltaTime = (float)(time-startTime)/1000.0;
		if (deltaTime > duration) {
			finished();
		}
		// Out Cubic calculation
		var progress = 
			(float)deltaTime/duration;
		var value = 
			outCubic(progress) * (endValue-startValue) + startValue;
		update(value);
		return true;
	}

	private float outCubic(float x) {
		return (float)(1-Math.pow(1-x, 3.0));
	}

}
