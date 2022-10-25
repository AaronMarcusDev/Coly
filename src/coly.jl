import Base.run

module coly
    # Opening and reading file.
    function readFile(name)
        open(name) do file
            return read(file, String)
        end
    end

    # Included .jl files
    include("keywords.jl")
    include("error.jl")
    include("interpreter.jl")
    include("identifier.jl")
    include("preprocessor.jl")
    include("parser.jl")
    include("lexer.jl")

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
            mainFile = filePath
            run(ARGS[1], "run")
        end
    end
end # module coly