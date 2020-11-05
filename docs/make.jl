using Documenter, QuantExQASM

makedocs(
    modules = [QuantExQASM],
    clean = false,
    sitename = "QuantZoo.jl",
    pages = Any[
        "Home" => "index.md",
        #"Tutorial" => "tutorial.md",
        "Manual" => Any[
            "Gates" => "gates_circuits/GateOps.md",
            "Circuits" => "gates_circuits/circuits.md",
            "Algorithms" => Any[ "NCU" => "algo/ncu.md", "Grover" => "algo/grover.md" ],
        ],
    ]
)
deploydocs(
    repo = "github.com/ICHEC/QuantZoo.jl.git",
)
