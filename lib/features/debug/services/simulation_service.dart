import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SimulationService {
  final SupabaseClient _supabase;

  SimulationService(this._supabase);

  // --- Helpers ---
  String _randomId() => const Uuid().v4();
  final _random = Random();

  T _pickOne<T>(List<T> list) => list[_random.nextInt(list.length)];

  // --- Data Lists ---
  final _skills = [
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'AI/ML',
    'Blockchain',
    'UI/UX Design',
    'Marketing',
    'Sales',
  ];

  final _titles = [
    'Eco-Friendly Food Delivery',
    'AI Powered Personal Stylist',
    'Blockchain Voting System',
    'VR Education Platform',
    'Smart Home Energy Manager',
    'Health & Wellness Tracker',
    'Remote Team Collaboration Tool',
    'Sustainable Fashion Marketplace',
  ];

  // --- 1. Profile Simulation ---
  Future<void> autoFillProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final updates = {
      'full_name': 'Alex Innovator',
      'headline': 'Building the future of tech',
      'bio':
          'Passionate entrepreneur with a background in software engineering. Loves coffee and code.',
      'skills': [_pickOne(_skills), _pickOne(_skills), _pickOne(_skills)],
      'role': 'Innovator', // Defaulting to Innovator for test
      'profile_completion': 85,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  // --- 2. Idea Simulation ---
  Future<void> postDummyIdeas(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    for (int i = 0; i < count; i++) {
      final title = '${_pickOne(_titles)} ${i + 1}';
      await _supabase.from('ideas').insert({
        'id': _randomId(),
        'owner_id': userId,
        'title': title,
        'description':
            'A revolutionary solution for $title. We address key pain points using advanced technology.',
        'problem_statement':
            'People struggle with X, and current solutions are too expensive or complex.',
        'solution':
            'Our app provides a seamless key-value proposition that solves X efficiently.',
        'target_audience': 'Gen Z, Tech Enthusiasts',
        'category': 'Technology',
        'stage': _pickOne(['Idea', 'Prototype', 'MVP', 'Growth']),
        'status': 'Active',
        'skills_needed': [_pickOne(_skills), _pickOne(_skills)],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // --- 3. Interaction Simulation (Tricky part: Creating Fake Users) ---
  // We attempt to create profiles. If FK constraint exists, this might fail unless we have a way to create auth users.
  // For 'Simulating Real Users', we will try to insert into profiles.
  Future<void> simulateIncomingRequests(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    // Get user's ideas
    final ideas = await _supabase
        .from('ideas')
        .select('id')
        .eq('owner_id', userId);
    if (ideas.isEmpty) throw Exception('Post some ideas first!');

    for (int i = 0; i < count; i++) {
      final fakeUserId = _randomId();

      // Try to create a fake profile first (might fail if auth.users FK exists)
      try {
        await _supabase.from('profiles').insert({
          'id': fakeUserId,
          'full_name': 'Fake User ${i + 1}',
          'headline': 'Aspiring Collaborator',
          'role': 'Collaborator',
          'email': 'fake${i + 1}@test.com', // Optional if schema allows
          // 'avatar_url': 'https://i.pravatar.cc/150?u=$fakeUserId',
        });
      } catch (e) {
        debugPrint('Could not create fake profile (expected if stricter FK): $e');
        // If we can't create a profile, we can't really simulate a request from "someone else"
        // effectively unless we reuse the current user (which is weird) or have seeded users.
        // Let's assume for a "Test Context" we might have disabled FK or have a way.
        // If this fails, we stop.
        return;
      }

      // Create Request
      final ideaId = _pickOne(ideas)['id'];
      await _supabase.from('collaboration_requests').insert({
        'id': _randomId(),
        'idea_id': ideaId,
        'applicant_id': fakeUserId,
        'innovator_id': userId,
        'status': 'pending',
        'message':
            'I would love to help with this! I have experience in ${_pickOne(_skills)}.',
        'role_applied': 'Developer',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // --- 4. Investor Simulation ---
  Future<void> simulateInvestorInterest() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final ideas = await _supabase
        .from('ideas')
        .select('id')
        .eq('owner_id', userId);
    if (ideas.isEmpty) throw Exception('Post some ideas first!');

    final fakeInvestorId = _randomId();
    // Try create fake investor profile
    try {
      await _supabase.from('profiles').insert({
        'id': fakeInvestorId,
        'full_name': 'VC Partner ${Random().nextInt(100)}',
        'headline': 'Angel Investor',
        'role': 'Investor',
        'email': 'investor${Random().nextInt(1000)}@vc.com',
      });
    } catch (_) {}

    final ideaId = _pickOne(ideas)['id'];
    await _supabase.from('interests').insert({
      'id': _randomId(),
      'investor_id': fakeInvestorId,
      'idea_id': ideaId,
      'status': 'Pending', // or 'Interested'
      'message': 'We are interested in your seed round.',
      'commitment_amount': (Random().nextInt(50) + 10) * 1000, // 10k - 60k
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // --- 5. AI Feedback Simulation ---
  Future<void> simulateAIFeedback() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user logged in');

    final ideas = await _supabase
        .from('ideas')
        .select('id')
        .eq('owner_id', userId);
    if (ideas.isEmpty) throw Exception('Post some ideas first!');

    final ideaId = _pickOne(ideas)['id'];

    // Assume 'ai_feedback' table
    await _supabase.from('ai_feedback').insert({
      'id': _randomId(),
      'idea_id': ideaId,
      'overall_score': 85,
      'viability_score': 80,
      'technical_score': 90,
      'market_score': 85,
      'feedback_text':
          'Strong technical foundation. Market entry strategy needs refinement.',
      'suggestions': ['Focus on MVP', 'Validate with 10 users'],
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
