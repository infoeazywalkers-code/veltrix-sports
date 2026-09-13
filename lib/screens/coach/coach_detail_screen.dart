import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/social/coach_service.dart';
import '../../widgets/dialogs/coach_booking_dialog.dart';
import 'coach_questionnaire_screen.dart';

/// Public coach detail: profile hero, credentials, rating summary,
/// booking CTAs, and the `coaches/{coachId}/reviews` read/write path.
class CoachDetailScreen extends StatefulWidget {
  final String coachId;
  const CoachDetailScreen({super.key, required this.coachId});

  @override
  State<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends State<CoachDetailScreen> {
  Future<CoachProfile?>? _future;

  @override
  void initState() {
    super.initState();
    _future = CoachService.fetchCoachById(widget.coachId);
  }

  void _retry() {
    setState(() => _future = CoachService.fetchCoachById(widget.coachId));
  }

  Future<void> _openBooking(CoachProfile coach) async {
    await showDialog(
      context: context,
      builder: (_) => CoachBookingDialog(coach: coach),
    );
  }

  Future<void> _openQuestionnaire() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CoachQuestionnaireScreen()));
    if (!mounted) return;
    if (result == true) {
      showFeatureMessage(
        context,
        'Questionnaire submitted. We will match you shortly.',
      );
    } else if (result == 'signIn') {
      showFeatureMessage(
        context,
        'Please sign in to submit your coach questionnaire.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach detail')),
      body: FutureBuilder<CoachProfile?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40, color: orange),
                  const SizedBox(height: 12),
                  const Text('Could not load coach.'),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          final coach = snapshot.data;
          if (coach == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 40, color: muted),
                  const SizedBox(height: 12),
                  const Text(
                    'Coach not found.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 48),
            children: [
              _CoachHero(coach: coach),
              const SizedBox(height: 20),
              _CtaRow(
                onBook: () => _openBooking(coach),
                onMatch: _openQuestionnaire,
              ),
              const SizedBox(height: 24),
              _ReviewsSection(coachId: coach.id),
            ],
          );
        },
      ),
    );
  }
}

class _CoachHero extends StatelessWidget {
  final CoachProfile coach;
  const _CoachHero({required this.coach});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DetailAvatar(image: coach.displayAvatar, name: coach.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              coach.name.isEmpty ? 'Coach' : coach.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: dark ? Colors.white : navy,
                              ),
                            ),
                          ),
                          if (coach.verified)
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (coach.title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          coach.title,
                          style: const TextStyle(
                            color: blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _RatingSummary(coach: coach),
                    ],
                  ),
                ),
              ],
            ),
            if (coach.credentials.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    size: 16,
                    color: muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      coach.credentials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (coach.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                coach.bio,
                style: TextStyle(
                  color: dark ? const Color(0xFFB0BEC5) : muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
            if (coach.philosophy.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1A2A3A) : bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '“${coach.philosophy}”',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    height: 1.5,
                    color: dark ? Colors.white70 : ink,
                  ),
                ),
              ),
            ],
            if (coach.specialities.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: coach.specialities
                    .map(
                      (spec) => Chip(
                        label: Text(
                          spec,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: bg,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (coach.sports.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: coach.sports
                    .map(
                      (sport) => Chip(
                        label: Text(
                          sport,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: const Color(0xffe7eff6),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              coach.monthlyFee,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: dark ? Colors.white : navy,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final CoachProfile coach;
  const _RatingSummary({required this.coach});

  @override
  Widget build(BuildContext context) {
    if (coach.reviewCount <= 0) {
      return const Row(
        children: [
          Icon(Icons.star_border, color: muted, size: 14),
          SizedBox(width: 4),
          Text('No reviews yet', style: TextStyle(fontSize: 11, color: muted)),
        ],
      );
    }
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 14),
        const SizedBox(width: 4),
        Text(
          '${coach.displayRating} (${coach.reviewCount} review${coach.reviewCount == 1 ? '' : 's'})',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DetailAvatar extends StatelessWidget {
  final String image;
  final String name;
  const _DetailAvatar({required this.image, required this.name});

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = image.trim();
    if (trimmed.isEmpty) {
      return CircleAvatar(
        radius: 34,
        backgroundColor: navy,
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      );
    }
    if (trimmed.startsWith('http')) {
      return CircleAvatar(
        radius: 34,
        backgroundColor: navy,
        child: ClipOval(
          child: Image.network(
            trimmed,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 34,
      backgroundColor: navy,
      child: ClipOval(
        child: Image.asset(
          trimmed,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaRow extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onMatch;
  const _CtaRow({required this.onBook, required this.onMatch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: lime,
              foregroundColor: navy,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onBook,
            icon: const Icon(Icons.call_outlined, size: 18),
            label: const Text(
              'Book Call',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onMatch,
            icon: const Icon(Icons.quiz_outlined, size: 18),
            label: const Text(
              'Request Match',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  final String coachId;
  const _ReviewsSection({required this.coachId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  Future<bool>? _eligibility;

  @override
  void initState() {
    super.initState();
    _eligibility = _checkEligibility();
  }

  /// Athletes with a prior inquiry for this coach (any status) or a
  /// `coach_athletes` assignment link may review. Guests cannot.
  Future<bool> _checkEligibility() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final inquiries = await CoachService.fetchMyInquiries(user.uid);
      if (inquiries.any((inquiry) => inquiry.coachId == widget.coachId)) {
        return true;
      }
    } catch (_) {}
    try {
      final assignment = await FirebaseFirestore.instance
          .collection('coach_athletes')
          .doc(user.uid)
          .get();
      if (assignment.exists) return true;
    } catch (_) {}
    return false;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: dark ? Colors.white : navy,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<bool>(
          future: _eligibility,
          builder: (context, snapshot) {
            final eligible = snapshot.data == true;
            if (eligible) return _ReviewForm(coachId: widget.coachId);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2A3A) : bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                FirebaseAuth.instance.currentUser == null
                    ? 'Sign in and book a call with this coach to leave a review.'
                    : 'Book a call with this coach to leave a review.',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? Colors.white70 : muted,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<CoachReview>>(
          stream: CoachService.watchReviews(widget.coachId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Text(
                'Could not load reviews.',
                style: TextStyle(color: muted, fontSize: 13),
              );
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Text(
                'No reviews yet — be the first after your session.',
                style: TextStyle(color: muted, fontSize: 13),
              );
            }
            return Column(
              children: reviews
                  .map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReviewCard(
                        review: review,
                        dateLabel: _formatDate(review.createdAt),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String coachId;
  const _ReviewForm({required this.coachId});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final ok = await CoachService.submitReview(
        coachId: widget.coachId,
        rating: _rating,
        text: _textController.text,
      );
      if (!mounted) return;
      if (ok) {
        _textController.clear();
        setState(() => _rating = 5);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted. Thank you!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not submit review.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leave a review',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _rating,
                decoration: const InputDecoration(
                  labelText: 'Rating',
                  border: OutlineInputBorder(),
                ),
                items: const [1, 2, 3, 4, 5]
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text('$v star${v == 1 ? '' : 's'}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _rating = v ?? 5),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _textController,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Your review *',
                  hintText: 'What worked well in your sessions?',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: lime,
                  foregroundColor: navy,
                ),
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rate_review_outlined, size: 18),
                label: Text(
                  _submitting ? 'Submitting…' : 'Submit review',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final CoachReview review;
  final String dateLabel;
  const _ReviewCard({required this.review, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final initial = review.userName.trim().isEmpty
        ? '?'
        : review.userName.trim()[0].toUpperCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: navy,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.userName.isEmpty ? 'Athlete' : review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${review.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (review.text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      review.text,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    dateLabel,
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
