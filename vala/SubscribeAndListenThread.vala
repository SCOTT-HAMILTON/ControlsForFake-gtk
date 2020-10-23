using GLib;

public class SubscribeAndListenThread {
	private int canRun;
	private GLib.Thread<int> thread;
	public static SubscribeAndListenThread singleton;

	public signal void newEvent(PaSubscriptionEvent event);

	public void start() {
		AtomicInt.set(ref canRun, 1);
		stderr.printf("Beginning run\n");

		Fake.init_subscribtion(
				PaSubscriptionMask.SINK |
				PaSubscriptionMask.SOURCE |
				PaSubscriptionMask.SINK_INPUT |
				PaSubscriptionMask.SOURCE_OUTPUT |
				PaSubscriptionMask.MODULE,
				eventCallback);

		thread = new Thread<int>("SubscribtionThread", run);
	}

	public void stop () {
		AtomicInt.set(ref canRun, 0);
		thread.join();
	}

	public static void eventCallback(PaSubscriptionEvent event) {
		stderr.printf("[log] received PA event\n");
		singleton.newEvent(event);
	}

	public int run() {
		stderr.printf("[log] Starting Running Subscribtion Thread\n");
		while (AtomicInt.get(ref canRun) != 0) {
			Thread.usleep((ulong)0.5*1000000);
			Fake.iterate_subscribtion_loop();
		}
		Fake.clean_subscribtion_loop();
		stderr.printf("[log] Ending Running Subscribtion Thread\n");

		return 0;
	}
}
