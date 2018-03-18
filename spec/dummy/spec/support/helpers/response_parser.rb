def parsed_response
  @parsed_response ||= JSON.parse(response.body)
end

# Returns the data from the parsed JSON response
def response_data
  parsed_response['data']
end

# Returns the errors from the parsed JSON response
def response_errors
  parsed_response['errors']
end
