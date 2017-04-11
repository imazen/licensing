'use strict';

const crypto = require('crypto');

exports.sign = (data, key, passphrase) => {
  const hash = crypto.createHash('sha512');
  hash.update('some data to hash');
  var bytes = crypto.privateEncrypt({key: key, passphrase: passphrase, padding: crypto.constants.RSA_PKCS1_PADDING}, hash.digest());
  return bytes.toString('base64');
};

exports.plaintext = (data) => {
  //data.plan
  //data.subscription
  //data.
};