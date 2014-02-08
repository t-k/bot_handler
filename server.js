var CONFIG, HOST, PORT, createWebPage, env, pidfile, system, webpage;

webpage = require("webpage");
system = require("system");
env = system.env;

if (typeof env.PHANTOM_ENV === "undefined") {
  env.PHANTOM_ENV = "development";
}
console.log("Phantomjs server started in " + env.PHANTOM_ENV + " environment.");

CONFIG = require("./config/" + env.PHANTOM_ENV);

pidfile = CONFIG.pid || "/tmp/phantomjs.pid";
require("fs").write(pidfile, system.pid);
console.log("PID:", system.pid);

HOST = CONFIG.host || "http://localhost:8000";
console.log("Target HOST:", HOST);

PORT = CONFIG.port || 8001;
console.log("Server PORT:", PORT);

createWebPage = function(request) {
  var page;
  page = webpage.create();
  page.viewportSize = CONFIG.viewportSize || {
    width: 1900,
    height: 1200
  };
  page.settings.resourceTimeout = CONFIG.resourceTimeout || 30000;
  page.settings.userAgent = request.headers["User-Agent"] || "Phantomjs";
  page.settings.loadImages = CONFIG.loadImages || false;
  return page;
};

require("webserver").create().listen(PORT, function(request, response) {
  var requestPage = function(request, callback) {
    var page, targetURL, httpStatus;
    page = createWebPage(request);
    targetURL = HOST + request.url;
    page.onResourceRequested = function(requestData, networkRequest) {
      // abort request for GA and GTM
      if (/^http(|s):\/\/www\.(google-analytics|googletagmanager)\.com/.test(requestData.url)) {
        networkRequest.abort();
      }
    };
    page.onResourceReceived = function(resource) {
      if (targetURL === resource.url) {
        httpStatus = resource.status;
      }
    };
    page.onLoadFinished = function(status) {
      return callback(page.content, httpStatus);
    };
    return page.open(targetURL);
  };
  requestPage(request, function(content, httpStatus) {
    response.setHeader("Content-Type", "text/html");
    response.setEncoding("UTF-8");
    response.statusCode = httpStatus || 200;

    response.write(content);
    // Or rewrite URL for SPA
    // response.write(content.replace(/href=(\"|')\/#/gi, "href=$1/")); // rewrite "/#foo" to "/foo"

    return response.close();
  });
});
