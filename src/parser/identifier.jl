function applyEscapeChars(input)
    input = replace(input, "\\n" => "\n")
    input = replace(input, "\\t" => "\t" )
    input = replace(input, "\\r" => "\r" )
    input = replace(input, "\\\\" => "\\")
    return input
end

# Identifier.
function identifier(og_tokens)
    tokens = []
    for token in og_tokens
        type = getType(token)
        value = getValue(token)
        
        if type == "keyword"
            push!(tokens, token)
        elseif type == "string"
            string = applyEscapeChars(value)
            push!(tokens, Dict("string" => string))
        else
            push!(tokens, token)
        end
    end
    interpreter(tokens)
end 