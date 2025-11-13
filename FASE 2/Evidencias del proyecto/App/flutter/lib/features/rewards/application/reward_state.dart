import 'package:equatable/equatable.dart';

class Reward extends Equatable {
  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.active = false,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final bool active;

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    bool? active,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'active': active,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      active: json['active'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, description, points, active];
}

class RewardSummary extends Equatable {
  const RewardSummary({required this.items, required this.balance});

  final List<Reward> items;
  final int balance;

  RewardSummary copyWith({List<Reward>? items, int? balance}) {
    return RewardSummary(
      items: items ?? this.items,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'items': items.map((r) => r.toJson()).toList(),
    };
  }

  factory RewardSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return RewardSummary(
      items: rawItems
          .map((item) => Reward.fromJson(item as Map<String, dynamic>))
          .toList(),
      balance: json['balance'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [items, balance];
}

sealed class RewardState {
  const RewardState();

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(String message) error,
    required T Function(RewardSummary summary) loaded,
  }) {
    final state = this;
    if (state is RewardInitial) return initial();
    if (state is RewardLoading) return loading();
    if (state is RewardError) return error(state.message);
    if (state is RewardLoaded) return loaded(state.summary);
    return initial();
  }
}

class RewardInitial extends RewardState {
  const RewardInitial();
}

class RewardLoading extends RewardState {
  const RewardLoading();
}

class RewardLoaded extends RewardState {
  const RewardLoaded(this.summary);
  final RewardSummary summary;
}

class RewardError extends RewardState {
  const RewardError(this.message);
  final String message;
}
