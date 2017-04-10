'use strict';

var chargebee = require('chargebee');

console.log('Loading function');

exports.subscribed = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    // console.log('value1 =', event.key1);
    // console.log('value2 =', event.key2);
    // console.log('value3 =', event.key3);
    callback(null, "stuff");  // Echo back the first key value
};


exports.subscription_ended = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    // console.log('value1 =', event.key1);
    // console.log('value2 =', event.key2);
    // console.log('value3 =', event.key3);
    callback(null, "stuff");  // Echo back the first key value
};