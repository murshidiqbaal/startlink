import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/idea/data/models/idea_model.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final SupabaseClient _supabase;

  IdeaRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<Idea>> fetchMyIdeas() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('ideas')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ideas: $e');
    }
  }

  @override
  Future<List<Idea>> fetchPublishedIdeas() async {
    try {
      final response = await _supabase
          .from('ideas')
          .select('*, profiles(full_name, avatar_url)')
          .eq('status', 'Published')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch published ideas: $e');
    }
  }

  @override
  Future<Idea?> fetchIdeaById(String id) async {
    try {
      final response = await _supabase
          .from('ideas')
          .select('*, profiles(full_name, avatar_url)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return IdeaModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch idea by id: $e');
    }
  }

  @override
  Future<List<Idea>> fetchAllPublicIdeas() async {
    try {
      final response = await _supabase
          .from('ideas')
          .select()
          .eq('visibility', 'Public')
          .eq('status', 'Published')
          .order('created_at', ascending: false);

      return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch public ideas: $e');
    }
  }

  @override
  Future<String> createIdea(Idea idea) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final ideaModel = IdeaModel(
        id: idea.id,
        title: idea.title,
        description: idea.description,
        ownerId: userId,
        problemStatement: idea.problemStatement,
        targetMarket: idea.targetMarket,
        currentStage: idea.currentStage,
        isPublic: idea.isPublic,
        tags: idea.tags,
        status: idea.status,
        viewCount: idea.viewCount,
        applicationCount: idea.applicationCount,
        aiQualityScore: idea.aiQualityScore,
        industry: idea.industry,
        subIndustry: idea.subIndustry,
        businessModel: idea.businessModel,
        monetizationStrategy: idea.monetizationStrategy,
        location: idea.location,
        fundingNeeded: idea.fundingNeeded,
        equityOffered: idea.equityOffered,
        teamSize: idea.teamSize,
        lookingForInvestor: idea.lookingForInvestor,
        lookingForCofounder: idea.lookingForCofounder,
        lookingForMentor: idea.lookingForMentor,
        coverImageUrl: idea.coverImageUrl,
        pitchDeckUrl: idea.pitchDeckUrl,
        demoVideoUrl: idea.demoVideoUrl,
        websiteUrl: idea.websiteUrl,
      );

      final json = ideaModel.toJson();
      if (idea.id.isEmpty) json.remove('id');

      final response = await _supabase
          .from('ideas')
          .insert(json)
          .select()
          .maybeSingle();
      if (response == null) throw Exception('Failed to retrieve created idea ID');
      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create idea: $e');
    }
  }

  @override
  Future<void> updateIdea(Idea idea) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final ideaModel = IdeaModel(
        id: idea.id,
        title: idea.title,
        description: idea.description,
        ownerId: userId,
        problemStatement: idea.problemStatement,
        targetMarket: idea.targetMarket,
        currentStage: idea.currentStage,
        isPublic: idea.isPublic,
        tags: idea.tags,
        status: idea.status,
        viewCount: idea.viewCount,
        applicationCount: idea.applicationCount,
        aiQualityScore: idea.aiQualityScore,
        industry: idea.industry,
        subIndustry: idea.subIndustry,
        businessModel: idea.businessModel,
        monetizationStrategy: idea.monetizationStrategy,
        location: idea.location,
        fundingNeeded: idea.fundingNeeded,
        equityOffered: idea.equityOffered,
        teamSize: idea.teamSize,
        lookingForInvestor: idea.lookingForInvestor,
        lookingForCofounder: idea.lookingForCofounder,
        lookingForMentor: idea.lookingForMentor,
        coverImageUrl: idea.coverImageUrl,
        pitchDeckUrl: idea.pitchDeckUrl,
        demoVideoUrl: idea.demoVideoUrl,
        websiteUrl: idea.websiteUrl,
      );

      final json = ideaModel.toJson();
      json.remove('owner_id');
      json.remove('id');

      await _supabase
          .from('ideas')
          .update(json)
          .eq('id', idea.id)
          .eq('owner_id', userId);
    } catch (e) {
      throw Exception('Failed to update idea: $e');
    }
  }

  @override
  Future<void> deleteIdea(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await _supabase
          .from('ideas')
          .delete()
          .eq('id', id)
          .eq('owner_id', userId);
    } catch (e) {
      throw Exception('Failed to delete idea: $e');
    }
  }

  @override
  Future<void> incrementViewCount(String ideaId) async {
    try {
      await _supabase.rpc(
        'increment_view_count',
        params: {'idea_uuid': ideaId},
      );
    } catch (e) {
      debugPrint('Failed to increment view count: $e');
    }
  }

  @override
  Future<String?> uploadCoverImage(dynamic imageFile, String userId) async {
    try {
      final file = imageFile as File;
      final fileExt = file.path.split('.').last.toLowerCase();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$userId.$fileExt';
      final bytes = await file.readAsBytes(); // Read file as bytes

      final response = await _supabase.storage
          .from('idea-assets') // Changed from 'idea-covers'
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isEmpty) return null;

      final url = _supabase.storage
          .from('idea-assets')
          .getPublicUrl(fileName); // Changed from 'idea-covers'
      return url;
    } catch (e) {
      debugPrint('[IdeaRepositoryImpl] uploadCoverImage error: $e');
      return null;
    }
  }
}
