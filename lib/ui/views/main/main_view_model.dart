import '../../../core/base/baic_base_view_model.dart';

class MainViewModel extends BaicBaseViewModel {
  static bool requestShopTab = false;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void activateShopMode() {
    // TODO: Implement communication with CalendarViewModel to switch to Shop tab
    // For now, setting index to 1 (Calendar) is enough to show the view.
    // Ideally, we'd use a service to broadcast 'OpenShop' event.
    setIndex(1);
    // Broadcast event
    GlobalEventBus.emit('open_shop_tab');
  }
}

// Simple Event Bus for loose coupling
class GlobalEventBus {
  static final List<Function(String)> _listeners = [];
  
  static void listen(Function(String) callback) {
    _listeners.add(callback);
  }
  
  static void emit(String event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }
}
