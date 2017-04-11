"use strict";
const assert = require('assert');
const generate = require('../generate');
const crypto = require('crypto');
const fs = require('fs');

describe ("license generation", function(){
  it ("should sign data", function() {
    var test_private_key = fs.readFileSync(__dirname + "/test.pem");
    var actual = generate.sign(Buffer.from("hello", "utf-8"), test_private_key, "test");
    var expected = "V7YeSnzlcFL+U9mMnoOCgUQNJm/iVC8elG4OwaRgML0XCvSQT0ofY34fVc301UoxV92EYaT/YbAe9zNPKcSwEWiHWSY8sbbg8rSJgS0ugDScAQqaF52v++A7bPcULKW2TNZGuoBgh7CXeoktNDTLC15PEkI/sNgrAADRWLfTdyKhfsCuuk7mAbCMgm6riePIo49cY2YZdhGpztzDReD0x6H9h39kpCH77BsMShyfbzu/BDhgMIx0pktQBO4fQd1k6eih4EtoRztQIhzIk/7qrOib8QA1mg6qRDbz8acNazyFenYtNh/2WpDtZbsjwYmsIUsgRPpnTg8xdWlmUUWbrA==";
    assert.equal(actual, expected);
  });

  it ("should sign data", function() {
    var test_private_key = fs.readFileSync(__dirname + "/test.pem");
    var actual = generate.sign(Buffer.from("hello", "utf-8"), test_private_key, "test");
    var expected = "V7YeSnzlcFL+U9mMnoOCgUQNJm/iVC8elG4OwaRgML0XCvSQT0ofY34fVc301UoxV92EYaT/YbAe9zNPKcSwEWiHWSY8sbbg8rSJgS0ugDScAQqaF52v++A7bPcULKW2TNZGuoBgh7CXeoktNDTLC15PEkI/sNgrAADRWLfTdyKhfsCuuk7mAbCMgm6riePIo49cY2YZdhGpztzDReD0x6H9h39kpCH77BsMShyfbzu/BDhgMIx0pktQBO4fQd1k6eih4EtoRztQIhzIk/7qrOib8QA1mg6qRDbz8acNazyFenYtNh/2WpDtZbsjwYmsIUsgRPpnTg8xdWlmUUWbrA==";
    assert.equal(actual, expected);
  });
});
