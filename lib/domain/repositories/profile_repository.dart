import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(int userId);
  Future<void> saveProfile(UserProfile profile);
}
