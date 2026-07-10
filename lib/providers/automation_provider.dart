import 'package:flutter/material.dart';
import '../models/automation_model.dart';

class AutomationProvider extends ChangeNotifier {
   final List<AutomationModel> _automation = [];
   List<AutomationModel> get automations => _automation;

   void addAutomation(AutomationModel automation) {
     _automation.add(automation);
     notifyListeners();
   }
}