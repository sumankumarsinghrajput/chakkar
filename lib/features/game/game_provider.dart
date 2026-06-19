import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_models.dart';
import '../../shared/services/audio_manager.dart';

// Sample questions database
// Sample questions database — Hindi/Hinglish Brain Trap riddles
final List<Question> _allQuestions = [
  Question(
    id: 'bt_h1',
    question:
        'Race mein tum second wale ko cross karo, tum kaunse number par aaoge?',
    options: ['First', 'Second', 'Third', 'Last'],
    correctIndex: 1,
    explanation: 'Tum second wale ki jagah le loge, woh third ban jayega!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h2',
    question: '1 kilo loha ya 1 kilo kapas, zyada bhaari kya hai?',
    options: ['Loha', 'Kapas', 'Dono same', 'Pata nahi'],
    correctIndex: 2,
    explanation: 'Dono ka wajan 1 kilo hi hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h4',
    question: '100 se 10 kitni baar ghata sakte ho?',
    options: ['10 baar', 'Sirf ek baar', '100 baar', '5 baar'],
    correctIndex: 1,
    explanation: 'Pehli baar ghatane ke baad 90 bachega, 100 nahi rahega!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h5',
    question: 'Agar tum 2 seb le lo, tumhare paas kitne seb honge?',
    options: ['1', '2', '3', '0'],
    correctIndex: 1,
    explanation: 'Tumne 2 liye, toh tumhare paas 2 hi hain!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h6',
    question: 'Murga anda kis taraf deta hai?',
    options: ['Left', 'Right', 'Murga anda nahi deta', 'Upar'],
    correctIndex: 2,
    explanation: 'Murgi anda deti hai, murga nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h7',
    question: 'Kaunsi cheez paani peete hi mar jaati hai?',
    options: ['Paudha', 'Aag', 'Macchi', 'Kapda'],
    correctIndex: 1,
    explanation: 'Paani daalte hi aag bujh jaati hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h8',
    question: 'Kaunsi cheez tootne ke baad kaam aati hai?',
    options: ['Glass', 'Anda', 'Plate', 'Phone'],
    correctIndex: 1,
    explanation: 'Anda todna padta hai use khane ke liye!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h9',
    question: 'Kaunsi cheez bharne par halki ho jaati hai?',
    options: ['Bottle', 'Bag', 'Balloon', 'Box'],
    correctIndex: 2,
    explanation: 'Gas se bhara balloon hawa mein udta hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h10',
    question: 'Kaunsi cheez jitni nikaalo utni badi hoti hai?',
    options: ['Rassi', 'Gaddha', 'Cake', 'Roti'],
    correctIndex: 1,
    explanation: 'Mitti nikalne se gaddha bada hota jaata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h11',
    question: 'Kaunsa bank paise nahi rakhta?',
    options: ['SBI', 'HDFC', 'River Bank', 'ICICI'],
    correctIndex: 2,
    explanation: 'River bank ek nadi ka kinara hota hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h12',
    question: 'Kaunsa cup peeya nahi ja sakta?',
    options: ['Tea Cup', 'World Cup', 'Coffee Cup', 'Milk Cup'],
    correctIndex: 1,
    explanation: 'World Cup ek trophy hai, peene wali cheez nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h13',
    question: 'Kaunsi cheez geeli hokar bhi sukhaati hai?',
    options: ['Pani', 'Towel', 'Sponge', 'Cloth'],
    correctIndex: 1,
    explanation: 'Towel khud geela hokar hume sukhaata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h14',
    question: 'Kaunsi cheez bolti nahi phir bhi jawab deti hai?',
    options: ['Phone', 'Echo', 'Radio', 'TV'],
    correctIndex: 1,
    explanation: 'Echo tumhari hi awaaz wapas karta hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h15',
    question: 'Kaunsi cheez ki aankh hai par dekh nahi sakti?',
    options: ['Sui', 'Camera', 'Doll', 'Glasses'],
    correctIndex: 0,
    explanation: 'Sui ki aankh sirf dhaaga dalne ke liye hoti hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h16',
    question: 'Kaunsi cheez ki gardan hai par sir nahi?',
    options: ['Bottle', 'Doll', 'Shirt', 'Necklace'],
    correctIndex: 0,
    explanation: 'Bottle ki gardan hoti hai par sir nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h17',
    question: 'Kaunsi cheez ke daant hain par kaat nahi sakti?',
    options: ['Aara', 'Kanghi', 'Chaaku', 'Kainchi'],
    correctIndex: 1,
    explanation: 'Kanghi ke daant baal sulajhane ke liye hote hain!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h18',
    question: 'Kaunsi cheez ka pair hai par chal nahi sakti?',
    options: ['Insaan', 'Table', 'Ghoda', 'Robot'],
    correctIndex: 1,
    explanation: 'Table ke pair hote hain par chal nahi sakti!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h19',
    question: 'Kaunsi cheez ki chaabi hai par tala nahi?',
    options: ['Door', 'Keyboard', 'Locker', 'Safe'],
    correctIndex: 1,
    explanation: 'Keyboard ki keys hoti hain, tala nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h20',
    question: 'Kaunsi cheez ka muh hai par khati nahi?',
    options: ['Insaan', 'Nadi', 'Bottle', 'Jaanwar'],
    correctIndex: 1,
    explanation: 'Nadi ka muh samundra mein milne ki jagah hota hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h21',
    question: 'Agar kal ke baad Sunday hai, aaj kya hai?',
    options: ['Friday', 'Saturday', 'Sunday', 'Monday'],
    correctIndex: 0,
    explanation: 'Kal ke baad Sunday matlab kal Saturday, toh aaj Friday!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h22',
    question:
        'Machhli paani mein hai, baarish ho gayi. Kya machhli geeli hogi?',
    options: ['Haan', 'Nahi, pehle se geeli hai', 'Pata nahi', 'Thodi si'],
    correctIndex: 1,
    explanation: 'Machhli pehle se hi paani mein geeli hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h23',
    question: 'Kaunsi cheez bina pankh ke udti hai?',
    options: ['Patang', 'Samay', 'Gubbara', 'Pakshi'],
    correctIndex: 1,
    explanation: 'Samay udta hai bina pankh ke!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h24',
    question: 'Kaunsi cheez upar jaati hai par neeche nahi aati?',
    options: ['Gend', 'Umar', 'Patang', 'Rocket'],
    correctIndex: 1,
    explanation: 'Umar sirf badhti hai, kam nahi hoti!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h25',
    question: 'Ek room mein 5 log hain, 2 bahar chale gaye. Kitne bache?',
    options: ['2', '3', '5', '0'],
    correctIndex: 1,
    explanation: '5 mein se 2 gaye toh 3 bache!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h26',
    question: 'Kaunsi cheez jitni chalti hai utni kam hoti jaati hai?',
    options: ['Pencil', 'Mombatti', 'Soap', 'Eraser'],
    correctIndex: 1,
    explanation: 'Mombatti jalte jalte chhoti hoti jaati hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h27',
    question:
        'Doctor ne 3 goli di, har 30 minute mein ek. Kitne time mein khatam?',
    options: ['1.5 Hour', '1 Hour', '90 minute', '2 Hour'],
    correctIndex: 1,
    explanation: 'Pehli goli abhi, dusri 30 min baad, teesri 1 hour baad!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h28',
    question: 'Kaunsi cheez hamesha saamne hai par dikhti nahi?',
    options: ['Past', 'Future', 'Hawa', 'Khushi'],
    correctIndex: 1,
    explanation: 'Future hamesha aage hai par dikhta nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h29',
    question: 'Kaunsi cheez hamesha aati hai par kabhi nahi aati?',
    options: ['Aaj', 'Kal', 'Bahar', 'Andar'],
    correctIndex: 1,
    explanation: 'Kal kabhi nahi aata, har din "aaj" ban jaata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h30',
    question: 'Ek aadmi 8 din bina soye kaise raha?',
    options: ['Coffee piya', 'Raat mein sota tha', 'Pill khayi', 'Yoga kiya'],
    correctIndex: 1,
    explanation: 'Woh raat mein sota tha, sirf din mein nahi soya!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h31',
    question: 'Kaunsa room hai jisme reh nahi sakte?',
    options: ['Bedroom', 'Mushroom', 'Bathroom', 'Classroom'],
    correctIndex: 1,
    explanation: 'Mushroom ek sabzi hai, kamra nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h32',
    question:
        'Kaunsi cheez khane ke liye kharidi jaati hai par khayi nahi jaati?',
    options: ['Roti', 'Plate', 'Sabzi', 'Chawal'],
    correctIndex: 1,
    explanation: 'Plate mein khaana parosa jaata hai, plate nahi khaate!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h33',
    question: 'Kaunsi cheez ka dil hai par dhadakta nahi?',
    options: ['Insaan', 'Cards ka Heart', 'Robot', 'Jaanwar'],
    correctIndex: 1,
    explanation: 'Cards ke heart symbol mein dhadkan nahi hoti!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h34',
    question: 'Kaunsi cheez ka wajan nahi hota par pakad nahi sakte?',
    options: ['Hawa', 'Saans', 'Paani', 'Dhuaan'],
    correctIndex: 1,
    explanation: 'Saans ko pakda nahi ja sakta!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h35',
    question: 'Agar train electric hai to dhuaan kidhar jayega?',
    options: ['Upar', 'Neeche', 'Dhuaan nahi hoga', 'Side mein'],
    correctIndex: 2,
    explanation: 'Electric train mein dhuaan hota hi nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h36',
    question: 'Kaunsi cheez bina zubaan ke bolti hai?',
    options: ['Tota', 'Ghanti', 'Radio', 'Phone'],
    correctIndex: 1,
    explanation: 'Ghanti bajti hai bina zubaan ke!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h37',
    question: 'Kaunsa phal padh nahi sakta?',
    options: ['Aam', 'Anpadh phal', 'Seb', 'Kela'],
    correctIndex: 1,
    explanation: 'Yeh ek wordplay hai - "Anpadh" matlab jo padh nahi sakta!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h38',
    question: 'Kaunsi cheez andhere mein bhi tumhare saath hoti hai?',
    options: ['Saaya', 'Tum khud', 'Doston', 'Phone'],
    correctIndex: 1,
    explanation:
        'Saaya andhere mein gayab ho jaata hai, par tum hamesha tumhare saath ho!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h39',
    question: 'Ek aadmi ka birthday har saal nahi aata. Kaise?',
    options: [
      'Voh fake hai',
      '29 February',
      'Voh bhool jaata hai',
      'Calendar galat hai',
    ],
    correctIndex: 1,
    explanation: '29 February sirf leap year mein aata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h40',
    question: 'Kaunsi cheez ko jitna saaf karo utni kaali hoti hai?',
    options: ['Mirror', 'Blackboard', 'Glass', 'Table'],
    correctIndex: 1,
    explanation:
        'Blackboard saaf karne se chalk ke nishaan hat jaate hain aur kaala dikhta hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h41',
    question: 'Agar 10 machhli mein 3 mar gayi, kitni bachi?',
    options: ['7', '10', '3', '0'],
    correctIndex: 1,
    explanation: 'Saari machhli paani mein hi hai, koi nahi gayi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h42',
    question: 'Kaunsi cheez khud chalti nahi phir bhi time batati hai?',
    options: ['Clock', 'Calendar', 'Phone', 'Watch'],
    correctIndex: 1,
    explanation: 'Calendar khud nahi chalta, par din-mahina batata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h43',
    question: 'Kaunsi cheez khud toot jaaye to awaaz nahi karti?',
    options: ['Glass', 'Vishwas', 'Plate', 'Mirror'],
    correctIndex: 1,
    explanation: 'Vishwas tootne par koi awaaz nahi hoti!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h44',
    question: 'Kaunsi cheez ka rang nahi hota phir bhi dikh jaati hai?',
    options: ['Hawa', 'Dhuaan', 'Paani', 'Roshni'],
    correctIndex: 1,
    explanation: 'Dhuaan bina rang ke bhi dikh jaata hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h45',
    question:
        'Agar tumhare ek haath mein 5 seb aur doosre mein 6 seb hain, tumhare paas kya hai?',
    options: ['11 seb', 'Bade haath', '5 seb', '6 seb'],
    correctIndex: 1,
    explanation: '11 seb itne bade haath mein nahi aate, isliye bade haath!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h46',
    question: 'Kaunsi cheez bina engine ke chalti hai?',
    options: ['Car', 'Nadi', 'Train', 'Bike'],
    correctIndex: 1,
    explanation: 'Nadi bina engine ke khud bahti hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.easy,
  ),
  Question(
    id: 'bt_h47',
    question: 'Kaunsi cheez ko jitna kheencho utni chhoti hoti hai?',
    options: ['Rassi', 'Cigarette', 'Rubber Band', 'Dhaaga'],
    correctIndex: 1,
    explanation:
        'Cigarette jitni cash ki jaati hai utni chhoti hoti jaati hai!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h48',
    question: 'Kaunsa din kabhi nahi aata?',
    options: ['Aaj', 'Kal', 'Parso', 'Sunday'],
    correctIndex: 1,
    explanation: 'Kal hamesha "aane wala" hota hai, kabhi aata nahi!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'bt_h49',
    question: 'Kaunsi cheez kharidne wala use nahi karta?',
    options: ['Gift', 'Kafan', 'Bookcase', 'Toy'],
    correctIndex: 1,
    explanation: 'Kafan kharidne wala khud uska upyog nahi karta!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  Question(
    id: 'bt_h50',
    question: 'Kaunsi cheez bechne wala use nahi karta?',
    options: ['Sabzi', 'Kafan', 'Mithai', 'Kapda'],
    correctIndex: 1,
    explanation: 'Kafan bechne wala bhi khud use istemal nahi karta!',
    category: GameCategory.brainTrap,
    difficulty: Difficulty.hard,
  ),
  // Logic
  Question(
    id: 'lg1',
    question:
        'If all Bloops are Razzles and all Razzles are Lazzles, are all Bloops definitely Lazzles?',
    options: ['Yes', 'No', 'Maybe', 'Cannot say'],
    correctIndex: 0,
    explanation: 'Bloops → Razzles → Lazzles, so Bloops are Lazzles!',
    category: GameCategory.logic,
    difficulty: Difficulty.medium,
  ),
  Question(
    id: 'lg2',
    question: 'What comes next: 2, 4, 8, 16, ?',
    options: ['24', '32', '18', '20'],
    correctIndex: 1,
    explanation: 'Each number doubles: 16 x 2 = 32',
    category: GameCategory.logic,
    difficulty: Difficulty.easy,
  ),
  // Memory
  Question(
    id: 'mm1',
    question:
        'Which color appears in BOTH the Indian flag and the French flag?',
    options: ['Green', 'Orange', 'Blue', 'White'],
    correctIndex: 3,
    explanation: 'White appears in both flags!',
    category: GameCategory.memory,
    difficulty: Difficulty.easy,
  ),
];

List<Question> getQuestions(GameCategory category, Difficulty difficulty) {
  var filtered = _allQuestions
      .where((q) => q.category == category && q.difficulty == difficulty)
      .toList();

  // Fallback only if truly empty for this category+difficulty
  if (filtered.isEmpty) {
    filtered = _allQuestions.where((q) => q.category == category).toList();
  }

  filtered.shuffle();
  return filtered.take(5).toList();
}

// Game State
class GameState {
  final List<Question> questions;
  final int currentIndex;
  final int score;
  final int correct;
  final int wrong;
  final int timeLeft;
  final bool answered;
  final int? selectedIndex;
  final bool isFinished;

  const GameState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.correct = 0,
    this.wrong = 0,
    this.timeLeft = 30,
    this.answered = false,
    this.selectedIndex,
    this.isFinished = false,
  });

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  GameState copyWith({
    int? currentIndex,
    int? score,
    int? correct,
    int? wrong,
    int? timeLeft,
    bool? answered,
    int? selectedIndex,
    bool? isFinished,
  }) {
    return GameState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      timeLeft: timeLeft ?? this.timeLeft,
      answered: answered ?? this.answered,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  final Difficulty difficulty;
  final DateTime _startTime = DateTime.now();

  GameNotifier({required List<Question> questions, required this.difficulty})
    : super(GameState(questions: questions, timeLeft: difficulty.timeLimit)) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.answered) return;
      if (state.timeLeft <= 0) {
        _timeUp();
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  void _timeUp() {
    state = state.copyWith(answered: true, wrong: state.wrong + 1);
    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void answerQuestion(int index) {
    if (state.answered) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = index == question.correctIndex;
    final points = isCorrect
        ? (state.timeLeft * difficulty.pointsMultiplier * 10)
        : 0;

    // Play sound
    if (isCorrect) {
      print('Playing correct sound');
      audioManager.playCorrect();
    } else {
      print('Playing wrong sound');
      audioManager.playWrong();
    }

    state = state.copyWith(
      answered: true,
      selectedIndex: index,
      score: state.score + points,
      correct: isCorrect ? state.correct + 1 : state.correct,
      wrong: isCorrect ? state.wrong : state.wrong + 1,
    );

    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.questions.length) {
      _timer?.cancel();
      state = state.copyWith(isFinished: true);
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      timeLeft: difficulty.timeLimit,
      answered: false,
      selectedIndex: null,
    );
  }

  GameResult getResult() {
    return GameResult(
      score: state.score,
      correct: state.correct,
      wrong: state.wrong,
      total: state.questions.length,
      timeTaken: DateTime.now().difference(_startTime),
      difficulty: difficulty,
      category: state.questions.first.category,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, Map<String, dynamic>>(
      (ref, params) {
        return GameNotifier(
          questions: params['questions'] as List<Question>,
          difficulty: params['difficulty'] as Difficulty,
        );
      },
    );
