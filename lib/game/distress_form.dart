import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pducky/game/game.dart';

class DistressForm extends StatefulWidget {
  const DistressForm({
    required this.gameRef,
    required this.onDismiss,
    super.key,
  });

  final Pducky gameRef;
  final VoidCallback onDismiss;

  @override
  State<DistressForm> createState() => _DistressFormState();
}

class _DistressFormState extends State<DistressForm> {
  final _formKey = GlobalKey<FormState>();
  final _negativeThoughtController = TextEditingController();
  double _distressLevel = 1;
  final _pageController = PageController();

  bool _skipIntro = false;

  @override
  void dispose() {
    _negativeThoughtController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _skipIntro,
                            onChanged: (v) {
                              setState(() {
                                _skipIntro = v ?? false;
                              });
                            },
                          ),
                          const Text('Skip intro'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        child: const Text('Next'),
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
                    // TextField focus steals keyboard events; explicitly return
                    // focus to the GameWidget after dismissing the overlay.
                    FocusManager.instance.primaryFocus?.unfocus();

                    // Small delay gives the overlay removal time to settle.
                    await Future.delayed(const Duration(milliseconds: 50));
                    widget.gameRef.overlays.remove('DistressForm');

                    widget.gameRef.startRoundWithThought(
                      _negativeThoughtController.text,
                      skipIntro: _skipIntro,
                    );
                    widget.gameRef.resumeEngine();
                    widget.onDismiss();
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
