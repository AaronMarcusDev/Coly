module ssbl
    
    # Int to keep track of the amount of errors.
    errors = 0

    # All keywords
    keywords = [
        "debug",
        "out",
        "prt",
        "pop",
        "dup",
        "clr",
        "set",
        "jmp",
        "exit",
        "if",
        "end",
        "swp",
        "in",
        "num",
        "mac",
    ]

    # Global helper functions
    function applyEscapeChars(input)
        input = replace(input, "\\n" => "\n")
        input = replace(input, "\\t" => "\t" )
        input = replace(input, "\\r" => "\r" )
        input = replace(input, "\\\\" => "\\")
        return input
    end

    # The error function.
    function error(line, pos, message)
        println(string("[ERROR] ", message, " ", line, ":", pos, "."))
        global errors += 1
    end

    function EOFError(line, pos)
        error(line, pos, "Unexpected end of file.")
    end
    
    function emptyStack(line, pos, cmd)
        error(line, pos, "Cannot issue '$cmd' command. Stack is empty.")
    end

    function tooLittleStackItems(line, pos, cmd)
        error(line, pos, "Cannot issue '$cmd' command. Stack has too little items.")
    end

    function unexpectedType(line, pos, type, keyword)
        error(line, pos, "Expected token of type $type for '$keyword'.")
    end

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
        global charsPassed = 0
        global lastloc = 0
        inMacro = false
        stack = []
        jumpPoints = Dict()
        macros = Dict()

        while pos <= length(tokens)
            type = getType(tokens[pos])
            value = getValue(tokens[pos])

            # Check if an error was found on every token.
            if errors > 0
                println("[INFO] Interpreter halted due to $errors error(s).")
                break
            end

            if type == "EOL"
                    global charsPassed = 0
                    global line += 1

            #Commands
            elseif type == "keyword"
                if value in keywords
                    if value == "debug"
                        println(stack)
                    end
                    if value == "end"
                        if inMacro
                            pos = lastloc
                        end
                    elseif value == "out"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            print(getValue(pop!(stack)))
                        end
                    elseif value == "prt"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            println(getValue(pop!(stack)))
                        end
                    elseif value == "pop"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            pop!(stack)
                        end
                    elseif value == "dup"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            push!(stack, stack[1])
                        end
                    elseif value == "clr"
                        stack = []
                    elseif value == "set"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            if expect(stack[length(stack)], "string")
                                jumpPoints[getValue(pop!(stack))] = pos
                            else
                                unexpectedType(line, charsPassed, "string", value)
                            end
                        end
                    elseif value == "jmp"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                            return
                        end
                        stackItem = pop!(stack)
                        stackValue = getValue(stackItem)
                        if expect(stackItem, "string")
                            if haskey(jumpPoints, stackValue)
                                pos = jumpPoints[stackValue]
                            else
                                error(line, charsPassed, "No jump-point found for '$stackValue'.")
                            end
                        else
                            unexpectedType(line, charsPassed, "string", value)
                        end
                    elseif value == "exit"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            if expect(stack[length(stack)], "number")
                                code = getValue(pop!(stack))
                                exit(parse(Int, code))
                            else
                                unexpectedType(line, charsPassed, "number", value)
                            end
                        end
                    elseif value == "if"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
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
                                        EOFError(line, charsPassed)
                                        break
                                    end
                                    global pos += 1
                                end
                            else
                                unexpectedType(line, charsPassed, "number", value)
                            end
                        end
                    elseif value == "swp"
                        if length(stack) < 2
                            tooLittleStackItems(line, charsPassed, value)
                        else
                            a = pop!(stack)
                            b = pop!(stack)
                            push!(stack, b)
                            push!(stack, a)
                        end
                    elseif value == "in"
                        push!(stack, Dict("string" => readline()))
                    elseif value == "num"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                        else
                            a = pop!(stack)

                            if isInt(getValue(a))
                                push!(stack, Dict("number" => getValue(a)))
                            else
                                a = getValue(a)
                                error(line, charsPassed, "Cannot convert '$a' to integer.")
                            end
                        end
                    elseif value == "mac"
                        if isEmpty(stack)
                            emptyStack(line, charsPassed, value)
                            return
                        end

                        name = pop!(stack)

                        if !expect(name, "string")
                            unexpectedType(line, charsPassed, "string", value)
                            return
                        end

                        name = getValue(name)

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
                                            error(line, charsPassed, "Macro '$name' already exists.")
                                        else
                                            if name in keywords
                                                error(line, charsPassed, "Cannot use keyword '$name' as macro name.")
                                            else
                                                macros[name] = start + 1
                                                push!(keywords, name)
                                            end
                                        end
                                        break
                                    else
                                        nestedIfs -= 1
                                    end
                                end
                            elseif expect(tokens[pos], "EOL")
                                global line += 1
                            elseif expect(tokens[pos], "EOF")
                                error(start, start, "Macro was never closed with 'end'.")
                                EOFError(line, charsPassed)
                                break
                            end
                            global pos += 1
                        end
                    else
                        global lastloc = pos
                        inMacro = true
                        pos = macros[value]
                    end
                else
                    error(line, charsPassed, "Unknown command:'$value'.")
                end
            elseif type == "arithmetic"
                if value == "ADD"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => string(parse(Int, getValue(a)) + parse(Int, getValue(b)))))
                        else
                            println(a)
                            unexpectedType(line, charsPassed, "number", "+")
                        end
                    end
                elseif value == "SUB"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => string(parse(Int, getValue(b)) - parse(Int, getValue(a)))))
                        else
                            unexpectedType(line, charsPassed, "number", "-")
                        end
                    end
                elseif value == "MUL"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => string(parse(Int, getValue(a)) * parse(Int, getValue(b)))))
                        else
                            unexpectedType(line, charsPassed, "number", "*")
                        end
                    end
                elseif value == "DIV"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => string(Int(parse(Int, getValue(b)) / parse(Int, getValue(a))))))
                        else
                            unexpectedType(line, charsPassed, "number", "/")
                        end
                    end
                elseif value == "MOD"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => string(parse(Int, getValue(b)) % parse(Int, getValue(a)))))
                        else
                            unexpectedType(line, charsPassed, "number", "%")
                        end
                    end
                end
            elseif type == "comparator"
                if value == "LT"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, getValue(a)) < parse(Int, getValue(b)))))
                        else
                            unexpectedType(line, charsPassed, "number", "<")
                        end
                    end
                elseif value == "LTE"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) <= parse(Int, string(getValue(b))))))
                        else
                            unexpectedType(line, charsPassed, "number", "<=")
                        end
                    end
                elseif value == "GT"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) > parse(Int, string(getValue(b))))))
                        else
                            unexpectedType(line, charsPassed, "number", ">")
                        end
                    end
                elseif value == "GTE"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) >= parse(Int, string(getValue(b))))))
                        else
                            unexpectedType(line, charsPassed, "number", ">=")
                        end
                    end
                elseif value == "EQ"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) == parse(Int, string(getValue(b))))))
                        else
                            unexpectedType(line, charsPassed, "number", "=")
                        end
                    end
                elseif value == "NEQ"
                    if length(stack) < 2
                        tooLittleStackItems(line, charsPassed, value)
                    else
                        a = pop!(stack)
                        b = pop!(stack)

                        if expect(a, "number") && expect(b, "number")
                            push!(stack, Dict("number" => Int(parse(Int, string(getValue(a))) != parse(Int, string(getValue(b))))))
                        else
                            unexpectedType(line, charsPassed, "number", "!=")
                        end
                    end
                end
            else
                push!(stack, tokens[pos])
            end
            global charsPassed += length(getValue(tokens[pos]))
            global pos += 1
        end
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
    
    # Regex functions.
    function isLetter(input)
        check = string(input)
        return occursin(r"[a-zA-Z]", check)
    end
    
    function isDigit(input)
        check = string(input)
        return occursin(r"[0-9]", check)
    end
    
    # Lexer.
    function lexer(content)
        # Turning file into array of characters.
        chars = split(replace(content, "\r" => ""), "")
        push!(chars, " ") # Is needed for the lexer to function correctly.
        tokens = []
        global i = 1
        global line = 1

        while i < length(chars)
            curr = chars[i]
            if curr == " "
            elseif curr == "\n"
                push!(tokens, Dict("EOL" => "EOL"))
                global line += 1
            elseif curr == "+"
                push!(tokens, Dict("arithmetic" => "ADD"))
            elseif curr == "-"
                push!(tokens, Dict("arithmetic" => "SUB"))
            elseif curr == "*"
                push!(tokens, Dict("arithmetic" => "MUL"))
            elseif curr == "/"
                push!(tokens, Dict("arithmetic" => "DIV"))
            elseif curr == "%"
                push!(tokens, Dict("arithmetic" => "MOD"))
            elseif curr == "<"
                if chars[i+1] == "="
                    push!(tokens, Dict("comparator" => "LTE"))
                    i += 1
                else
                    push!(tokens, Dict("comparator" => "LT"))
                end
            elseif curr == ">"
                if chars[i+1] == "="
                    push!(tokens, Dict("comparator" => "GTE"))
                    i += 1
                else
                    push!(tokens, Dict("comparator" => "GT"))
                end
            elseif curr == "="
                push!(tokens, Dict("comparator" => "EQ"))
            elseif curr == "!"
                if chars[i+1] == "="
                    push!(tokens, Dict("comparator" => "NEQ"))
                    i += 1
                else
                    error(line, i, "Unexpected character.")
                end
            elseif curr == "("
                push!(tokens, Dict("special" => "LPAREN"))
            elseif curr == ")"
                push!(tokens, Dict("special" => "RPAREN"))
            elseif curr == ","
                push!(tokens, Dict("special" => "COMMA"))
            elseif curr == ";"
                if chars[i+1] == ";"
                    global i += 1
                    while true
                        if i >= length(chars)
                            break
                        elseif chars[i] == "\n"
                            push!(tokens, Dict("EOL" => "EOL"))
                            break
                        end
                        global i += 1
                    end
                else
                    error(line, i, "Unexpected character.")
                end
            elseif curr == "\""
                result = []
                global i += 1
                while true
                    if i > length(chars)
                        error(line, i, "Unterminated string.")
                        break
                    elseif chars[i] == "\""
                        push!(tokens, Dict("string" => join(result, "")))
                        break
                    else
                        push!(result, chars[i])
                        global i += 1
                    end
                end
            elseif isLetter(curr)
                result = []
                while true
                    if i > length(chars)
                        push!(tokens, Dict("keyword" => join(result, "")))
                        break
                    elseif !isLetter(chars[i])
                        push!(tokens, Dict("keyword" => join(result, "")))
                        break
                    else
                        push!(result, chars[i])
                        global i += 1
                    end
                end
                global i -= 1
            elseif isDigit(curr)
                result = []
                while true
                    if i > length(chars)
                        push!(tokens, Dict("number" => join(result, "")))
                        break
                    elseif !isDigit(chars[i])
                        push!(tokens, Dict("number" => join(result, "")))
                        break
                    else
                        push!(result, chars[i])
                        global i += 1
                    end
                end
                global i -= 1
            else
                error(line, i, "Unexpected character.")
            end
            global i += 1
        end
        if errors > 0
            println("[INFO] Lexing failed due to $errors error(s).")
            exit(1)
        else
            push!(tokens, Dict("EOF" => "EOF"))
            # println("[INFO] Lexing successful.")
            identifier(tokens)
        end
    end

    # Opening and reading file.
    function readFile(name)
        content = open(name) do file
            read(file, String)
        end
        lexer(content)
    end

    # Run the language
    function run(file, mode)
        readFile(file)
    end

    # Entry point of language.
    if length(ARGS) != 1
        println("Usage: ssbl <file>")
        exit(1)
    else
        if !isfile(ARGS[1])
            println(string("File not found: ", ARGS[1]))
            exit(1)
        else
            run(ARGS[1], "run")
        end
    end
end # module ssbl
