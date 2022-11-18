# Int to keep track of the amount of errors.
errors = 0

# Interpreter.
function getType(token)
    for item in keys(token)
        return item
    end
end

function isInt(x)
    try
        parse(Int, x)
        return true
    catch
        return false
    end
end

function getValue(token)
    for item in values(token)
        return item
    end
end

function expect(token, expectation)
    return (getType(token) == expectation)
end

function isEmpty(item)
    return (length(item) == 0)
end

function interpreter(tokens)
    global pos = 1
    global line = 1
    global lastLine = 0
    global enum = -1
    expectEnd = false
    jumpPoints = Dict()
    stack = []

    while pos <= length(tokens)
        type = getType(tokens[pos])
        value = getValue(tokens[pos])

        # Check if an error was found on every token iteration.
        if errors > 0
            println("[INFO] Interpreter halted due to $errors error(s).")
            break
        end

        if type == "EOL"
                # global charsPassed = 0
                global line += 1

        #Commands
        elseif type == "keyword"
            if value in keywords
                if value == "debug"
                    println(stack)
                    return
                end
                if value == "end"
                    if !expectEnd
                        error(line, "Unexpected 'end' keyword.")
                    end
                    expectEnd = false
                elseif value == "out"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        if getType(stack[length(stack)]) != "list"
                            print(getValue(pop!(stack)))
                        else
                            print("[ ")
                            for item in getValue(pop!(stack))
                                if getType(item) == "string"
                                    print("\"", getValue(item), "\" ")
                                else
                                    print(getValue(item), " ")
                                end
                            end
                            print("]")
                        end
                    end
                elseif value == "pop"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        pop!(stack)
                    end
                elseif value == "dup"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        a = pop!(stack)
                        push!(stack, a)
                        push!(stack, a)
                    end
                elseif value == "clr"
                    stack = []
                elseif value == "peek"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        println(getValue(stack[length(stack)]))
                    end
                elseif value == "set"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        if expect(stack[length(stack)], "string")
                            jumpPoints[getValue(pop!(stack))] = pos
                        else
                            unexpectedType(line, "string", value)
                        end
                    end
                elseif value == "jump"
                    if isEmpty(stack)
                        emptyStack(line, value)
                        return
                    end
                    stackItem = pop!(stack)
                    stackValue = getValue(stackItem)
                    if expect(stackItem, "string")
                        if haskey(jumpPoints, stackValue)
                            pos = jumpPoints[stackValue]
                        else
                            error(line, "No jump-point found for '$stackValue'.")
                        end
                    else
                        unexpectedType(line, "string", value)
                    end
                elseif value == "exit"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        if expect(stack[length(stack)], "number")
                            code = getValue(pop!(stack))
                            exit(parse(Int, code))
                        else
                            unexpectedType(line, "number", value)
                        end
                    end
                elseif value == "if"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        if expect(stack[length(stack)], "number")
                            condition = getValue(pop!(stack))
                            nestedIfs = 0
                            linesfound = 0
                            start = pos
                            global pos += 1
                            while pos <= length(tokens)
                                if expect(tokens[pos], "keyword")
                                    if getValue(tokens[pos]) == "if" || getValue(tokens[pos]) == "mac"
                                        nestedIfs += 1
                                    elseif getValue(tokens[pos]) == "end"
                                        if nestedIfs == 0
                                            if condition == 1
                                                lastIf = 1
                                                expectEnd = true
                                                global line -= linesfound
                                                global pos = start + 1
                                            elseif condition == 0
                                                lastIf = 0
                                                break
                                            else
                                                error(line, start, "Invalid boolean, condition must be either 0 (false) or 1 (true).")
                                            end
                                            break
                                        else
                                            nestedIfs -= 1
                                        end
                                    end
                                elseif expect(tokens[pos], "EOL")
                                    global line += 1
                                    linesfound += 1
                                elseif expect(tokens[pos], "EOF")
                                    error(line - linesfound, start, "if-statement was never closed with 'end'.")
                                    EOFError(line)
                                    break
                                end
                                global pos += 1
                            end
                        else
                            unexpectedType(line, "number", value)
                        end
                    end
                elseif value == "swap"
                    if length(stack) < 2
                        tooLittleStackItems(line, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)
                        push!(stack, a)
                        push!(stack, b)
                    end
                elseif value == "input"
                    push!(stack, Dict("string" => readline()))
                elseif value == "num"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        a = pop!(stack)

                        if isInt(getValue(a))
                            push!(stack, Dict("number" => getValue(a)))
                        else
                            a = getValue(a)
                            error(line, "Cannot convert '$a' to integer.")
                        end
                    end
                elseif value == "str"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        a = pop!(stack)
                        push!(stack, Dict("string" => string(getValue(a))))
                    end
                elseif value == "con"
                    if length(stack) < 2
                        tooLittleStackItems(line, "@")
                    else
                        a = pop!(stack)
                        b = pop!(stack)
                        push!(stack, Dict("string" => string(getValue(a), getValue(b))))
                    end
                elseif value == "mac"
                    error(line, "Unexpected Macro definition.")
                    error(line, "Expected Coly-preprocessor error.")
                elseif value == "sys"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        a = pop!(stack)

                        if expect(a, "string")
                            try
                                if occursin(" ", a)
                                    a = split(a, " ")
                                    Base.run(`$(a[1]) $(a[2:end])`)
                                else
                                    Base.run(`$a`)
                                end
                            catch
                                a = join(a, " ")
                                error(line, "Command '$a' failed.")
                            end
                        else
                            unexpectedType(line, "string", value)
                        end
                    end
                elseif value == "len"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        push!(stack, Dict("number" => length(getValue(pop!(stack)))))
                    end
                elseif value == "rev"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        stack = reverse(stack)
                    end
                elseif value == "args"
                    if !isEmpty(ARGS)
                        for argument in reverse(deepcopy(ARGS[2:length(ARGS)]))
                            push!(stack, Dict("string" => argument))
                        end
                    end
                elseif value == "argc"
                    if length(ARGS) > 1
                        push!(stack, Dict("number" => length(ARGS) - 1))
                    else
                        push!(stack, Dict("number" => 0))
                    end
                elseif value == "argv"
                    R = []
                    for arg in ARGS
                        push!(R, Dict("string" => arg))
                    end
                    push!(stack, Dict("list" => R))
                elseif value == "over"
                    if length(stack) < 2
                        tooLittleStackItems(line, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)
                        push!(stack, b)
                        push!(stack, a)
                        push!(stack, b)
                    end
                elseif value == "enum"
                    global enum += 1
                    push!(stack, Dict("number" => enum))
                elseif value == "renum"
                    global enum = -1
                else
                    error(line, "Unknown keyword '$value'.")
                end
            else
                error(line, "Unknown command:'$value'.")
            end
        elseif type == "arithmetic"
            if value == "ADD"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(a)) + parse(Int, getValue(b)))))
                    else
                        println(a)
                        unexpectedType(line, "number", "+")
                    end
                end
            elseif value == "SUB"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(b)) - parse(Int, getValue(a)))))
                    else
                        unexpectedType(line, "number", "-")
                    end
                end
            elseif value == "MUL"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(a)) * parse(Int, getValue(b)))))
                    else
                        unexpectedType(line, "number", "*")
                    end
                end
            elseif value == "DIV"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => string(Int(parse(Int, getValue(b)) / parse(Int, getValue(a))))))
                    else
                        unexpectedType(line, "number", "/")
                    end
                end
            elseif value == "MOD"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(b)) % parse(Int, getValue(a)))))
                    else
                        unexpectedType(line, "number", "%")
                    end
                end
            elseif value == "INC"
                if isEmpty(stack)
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    if expect(a, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(a)) + 1)))
                    else
                        unexpectedType(line, "number", "++")
                    end
                end
            elseif value == "DEC"
                if isEmpty(stack)
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    if expect(a, "number")
                        push!(stack, Dict("number" => string(parse(Int, getValue(a)) - 1)))
                    else
                        unexpectedType(line, "number", "--")
                    end
                end
            end
        elseif type == "comparator"
            if value == "LT"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, getValue(a)) < parse(Int, getValue(b)))))
                    else
                        unexpectedType(line, "number", "<")
                    end
                end
            elseif value == "LTE"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) <= parse(Int, string(getValue(b))))))
                    else
                        unexpectedType(line, "number", "<=")
                    end
                end
            elseif value == "GT"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) > parse(Int, string(getValue(b))))))
                    else
                        unexpectedType(line, "number", ">")
                    end
                end
            elseif value == "GTE"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) >= parse(Int, string(getValue(b))))))
                    else
                        unexpectedType(line, "number", ">=")
                    end
                end
            elseif value == "EQ"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) == parse(Int, string(getValue(b))))))
                    else
                        unexpectedType(line, "number", "=")
                    end
                end
            elseif value == "NEQ"
                if length(stack) < 2
                    tooLittleStackItems(line, value)
                else
                    a = pop!(stack)
                    b = pop!(stack)

                    if expect(a, "number") && expect(b, "number")
                        push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) != parse(Int, string(getValue(b))))))
                    else
                        unexpectedType(line, "number", "!=")
                    end
                end
            end
        elseif type == "file"
            global filePath = value
            if filePath != mainFile
                global lastLine = line
                global line = 1
            else
                global line = lastLine
            end
        else
            push!(stack, tokens[pos])
        end
        global pos += 1
    end
end