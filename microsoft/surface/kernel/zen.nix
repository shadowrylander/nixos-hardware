{ lib, callPackage, fetchFromGitHub, linuxKernel, ... }: with builtins; let
    kernel = callPackage (import ./kernel-file.nix lib) { };
    ref = "${kernel.version}-zen1";
in kernel.override {
    argsOverride = rec {
        version = ref;
        modDirVersion = version;
        src = fetchGit {
            url = "https://github.com/zen-kernel/zen-kernel.git";
            inherit ref;
        };
        kernelPatches = linuxKernel.kernels.linux_zen.kernelPatches ++ (kernel.kernelPatches or []);
        structuredExtraConfig = linuxKernel.kernels.linux_zen.structuredExtraConfig // (kernel.structuredExtraConfig or {});
    };
}