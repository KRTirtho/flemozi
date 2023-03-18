import 'package:flutter/material.dart';

String uriToString(Uri uri) => uri.toString();
Duration secondsToDuration(double seconds) => Duration(
    seconds: seconds.toInt(), milliseconds: (seconds * 1000).toInt() % 1000);

double durationToSeconds(Duration d) => d.inSeconds + d.inMilliseconds / 1000;
Size dimsFromJson(List<int> dims) =>
    Size(dims[0].toDouble(), dims[1].toDouble());
List<int> dimsToJson(Size dims) => [dims.width.toInt(), dims.height.toInt()];
int dateTimeToUnix(DateTime d) => d.millisecondsSinceEpoch;
