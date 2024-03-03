import 'dart:io';
import 'dart:math';

import 'package:refilc/api/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'error_report_screen.i18n.dart';

class ErrorReportScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const ErrorReportScreen(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3EBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Spacer(),
              Image.asset('assets/icons/ic_rounded.png', height: 40 ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "ekretaYou".i18n,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "description".i18n,
                style: TextStyle(
                  color: Colors.white.withOpacity(.95),
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 110.0,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: const Color(0xFFF7F9FC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        details.exceptionAsString(),
                        style: const TextStyle(
                            fontFamily: 'GeistMono',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FeatherIcons.info),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => StacktracePopup(details));
                    },
                  )
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 14.0)),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF0E275A)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  child: Text(
                    "submit".i18n,
                    style: const TextStyle(
                        color: Color(0xFFF7F9FC),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat'),
                  ),
                  onPressed: () => reportProblem(context),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 14.0)),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFF3F7FE)),
                    foregroundColor:
                        MaterialStateProperty.all(const Color(0xFFC7D3EB)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  child: Text(
                    "goback".i18n,
                    style: const TextStyle(
                      color: Color(0xFF011234),
                      fontSize: 18.0,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              const SizedBox(height: 32.0)
            ],
          ),
        ),
      ),
    );
  }

  Future reportProblem(BuildContext context) async {
    final report = ErrorReport(
      os: "${Platform.operatingSystem} ${Platform.operatingSystemVersion}",
      error: details.exceptionAsString(),
      version: const String.fromEnvironment("APPVER", defaultValue: "?"),
      stack: details.stack.toString(),
    );
    FilcAPI.sendReport(report);
    Navigator.pop(context);
  }
}

class StacktracePopup extends StatelessWidget {
  final FlutterErrorDetails details;

  const StacktracePopup(this.details, {super.key});

  @override
  Widget build(BuildContext context) {
    String stack = details.stack.toString();

    return Container(
      margin: const EdgeInsets.all(32.0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.only(top: 15.0, right: 15.0, left: 15.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "details".i18n,
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ),
                  ErrorDetail(
                    "error".i18n,
                    details.exceptionAsString(),
                  ),
                  ErrorDetail("os".i18n,
                      "${Platform.operatingSystem} ${Platform.operatingSystemVersion}"),
                  ErrorDetail(
                      "version".i18n,
                      const String.fromEnvironment("APPVER",
                          defaultValue: "?")),
                  ErrorDetail(
                      "stack".i18n, stack.substring(0, min(stack.length, 5000)))
                ]),
              ),
              TextButton(
                  child: Text("done".i18n,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorDetail extends StatelessWidget {
  final String title;
  final String content;

  const ErrorDetail(this.title, this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.5, vertical: 4.0),
              margin: const EdgeInsets.only(top: 4.0),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4.0)),
              child: Text(
                content,
                style: const TextStyle(
                    fontFamily: 'SpaceMono', color: Colors.white),
              ))
        ],
      ),
    );
  }
}
