# stripe_batch_example
This is an example of how one might batch charges using Stripe.

##How to run

The example file relies on existing customers, so you will need to replace with customers in your Stripe account. 

You'll also need to place holder text here with your API key:
`Stripe.api_key = <YOUR TEST KEY>`

Once you've done the above, to run within pry:
`load '<path to>batch_capture.rb'`

`batch_capture(<example_batch_file.csv | <your csv file>)`
