import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

void startup(ProviderContainer container) {
  container.read(transportProvider);
  container.read(parserProvider);
  container.read(mavlinkServiceProvider);
  container.read(timeSyncRepoProvider);
  container.read(timeStateProvider);
  container.read(tickerProvider);
}