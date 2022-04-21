lib: with builtins; with lib; pipe ./. [
    readDir
    attrNames
    (filter (k: hasPrefix "linux-" k))
    last
    (f: "${toString ./.}/${f}")
]