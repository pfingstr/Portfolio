import 'package:flutter/material.dart';

Size displaySize(BuildContext context) => MediaQuery.of(context).size;

double displayHeight(BuildContext context) => displaySize(context).height;

double displayWidth(BuildContext context) => displaySize(context).width;
