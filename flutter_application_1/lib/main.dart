import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            Text(
              'Study Jam',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Perform login logic here
                String email = emailController.text;
                String password = passwordController.text;

                // Check for a valid email format using regex
                RegExp emailRegex = RegExp(
                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                if (!emailRegex.hasMatch(email)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Email'),
                        content: Text('Please enter a valid email.'),
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
                  return; // Exit the method if email is invalid
                }

                if (password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No Password'),
                        content: Text('Please enter a password.'),
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
                  return; // Exit the method if password is empty
                }

                // Add your login code here
                print('Email: $email, Password: $password');

                // Redirect to the Study Page
                Navigator.pushNamed(context, '/events');
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
                // Perform registration logic here
                String name = nameController.text;
                String email = emailController.text;
                String password = passwordController.text;
                // Add your registration code here

                // Check for a valid email format using regex
                RegExp emailRegex = RegExp(
                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                if (!emailRegex.hasMatch(email)) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Email'),
                        content: Text('Please enter a valid email.'),
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
                  return; // Exit the method if email is invalid
                }

                if (password.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No Password'),
                        content: Text('Please enter a password.'),
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
                  return; // Exit the method if password is empty
                }

                print('Name: $name, Email: $email, Password: $password');

                // Redirect to the Study Page
                Navigator.pushNamed(context, '/events');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

//class StudyPage extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Study Jam. Let\'s Study'),
//        actions: [
//          IconButton(
//            icon: Icon(Icons.add),
//            onPressed: () {
//              Navigator.pushNamed(context, '/createEvent');
//            },
//          ),
//        ],
//      ),
//      body: Center(
//        child: Text('Welcome to Study Jam. Let\'s Study'),
//      ),
//    );
//  }
//}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController roomLimitController = TextEditingController();
  String errorText = '';

  void saveEvent() {
    String title = titleController.text;
    String time = timeController.text;
    String location = locationController.text;
    String roomLimit = roomLimitController.text;

    if (!isValidTime(time)) {
      setState(() {
        errorText = 'Please enter a valid time (HH:MM)';
      });
      return;
    }

    // Add your event saving code here
    print('Title: $title, Time: $time, Location: $location, Room Limit: $roomLimit');

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore.collection('events').add({
      'title': title,
      'time': time,
      'location': location,
      'groupSize': roomLimit,   
    });





    // Redirect to the Events Page
    Navigator.pushNamed(
      context,
      '/events',
      arguments: {
        'title': title,
        'time': time,
        'location': location,
        'roomLimit': roomLimit,
      },
    );
  }

  bool isValidTime(String time) {
    RegExp timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Event'),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
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
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Time',
                  errorText: errorText.isNotEmpty ? errorText : null,
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


class EventsPage extends StatelessWidget {
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

              return ListTile(
                title: Text(eventDetails['title']),
                subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time: ${eventDetails['time']}'),
                  Text('Location: ${eventDetails['location']}'),
                  Text('Group Size: ${eventDetails['groupSize']}'),
                  ],
                ),
                onTap: () {
                  // Navigate to a detailed event page passing eventDetails as arguments
                  Navigator.pushNamed(context, '/eventDetails', arguments: eventDetails);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
