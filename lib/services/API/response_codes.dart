import 'package:cw_core/cw_core.dart';

/// [AppServerResponseCodes] homes all the response codes that server uses to
/// communicate with the app. Dive into the [HttpEngineResponseCode] class and have a
/// look at all the response codes available.
///
/// Usually the response codes are defined based on this
///
/// 1xx informational response – the request was received, continuing process
/// 2xx successful – the request was successfully received, understood, and accepted
/// 3xx redirection – further action needs to be taken in order to complete the request
/// 4xx client error – the request contains bad syntax or cannot be fulfilled
/// 5xx server error – the server failed to fulfil an apparently valid request
///
/// But if there are scenarios where the code is predefined and your server wants to communicate
/// a bit differently please feel free to override the codes
class AppServerResponseCodes extends HttpEngineResponseCode {
  @override
  int get success => 200;
}
