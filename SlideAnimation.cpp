#include "SlideAnimation.h"

#include <iostream>
#include <cmath>
#include <chrono>

std::vector<std::unique_ptr<SlideAnimation>> SlideAnimation::m_anims;

SlideAnimation::SlideAnimation()
{}

SlideAnimation* SlideAnimation::startNewAnimation(int start, int end, int duration, Gtk::Window* window) {
	m_anims.emplace_back(std::make_unique<SlideAnimation>());
	m_anims.back()->start(start, end, duration, window);
	return m_anims.back().get();
}

update_signal SlideAnimation::signal_update() {
	return m_signal_update;
}

finished_signal SlideAnimation::signal_finished() {
	return m_signal_finished;
}

guint SlideAnimation::id() const {
	return m_id;
}

void SlideAnimation::start(int start, int end, int durationT, Gtk::Window* window) {
	startValue = start;	
	endValue = end;
	duration = durationT;
	first = true;
	m_id = window->add_tick_callback([this](const Glib::RefPtr< Gdk::FrameClock >& clock){
		return timeoutHandler(clock);
	});
}

bool SlideAnimation::timeoutHandler(const Glib::RefPtr< Gdk::FrameClock >& clock) {
	auto time =  clock->get_frame_time();
	if (first) {
		first = false;
		startTime = time;
	}
	auto deltaTime = static_cast<float>(time-startTime)/1000;
	if (deltaTime > duration) {
		m_signal_finished.emit();
	}
	// Out Cubic calculation
	float progress = 
		static_cast<float>(deltaTime)/duration;
	float value = 
		outCubic(progress) * (endValue-startValue) + startValue;
	m_signal_update.emit(value);
	return true;
}

float SlideAnimation::outCubic(float x) {
	return 1 - std::pow(1 - x, 3.0);
}
