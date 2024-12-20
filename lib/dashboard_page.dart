import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Dashbord extends StatefulWidget {
  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {

  void logout() {
  final box = GetStorage();
  box.erase(); // Clear all stored data
  Get.offNamed('/login'); // Redirect to login screen
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body:  SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              Center(
                child: GestureDetector(
                  onTap: (){
                    logout();
                  },
                  child: Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.only(left: 55.0 , right: 55.0 , top: 15.0, bottom: 15.0,),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                            Text("LogOut" , style: TextStyle(color: Colors.black),)
                        ],  
                      ),
                    ),
                  ),
                ),
              ) 
            ],
          ),
      ),
    );
  }
}