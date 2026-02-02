import 'package:startlink/features/idea_dna/domain/entities/idea_dna.dart';

abstract class IdeaDnaRepository {
  Future<IdeaDna> getIdeaDna(String ideaId);
}
