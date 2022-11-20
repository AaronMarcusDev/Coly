function applyEscapeChars(input)
    return replace(input, "\\n" => "\n", "\\t" => "\t", "\\r" => "\r", "\\\\" => "\\")
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