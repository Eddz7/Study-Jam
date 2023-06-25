import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Study Jam',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Register'),
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
        title: const Text('Login'),
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
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),  
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () {
                loginWithEmailAndPassword(context); // Call the new login method
              },
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
  String errorTextEndTime = '';
  String errorTextStartTime = '';
  String errorTextRoom = '';

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

  void saveEvent() {
    String title = titleController.text;
    String startTime = startTimeController.text;
    String endTime = endTimeController.text;
    String location = locationController.text;
    String roomLimit = roomLimitController.text;

    setState(() {
      errorTextStartTime = '';
      errorTextEndTime = '';
      errorTextRoom = '';
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

    if (!isValidTime(startTime) || !isValidTime(endTime) || !isNumber(roomLimit)) {
      return;
    }

    // Add your event saving code here
    print('Title: $title, Start Time: $startTime, End Time: $endTime, Location: $location, Room Limit: $roomLimit');

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore.collection('events').add({
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'groupSize': roomLimit,
      'participants': 1,
    });

    // Redirect to the Events Page
    Navigator.pushNamed(
      context,
      '/events',
      //arguments: {
      //  'title': title,
      //  'start_time': startTime,
      //  'end_time': endTime,
      //  'location': location,
      //  'roomLimit': roomLimit,
      //},
    );
  }

  bool isValidTime(String time) {
    RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
    return timeRegex.hasMatch(time);
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
              InkWell(
                onTap: _selectStartTime,
                child: IgnorePointer(
                  child: TextField(
                    controller: startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      errorText: errorTextStartTime.isNotEmpty ? errorTextStartTime : null,
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
                      errorText: errorTextEndTime.isNotEmpty ? errorTextEndTime : null,
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
  Map<String, bool> joinedEvents = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
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

              return ListTile(
                title: Text(eventDetails['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time: ${eventDetails['start_time']} - ${eventDetails['end_time']}'),
                    Text('Location: ${eventDetails['location']}'),
                    Text('Group Size: ${eventDetails['groupSize']}'),
                    Text('Participants: ${eventDetails['participants']}/${eventDetails['groupSize']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (joinedEvents.containsKey(eventId)) {
                        joinedEvents.remove(eventId);
                      } else {
                        joinedEvents[eventId] = true;
                      }
                    });
                  },
                  child: Text(joinedEvents.containsKey(eventId) ? 'Leave' : 'Join'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
