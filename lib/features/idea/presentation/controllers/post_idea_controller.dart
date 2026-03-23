import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/post_idea_repository.dart';

// ---------------------------------------------------------------------------
// Plain Dart service — no Riverpod dependency.
// Used directly from IdeaFormBloc or any BLoC that needs to post a new idea.
// ---------------------------------------------------------------------------

class PostIdeaService {
  final PostIdeaRepository _repository;
  final SupabaseClient _supabase;

  PostIdeaService({PostIdeaRepository? repository, SupabaseClient? supabase})
    : _repository = repository ?? PostIdeaRepository(Supabase.instance.client),
      _supabase = supabase ?? Supabase.instance.client;

  /// Uploads optional cover image and inserts the idea. Throws on any error.
  Future<void> submitIdea({
    // Step 1
    required String title,
    required String description,
    required String problemStatement,
    required String targetMarket,
    required List<String> tags,
    // Step 2
    required String industry,
    required String subIndustry,
    required String businessModel,
    required String monetizationStrategy,
    required String currentStage,
    required String location,
    // Step 3
    required double fundingNeeded,
    required double equityOffered,
    required int teamSize,
    required bool lookingForInvestor,
    required bool lookingForCofounder,
    required bool lookingForMentor,
    // Step 4
    required String pitchDeckUrl,
    required String demoVideoUrl,
    required String websiteUrl,
    // Step 5
    required String visibility,
    File? coverImage,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('You must be logged in to post an idea');

    String? coverImageUrl;
    if (coverImage != null) {
      coverImageUrl = await _repository.uploadCoverImage(coverImage, user.id);
    }

    final ideaData = <String, dynamic>{
      // User-provided fields
      'owner_id': user.id,
      'title': title.trim(),
      'description': description.trim(),
      'problem_statement': problemStatement.trim(),
      'target_market': targetMarket.trim(),
      'tags': tags,
      'industry': industry.trim(),
      'sub_industry': subIndustry.trim(),
      'business_model': businessModel.trim(),
      'monetization_strategy': monetizationStrategy.trim(),
      'current_stage': currentStage,
      'location': location.trim(),
      'funding_needed': fundingNeeded,
      'equity_offered': equityOffered,
      'team_size': teamSize,
      'looking_for_investor': lookingForInvestor,
      'looking_for_cofounder': lookingForCofounder,
      'looking_for_mentor': lookingForMentor,
      'cover_image_url': coverImageUrl,
      'pitch_deck_url': pitchDeckUrl.trim(),
      'demo_video_url': demoVideoUrl.trim(),
      'website_url': websiteUrl.trim(),
      'visibility': visibility.toLowerCase(),
      // Auto-set defaults
      'status': 'published',
      'is_active': true,
      'view_count': 0,
      'application_count': 0,
      'like_count': 0,
      'comment_count': 0,
      'bookmark_count': 0,
      'share_count': 0,
      'boost_score': 0,
      'trending_score': 0,
      'hot_score': 0,
      'funding_raised': 0,
      'currency': 'USD',
      'ai_quality_score': null,
      'ai_market_score': null,
      'ai_feasibility_score': null,
      'ai_innovation_score': null,
      'is_featured': false,
      'is_verified': false,
      'moderation_status': 'approved',
      'reported_count': 0,
      'last_activity_at': DateTime.now().toUtc().toIso8601String(),
    };

    await _repository.insertIdea(ideaData);
    debugPrint('[PostIdeaService] Idea submitted successfully.');
  }
}
