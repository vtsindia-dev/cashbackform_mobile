import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../common/widget/api_service.dart';
import '../../common/widget/sessionhandler.dart';

class NotificationController extends ChangeNotifier {
  // Singleton pattern
  static final NotificationController _instance = NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  // Dependencies
  final SessionManager _sessionManager = SessionManager();

  // State variables
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _unreadCount = 0;
  String? _token;
  String? _errorMessage;

  // Add a flag to track if controller is active
  bool _isActive = true;

  // Getters
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;
  bool get hasMorePages => _currentPage < _lastPage;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnreadNotifications => _unreadCount > 0;

  // Initialize controller
  Future<void> init() async {
    if (!_isActive) return;
    await _loadToken();
    if (_token != null && _isActive) {
      await refreshNotifications();
    }
  }

  // Load token from session
  Future<void> _loadToken() async {
    if (!_isActive) return;
    _token = await SessionManager.getToken();
  }

  // Refresh all data (pull to refresh)
  Future<void> refreshNotifications() async {
    if (!_isActive) return;
    _currentPage = 1;
    await _loadNotifications();
    await _loadUnreadCount();
  }

  // Load notifications with current page
  Future<void> _loadNotifications() async {
    if (!_isActive) return;

    if (_token == null) {
      _errorMessage = 'User not authenticated';
      if (_isActive) notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final Response response = await ApiService.getNotifications(
        token: _token!,
        page: _currentPage,
      );

      if (!_isActive) return;

      if (response.statusCode == 200 && response.data['status'] == true) {
        final notificationsData = response.data['data']['notifications'] as List;

        if (_currentPage == 1) {
          _notifications = notificationsData
              .map((item) => _parseNotification(item))
              .toList();
        } else {
          _notifications.addAll(
              notificationsData.map((item) => _parseNotification(item))
          );
        }

        _lastPage = response.data['data']['pagination']['last_page'];
        _errorMessage = null;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      debugPrint('Error loading notifications: $e');
    }

    _setLoading(false);
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!_isActive) return;
    if (!hasMorePages || _isLoading) return;

    _currentPage++;
    await _loadNotifications();
  }

  // Load unread count
  Future<void> _loadUnreadCount() async {
    if (!_isActive) return;
    if (_token == null) return;

    try {
      final Response response = await ApiService.getNotificationCount(
        token: _token!,
      );

      if (!_isActive) return;

      if (response.statusCode == 200 && response.data['status'] == true) {
        _unreadCount = response.data['count'] ?? 0;
        if (_isActive) notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  // Mark single notification as read
  Future<bool> markAsRead(int notificationId) async {
    if (!_isActive) return false;
    if (_token == null) return false;

    try {
      final Response response = await ApiService.markNotificationAsRead(
        token: _token!,
        notificationId: notificationId,
      );

      if (!_isActive) return false;

      if (response.statusCode == 200 && response.data['status'] == true) {
        // Update local state
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
          _notifications[index]['is_read_local'] = true;
          if (_isActive) notifyListeners();
        }

        if (_unreadCount > 0) {
          _unreadCount--;
          if (_isActive) notifyListeners();
        }

        return true;
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }

    return false;
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    if (!_isActive) {
      return {'success': false, 'message': 'Controller not active'};
    }

    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    _setLoading(true);

    try {
      final Response response = await ApiService.clearAllNotifications(
        token: _token!,
      );

      if (!_isActive) {
        return {'success': false, 'message': 'Controller not active'};
      }

      if (response.statusCode == 200 && response.data['status'] == true) {
        for (var i = 0; i < _notifications.length; i++) {
          _notifications[i]['is_read'] = true;
          _notifications[i]['is_read_local'] = true;
        }

        _unreadCount = 0;
        if (_isActive) notifyListeners();

        return {
          'success': true,
          'message': response.data['message'] ?? 'All notifications marked as read',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to clear notifications',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    } finally {
      if (_isActive) {
        _setLoading(false);
      }
    }
  }

  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    if (!_isActive) {
      return {'success': false, 'message': 'Controller not active'};
    }

    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    Map<String, dynamic>? deletedNotification;
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      deletedNotification = Map.from(_notifications[index]);
    }

    try {
      final Response response = await ApiService.deleteNotification(
        token: _token!,
        notificationId: notificationId,
      );

      if (!_isActive) {
        return {'success': false, 'message': 'Controller not active'};
      }

      if (response.statusCode == 200 && response.data['status'] == true) {
        if (index != -1) {
          if (!_notifications[index]['is_read_local']) {

            _unreadCount--;
          }

          _notifications.removeAt(index);
          if (_isActive) notifyListeners();
        }

        return {
          'success': true,
          'message': response.data['message'] ?? 'Notification deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to delete notification',
        };
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return {
        'success': false,
        'message': 'Network error: Failed to delete notification',
      };
    }
  }

  void softDeleteNotification(int notificationId) {
    if (!_isActive) return;

    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      if (!_notifications[index]['is_read_local']) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
      if (_isActive) notifyListeners();
    }
  }

  Future<Map<String, dynamic>> deleteMultipleNotifications(List<int> notificationIds) async {
    if (!_isActive) {
      return {'success': false, 'message': 'Controller not active'};
    }

    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    int deletedCount = 0;
    List<String> errors = [];

    for (int id in notificationIds) {
      final result = await deleteNotification(id);
      if (result['success']) {
        deletedCount++;
      } else {
        errors.add('Failed to delete notification $id');
      }
    }

    return {
      'success': errors.isEmpty,
      'deletedCount': deletedCount,
      'errors': errors,
      'message': errors.isEmpty
          ? 'Successfully deleted $deletedCount notifications'
          : 'Deleted $deletedCount notifications with ${errors.length} errors',
    };
  }

  // Parse notification and handle HTML entities
  Map<String, dynamic> _parseNotification(dynamic notification) {
    return {
      'id': notification['id'],
      'user_id': notification['user_id'],
      'title': notification['title'],
      'message_raw': notification['message'],
      'message': parseMessage(notification['message']),
      'image': notification['image'],
      'type': notification['type'],
      'reference_id': notification['reference_id'],
      'is_read': notification['is_read'],
      'is_read_local': notification['is_read'],
      'created_at': notification['created_at'],
      'updated_at': notification['updated_at'],
    };
  }

  // Parse HTML entities in message
  String parseMessage(String htmlMessage) {
    return htmlMessage
        .replaceAll('&#8377;', '₹')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"');
  }

  // Navigate based on notification type (dynamic routing)
  Future<void> navigateToNotification(BuildContext context, Map<String, dynamic> notification) async {
    if (!_isActive) return;

    // Mark as read if not already
    if (!notification['is_read']) {
      await markAsRead(notification['id']);
    }

    // Dynamic navigation based on type
    switch (notification['type']) {
      case 'payment':
        Navigator.pushNamed(
          context,
          '/payment-details',
          arguments: {'payment_id': notification['reference_id']},
        );
        break;

      case 'order':
        Navigator.pushNamed(
          context,
          '/order-details',
          arguments: {'order_id': notification['reference_id']},
        );
        break;

      case 'plot':
        Navigator.pushNamed(
          context,
          '/plot-details',
          arguments: {'plot_id': notification['reference_id']},
        );
        break;

      case 'material':
        Navigator.pushNamed(
          context,
          '/material-details',
          arguments: {'material_id': notification['reference_id']},
        );
        break;

      case 'service':
        Navigator.pushNamed(
          context,
          '/service-details',
          arguments: {'service_id': notification['reference_id']},
        );
        break;

      default:
        _showNotificationDialog(context, notification);
        break;
    }
  }

  // Show notification details in dialog
  void _showNotificationDialog(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['message']),
            const SizedBox(height: 8),
            Text(
              'Type: ${notification['type']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (notification['reference_id'] != null)
              Text(
                'Reference ID: ${notification['reference_id']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Clear all local notifications (without API call)
  void clearLocalNotifications() {
    if (!_isActive) return;
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;
    _lastPage = 1;
    if (_isActive) notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (!_isActive) return;
    _isLoading = loading;
    if (_isActive) notifyListeners();
  }

  void reset() {
    if (!_isActive) return;
    _notifications.clear();
    _isLoading = false;
    _currentPage = 1;
    _lastPage = 1;
    _unreadCount = 0;
    _errorMessage = null;
    if (_isActive) notifyListeners();
  }


  // DO NOT dispose the singleton - it should live for the entire app lifecycle
  // Instead of dispose, we just mark it as inactive
  void deactivate() {
    _isActive = false;
  }

  void reactivate() {
    _isActive = true;
  }
}
