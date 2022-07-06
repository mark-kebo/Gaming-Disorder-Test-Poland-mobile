// @dart=2.9

class ProjectConstants {
  static const emailRegExp =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const phoneRegExp = r'(^(?:[+0]9)?[0-9]{9,12}$)';
  static const prefsEmail = 'email';
  static const prefsPassword = 'password';
  static const usersCollectionName = 'users';
  static const settingsCollectionName = 'settings';
  static const settingsContactCollectionName = 'contact';
  static const formsCollectionName = 'forms';
  static const groupsCollectionName = 'user_groups';
  static const researchProgrammesCollectionName = 'researchProgrammes';
  static const completedFormsCollectionName = 'completedForms';
  static const selectedUsersCollectionName = 'selectedUsers';
  static const defaultQuestionSec = 60;
}
