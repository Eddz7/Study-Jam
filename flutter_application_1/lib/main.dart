import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(StudyJamApp());
}

class StudyJamApp extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Jam',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudyJamHomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/createEvent': (context) => CreateEventPage(),
        '/events': (context) => EventsPage(),
      },
    );
  }
}

class StudyJamHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Jam'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Study Jam',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithEmailAndPassword(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User is successfully logged in
      print('User logged in: ${userCredential.user?.uid}');

      // Redirect to the Events Page
      Navigator.pushNamed(context, '/events');
    } catch (e) {
      // Display an error dialog if login fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            //content: Text(e.toString()),\
            content: const Text("Incorrect username or password"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => loginWithEmailAndPassword(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}


class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerWithEmailAndPassword(BuildContext context) async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User is successfully registered and logged in
      print('User registered: ${userCredential.user?.uid}');

      // Store user information in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
      });

      // Redirect to the Events Page
      Navigator.pushNamed(context, '/events');
    } catch (e) {
      // Display an error dialog if registration fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registration Failed'),
            content: const Text("The email address is already in use by another account."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
               onPressed: () {
                registerWithEmailAndPassword(context); // Call the new registration method
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController roomLimitController = TextEditingController();
  final TextEditingController dateLimitController = TextEditingController();
  String errorTextEndTime = '';
  String errorTextStartTime = '';
  String errorTextRoom = '';
  String errorTextDate = '';

  Future<void> _selectStartTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime = selectedTime.format(context);
      startTimeController.text = formattedTime;
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime = selectedTime.format(context);
      endTimeController.text = formattedTime;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      dateLimitController.text = formattedDate;
    }
  }

  void saveEvent() {
    String title = titleController.text;
    String startTime = startTimeController.text;
    String endTime = endTimeController.text;
    String location = locationController.text;
    String roomLimit = roomLimitController.text;
    String date = dateLimitController.text;

    setState(() {
      errorTextStartTime = '';
      errorTextEndTime = '';
      errorTextRoom = '';
      errorTextDate = '';
    });

    if (!isValidTime(startTime)) {
      setState(() {
        errorTextStartTime = 'Please enter a valid time (HH:MM)';
      });
    }
    if (!isValidTime(endTime)) {
      setState(() {
        errorTextEndTime = 'Please enter a valid time (HH:MM)';
      });
    }

    if (!isNumber(roomLimit)) {
      setState(() {
        errorTextRoom = 'Please enter a valid number';
      });
    }

    if (!isValidDate(date)) {
      setState(() {
        errorTextDate = 'Please enter a valid date (YYYY-MM-DD)';
      });
    }

    if (!isValidTime(startTime) ||
        !isValidTime(endTime) ||
        !isNumber(roomLimit) ||
        !isValidDate(date)) {
      return;
    }

    if (startTime == endTime) {
      setState(() {
        errorTextStartTime = 'Start time and end time cannot be the same';
        errorTextEndTime = 'Start time and end time cannot be the same';
      });
      return;
    }

    //Get the current user's email
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? email = currentUser?.email;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    date = formatDate(date);
    int roomLimitInt = int.parse(roomLimit);

    firestore.collection('events').add({
      'title': title,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'groupSize': roomLimitInt,
      'participants': 1,
      'organizer': email,
    });

    //Redirect to the Events Page
    Navigator.pushNamed(
      context,
      '/events',
    );
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateFormat formatter = DateFormat('MMMM d, yyyy');
      return formatter.format(date);
    } catch (e) {
      return '';
    }
  }

  bool isValidTime(String time) {
    RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
    return timeRegex.hasMatch(time);
  }

  bool isValidDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      return !date.isBefore(now); // Check if the date is not in the past
    } catch (e) {
      return false;
    }
  }

  bool isNumber(String value) {
    if (value == null) return false;
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: dateLimitController,
                onTap: _selectDate,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  errorText: errorTextDate.isNotEmpty ? errorTextDate : null,
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: _selectStartTime,
                child: IgnorePointer(
                  child: TextField(
                    controller: startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      errorText:
                          errorTextStartTime.isNotEmpty ? errorTextStartTime : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: _selectEndTime,
                child: IgnorePointer(
                  child: TextField(
                    controller: endTimeController,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      errorText:
                          errorTextEndTime.isNotEmpty ? errorTextEndTime : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: roomLimitController,
                decoration: InputDecoration(
                  labelText: 'Room Limit',
                  errorText: errorTextRoom.isNotEmpty ? errorTextRoom : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveEvent,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late SharedPreferences _prefs;
  Map<String, bool> joinedEvents = {};

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final storedJoinedEvents = _prefs.getStringList('joinedEvents') ?? [];
    setState(() {
      joinedEvents = Map.fromIterable(storedJoinedEvents, key: (eventId) => eventId, value: (_) => true);
    });
  }

  void updateSharedPreferences() {
    final storedJoinedEvents = joinedEvents.keys.toList();
    _prefs.setStringList('joinedEvents', storedJoinedEvents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/createEvent');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final eventDetails = doc.data() as Map<String, dynamic>;
              final eventId = doc.id;

              final isJoined = joinedEvents.containsKey(eventId);
              final currentParticipantCount = eventDetails['participants'];

              return ListTile(
                title: Text(eventDetails['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${eventDetails['date']}'),
                    Text('Time: ${eventDetails['start_time']} - ${eventDetails['end_time']}'),
                    Text('Location: ${eventDetails['location']}'),
                    Text('Group Size: ${eventDetails['groupSize']}'),
                    Text('Participants: $currentParticipantCount/${eventDetails['groupSize']}'),
                    Text('Contact Organizer: ${eventDetails['organizer']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (isJoined) {
                        joinedEvents.remove(eventId);
                        eventDetails['participants'] -= 1; // Decrement participant count
                      } else {
                        if (eventDetails['participants'] == eventDetails['groupSize']) {
                          return;
                        } else {
                          joinedEvents[eventId] = true;
                          eventDetails['participants'] += 1; // Increment participant count
                        }
                      }
                      // Save the updated participant count to Firestore
                      FirebaseFirestore.instance.collection('events').doc(eventId).update({
                        'participants': eventDetails['participants'],
                      });

                      updateSharedPreferences(); // Save the updated join status
                    });
                  },
                  child: Text(isJoined ? 'Leave' : 'Join'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}