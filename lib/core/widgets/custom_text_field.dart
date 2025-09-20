import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final bool isObscure;
  final String? headerText;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.isObscure,
    required this.headerText,
    required this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.isObscure;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.headerText != null && widget.headerText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.headerText!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          TextFormField(
            controller: widget.controller,
            obscureText: widget.isObscure ? _obscureText : false,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w300,
                // fontSize: 16,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: Theme.of(context).inputDecorationTheme.border,
              enabledBorder: Theme.of(
                context,
              ).inputDecorationTheme.enabledBorder,
              errorBorder: Theme.of(context).inputDecorationTheme.errorBorder,
              
              suffixIcon: widget.isObscure
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
