import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/database/userManage.dart';
import 'package:healthapp/widgets/components.dart';
import 'package:healthapp/widgets/datePicker.dart';

class Register extends StatelessWidget {
  Register({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen background (prevents white space)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 136, 194, 241), Colors.white],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ), // or your gradient
          ),
          // Background image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(),
            child: Icon(Icons.add_alert, size: 50, color: Colors.white),
          ),
          // Purple container
          Positioned(
            top: 150,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 210,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 136, 194, 241), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Register Now!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Please Sign Up to start using the Health App.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Enter  your Alias Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your alias name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Enter  your Email',
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Please enter your Email'
                                  : null,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _functionController,
                              decoration: InputDecoration(
                                labelText: 'Enter  your Function',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter your function'
                                  : null,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Enter  your Address',
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: _dateController,
                              onTap: () => Datepicker.selectDate(
                                context,
                                _dateController,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Enter  your Date of Birth',
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Please enter your date of birth'
                                  : null,
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Enter your Password',

                                    suffixIcon: Icon(Icons.visibility),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _rPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Re-type your Password',

                                    suffixIcon: Icon(Icons.visibility),
                                  ),
                                  validator: (value) =>
                                      value == null ||
                                          value.isEmpty ||
                                          _passwordController.text !=
                                              _rPasswordController.text
                                      ? 'Passwords do not match'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String hashedPassword = hashPassword(
                                  _passwordController.text,
                                );
                                print('HashedPassword:$hashedPassword');
                                final UserModel user = UserModel(
                                  username: _emailController.text,
                                  password: hashedPassword,
                                  nickname: _nameController.text,
                                  function: _functionController.text,
                                  address: _addressController.text,
                                  birthdate: _dateController.text,
                                  createdAt: DateTime.now().toIso8601String(),
                                );
                                int id = await Usermanage.createUser(user);
                                if (id > 0) {
                                  Components.showErrorSnackBar(
                                    context,
                                    'You are registered successfully! Login now.',
                                    Icons.check_circle,
                                    Colors.green,
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/Login',
                                  );
                                } else {
                                  Components.showErrorSnackBar(
                                    context,
                                    'Error registering user!',
                                    Icons.error,
                                    Colors.red,
                                  );
                                }
                              } else {
                                Components.showErrorSnackBar(
                                  context,
                                  'Please fix the errors in red',
                                  Icons.error,
                                  Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.square_arrow_down,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/Login');
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String hashPassword(String plainTextPassword) {
    final salt = BCrypt.gensalt(logRounds: 12);
    return BCrypt.hashpw(plainTextPassword, salt);
  }
}
