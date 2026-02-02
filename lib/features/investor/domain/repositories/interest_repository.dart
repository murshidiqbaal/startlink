abstract class InterestRepository {
  Future<void> expressInterest(String ideaId, String investorId);
  Future<void> bookmarkIdea(String ideaId, String investorId);
  Future<List<String>> getInterestedIdeaIds(String investorId);
  Future<List<String>> getBookmarkedIdeaIds(String investorId);
}
