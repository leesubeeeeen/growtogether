import 'package:flutter/material.dart';

/// PartnerProvider는 사용자와 연동된 배우자의 계정 정보를
/// 상태로 관리하는 클래스입니다. 상태 변경 시 위젯에 알림을 보냅니다.
class PartnerProvider extends ChangeNotifier {
  // 현재 연동된 배우자의 사용자 ID (없으면 null)
  String? _partnerId;

  /// 외부에서 현재 연동된 partnerId를 읽을 수 있도록 하는 getter
  String? get partnerId => _partnerId;

  /// 배우자 연동 여부를 나타냅니다.
  /// 연동되어 있으면 true, 아니면 false
  bool get isConnected => _partnerId != null;

  /// 배우자 계정을 연동할 때 호출합니다.
  /// partnerId를 저장하고, 상태 변경을 알립니다.
  void connectPartner(String partnerId) {
    _partnerId = partnerId;
    notifyListeners(); // 연결된 정보를 UI에 반영
  }

  /// 배우자 계정 연동을 해제할 때 호출합니다.
  /// partnerId를 null로 만들고 상태 변경을 알립니다.
  void disconnectPartner() {
    _partnerId = null;
    notifyListeners(); // 해제된 정보를 UI에 반영
  }
}