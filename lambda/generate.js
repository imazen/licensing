'use strict';

const crypto = require('crypto');

// Refactor 

exports.sign = (bytes, key, passphrase) => {
  const hash = crypto.createHash('sha512');
  hash.update(bytes);
  var bytes = crypto.privateEncrypt({key: key, passphrase: passphrase, padding: crypto.constants.RSA_PKCS1_PADDING}, hash.digest());
  return bytes.toString('base64');
};

exports.fullLicenseFor = (info, key, passphrase) => {
  var text = exports.plaintextFor(info);
  var textBytes = Buffer.from(text, "utf8");
  return exports.summaryFor(info) + ":" + textBytes.toString('base64') + ":" + exports.sign(textBytes, key, passphrase);
};
exports.summaryFor = (info) => {
  return info.summary;
};
exports.plaintextFor = (info) => {
  var fields = info.fields;
  var text = "";
  for (var key in fields) {
      if(!fields.hasOwnProperty(key)) continue;

      //TODO: Sanitize strings for colons, newline.
      text += String(key) + ": " + String([key]) + "\n";
  }
  return text;
}

//   Owner: [company name (or individual, if no company specified)]
// Domain: [domain name]
// Issued: [iso8601]
// Expires: [iso8601] (currently optional)
// Restrictions: [space delimited terms] (non-profit use only, trial version, etc)
// Features: [space and comma delimited strings, like R4Performance]


  // { requiredFields: [ 'subscription.cf_for_use_within_product_oem_redistribution' ],
  // products: [ 'ImageResizer' ],
  // fields:
  //  { SKU: 'R_OEM_Monthly',
  //    Restrictions: 'Only licensed for use within {{subscription.cf_for_use_within_product_oem_redistribution}}',
  //    Features: 'R_OEM R_Elite, R_Creative, R_Performance',
  //    'Network grace period': '2880',
  //    'Subscription grace period': '2880' } }

  //context.plan
  //context.subscription
  //context.


exports.collectInfo = (context, secret_only) => {
  var plan_meta = context.plan.meta_data;
  if (plan_meta == null){
    throw "Cannot create license without plan metadata. context.plan.meta_data is null.";
  }
  var subscription_meta = context.subscription.meta_data;
  if (subscription_meta == null){
    throw "Cannot create license without subscription metadata. context.subscription.meta_data is null.";
  }
  var id = subscription_meta.id;
  var secret = subscription_meta.secret;
  if (id == null){
    throw "Cannot create license without license id. context.subscription.meta_data.id is null.";
  }
  if (secret == null){
    throw "Cannot create license without license secret. context.subscription.meta_data.secret is null.";
  }
  var max_uncached_grace_minutes = plan_meta.max_uncached_grace_minutes || (60 * 2);
  if (secret_only){
    return {
      summary: "secret_for_" + String(id),
      fields: {
        Kind: "placeholder",
        Id: id,
        Secret: secret,
        IsPublic: false,
        "Max Uncached Grace Minutes": max_uncached_grace_minutes
      }
    };
  }else{
    return {

    };
  }
};