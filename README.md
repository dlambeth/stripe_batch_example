# stripe_batch_example
Simple example of how to batch charges using Stripe

How to run

The example file relies on existing customers, so you will need to replace with customers in your Stripe account. 

You'll also need to set the Stripe.api_key

Once you've done the above, to run within pry:
> load 'batch_capture.rb'

> batch_capture(<your csv file>)


