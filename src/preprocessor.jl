function getType(token)
    for item in keys(token)
        return item
    end
end

function getValue(token)
    for item in values(token)
        return item
    end
end

function preprocess(tokens)
    global pos = 1
    global line += 1
    charsPassed = 0
    macros = Dict()
    stack = []
    result = []

    while pos <= length(tokens)
        type = getType(tokens[pos])
        value = getValue(tokens[pos])

        if type == "EOL"
            push!(result, tokens[pos])
            global line += 1
        elseif type == "keyword"
            if value == "mac"
                if isEmpty(stack)
                    emptyStack(line, 0, value)
                    return
                end

                name = pop!(stack)

                if !expect(name, "string")
                    unexpectedType(line, 0, "string", value)
                    return
                end
                pop!(result)
                name = getValue(name)
                macrotokens = []

                nestedIfs = 0
                start = pos
                global pos += 1
                while pos <= length(tokens)
                    if expect(tokens[pos], "keyword")
                        if getValue(tokens[pos]) == "if" || getValue(tokens[pos]) == "mac"
                            nestedIfs += 1
                        elseif getValue(tokens[pos]) == "end"
                            if nestedIfs == 0
                                if haskey(macros, name)
                                    error(line, "Macro '$name' already exists.")
                                else
                                    macros[name] = macrotokens
                                end
                                break
                            else
                                nestedIfs -= 1
                            end
                        end
                    elseif expect(tokens[pos], "EOL")
                        global line += 1
                    elseif expect(tokens[pos], "EOF")
                        error(start, "Macro was never closed with 'end'.")
                        EOFError(line)
                        break
                    end
                    if getType(tokens[pos]) != "EOL"
                        push!(macrotokens, tokens[pos])
                    end
                    global pos += 1
                end
            elseif haskey(macros, value)
                for item in macros[value]
                     push!(result, item)
                end
            else
                push!(result, tokens[pos])
            end
        elseif type == "arithmetic"
            push!(result, tokens[pos])
        elseif type == "comparator"
            push!(result, tokens[pos])
        else
            push!(stack, tokens[pos])
            push!(result, tokens[pos])
        end
        global pos += 1
    end

    if errors > 0
        println("[INFO] Preprocessing failed due to $errors error(s).")
    else
        # println("[INFO] Preprocessing completed successfully.")
        identifier(result)
    end
end