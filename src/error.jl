# The error function.
function error(line, pos, message)
    println(string("[ERROR] ", message, " ", line, ":", pos, "."))
    global errors += 1
end

# Error helper functions.
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