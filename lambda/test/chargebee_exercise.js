"use strict";

describe ("chargebee", function(){
  it ("should fetch plan", function() {
    
    var chargebee = require('chargebee');

    chargebee.configure({site: "imazen-test", api_key: "test_bOJ3nmQFjkduvQcG1coxEYxuqdZaYJpx"});

    chargebee.plan.retrieve("imageresizer-elite-oem").then(function (a){
      console.log(a);
    });
  });

});