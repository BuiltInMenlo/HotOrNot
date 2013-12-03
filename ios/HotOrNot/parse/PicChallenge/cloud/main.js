
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("duration", function(request, response) {
  var query = new Parse.Query("Durations");
  query.equalTo("app_name", request.params.app_name);
  query.find({
    success: function(results) {
      response.success(results[0].get("duration"));
    },
    error: function() {
      response.error("duration lookup failed\n");
    }
  });
});
