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
    macros = Dict()
    macrolocs = Dict()
    currentFile = mainFile
    stack = []
    result = []
    preresult = []

    while pos <= length(tokens)
        type = getType(tokens[pos])
        value = getValue(tokens[pos])

        if type == "EOL"
            push!(preresult, tokens[pos])
            global line += 1
        elseif type == "keyword"
            if value == "inc"
                if isEmpty(stack)
                    emptyStack(line, value)
                else
                    a = pop!(stack)
                    if !expect(a, "string")
                        unexpectedType(line, "string", value)
                        return
                    end

                    a = getValue(a)
                    if !isfile(a)
                        error(line, "Failed to include file. File does not exist.")
                        return
                    end
                    pop!(preresult)
                    push!(preresult, Dict("file" => string(@__DIR__, "\\", a)))
                    for item in lexer(readFile(a), true)
                        push!(preresult, item)
                    end
                    pop!(preresult)
                    push!(preresult, Dict("file" => string(@__DIR__, "\\", filePath)))
                end
            else
            push!(preresult, tokens[pos])
            end
        elseif type == "arithmetic"
            push!(preresult, tokens[pos])
        elseif type == "comparator"
            push!(preresult, tokens[pos])
        elseif type == "EOF"
            push!(preresult, tokens[pos])
        else
            push!(stack, tokens[pos])
            push!(preresult, tokens[pos])
        end
        global pos += 1
    end
    stack = []
    global pos = 1
    
    while pos <= length(preresult)
        type = getType(preresult[pos])
        value = getValue(preresult[pos])

        if type == "EOL"
            push!(result, preresult[pos])
            global line += 1
        elseif type == "keyword"
            if value == "mac"
                if isEmpty(stack)
                    emptyStack(line, value)
                    return
                end

                name = pop!(stack)

                if !expect(name, "string")
                    unexpectedType(line, "string", value)
                    return
                end
                pop!(result)
                name = getValue(name)
                macrotokens = []

                nestedIfs = 0
                start = pos
                global pos += 1
                while pos <= length(preresult)
                    if expect(preresult[pos], "keyword")
                        if getValue(preresult[pos]) == "if" || getValue(preresult[pos]) == "mac"
                            nestedIfs += 1
                        elseif getValue(preresult[pos]) == "end"
                            if nestedIfs == 0
                                if haskey(macros, name)
                                    error(line, "Macro '$name' already exists.")
                                elseif name in keywords
                                    error(line, "Cannot use keyword '$name' as macro name.")
                                else
                                    macros[name] = macrotokens
                                    macrolocs[name] = currentFile
                                end
                                break
                            else
                                nestedIfs -= 1
                            end
                        end
                    elseif expect(preresult[pos], "EOL")
                        global line += 1
                    elseif expect(preresult[pos], "EOF")
                        error(start, "Macro was never closed with 'end'.")
                        EOFError(line)
                        break
                    end
                    if getType(preresult[pos]) != "EOL"
                        push!(macrotokens, preresult[pos])
                    end
                    global pos += 1
                end
            elseif value == "pop"
                if isEmpty(stack)
                    emptyStack(line, value)
                    return
                end
                pop!(stack)
            elseif value == "clr"
                stack = []
            elseif value == "dup"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                    return
                end
                push!(stack, stack[length(stack)])
            elseif haskey(macros, value)
                push!(result, Dict("file" => macrolocs[value]))
                for item in macros[value]
                     push!(result, item)
                end
                push!(result, Dict("file" => currentFile))
            else
                push!(result, preresult[pos])
            end
        elseif type == "arithmetic"
            push!(result, preresult[pos])
        elseif type == "comparator"
            push!(result, preresult[pos])
        elseif type == "file"
            # push!(result, preresult[pos])
            currentFile = value
        else
            push!(stack, preresult[pos])
            push!(result, preresult[pos])
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