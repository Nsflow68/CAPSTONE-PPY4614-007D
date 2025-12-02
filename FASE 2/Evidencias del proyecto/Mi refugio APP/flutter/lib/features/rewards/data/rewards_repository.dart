import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/shared/models/user_rewards.dart';

class RewardsRepository {
  final ApiService _apiService = ApiService.instance;

  Future<UserRewards?> getRewards() async {
    try {
      final response = await _apiService.getRaw('/rewards');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserRewards.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
      return null;
    }
  }

  Future<void> addPoints(int points) async {
    try {
      await _apiService.postRaw(
        '/rewards/add-points',
        body: jsonEncode({'points': points}),
      );
    } catch (e) {
      debugPrint('Error adding points: $e');
      rethrow;
    }
  }

  Future<void> updateUnlockedMascots(List<String> mascots) async {
    try {
      await _apiService.postRaw(
        '/rewards/unlock-mascots',
        body: jsonEncode({'mascots': mascots}),
      );
    } catch (e) {
      debugPrint('Error updating mascots: $e');
      rethrow;
    }
  }
}
