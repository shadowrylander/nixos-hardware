{ config, pkgs, ... }: with lib; let
    kernel = pkgs.callPackage ./kernel/linux-5.16.11.nix { };
    structuredExtraConfig = kernel.structuredExtraConfig or {};
in {
    imports = [ ./. ];
    boot.kernelPackages = mkOverride 99 (kernel.override {
        argsOverride = rec {
            version = "5.16.11-xanmod1";
            modDirVersion = version;
            src = pkgs.fetchFromGitHub {
                owner = "xanmod";
                repo = "linux";
                rev = "0af0c5df407fd0b20e0935cd315dd337bdccff99";
                sha256 = "sha256-4NlD5VfsBx7e6GTCHGDs6hGmH7qs1mIkS23sj0HlK24=";
            };
            # kernelPatches = [
            #     (last (filter (set: hasPrefix "bcachefs-" set.name) pkgs.linuxKernel.kernels.linux_testing_bcachefs.kernelPatches))
            # ] ++ kernel.kernelPatches;
            structuredExtraConfig = pkgs.linuxKernel.kernels.linux_xanmod.structuredExtraConfig // structuredExtraConfig;
        };
    });
}