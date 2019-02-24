import 'package:Openbook/models/categories_list.dart';
import 'package:Openbook/models/community_membership.dart';
import 'package:Openbook/models/community_membership_list.dart';
import 'package:Openbook/models/updatable_model.dart';
import 'package:Openbook/models/user.dart';
import 'package:Openbook/models/users_list.dart';
import 'package:dcache/dcache.dart';

class Community extends UpdatableModel<Community> {
  static convertTypeToString(CommunityType type) {
    String result;
    switch (type) {
      case CommunityType.private:
        result = 'T';
        break;
      case CommunityType.public:
        result = 'P';
        break;
      default:
        throw 'Unsupported community type';
    }
    return result;
  }

  static String convertExclusionToString(CommunityMembersExclusion exclusion) {
    String result;
    switch (exclusion) {
      case CommunityMembersExclusion.administrators:
        result = 'administrators';
        break;
      case CommunityMembersExclusion.moderators:
        result = 'moderators';
        break;
      default:
        throw 'Unsupported community members exclusion';
    }
    return result;
  }

  final int id;
  final User creator;
  String name;
  String title;
  String description;
  String rules;
  String color;
  String avatar;
  String cover;
  String userAdjective;
  String usersAdjective;
  int membersCount;
  CommunityType type;

  // Whether the user has been invited to the community
  bool isInvited;

  // Whether the user is the creator of the community
  bool isCreator;

  bool invitesEnabled;

  CategoriesList categories;

  UsersList moderators;

  UsersList administrators;

  CommunityMembershipList memberships;

  Community(
      {this.id,
      this.creator,
      this.rules,
      this.avatar,
      this.title,
      this.type,
      this.userAdjective,
      this.usersAdjective,
      this.description,
      this.name,
      this.color,
      this.cover,
      this.isInvited,
      this.isCreator,
      this.moderators,
      this.memberships,
      this.administrators,
      this.invitesEnabled,
      this.membersCount,
      this.categories});

  bool hasDescription() {
    return description != null;
  }

  bool hasCover() {
    return cover != null;
  }

  bool hasAvatar() {
    return avatar != null;
  }

  bool isPrivate() {
    return type == CommunityType.private;
  }

  bool isAdministrator(User user) {
    CommunityMembership membership = getMembershipForUser(user);
    if (membership == null) return false;
    return membership.isAdministrator;
  }

  bool isModerator(User user) {
    CommunityMembership membership = getMembershipForUser(user);
    if (membership == null) return false;
    return membership.isModerator;
  }

  bool isMember(User user) {
    return getMembershipForUser(user) != null;
  }

  CommunityMembership getMembershipForUser(User user) {
    if (memberships == null) return null;

    int membershipIndex = memberships.communityMemberships
        .indexWhere((CommunityMembership communityMembership) {
      return communityMembership.userId == user.id &&
          communityMembership.communityId == this.id;
    });

    if (membershipIndex < 0) return null;

    return memberships.communityMemberships[membershipIndex];
  }

  static final factory = CommunityFactory();

  factory Community.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('type')) {
      type = factory.parseType(json['type']);
    }

    if (json.containsKey('is_invited')) {
      isInvited = json['is_invited'];
    }

    if (json.containsKey('memberships')) {
      memberships = factory.parseMemberships(json['memberships']);
    }

    if (json.containsKey('is_creator')) {
      isCreator = json['is_creator'];
    }

    if (json.containsKey('invites_enabled')) {
      invitesEnabled = json['invites_enabled'];
    }

    if (json.containsKey('title')) {
      title = json['title'];
    }

    if (json.containsKey('rules')) {
      rules = json['rules'];
    }

    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('user_adjective')) {
      userAdjective = json['user_adjective'];
    }

    if (json.containsKey('users_adjective')) {
      usersAdjective = json['users_adjective'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('avatar')) {
      avatar = json['avatar'];
    }

    if (json.containsKey('cover')) {
      cover = json['cover'];
    }

    if (json.containsKey('members_count')) {
      membersCount = json['members_count'];
    }
    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('categories')) {
      categories = factory.parseCategories(json['categories']);
    }

    if (json.containsKey('moderators')) {
      moderators = factory.parseUsers(json['moderators']);
    }
  }

  void incrementMembersCount() {
    if (this.membersCount != null) {
      this.membersCount += 1;
      notifyUpdate();
    }
  }

  void decrementMembersCount() {
    if (this.membersCount != null && this.membersCount > 0) {
      this.membersCount -= 1;
      notifyUpdate();
    }
  }
}

class CommunityFactory extends UpdatableModelFactory<Community> {
  @override
  SimpleCache<int, Community> cache =
      SimpleCache(storage: SimpleStorage(size: 20));

  @override
  Community makeFromJson(Map json) {
    return Community(
        id: json['id'],
        name: json['name'],
        title: json['title'],
        description: json['description'],
        rules: json['rules'],
        avatar: json['avatar'],
        isInvited: json['is_invited'],
        isCreator: json['is_creator'],
        invitesEnabled: json['invites_enabled'],
        cover: json['cover'],
        color: json['color'],
        memberships: parseMemberships(json['memberships']),
        membersCount: json['members_count'],
        userAdjective: json['user_adjective'],
        usersAdjective: json['users_adjective'],
        type: parseType(json['type']),
        creator: parseUser(json['creator']),
        moderators: parseUsers(json['moderators']),
        categories: parseCategories(json['categories']));
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  UsersList parseUsers(List usersData) {
    if (usersData == null) return null;
    return UsersList.fromJson(usersData);
  }

  CommunityMembershipList parseMemberships(List membershipsData) {
    if (membershipsData == null) return null;
    return CommunityMembershipList.fromJson(membershipsData);
  }

  CategoriesList parseCategories(List categoriesData) {
    if (categoriesData == null) return null;
    return CategoriesList.fromJson(categoriesData);
  }

  CommunityType parseType(String strType) {
    if (strType == null) return null;

    CommunityType type;
    if (strType == 'P') {
      type = CommunityType.public;
    } else if (strType == 'T') {
      type = CommunityType.private;
    } else {
      throw 'Unsupported community type';
    }

    return type;
  }
}

enum CommunityType { public, private }

enum CommunityMembersExclusion { administrators, moderators }
