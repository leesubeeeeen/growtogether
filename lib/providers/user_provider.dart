import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier { //최신상태 반영
  User? _currentUser; //로그인 된 현재 사용자 정보 저장
  //?은 널 가능성. 로그인 안 되어 있을 수 있으므로

  User? get currentUser => _currentUser;
  //외부에서 현재 로그인한 유저 정보 확인하기 위해 getter 정의

  void login(User user) { //User정보 받아 _currentUser에 저장
    _currentUser = user;
    notifyListeners(); //사용자 바뀌었다고 알림 보내기
  }

  void logout() {
    _currentUser = null;
    notifyListeners(); //앱 전체에 알림 보내기 -> 로그인상태 아니라는 걸 화면에서 반영
  }

  void updateUser(User user) { //이미 로그인된 유저의 닉네임, 역할 등 정보 바꿀 때 사용
    _currentUser = user;
    notifyListeners();
  }
}
