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
function lexer(content, needReturn=false)
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
        elseif curr == "@"
            push!(tokens, Dict("keyword" => "con"))
        elseif curr == "*"
            push!(tokens, Dict("arithmetic" => "MUL"))
        elseif curr == "/"
            push!(tokens, Dict("arithmetic" => "DIV"))
        elseif curr == "%"
            push!(tokens, Dict("arithmetic" => "MOD"))
        elseif curr == "+"
            if chars[i+1] == "+"
                push!(tokens, Dict("arithmetic" => "INC"))
                i += 1
            else
                push!(tokens, Dict("arithmetic" => "ADD"))
            end
        elseif curr == "-"
            if chars[i+1] == "-"
                push!(tokens, Dict("arithmetic" => "DEC"))
                i += 1
            else
                push!(tokens, Dict("arithmetic" => "SUB"))
            end
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
                error(line, "Unexpected character: '$curr'.")
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
                        global line += 1
                        push!(tokens, Dict("EOL" => "EOL"))
                        break
                    end
                    global i += 1
                end
            else
                error(line, "Unexpected character: '$curr'.")
            end
        elseif curr == "\""
            result = []
            global i += 1
            while true
                if i > length(chars)
                    error(line, "Unterminated string.")
                    break
                elseif chars[i] == "\""
                    push!(tokens, Dict("string" => join(result, "")))
                    break
                else
                    push!(result, chars[i])
                    global i += 1
                end
            end
        elseif curr == "["
            push!(tokens, Dict("special" => "LBRACKET"))
        elseif curr == "]"
            push!(tokens, Dict("special" => "RBRACKET"))
        elseif isLetter(curr)
            result = []
            while true
                if i > length(chars)
                    push!(tokens, Dict("keyword" => join(result, "")))
                    break
                elseif !isLetter(chars[i]) && chars[i] != "_"
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
            error(line, "Unexpected character: '$curr'.")
        end
        global i += 1
    end
    if errors > 0
        println("[INFO] Lexing failed due to $errors error(s).")
        exit(1)
    else
        push!(tokens, Dict("EOF" => "EOF"))
        if needReturn
            return tokens
        else
            parser(tokens)
        end
    end
end