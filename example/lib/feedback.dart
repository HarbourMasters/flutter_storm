import 'package:flutter/material.dart';

class HMFeedback {
  static void showLoadingScreen(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () => Future.value(false),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(color: Colors.orange),
              ),
            ),
          );
        });
  }

  static Future showCustomDialog(context,
      {title,
      alignment = CrossAxisAlignment.start,
      body,
      height = 0.0,
      dismissible = true,
      topPadding = 20.0}) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          double bottom = MediaQuery.of(context).viewInsets.bottom;

          return Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 350),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: alignment,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 5, right: 5),
                                    child: SizedBox(
                                      width: 350,
                                      child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(title,
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.black
                                                      .withOpacity(.40),
                                                  fontWeight:
                                                      FontWeight.w800))),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: topPadding),
                                    child: body,
                                  ),
                                ],
                              ),
                              if (dismissible)
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      enableFeedback: true,
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.close_rounded,
                                          size: 32,
                                          color: Colors.black.withOpacity(.40)),
                                    ))
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
