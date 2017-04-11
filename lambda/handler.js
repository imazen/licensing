'use strict';

const request = require('request');

var get_chargebee_plan = (plan_id) => {
  return plan_id;
}

exports.handler = (event, context, callback) => {
  var body = JSON.parse(event.body);
  var event_type = body.event_type;
  var subscription = body.content.subscription;
  var customer = body.content.customer;

  var started_at = subscription.started_at;
  var next_billing_at = subscription.next_billing_at;
  var quantity = subscription.plan_quantity;
  var plan_id = subscription.plan_id;

  var plan = get_chargebee_plan(plan_id);

  console.log('Event Type', event_type);
  console.log('Subscription: ', JSON.stringify(subscription, null, 2));
  console.log('Customer: ', JSON.stringify(customer, null, 2));
  console.log('Plan: ', JSON.stringify(plan, null, 2));

  context.succeed(200);
};