{ lib, callPackage, linuxPackagesFor, ... }:
# To test the kernel build:
# nix-build -E "with import <nixpkgs> {}; (pkgs.callPackage ./linux-5.16.11.nix {}).kernel"
let
  repos = callPackage ../repos.nix {};
  linuxPkg = { fetchFromGitHub, fetchpatch, fetchurl, buildLinux, ... }@args:
    buildLinux (args // rec {
      version = "5.16.11-xanmod1";
      modDirVersion = version;
      extraMeta.branch = "5.16";

      # src = repos.linux-surface-kernel;
      src = fetchFromGitHub {
        owner = "xanmod";
        repo = "linux";
        rev = "0af0c5df407fd0b20e0935cd315dd337bdccff99";
        sha256 = "sha256-4NlD5VfsBx7e6GTCHGDs6hGmH7qs1mIkS23sj0HlK24=";
      };

      kernelPatches = [
      {
        name = "bcachefs-6ddf061e68560a2bb263b126af7e894a6c1afb5f";

        patch = fetchpatch {
          name = "bcachefs-6ddf061e68560a2bb263b126af7e894a6c1afb5f.diff";
          url = "https://evilpiepirate.org/git/bcachefs.git/rawdiff/?id=6ddf061e68560a2bb263b126af7e894a6c1afb5f&id2=v5.16";
          sha256 = "1nkrr1cxavw0rqxlyiz7pf9igvqay0d5kk7194v9ph3fcp9rz5kc";
        };

        extraConfig = "BCACHEFS_FS m";
      }
      {
        name = "5.16.11-xanmod1";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          # removed options
          CFS_BANDWIDTH = lib.mkForce (option no);
          RT_GROUP_SCHED = lib.mkForce (option no);
          SCHED_AUTOGROUP = lib.mkForce (option no);

          # AMD P-state driver
          X86_AMD_PSTATE = yes;

          # Linux RNG framework
          LRNG = yes;

          # Paragon's NTFS3 driver
          NTFS3_FS = module;
          NTFS3_LZX_XPRESS = yes;
          NTFS3_FS_POSIX_ACL = yes;

          # Preemptive Full Tickless Kernel at 500Hz
          SCHED_CORE = lib.mkForce (option no);
          PREEMPT_VOLUNTARY = lib.mkForce no;
          PREEMPT = lib.mkForce yes;
          NO_HZ_FULL = yes;
          HZ_500 = yes;

          # Google's BBRv2 TCP congestion Control
          TCP_CONG_BBR2 = yes;
          DEFAULT_BBR2 = yes;

          # FQ-PIE Packet Scheduling
          NET_SCH_DEFAULT = yes;
          DEFAULT_FQ_PIE = yes;

          # Graysky's additional CPU optimizations
          CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;

          # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
          FUTEX = yes;
          FUTEX_PI = yes;

          # WineSync driver for fast kernel-backed Wine
          WINESYNC = module;
        };
      }
      {
        name = "microsoft-surface-patches-linux-5.16.2";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          #
          # Surface Aggregator Module
          #
          SURFACE_AGGREGATOR = module;
          SURFACE_AGGREGATOR_ERROR_INJECTION = no;
          SURFACE_AGGREGATOR_BUS = yes;
          SURFACE_AGGREGATOR_CDEV = module;
          SURFACE_AGGREGATOR_REGISTRY = module;

          SURFACE_ACPI_NOTIFY = module;
          SURFACE_DTX = module;
          SURFACE_PLATFORM_PROFILE = module;

          SURFACE_HID = module;
          SURFACE_KBD = module;

          BATTERY_SURFACE = module;
          CHARGER_SURFACE = module;

          #
          # Surface laptop 1 keyboard
          #
          SERIAL_DEV_BUS = yes;
          SERIAL_DEV_CTRL_TTYPORT = yes;

          #
          # Surface Hotplug
          #
          SURFACE_HOTPLUG = module;

          #
          # IPTS touchscreen
          #
          # This only enables the user interface for IPTS data.
          # For the touchscreen to work, you need to install iptsd.
          #
          MISC_IPTS = module;

          #
          # Cameras: IPU3
          #
          VIDEO_IPU3_IMGU = module;
          VIDEO_IPU3_CIO2 = module;
          CIO2_BRIDGE = yes;
          INTEL_SKL_INT3472 = module;

          #
          # Cameras: Sensor drivers
          #
          VIDEO_OV5693 = module;
          VIDEO_OV8865 = module;

          #
          # ALS Sensor for Surface Book 3, Surface Laptop 3, Surface Pro 7
          #
          APDS9960 = module;

          #
          # Other Drivers
          #
          INPUT_SOC_BUTTON_ARRAY = module;
          SURFACE_3_BUTTON = module;
          SURFACE_3_POWER_OPREGION = module;
          SURFACE_PRO3_BUTTON = module;
          SURFACE_GPE = module;
          SURFACE_BOOK1_DGPU_SWITCH = module;
        };
      }];
    } // (args.argsOverride or {}));
in lib.recurseIntoAttrs (linuxPackagesFor (callPackage linuxPkg {}))
