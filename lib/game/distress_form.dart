import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pducky/game/game.dart';

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
                  onPressed: () async {
                    print('Start the session! button pressed');

                    context.read<UserCubit>().updateDistressLevelAndThought(
                          _distressLevel.toInt(),
                          _negativeThoughtController.text,
                        );
                    print('Distress level: $_distressLevel');
                    print('Thought: ${_negativeThoughtController.text}');
                    print(
                        'Before Butotn Press Focus: ${FocusManager.instance.primaryFocus}');
                    print('Removing DistressForm overlay');
                    await Future.delayed(
                        Duration(milliseconds: 100)); // Wait a bit
                    widget.gameRef.overlays.remove('DistressForm');

                    print(
                        'After Button press Current Focus: ${FocusManager.instance.primaryFocus}');

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
