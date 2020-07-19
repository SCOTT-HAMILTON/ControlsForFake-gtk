#ifndef SLIDE_ANIMATION_H
#define SLIDE_ANIMATION_H

#include <glibmm.h>
#include <vector>

using update_signal = sigc::signal<void(float)>;
using finished_signal = sigc::signal<void(void)>;

class SlideAnimation {
public:
	SlideAnimation() = default;
	static SlideAnimation& startNewAnimation(int start, int end, int duration);
	update_signal signal_update();
	finished_signal signal_finished();

private:
	void start(int start, int end, int duration /*in milliseconds*/);
	bool timeoutHandler();
	int startValue;
	int endValue;
	int duration;
	gint64 startTime;
	sigc::connection connectionHandle;
	update_signal m_signal_update;
	finished_signal m_signal_finished;

	float outCubic(float x);

	static std::vector<SlideAnimation> m_anims;
};

#endif //SLIDE_ANIMATION_H
