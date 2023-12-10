import 'package:flutter/material.dart';

Widget customDropDown(List<String> items, String value, void Function(String?) onChange) {
  String? dropdownValue = (value.isEmpty || !items.contains(value)) ? null : value;
  
  List<DropdownMenuItem<String>> menuItems = items
      .map<DropdownMenuItem<String>>((String val) {
        return DropdownMenuItem(
          child: Text(val),
          value: val,
        );
      }).toList();
  
  // Add a 'Please select' item at the start of the list
  if (dropdownValue == null) {
    menuItems.insert(0, DropdownMenuItem(value: null, child: Text('Please select')));
  }

  return Container(
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: DropdownButton<String>(
      value: dropdownValue,
      onChanged: (value) => onChange(value),
      items: menuItems,
      hint: Text('Please select'), // Display this text when no item is selected
    ),
  );
}
