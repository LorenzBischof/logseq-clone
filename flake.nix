{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
            inherit system;
            config = {
                android_sdk.accept_license = true;
                allowUnfree = true;
            };
        };
        uber-apk-signer = pkgs.fetchurl {
          url = "https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar";
          hash = "sha256-4Smf1vz02lJ91Tc1tWEn6OqSKjIRKBI7nDLWGbuh2DU=";
        };

        buildToolsVersion = "30.0.3";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [ buildToolsVersion ];
        };
        zipAlignPath = "${androidComposition.androidsdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/zipalign";
        logseqVersion = "0.10.7";

      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "logseq";
          version = "1.0";
          src = pkgs.fetchurl {
            url = "https://github.com/logseq/logseq/releases/download/${logseqVersion}/Logseq-android-${logseqVersion}.apk";
            hash = "sha256-fORtNB/Mi+r5JHSwmGjO660DBBzWgvU5+o2TcPMILy4=";
          };
          nativeBuildInputs = with pkgs; [apktool openjdk17 perl androidComposition.build-tools];
          unpackPhase = ''
            apktool d $src -o logseq
          '';
          patchPhase = ''
            # Use perl because it supports lookaheads
            # Replace everything except for MainActivity
            perl -i -lape 's/com\.logseq\.app(?!\.MainActivity)/com.logseq.app2/' logseq/AndroidManifest.xml
            # Change the application label
            sed -i 's/@string\/app_name/Logseq2/' logseq/AndroidManifest.xml
            sed -i 's/@string\/title_activity_main/Logseq2/' logseq/AndroidManifest.xml
          '';
          buildPhase = ''
            apktool b logseq -o logseq.apk
            java -jar ${uber-apk-signer} --apks logseq.apk --zipAlignPath ${zipAlignPath} --debug
          '';
          installPhase = ''
            mkdir $out/
            mv logseq.apk $out/Logseq-android-${logseqVersion}-cloned.apk
          '';
        };
      });
  }
