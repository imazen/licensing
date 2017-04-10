'use strict';

console.log('Loading function');

get_chargebee_plan = (chargebee,plan_id) => {
  var plan;
  chargebee.plan.retrieve(plan_id).request(
  function(error,result){
    if(error){
      console.log(error);
    }else{
      console.log(result);
      plan = result.plan;
    }
  });
  plan;
};

exports.handler = (event, context, callback) => {
  var body = JSON.parse(event.body);
  var event_type = body.event_type;
  var subscription = body.content.subscription;
  var customer = body.content.customer;

  var started_at = subscription.started_at;
  var next_billing_at = subscription.next_billing_at;
  var quantity = subscription.plan_quantity;
  var plan_id = subscription.plan_id;

  var chargebee = require("chargebee");
  chargebee.configure({
    site: "imazen-test",
    api_key: "test_bOJ3nmQFjkduvQcG1coxEYxuqdZaYJpx"
  });

  var plan = get_chargebee_plan(chargebee,plan_id);

  console.log('Event Type', event_type);
  console.log('Subscription: ', JSON.stringify(subscription, null, 2));
  console.log('Customer: ', JSON.stringify(customer, null, 2));
  console.log('Plan: ', JSON.stringify(plan, null, 2));

  context.succeed(200);
};