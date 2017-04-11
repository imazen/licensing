"use strict";
var assert = require('assert');
var chargebee = require('chargebee');


describe ("chargebee", function(){
  it ("should fetch plan", function(done) {
    
    
    chargebee.configure({site: "imazen-test", api_key: "test_bOJ3nmQFjkduvQcG1coxEYxuqdZaYJpx"});

    chargebee.plan.retrieve("imageresizer-elite-oem").request().then(function(a){
      console.log(a.plan.meta_data);

      done();
      },function(a){
        console.log(a);
      done();
      });
  });

});