enum UserRole {
  innovator,
  mentor,
  investor,
  collaborator;

  String get toStringValue {
    switch (this) {
      case UserRole.innovator:
        return 'Innovator';
      case UserRole.mentor:
        return 'Mentor';
      case UserRole.investor:
        return 'Investor';
      case UserRole.collaborator:
        return 'Collaborator';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'innovator':
        return UserRole.innovator;
      case 'mentor':
        return UserRole.mentor;
      case 'investor':
        return UserRole.investor;
      case 'collaborator':
        return UserRole.collaborator;
      default:
        return UserRole.innovator; // Default
    }
  }
}
