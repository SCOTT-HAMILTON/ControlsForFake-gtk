#ifndef SLIDE_ANIMATION_H
#define SLIDE_ANIMATION_H

#include <glibmm.h>
#include <gtkmm.h>
#include <vector>
#include <memory>

using update_signal = sigc::signal<void(float)>;
using finished_signal = sigc::signal<void(void)>;

class SlideAnimation {
public:
	SlideAnimation();
	static SlideAnimation* startNewAnimation(int start, int end, int duration, Gtk::Window* window);
	update_signal signal_update();
	finished_signal signal_finished();
	guint id() const;

private:
	void start(int start, int end, int duration /*in milliseconds*/, Gtk::Window* window);
	void run();
	bool timeoutHandler(const Glib::RefPtr< Gdk::FrameClock >& clock);
	int startValue;
	int endValue;
	int duration;
	guint m_id;
	bool first;
	gint64 startTime;

	update_signal m_signal_update;
	finished_signal m_signal_finished;

	float outCubic(float x);

	static std::vector<std::unique_ptr<SlideAnimation>> m_anims;
};

#endif //SLIDE_ANIMATION_H
