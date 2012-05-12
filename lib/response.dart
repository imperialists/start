#library('response');

#import('dart:io');
#import('dart:json');

#import('cookie.dart');

class Response {
  HttpResponse response;

  Response(this.response);

  header(String name, [value]) {
    if (value == null) {
      return response.headers[name];
    }
    response.headers.set(name, value);
    print("${header}=${value}");
    return this;
  }

  Response get(String name) => header(name);

  Response set(name, value) => header(name, value);

  String get charset()             => _charset;
         set charset(String value) => _charset = value;

  Response set type(typecontentType) => set('Content-Type', contentType);

  Response cache(String cacheType, [Map options]) {
    if (options == null) {
      options = {};
    }
    String value = cacheType;
    options.forEach((key, val) {
      value += ', ${key}=${val}';
    });
    return set('Cache-Control', value);
  }

  Response set status(code) {
    response.statusCode = code;
    return this;
  }

  Response cookie(name, val, [Map options]) {
    if(options == null) {
      options = {};
    }
    options['name'] = name;
    options['value'] = val;
    var cookieHeader = Cookie.stringify(options);
    return header('Set-Cookie', cookieHeader);
  }

  Response deleteCookie(name) {
    Map options = { 'expires': 'Thu, 01-Jan-70 00:00:01 GMT', 'path': '/' };
    return cookie(name, '', options);
  }

  send(String string) {
    response.outputStream.write(string.charCodes());
    response.outputStream.close();
  }

  sendfile(path) {
    var file = new File(path);
    file.exists().then((found) {
      if (found) {
        file.openInputStream().pipe(response.outputStream);
      } else {
        response.statusCode = HttpStatus.NOT_FOUND;
        response.outputStream.close();
      }
    });
  }

  json(Object obj, [int statusCode]) {
    String body = JSON.stringify(obj);

    if (charset == null) {
      charset = 'utf-8';
    }
    set('Content-Type', 'text/javascript');

    return send(body);
  }

  redirect(url, [int code = 302]) {
    response.statusCode = code;
    header('Location', url);
    response.outputStream.close();
  }
}
