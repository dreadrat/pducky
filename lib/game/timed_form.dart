import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimedFormComponent extends Component with HasGameRef<Pducky> {
  TimedFormComponent(
      {required this.startTime, required this.cubit, this.isAdded = false});
  bool isAdded;
  final double startTime;
  final SessionCubit cubit; // <-- Add this
  final distressOverlay = 'DistressForm';

  @override
  void onMount() {
    super.onMount();

    // Call start method here
    startDistressForm(cubit);
  }

  void startDistressForm(SessionCubit cubit) {
    if (isAdded) {
      print('Initiating START in TimedFormComponent');
      gameRef.overlays.add(distressOverlay);
      print('TimedForm Start: pausing engine');
      gameRef.pauseEngine();
    } else {
      print('already added bro');
    }
  }

  void updateDistress(SessionCubit cubit) {}
}

class DistressForm extends StatefulWidget {
  final Pducky gameRef;

  DistressForm({required this.gameRef});

  @override
  _DistressFormState createState() => _DistressFormState();
}

class _DistressFormState extends State<DistressForm> {
  final _formKey = GlobalKey<FormState>();
  final _negativeThoughtController = TextEditingController();
  double _distressLevel = 1;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue[50], // Set a light-colored background
      child: PageView.builder(
        controller: _pageController,
        itemCount: 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Form(
              key: _formKey,
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: 600), // Set a maximum width

                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                          'Step 1: Identify your negative thought'), // Add a label
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            controller: _negativeThoughtController,
                            decoration: InputDecoration(
                                labelText: 'Today\'s Negative Thought'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your negative thought';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Text(
                          'Please enter the negative thought you are currently having.'), // Add a description
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // If the form is valid, go to the next page
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (index == 1) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Step 2: Rate your distress level'), // Add a label
                Text(
                    'On a scale of 1 to 7, how distressing is this thought?'), // Add a description
                Slider(
                  min: 1,
                  max: 7,
                  divisions: 6,
                  value: _distressLevel,
                  label: _distressLevel.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _distressLevel = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Start the session! button pressed');

                    print('Distress level: $_distressLevel');
                    context.read<UserCubit>().updateDistressLevelAndThought(
                          _distressLevel.toInt(),
                          _negativeThoughtController.text,
                        );
                    print('Updated distress level and thought');

                    print('Removing DistressForm overlay');
                    widget.gameRef.overlays.remove('DistressForm');

                    print('Resuming game engine');
                    widget.gameRef.resumeEngine();
                  },
                  child: Text('Start the session!'),
                ),
              ],
            );
          }
          return Container(); // Return an empty container for safety
        },
      ),
    );
  }
}
