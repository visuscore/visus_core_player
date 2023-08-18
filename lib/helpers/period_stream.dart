class PeriodStream {
  final Duration _period;
  Duration delay;

  PeriodStream(this._period, {this.delay = Duration.zero});

  Stream<void> start() async* {
    await Future.delayed(delay);
    yield null;

    while (true) {
      await Future.delayed(_period);
      yield null;
    }
  }
}
