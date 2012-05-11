#library('server');

#import('dart:io');
#import('dart:isolate');
#import('router.dart');

class Server extends Isolate {
  String _host;
  int _port;
  HttpServer _server;
  Router _router;
  Map _settings;

  Server() : super() {
    _router = new Router();
    _settings = new Map();
  }

  void stop() {
    _server.close();
    this.port.close();
  }

  void main() {
    this.port.receive((var message, SendPort replyTo) {
      if (message.isStart) {
        _host = message.params['host'];
        _port = message.params['port'];
        replyTo.send('Server starting', null);
        _server = new HttpServer();
        try {
          _server.listen(_host, _port);
          _server.defaultRequestHandler = (HttpRequest req, HttpResponse rsp) =>
            _router.parse(req, rsp);
          replyTo.send('Server started', null);
        } catch (var e) {
          replyTo.send('Server error:${e.toString()}', null);
        }
      } else if (message.isStop) {
        replyTo.send('Server stopping', null);
        stop();
        replyTo.send('Server stopped', null);
      }
    });
  }

  bool operator [](String setting) {
    return _setting[setting];
  }

  Server operator []=(String setting, bool val) {
    _setting[setting] = val;
    return this;
  }

  Server enable(String setting) {
    return this[setting] = true;
  }

  Server disable(String setting) {
    return this[setting] = false;
  }

  Server configure(Function fn, [String env]) {
    fn();
    return this;
  }

  /**
   * Listen for connections.
   */
  void listen() {
    _host = message.params['host'];
    _port = message.params['port'];
    _server = new HttpServer();
    try {
      _server.defaultRequestHandler = (req, res) => _router.parse(req, res);
      _server.listen(_host, _port);
    } catch (var e) {
      replyTo.send('Server error: ${e.toString}', null);
    }
  }

  void noSuchMethod(String name, List args) {
    _router.add(name, args[0], args[1]);
  }
}
