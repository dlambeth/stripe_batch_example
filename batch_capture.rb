require 'stripe'
require 'csv'

Stripe.api_key = <YOUR TEST KEY>

def batch_capture(source)
  log_name = "batchresults_#{Time.now.to_i}.csv"
  error_name = "batcherrors_#{Time.now.to_i}.csv"
  successful_charges = Hash.new()
  errors = Hash.new()
  
  #start at 1 to account for header
  row_count = 1
  successful_charges = 0
  errors = 0

  log_file = CSV.open(log_name, "w") 
  log_file << ["line_num", "id", "amount", "created", "customer"]

  error_file = CSV.open(error_name, "w")
  error_file << ["line_num", "request_id", "message"]
  
  CSV.foreach(source, :headers => true) do |row| 
    #increment immediately so we can use for logging errors
  	row_count += 1
 
    headers = {}

    if !row['idempotency_key'].nil?   
      headers[:idempotency_key] = row['idempotency_key']
      row.delete('idempotency_key')
    end

    begin
      charge = Stripe::Charge.create(row, headers)
      
      log_file << [row_count, charge.id, charge.amount, charge.created, charge.customer]
      successful_charges += 1
    rescue => error
      puts error
      error_file << [row_count, error.request_id, error.message]
      errors += 1
    end
  end

  log_file << ["#total charges processed #{successful_charges}"]
  log_file << ["#last line processed #{row_count}"]
  log_file.close()
 
  error_file << ["#total errors #{errors}"]
  error_file << ["#last line processed #{row_count}"]
  error_file.close()
end
