# The error function.
function error(line, message)
    println(string("[ERROR] ", message))
    println(string("[TRACE] ", filePath, ":", line))
    global errors += 1
end

# Error helper functions.
function EOFError(line)
    error(line, "Unexpected end of file.")
end

function emptyStack(line, cmd)
    error(line, "Cannot issue '$cmd' command. Stack is empty.")
end

function tooLittleStackItems(line, cmd)
    error(line, "Cannot issue '$cmd' command. Stack has too little items.")
end

function unexpectedType(line, type, keyword)
    error(line, "Expected token of type $type for '$keyword'.")
end