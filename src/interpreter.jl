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
    # global lastloc = 0
    # inMacro = false
    # macros = Dict()
    stack = []
    jumpPoints = Dict()

    while pos <= length(tokens)
        type = getType(tokens[pos])
        value = getValue(tokens[pos])

        # Check if an error was found on every token.
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
                    # if inMacro
                    #     pos = lastloc
                    #     inMacro = false
                    # end
                elseif value == "out"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        print(getValue(pop!(stack)))
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
                elseif value == "jmp"
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
                elseif value == "swp"
                    if length(stack) < 2
                        tooLittleStackItems(line, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)
                        push!(stack, a)
                        push!(stack, b)
                    end
                elseif value == "in"
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
                        tooLittleStackItems(line, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)
                        push!(stack, Dict("string" => string(getValue(b), getValue(a))))
                    end
                elseif value == "mac"
                    # if isEmpty(stack)
                    #     emptyStack(line, value)
                    #     return
                    # end

                    # name = pop!(stack)

                    # if !expect(name, "string")
                    #     unexpectedType(line, "string", value)
                    #     return
                    # end

                    # name = getValue(name)

                    # nestedIfs = 0
                    # start = pos
                    # global pos += 1
                    # while pos <= length(tokens)
                    #     if expect(tokens[pos], "keyword")
                    #         if getValue(tokens[pos]) == "if" || getValue(tokens[pos]) == "mac"
                    #             nestedIfs += 1
                    #         elseif getValue(tokens[pos]) == "end"
                    #             if nestedIfs == 0
                    #                 if haskey(macros, name)
                    #                     error(line, "Macro '$name' already exists.")
                    #                 else
                    #                     if name in keywords
                    #                         error(line, "Cannot use keyword '$name' as macro name.")
                    #                     else
                    #                         macros[name] = start + 1
                    #                         push!(keywords, name)
                    #                     end
                    #                 end
                    #                 break
                    #             else
                    #                 nestedIfs -= 1
                    #             end
                    #         end
                    #     elseif expect(tokens[pos], "EOL")
                    #         global line += 1
                    #     elseif expect(tokens[pos], "EOF")
                    #         error(start, start, "Macro was never closed with 'end'.")
                    #         EOFError(line)
                    #         break
                    #     end
                    #     global pos += 1
                    # end
                elseif value == "sys"
                    if isEmpty(stack)
                        emptyStack(line, value)
                    else
                        a = pop!(stack)

                        if expect(a, "string")
                            a = getValue(a)
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
                else
                    # global lastloc = pos
                    # inMacro = true
                    # pos = macros[value]
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
        # global charsPassed += length(getValue(tokens[pos]))
        global pos += 1
    end
end