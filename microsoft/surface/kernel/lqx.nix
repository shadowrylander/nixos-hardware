{ lib, callPackage, fetchFromGitHub, linuxKernel, ... }: with builtins; let
    kernel = callPackage (import ./kernel-file.nix lib) { };
    ref = "${kernel.version}-lqx1";
in kernel.override {
    argsOverride = rec {
        version = ref;
        modDirVersion = version;
        src = fetchGit {
            url = "https://github.com/zen-kernel/zen-kernel.git";
            inherit ref;
        };
        kernelPatches = linuxKernel.kernels.linux_lqx.kernelPatches ++ (kernel.kernelPatches or []);
        structuredExtraConfig = linuxKernel.kernels.linux_lqx.structuredExtraConfig // (kernel.structuredExtraConfig or {});
    };
}