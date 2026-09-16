import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/features/auth/auth_provider.dart';
import 'package:jahitin_mobile/features/home/home_state.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final authState = ref.watch(authProvider);

    return HomeState(
      status: HomeStatus.loaded,
      user: authState.user,
      activeOrderCount: 2,
      selectedTab: HomeTab.active,
    );
  }

  void setTab(HomeTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void updateActiveOrderCount(int count) {
    state = state.copyWith(activeOrderCount: count);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
