import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MessageHandler {
  static void showLoginSuccess() {
    Fluttertoast.showToast(
      msg: "Login Successful",
      backgroundColor: Colors.green,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void showLoginFailed() {
    Fluttertoast.showToast(
      msg: "Login Failed",
      backgroundColor: Colors.red,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void EmployeAdded() {
    Fluttertoast.showToast(
      msg: "Employee Added",
      backgroundColor: Colors.green,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void EmployeAddedFailed(String error) {
    Fluttertoast.showToast(
      msg: "Employee Added Failed $error",
      backgroundColor: Colors.red,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void taskAssigned() {
    Fluttertoast.showToast(
      msg: "Task Assign Successful",
      backgroundColor: Colors.green,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void taskAssignedFailed() {
    Fluttertoast.showToast(
      msg: "Task Assign Failed",
      backgroundColor: Colors.red,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void fillAllDetails() {
    Fluttertoast.showToast(
      msg: "Please fill all fields correctly.",
      backgroundColor: Colors.red,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  static void showCustomMessage(String message, {Color backgroundColor = Colors.blue}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      fontSize: 14,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }
}
