{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "kubeswitch";
  version = "0.7.1";
  binary = "switcher";
  release = with lib; with stdenv.targetPlatform;
           "switcher_" +
           optionalString isWindows "windows" +
           optionalString isLinux "linux" +
           optionalString isDarwin "darwin" +
           "_" + 
           optionalString isx86_64 "amd64" +
           optionalString isWindows ".exe";
in stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    dontUnpack = true;
    
    src = builtins.fetchurl {
      url = "https://github.com/danielfoehrKn/${name}/releases/download/${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = "sha256-m3q+Yrr5uZJbOYhoSKFi1BlH5vM6OKcfg4N5oPJahjA=";
      #showURLs = false;
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
      platforms = with platforms; linux ++ darwin ++ windows;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }
