require 'stripe'
require 'csv'

Stripe.api_key = <YOUR TEST KEY>

def batch_capture(source)
  log_file = "batchresults_#{Time.now.to_i}.csv"
  error_file = "batcherrors_#{Time.now.to_i}.csv"
  successful_charges = Hash.new()
  errors = Hash.new()
  
  #start at 1 to account for header
  row_count = 1

  CSV.foreach(source, :headers => true) do |row| 
    #increment immediately so we can use for logging errors
  	row_count += 1

    idempotency_key = row['idempotency_key']
    row.delete('idempotency_key')

    begin
      if !idempotency_key.nil?
  	    charge = Stripe::Charge.create(row, {:idempotency_key => idempotency_key})
      else
        charge =  Stripe::Charge.create(row)
      end
      successful_charges[charge.id] = charge
    rescue => e
      puts e
      errors[row_count] = e    
    end
  end

  CSV.open(log_file, "wb") do |output|
    output << ["#total charges processed #{successful_charges.count}"]
    output << ["#last line processed #{row_count}"]
    output << ["id", "amount", "created", "customer"]
    successful_charges.map do |id, ch|
      output << [ch.id, ch.amount, ch.created, ch.customer]
    end
  end

  CSV.open(error_file, "wb") do |output|
    output << ["#total errors #{errors.count}"]
    output << ["#last line processed #{row_count}"]
    output << ["line_num", "request_id", "message"]
    errors.map do |line_num, error|
      output << [line_num, error.request_id, error.message]
    end
  end
end
