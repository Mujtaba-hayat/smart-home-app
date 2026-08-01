import 'package:flutter/material.dart';
import '../models/automation_model.dart';
import '../services/automation_service.dart';

class AutomationProvider extends ChangeNotifier {
   final List<AutomationModel> _automation = [];
   final AutomationService _automationService = AutomationService();
   List<AutomationModel> get automations => _automation;

   void addAutomation(AutomationModel automation) {
     _automation.add(automation);
     notifyListeners();
   }

   void updateAutomation(AutomationModel updatedAutomation) {

     final index = _automation.indexWhere(
         (automation) => automation.id == updatedAutomation.id,
     );

     if (index != -1) {
       _automation[index] = updatedAutomation;
       notifyListeners();
     }

     }
     void deleteAutomation(String id) {
       _automation.removeWhere(
             (automation) => automation.id == id,
       );

       notifyListeners();

   }
   Future<void> loadAutomations() async {

     final automations = await _automationService.getAutomations();

     _automation.clear();

     _automation.addAll(automations);

     notifyListeners();

   }
}