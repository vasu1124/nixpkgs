{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "kubeswitch";
  version = "0.7.1";
  binary = "switcher";
  release = with lib; with stdenv.targetPlatform;
           "switcher_" +
           optionalString isDarwin "darwin" +
           optionalString isLinux "linux" +
           "_" + 
           optionalString isAarch64 "arm64" +
           optionalString isx86_64 "amd64";      
in stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    dontUnpack = true;
    
    src = with lib; with stdenv.targetPlatform; builtins.fetchurl {
      url = "https://github.com/danielfoehrKn/${name}/releases/download/${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = optionalString isDarwin (optionalString isx86_64  "sha256:0c46bbra0yc3hcgsff1sygk4f6flcahlhs4875dr5fgrp9ibwylv") +
               optionalString isLinux  (optionalString isx86_64  "sha256:0i6cif6sym00a383ybbxd26jpg9qfhvf4n3n4pq29zv5211600hf") +
               optionalString isDarwin (optionalString isAarch64 "sha256:0c29hi2vv59jwgblzgrshbkqnwfm6hpd74i428k8g85h2sni7j3f");
    };
    src2 = builtins.fetchurl {
      url = "https://github.com/danielfoehrKn/${name}/releases/download/${version}/switch.sh";
      sha256 = "sha256-vghp8RuI9pSiQDDrwPSU7JkecEYCi0jhGn1x/2YjX/4=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp $src $out/bin/${binary}
      chmod a+x $out/bin/${binary}

      runHook postInstall
    '';

    nativeBuildInputs = [ installShellFiles ];
    postInstall = ''
      installShellCompletion --bash $src2
    '';

    meta = with lib; {
      description = ''
        kubeswitch (lazy: switch) is the single pane of glass for all of your kubeconfig files.
        Caters to operators of large scale Kubernetes installations.
        Designed as a drop-in replacement for kubectx.
        Steroids for your Kubernetes terminal.
      '';
      homepage = "https://github.com/danielfoehrKn/kubeswitch";
      license = licenses.asl20;
      platforms = with platforms; linux ++ darwin;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }
