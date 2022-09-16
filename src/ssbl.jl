import Base.run

module ssbl
    # Included jl files
    include("keywords.jl")
    include("error.jl")
    include("interpreter.jl")
    include("identifier.jl")
    include("preprocessor.jl")
    include("lexer.jl")

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
    if length(ARGS) != 1
        println("Usage: ssbl <file>")
        exit(1)
    else
        if !isfile(ARGS[1])
            println(string("[ERROR] File not found: ", @__DIR__, "\\", ARGS[1]))
            exit(1)
        else
            global filePath = string(@__DIR__, "\\", ARGS[1])
            run(ARGS[1], "run")
        end
    end
end # module ssbl