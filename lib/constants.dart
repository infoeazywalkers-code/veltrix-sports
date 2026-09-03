import 'package:flutter/material.dart';

const navy = Color(0xff102a43);
const ink = Color(0xff243b53);
const muted = Color(0xff829ab1);
const bg = Color(0xfff5f7fa);
const lime = Color(0xffb7e22a);
const blue = Color(0xff1687e0);
const purple = Color(0xff7657d5);
const orange = Color(0xffff8a3d);
const teal = Color(0xff00a9a5);
const darkNavy = Color(0xff081f33);
const lightGreen = Color(0xfff0f7ec);
const successGreen = Color(0xff4c8c2b);
const successText = Color(0xff3f6f26);
void showFeatureMessage(BuildContext context, String message) {
	ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
