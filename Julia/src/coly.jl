import Base.run

module coly
    # Included jl files
    include("error/error.jl")
    include("interpreter/keywords.jl")
    include("interpreter/interpreter.jl")
    include("parser/identifier.jl")
    include("parser/preprocessor.jl")
    include("parser/parser.jl")
    include("lexer/lexer.jl")
    # Opening and reading file.
    function readFile(name)
        open(name) do file
            return read(file, String)
        end
    end

    # Run the program.
    function run(file, mode)
        content = readFile(file)
        if length(strip(content)) != 0
            lexer(content)
        end
    end

    # Entry point of language.
    if isEmpty(ARGS)
        println("[ERROR] No file specified.")
        println("[INFOR] Usage: coly <file> <args>")
        exit(1)
    else
        if !isfile(ARGS[1])
            println(string("[ERROR] File not found: ", @__DIR__, "\\", ARGS[1]))
            exit(1)
        else
            global filePath = string(@__DIR__, "\\", ARGS[1])
            global const mainFile = filePath
            run(ARGS[1], "run")
        end
    end
end # module coly