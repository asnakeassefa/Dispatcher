import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart' as injectable;

enum AppPage {
  orders,
  trips,
  tripExecution,
}

enum DetailPageType {
  none,
  tripDetail,
  orderDetail,
  tripExecution,
  createTrip,
  assignOrders,
}

class AppStateData {
  final AppPage currentPage;
  final int currentTabIndex;
  final DetailPageType currentDetailPage;
  final String? currentTripId;
  final String? currentOrderId;
  final String? currentTripExecutionId;
  final Map<String, dynamic> additionalState;
  final List<Map<String, dynamic>> navigationStack; // Track navigation stack

  const AppStateData({
    required this.currentPage,
    required this.currentTabIndex,
    this.currentDetailPage = DetailPageType.none,
    this.currentTripId,
    this.currentOrderId,
    this.currentTripExecutionId,
    this.additionalState = const {},
    this.navigationStack = const [],
  });

  AppStateData copyWith({
    AppPage? currentPage,
    int? currentTabIndex,
    DetailPageType? currentDetailPage,
    String? currentTripId,
    String? currentOrderId,
    String? currentTripExecutionId,
    Map<String, dynamic>? additionalState,
    List<Map<String, dynamic>>? navigationStack,
  }) {
    return AppStateData(
      currentPage: currentPage ?? this.currentPage,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      currentDetailPage: currentDetailPage ?? this.currentDetailPage,
      currentTripId: currentTripId ?? this.currentTripId,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      currentTripExecutionId: currentTripExecutionId ?? this.currentTripExecutionId,
      additionalState: additionalState ?? this.additionalState,
      navigationStack: navigationStack ?? this.navigationStack,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage.name,
      'currentTabIndex': currentTabIndex,
      'currentDetailPage': currentDetailPage.name,
      'currentTripId': currentTripId,
      'currentOrderId': currentOrderId,
      'currentTripExecutionId': currentTripExecutionId,
      'additionalState': additionalState,
      'navigationStack': navigationStack,
    };
  }

  factory AppStateData.fromJson(Map<String, dynamic> json) {
    return AppStateData(
      currentPage: AppPage.values.firstWhere(
        (e) => e.name == json['currentPage'],
        orElse: () => AppPage.orders,
      ),
      currentTabIndex: json['currentTabIndex'] as int? ?? 0,
      currentDetailPage: DetailPageType.values.firstWhere(
        (e) => e.name == json['currentDetailPage'],
        orElse: () => DetailPageType.none,
      ),
      currentTripId: json['currentTripId'] as String?,
      currentOrderId: json['currentOrderId'] as String?,
      currentTripExecutionId: json['currentTripExecutionId'] as String?,
      additionalState: Map<String, dynamic>.from(json['additionalState'] as Map? ?? {}),
      navigationStack: List<Map<String, dynamic>>.from(json['navigationStack'] as List? ?? []),
    );
  }
}

@injectable.injectable
class AppStateManager extends HydratedCubit<AppStateData> {
  AppStateManager() : super(const AppStateData(
    currentPage: AppPage.orders,
    currentTabIndex: 0,
  ));

  void updateCurrentPage(AppPage page, {int? tabIndex}) {
    emit(state.copyWith(
      currentPage: page,
      currentTabIndex: tabIndex ?? state.currentTabIndex,
      currentDetailPage: DetailPageType.none, // Reset detail page when changing main page
    ));
  }

  void updateTabIndex(int index) {
    emit(state.copyWith(
      currentTabIndex: index,
      currentDetailPage: DetailPageType.none, // Reset detail page when changing tab
    ));
  }

  void updateCurrentTrip(String? tripId) {
    emit(state.copyWith(currentTripId: tripId));
  }

  void updateCurrentOrder(String? orderId) {
    emit(state.copyWith(currentOrderId: orderId));
  }

  void updateCurrentTripExecution(String? tripExecutionId) {
    emit(state.copyWith(currentTripExecutionId: tripExecutionId));
  }

  void updateDetailPage(DetailPageType detailPage, {
    String? tripId,
    String? orderId,
    String? tripExecutionId,
  }) {
    emit(state.copyWith(
      currentDetailPage: detailPage,
      currentTripId: tripId ?? state.currentTripId,
      currentOrderId: orderId ?? state.currentOrderId,
      currentTripExecutionId: tripExecutionId ?? state.currentTripExecutionId,
    ));
  }

  void pushToNavigationStack(String pageType, Map<String, dynamic> pageData) {
    final newStack = List<Map<String, dynamic>>.from(state.navigationStack);
    newStack.add({
      'pageType': pageType,
      'pageData': pageData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    emit(state.copyWith(navigationStack: newStack));
  }

  void popFromNavigationStack() {
    if (state.navigationStack.isNotEmpty) {
      final newStack = List<Map<String, dynamic>>.from(state.navigationStack);
      newStack.removeLast();
      emit(state.copyWith(navigationStack: newStack));
    }
  }

  void clearNavigationStack() {
    emit(state.copyWith(
      navigationStack: [],
      currentDetailPage: DetailPageType.none,
      currentTripId: null,
      currentOrderId: null,
      currentTripExecutionId: null,
    ));
  }

  void updateAdditionalState(String key, dynamic value) {
    final newAdditionalState = Map<String, dynamic>.from(state.additionalState);
    newAdditionalState[key] = value;
    emit(state.copyWith(additionalState: newAdditionalState));
  }

  // Add method to save order with customer data for restoration
  void updateDetailPageWithOrderData(DetailPageType detailPage, {
    String? tripId,
    String? orderId,
    String? tripExecutionId,
    Map<String, dynamic>? orderData, // Store order data for restoration
  }) {
    final newAdditionalState = Map<String, dynamic>.from(state.additionalState);
    
    if (orderData != null && orderId != null) {
      newAdditionalState['saved_order_$orderId'] = orderData;
    }
    
    emit(state.copyWith(
      currentDetailPage: detailPage,
      currentTripId: tripId ?? state.currentTripId,
      currentOrderId: orderId ?? state.currentOrderId,
      currentTripExecutionId: tripExecutionId ?? state.currentTripExecutionId,
      additionalState: newAdditionalState,
    ));
  }

  // Update the navigation restoration to use saved order data
  Map<String, dynamic>? getSavedOrderData(String orderId) {
    return state.additionalState['saved_order_$orderId'] as Map<String, dynamic>?;
  }

  @override
  AppStateData? fromJson(Map<String, dynamic> json) {
    try {
      return AppStateData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AppStateData state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}
