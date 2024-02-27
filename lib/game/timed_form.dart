import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pducky/game/cubit/cubit.dart';

class TimedFormComponent {
  TimedFormComponent({required this.startTime});

  final double startTime;

  void start(SessionCubit cubit) {}
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _negativeThoughtController = TextEditingController();
  double _distressLevel = 1;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _negativeThoughtController,
                  decoration: InputDecoration(labelText: 'Negative Thought'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your negative thought';
                    }
                    return null;
                  },
                ),
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
          );
        } else if (index == 1) {
          return Column(
            children: <Widget>[
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
                  // Save the data and go to the next page
                },
                child: Text('Submit'),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
