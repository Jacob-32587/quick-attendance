import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ProfileController extends GetxController {
  var userId = "".obs;
  var email = "dwalbolt@gmail.com".obs;
  var firstName = "Daniel".obs;
  var lastName = "Walbolt".obs;
  var joinedGroups =
      ["Group A", "Group B", "Group C", "Group D", "Group E", "Group F"].obs;
  var ownedGroups =
      ["Group G", "Group H", "Group I", "Group J", "Group K", "Group L"].obs;

  var prefersListView = true.obs;

  void setListViewPreference(bool prefersListView) {
    this.prefersListView.value = prefersListView;
  }

  void leaveJoinedGroup(String groupId) {
    // TODO: Connect to backend
  }

  void disbandOwnedGroup(String groupId) {
    // TODO: Connect to backend
  }

  void createGroup() {
    // TODO: Connect to backend
  }

  void joinGroup(String groupId) {
    // TODO: Connect to backend
  }
}
