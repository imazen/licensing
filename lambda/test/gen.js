"use strict";
const assert = require('assert');
const generate = require('../generate');
const crypto = require('crypto');
const fs = require('fs');

describe ("license generation", function(){
  it ("should sign data", function() {
    var test_private_key = fs.readFileSync(__dirname + "/test.pem");
    var actual = generate.sign(Buffer.from("hello", "utf-8"), test_private_key, "test");
    var expected = "RvWU6wi3TUVqtYD+QDvjc0g2W6oUL7hBP2bjEU0SHES5+g34ZQIR4iv28pVT+RBWJR45OfV7q9dgwbsC6PC9hpN98EWlGD3r5JC2GNTZAkJ/TnBzqHUPxtNH0F7AYRwoqWaTPaG4W4xqewHV6bu8m4/jBS2Nj67rahYbuU5LlUdRcGhWZjX58HYEEt7tuso1ERqRVviB7U4/kBbZDf0s4DkCjkgVoeTbewPVHCQ90YkbskNjEVfYAaPrm5Qjsucx3bbp+yHiiix+IVGVmRWsFc0IRU2HKWrR4bDph7A292inOZuQy5RDs9kilx0zEWlHmiI6fAn0plhxp2DnpSJI8Q==";
    assert.equal(actual, expected);
  });

  it ("should generate a license", function() {
    var test_private_key = fs.readFileSync(__dirname + "/test.pem");
    var actual = generate.fullLicenseFor({}, test_private_key, "test");
    var expected = "summary:S2V5OiB2YWx1ZQpLZXkgMjogdmFsdWU=:auhob+qPOOwdIz2KhwPXF8rtSnh1EkCDz+0cca8yx2C+pWVEauCseFOHtQxgXgJG2TnViQsLyaB+ocktjR8JFIn6D7j9Z2SmA10vEALpEMPyWHsAmqAtaJNfrWkwpfE3ft6cl2NAb85BRFLeTkXFTHvpQm05X2fDlmLz74P4Mwjm2nDIcLz0t2wM0Syfn3gkGU/5PaoTMNcOhp8BGNd9mB/QDlFfsuWanOmtrxcEeloMtb6zgj8YCSPOxVLqhiRg8PqFe6IglSbIYI4IxZWhXbwHhN3nn6nMRKoRpn6xAo6edqmMUFTaxECMiLRd3sn3qiXFjlMNF/3vsYMmLc3/fg==";
    assert.equal(actual, expected);
  });

  it ("should generate an ID license", function() {
    var test_private_key = fs.readFileSync(__dirname + "/test.pem");
    var actual = generate.fullLicenseFor({
      summary: "license secret",
      fields: {
        Kind: "Id",
        Id: 1503950351,
        Secret: "gsgt224wgae092gjalggxt99tgss",
        IsPublic: false,
        "Max Uncached Grace Minutes": (60 * 8)
      }
    }, test_private_key, "test");
    var expected = "summary:S2V5OiB2YWx1ZQpLZXkgMjogdmFsdWU=:auhob+qPOOwdIz2KhwPXF8rtSnh1EkCDz+0cca8yx2C+pWVEauCseFOHtQxgXgJG2TnViQsLyaB+ocktjR8JFIn6D7j9Z2SmA10vEALpEMPyWHsAmqAtaJNfrWkwpfE3ft6cl2NAb85BRFLeTkXFTHvpQm05X2fDlmLz74P4Mwjm2nDIcLz0t2wM0Syfn3gkGU/5PaoTMNcOhp8BGNd9mB/QDlFfsuWanOmtrxcEeloMtb6zgj8YCSPOxVLqhiRg8PqFe6IglSbIYI4IxZWhXbwHhN3nn6nMRKoRpn6xAo6edqmMUFTaxECMiLRd3sn3qiXFjlMNF/3vsYMmLc3/fg==";
    assert.equal(actual, expected);
  });
});
