module Translator

using QXZoo.GateMap
using QXZoo.GateOps
using QXZoo.Circuit
using QXZoo.DefaultGates

abstract type ATranslator end

function circuit_to_backend(cct::Circuit.Circ, backend::ATranslator)
    return backend.translate(cct)
end


function get_gate_def(gs::GateOps.GateSymbol)
    return QXZoo.GateMap.gates[gs]
end



end