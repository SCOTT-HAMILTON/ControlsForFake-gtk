#include "SlideAnimation.h"

#include <iostream>
#include <cmath>

std::vector<SlideAnimation> SlideAnimation::m_anims;

SlideAnimation& SlideAnimation::startNewAnimation(int start, int end, int duration) {
	m_anims.emplace_back();
	m_anims.back().start(start, end, duration);
	return m_anims.back();
}

update_signal SlideAnimation::signal_update() {
	return m_signal_update;
}

finished_signal SlideAnimation::signal_finished() {
	return m_signal_finished;
}

void SlideAnimation::start(int start, int end, int durationT) {
	startValue = start;	
	endValue = end;
	duration = durationT;
	connectionHandle = Glib::signal_timeout().connect(sigc::mem_fun(this, &SlideAnimation::timeoutHandler), 16);
	startTime = g_get_monotonic_time();
}


bool SlideAnimation::timeoutHandler() {
	auto deltaTime = (g_get_monotonic_time()-startTime)/1000;
	if (deltaTime > static_cast<gint64>(duration)) {
		connectionHandle.disconnect();
		m_signal_finished.emit();
	} else {
		// Out Cubic calculation
		float progress = 
			static_cast<float>(deltaTime)/duration;
		float value = 
			outCubic(progress) * (endValue-startValue) + startValue;
		m_signal_update.emit(value);
	}
	return true;
}

float SlideAnimation::outCubic(float x) {
	return 1 - std::pow(1 - x, 3.0);
}
