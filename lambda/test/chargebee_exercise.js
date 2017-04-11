"use strict";
const assert = require('assert');
const chargebee = require('chargebee');


describe ("chargebee", function(){
  it ("should fetch plan", function() {
    
    
    chargebee.configure({site: "imazen-test", api_key: "test_bOJ3nmQFjkduvQcG1coxEYxuqdZaYJpx"});

    return chargebee.plan.retrieve("imageresizer-elite-oem").request().then(function(a){
        console.log(a.plan.meta_data);
        assert.equal(a.plan.meta_data.fields.SKU, "R_OEM_Monthly");
        
      });
  }).timeout(8000);

});