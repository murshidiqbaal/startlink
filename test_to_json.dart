import 'package:startlink/features/profile/data/models/profile_model.dart';

void main() {
  const profile = ProfileModel(
    id: 'test-id',
    fullName: 'Test User',
    skills: ['Flutter', 'Dart'],
  );

  final json = profile.toJson();
  print('JSON: $json');

  if (json['id'] == 'test-id' && json['full_name'] == 'Test User' && json['skills'].contains('Flutter')) {
    print('SUCCESS: toJson works as expected');
  } else {
    print('FAILURE: toJson did not return expected data');
    print('Got: $json');
  }
}
