import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:femunity/features/posts/screens/Menstrual%20Tips%20Screen/exercise_tips.dart';
import 'package:femunity/features/posts/screens/Menstrual%20Tips%20Screen/food_tips.dart';
import 'package:femunity/features/posts/screens/Menstrual%20Tips%20Screen/stress_tips.dart';
import 'package:femunity/features/posts/screens/history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodTrackerScreen extends StatefulWidget {
  @override
  _PeriodTrackerScreenState createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  final TextEditingController _cycleController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _periodOn = false;
  DateTime? _selectedDate;
  DateTime? _nextPeriodDate;
  late String _userId;

  @override
  void initState() {
    super.initState();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _calculatePeriod() {
    if (_selectedDate != null &&
        _cycleController.text.isNotEmpty &&
        _periodController.text.isNotEmpty) {
      final int cycleLength = int.parse(_cycleController.text);
      final int periodLength = int.parse(_periodController.text);
      final Duration cycleDuration = Duration(days: cycleLength);
      final Duration periodDuration = Duration(days: periodLength);
      final DateTime periodStartDate = _selectedDate!;
      final DateTime periodEndDate =
          periodStartDate.add(periodDuration).subtract(const Duration(days: 1));
      final DateTime nextPeriodStartDate = periodStartDate.add(cycleDuration);
      final DateTime nextPeriodEndDate = nextPeriodStartDate
          .add(periodDuration)
          .subtract(const Duration(days: 1));
      setState(() {
        _nextPeriodDate = nextPeriodStartDate;
      });
      _saveData();
    }
  }

  void _saveData() {
    FirebaseFirestore.instance
        .collection('period-tracker-data')
        .doc(DateTime.now().toIso8601String())
        .set({
          'userId': _userId,
          'cycleLength': _cycleController.text,
          'periodLength': _periodController.text,
          'periodOn': _periodOn,
          'periodStartDate': _selectedDate,
          'periodEndDate': _selectedDate
              ?.add(Duration(days: int.parse(_periodController.text) - 1)),
          'nextPeriodDate': _nextPeriodDate,
        })
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data saved successfully'),
                backgroundColor: Color(0xFFAEC6CF),
              ),
            ))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save data: $error'),
                backgroundColor: const Color(0xFFAEC6CF),
              ),
            ));
  }

  Widget _buildHealthTipsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HealthTipsScreen()),
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: Colors.yellow),
            ),
          ),
          elevation: MaterialStateProperty.all<double>(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              const SizedBox(width: 8.0),
              const Text(
                'Health Tips',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Period Tracking',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Text(
                  'Enter your period details:',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _cycleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Cycle length (in days)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cycle length';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _periodController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Period length (in days)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter period length';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Period started on: ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      _selectedDate == null
                          ? 'Please select a date'
                          : DateFormat('dd MMM yyyy').format(_selectedDate!),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.green),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Are you on your period? ',
                      style: TextStyle(fontSize: 18),
                    ),
                    Switch(
                      value: _periodOn,
                      onChanged: (value) {
                        setState(() {
                          _periodOn = value;
                        });
                      },
                      activeColor: Colors.pink,
                      inactiveTrackColor: Colors.grey[400],
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: Colors.pink[100],
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ],
                ),
              ),
              if (_periodOn) _buildHealthTipsButton(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _calculatePeriod();
                    }
                  },
                  child: const Text(
                    'Calculate',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pink),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 72, vertical: 16)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
              ),
              if (_nextPeriodDate != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your next period will start on: ${DateFormat('dd MMM yyyy').format(_nextPeriodDate!)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthTipsScreen extends StatelessWidget {
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Female Health Tips'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPermanentFactsCard(),
            const SizedBox(height: 16),
            _buildHealthGuideCard(
              title: 'Healthy eating',
              imageUrl:
                  'https://flo.health/uploads/media/sulu-1000x-inset/09/929-foods%20periods%202.jpg',
              onTap: () => _navigateToScreen(context, FoodTipsScreen()),
            ),
            const SizedBox(height: 16),
            _buildHealthGuideCard(
              title: 'Fitness exercises',
              imageUrl:
                  'https://hips.hearstapps.com/hmg-prod/images/screen-shot-2020-10-29-at-10-09-57-am-1603980609.png?crop=1.00xw:0.576xh;0,0.424xh&resize=1200:*',
              onTap: () => _navigateToScreen(context, ExerciseTipsScreen()),
            ),
            const SizedBox(height: 16),
            _buildHealthGuideCard(
              title: 'Stress management',
              imageUrl:
                  'https://www.wikihow.com/images/thumb/a/a8/Deal-with-Stress-During-Menstruation-Step-3-Version-2.jpg/v4-460px-Deal-with-Stress-During-Menstruation-Step-3-Version-2.jpg',
              onTap: () => _navigateToScreen(context, StressTipsScreen()),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentFactsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Advice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Here are some tips about women health and hygiene that you should always keep in mind:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),
            _buildFactItem(
              '- Drink plenty of water to stay hydrated',
              Icons.local_drink,
            ),
            const SizedBox(height: 16),
            _buildFactItem(
              '- Eat a healthy and balanced diet',
              Icons.food_bank,
            ),
            const SizedBox(height: 16),
            _buildFactItem(
              '- Exercise regularly to maintain good health',
              Icons.fitness_center,
            ),
            const SizedBox(height: 16),
            _buildFactItem(
              '- Manage stress through relaxation techniques',
              Icons.spa,
            ),
            const SizedBox(height: 16),
            _buildFactItem(
              '- Get enough sleep to recharge your body and mind',
              Icons.nightlight_round,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.purpleAccent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[200],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthGuideCard({
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.purpleAccent,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
