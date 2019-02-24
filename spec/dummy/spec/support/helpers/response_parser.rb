def parsed_response
  @parsed_response ||= JSON.parse(response.body)
end

# Returns the message from the parsed JSON response
def response_message
  parsed_response['message']
end

# Returns the errors from the parsed JSON response
def response_errors
  parsed_response['error']
end
