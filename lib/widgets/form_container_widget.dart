import 'package:flutter/material.dart';
import 'package:rapid_rescue/constants/colors.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final void Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final TextStyle? hintTextStyle;

  const FormContainerWidget(
      {super.key,
      this.controller,
      this.isPasswordField,
      this.fieldKey,
      this.hintText,
      this.labelText,
      this.helperText,
      this.onSaved,
      this.validator,
      this.onFieldSubmitted,
      this.inputType,
      this.onChanged,
      this.autofillHints,
      this.hintTextStyle});

  @override
  _FormContainerWidgetState createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(90, 209, 209, 209).withOpacity(.37),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.white),
        controller: widget.controller,
        keyboardType: widget.inputType,
        autofillHints: widget.autofillHints,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(contentPadding: EdgeInsets.all(8),
          border: InputBorder.none,
          filled: false,
          hintText: widget.hintText,
          hintStyle: widget.hintTextStyle,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: widget.isPasswordField == true
                ? Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _obscureText == false ? PRIMARY_BACKGROUND_COLOR : PRIMARY_CARD_BACKGROUND_COLOR,
                  )
                : const Text(""),
          ),
        ),
      ),
    );
  }
}
