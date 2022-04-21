{ lib, callPackage, fetchFromGitHub, linuxKernel, ... }: with builtins; let
    kernel = callPackage (import ./kernel-file.nix lib) { };
    ref = "${kernel.version}-xanmod1";
in kernel.override {
    argsOverride = rec {
        version = ref;
        modDirVersion = version;
        src = fetchGit {
            url = "https://github.com/xanmod/linux.git";
            inherit ref;
        };
        kernelPatches = linuxKernel.kernels.linux_xanmod.kernelPatches ++ (kernel.kernelPatches or []);
        structuredExtraConfig = linuxKernel.kernels.linux_xanmod.structuredExtraConfig // (kernel.structuredExtraConfig or {});
    };
}