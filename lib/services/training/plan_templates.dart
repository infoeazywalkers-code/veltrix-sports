/// Catalog templates for the five marketplace training plans.
///
/// Each template describes 2-4 workouts per week plus the plan duration, so
/// [TrainingPlanService.materializeWeeklyWorkouts] can deterministically
/// expand a purchase into dated [Workout] docs. Nothing here is fetched from
/// a backend: the content mirrors the static marketplace catalog.
library;

/// A single workout repeated every week of a plan.
class PlanTemplateWorkout {
  final String title;
  final String sport;
  final String duration;
  final int tss;
  final String description;
  final int weekdayOffset;

  const PlanTemplateWorkout({
    required this.title,
    required this.sport,
    required this.duration,
    required this.tss,
    required this.description,
    required this.weekdayOffset,
  });
}

/// A marketplace plan template: weekly pattern x [durationWeeks].
class PlanTemplate {
  final String catalogId;
  final String name;
  final String description;
  final String sport;
  final int durationWeeks;
  final String difficulty;
  final double price;
  final List<PlanTemplateWorkout> workouts;

  const PlanTemplate({
    required this.catalogId,
    required this.name,
    required this.description,
    required this.sport,
    required this.durationWeeks,
    required this.difficulty,
    required this.price,
    required this.workouts,
  });
}

/// Monday of next week (always strictly in the future, even when [from]
/// is already a Monday), at midnight.
DateTime nextMonday(DateTime from) {
  final base = DateTime(from.year, from.month, from.day);
  final delta = (DateTime.monday - base.weekday) % 7;
  return base.add(Duration(days: delta == 0 ? 7 : delta));
}

const PlanTemplate _granFondo = PlanTemplate(
  catalogId: '1',
  name: 'Gran Fondo 200km',
  description:
      'Progressive endurance plan targeting a 200km Gran Fondo with 2500m+ climbing.',
  sport: 'bike',
  durationWeeks: 12,
  difficulty: 'Intermediate',
  price: 39.99,
  workouts: [
    PlanTemplateWorkout(
      title: 'Sweet Spot Intervals',
      sport: 'bike',
      duration: '60 min',
      tss: 75,
      description: '3x12 min sweet spot with 5 min easy spin between efforts.',
      weekdayOffset: 1,
    ),
    PlanTemplateWorkout(
      title: 'Aerobic Endurance Ride',
      sport: 'bike',
      duration: '90 min',
      tss: 65,
      description: 'Steady Zone 2 endurance, cadence 85-95 rpm.',
      weekdayOffset: 3,
    ),
    PlanTemplateWorkout(
      title: 'Long Gran Fondo Ride',
      sport: 'bike',
      duration: '4h',
      tss: 180,
      description:
          'Long Zone 2 ride with climbing simulation in the final hour.',
      weekdayOffset: 5,
    ),
    PlanTemplateWorkout(
      title: 'Recovery Spin',
      sport: 'bike',
      duration: '45 min',
      tss: 25,
      description: 'Easy Zone 1 spin to promote blood flow.',
      weekdayOffset: 6,
    ),
  ],
);

const PlanTemplate _sub3Marathon = PlanTemplate(
  catalogId: '2',
  name: 'Sub-3h Marathon',
  description:
      'Elite marathon program with VO2max intervals, tempo runs, and strategic tapering.',
  sport: 'run',
  durationWeeks: 16,
  difficulty: 'Advanced',
  price: 49.99,
  workouts: [
    PlanTemplateWorkout(
      title: 'VO2max Intervals',
      sport: 'run',
      duration: '50 min',
      tss: 85,
      description: '6x800m at 5K effort with 400m jog recoveries.',
      weekdayOffset: 1,
    ),
    PlanTemplateWorkout(
      title: 'Tempo Run',
      sport: 'run',
      duration: '60 min',
      tss: 80,
      description: '20 min warm up, 30 min marathon-pace tempo, cool down.',
      weekdayOffset: 3,
    ),
    PlanTemplateWorkout(
      title: 'Long Run',
      sport: 'run',
      duration: '2h',
      tss: 140,
      description: 'Aerobic long run finishing with 15 min marathon pace.',
      weekdayOffset: 5,
    ),
    PlanTemplateWorkout(
      title: 'Recovery Run',
      sport: 'run',
      duration: '30 min',
      tss: 25,
      description: 'Easy Zone 1 shakeout run.',
      weekdayOffset: 6,
    ),
  ],
);

const PlanTemplate _alpineUltra = PlanTemplate(
  catalogId: '3',
  name: 'Alpine Trail Ultra 100k',
  description:
      'Ultra-trail preparation with mountain-specific strength, vert training, and nutrition periodization.',
  sport: 'run',
  durationWeeks: 20,
  difficulty: 'Expert',
  price: 69.99,
  workouts: [
    PlanTemplateWorkout(
      title: 'Vert Intervals',
      sport: 'run',
      duration: '75 min',
      tss: 95,
      description: 'Hill repeats on steep grade, hike the recoveries.',
      weekdayOffset: 1,
    ),
    PlanTemplateWorkout(
      title: 'Mountain Strength',
      sport: 'strength',
      duration: '45 min',
      tss: 40,
      description: 'Single-leg strength, core, and downhill eccentric work.',
      weekdayOffset: 3,
    ),
    PlanTemplateWorkout(
      title: 'Long Trail Day',
      sport: 'run',
      duration: '5h',
      tss: 220,
      description: 'Back-to-back style long trail run with vert target.',
      weekdayOffset: 5,
    ),
    PlanTemplateWorkout(
      title: 'Easy Trail Shakeout',
      sport: 'run',
      duration: '40 min',
      tss: 30,
      description: 'Flat easy trail run with mobility finish.',
      weekdayOffset: 6,
    ),
  ],
);

const PlanTemplate _powerMastery = PlanTemplate(
  catalogId: '4',
  name: 'Power Meter Mastery',
  description:
      'Learn to train with power across all zones. Includes FTP testing, zone calibration, and race-power strategy.',
  sport: 'bike',
  durationWeeks: 8,
  difficulty: 'All Levels',
  price: 29.99,
  workouts: [
    PlanTemplateWorkout(
      title: 'FTP Builder Intervals',
      sport: 'bike',
      duration: '60 min',
      tss: 80,
      description: '2x20 min threshold efforts to calibrate zones.',
      weekdayOffset: 1,
    ),
    PlanTemplateWorkout(
      title: 'Zone Calibration Ride',
      sport: 'bike',
      duration: '75 min',
      tss: 60,
      description: 'Progressive Zone 2-4 ladder with cadence drills.',
      weekdayOffset: 3,
    ),
    PlanTemplateWorkout(
      title: 'Race-Power Simulation',
      sport: 'bike',
      duration: '90 min',
      tss: 95,
      description: 'Over-under intervals finishing with a 10 min time trial.',
      weekdayOffset: 5,
    ),
  ],
);

const PlanTemplate _couchTo100k = PlanTemplate(
  catalogId: '5',
  name: 'Base Building: Couch to 100km Cycling',
  description:
      'Zero to 100km in 10 weeks. Progressive volume with recovery weeks. Perfect for new cyclists.',
  sport: 'bike',
  durationWeeks: 10,
  difficulty: 'Beginner',
  price: 19.99,
  workouts: [
    PlanTemplateWorkout(
      title: 'Foundation Spin',
      sport: 'bike',
      duration: '45 min',
      tss: 35,
      description: 'Comfortable Zone 1-2 spin focusing on smooth pedaling.',
      weekdayOffset: 1,
    ),
    PlanTemplateWorkout(
      title: 'Skills and Cadence',
      sport: 'bike',
      duration: '40 min',
      tss: 30,
      description: 'Cadence pyramids and bike-handling drills.',
      weekdayOffset: 3,
    ),
    PlanTemplateWorkout(
      title: 'Weekend Endurance Builder',
      sport: 'bike',
      duration: '2h',
      tss: 90,
      description:
          'Longest ride of the week, fully aerobic with fueling practice.',
      weekdayOffset: 5,
    ),
  ],
);

/// The five marketplace catalog entries keyed by catalog id.
const Map<String, PlanTemplate> kPlanTemplates = {
  '1': _granFondo,
  '2': _sub3Marathon,
  '3': _alpineUltra,
  '4': _powerMastery,
  '5': _couchTo100k,
};
