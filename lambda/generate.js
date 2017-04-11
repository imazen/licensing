'use strict';

const crypto = require('crypto');

// Refactor 

exports.sign = (bytes, key, passphrase) => {
  const hash = crypto.createHash('sha512');
  hash.update(bytes);
  var bytes = crypto.privateEncrypt({key: key, passphrase: passphrase, padding: crypto.constants.RSA_PKCS1_PADDING}, hash.digest());
  return bytes.toString('base64');
};

exports.fullLicenseFor = (context, key, passphrase) => {
  var text = exports.plaintextFor(context);
  var textBytes = Buffer.from(text, "utf8");
  return exports.summaryFor(context) + ":" + textBytes.toString('base64') + ":" + exports.sign(textBytes, key, passphrase);
}
exports.summaryFor = (context) => {
  return "summary";
  // { requiredFields: [ 'subscription.cf_for_use_within_product_oem_redistribution' ],
  // products: [ 'ImageResizer' ],
  // fields:
  //  { SKU: 'R_OEM_Monthly',
  //    Restrictions: 'Only licensed for use within {{subscription.cf_for_use_within_product_oem_redistribution}}',
  //    Features: 'R_OEM R_Elite, R_Creative, R_Performance',
  //    'Network grace period': '2880',
  //    'Subscription grace period': '2880' } }
};
exports.plaintextFor = (context) => {
  //var fields = context.plan.meta_data.fields;
  return "Key: value\nKey 2: value";

//   Owner: [company name (or individual, if no company specified)]
// Domain: [domain name]
// Issued: [iso8601]
// Expires: [iso8601] (currently optional)
// Restrictions: [space delimited terms] (non-profit use only, trial version, etc)
// Features: [space and comma delimited strings, like R4Performance]


  //context.plan
  //context.subscription
  //context.
};