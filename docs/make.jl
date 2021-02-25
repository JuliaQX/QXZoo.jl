push!(LOAD_PATH,"../")
using Documenter, QXZoo, Random

makedocs(;
    modules=[QXZoo],
    authors="QuantEx team",
    repo="https://github.com/JuliaQX/QXZoo.jl/blob/{commit}{path}#L{line}",
    sitename="QXZoo.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaQX.github.io/QXZoo.jl",
        assets=String[],
    ),
    pages=Any[
        "Home" => "index.md",
        "Examples" => "examples.md",
        "Manual" => Any[
            "Gates" => Any[ "gates_circuits/GateOps.md", 
                            "gates_circuits/DefaultGates.md", 
                            "gates_circuits/CompositeGates.md", 
                            "gates_circuits/GateMap.md",
                        ],
            "Circuits" => "gates_circuits/circuits.md",
            "Algorithms" => Any[    "NCU" => "algo/ncu.md", 
                                    "Grover" => "algo/grover.md",
                                    "QFT" => "algo/qft.md",
                                    "RQC" => "algo/rqc.md"
                                ],
        ],
    ]
)
deploydocs(;
    repo="github.com/JuliaQX/QXZoo.jl",
)
