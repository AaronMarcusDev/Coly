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

function parser(tokens)
    # println(string(tokens, "\n"))
    tree = []
    global i = 1
    global line = 1
    global errors = 0

    while i < length(tokens)
        type = getType(tokens[i])
        value = getValue(tokens[i])
        
        if type == "special"
            if value == "LBRACKET"
                L = []
                i += 1
                # global nestedLists = 0
                # global reparse = false
                while true
                    if getType(tokens[i]) == "EOF" || getType(tokens[i]) == "EOL"
                        error(line, "Unterminated List.")
                        errors += 1
                        break
                    elseif getType(tokens[i]) == "special" && getValue(tokens[i]) == "LBRACKET"
                        # reparse = true
                        # nestedLists += 1
                        error(line, "A List cannot contain a List.")
                        errors += 1
                    elseif getType(tokens[i]) == "special" && getValue(tokens[i]) == "RBRACKET"
                        # if nestedLists == 0
                        #     if reparse
                        #         push!(tree, parser(L))
                        #     else
                        #         L2 = []
                        #         for item in L
                        #             if item != Dict("special" => "RBRACKET")
                        #                 push!(L2, item)
                        #             end
                        #         end
                        #         push!(tree, L2)
                        #         i += 1
                        #     end
                        #     break
                        # else
                        #     nestedLists -= 1
                        # end
                        push!(tree, Dict("list" => L))
                        break
                    end
                    push!(L, tokens[i])
                    i += 1
                end
            elseif value == "RBRACKET"
                error(line, "Unexpected ']'.")
                errors += 1
            else
                push!(tree, tokens[i])
            end
        elseif type == "EOL"
            line += 1
            push!(tree, tokens[i])
        else
            push!(tree, tokens[i])
        end
        i += 1
    end
    if errors > 0
        println("[INFOR] Parsing failed due to $errors error(s).")
    else
        # println("[INFO] Preprocessing completed successfully.")
        preprocessor(tree)
    end    
end