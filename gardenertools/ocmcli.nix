{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "ocm";
  version = "0.4.0";
  binary = "ocm";
  release = with lib; with stdenv.targetPlatform;
           "ocm-" + version + "-" + 
           optionalString isWindows "windows" +
           optionalString isLinux "linux" +
           optionalString isDarwin "darwin" +
           "-" + 
           optionalString isx86_64 "amd64" +
           optionalString isAarch64 "arm64" +
           "." +
           optionalString isWindows "zip" +
           optionalString isLinux   "tar.gz" +
           optionalString isDarwin  "tar.gz";

in stdenv.mkDerivation {
    name = "${binary}-${version}";
    version = "${version}";
    dontUnpack = false;
    sourceRoot = ".";
    
    src = with lib; with stdenv.targetPlatform; builtins.fetchurl {
      url = "https://github.com/open-component-model/${name}/releases/download/v${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = optionalString isDarwin  (optionalString isx86_64  "08ndc1g07d762wbah22z7v351x0hj924yhhf2aja6qdi9jiq1nxa") +
               optionalString isLinux   (optionalString isx86_64  "sha256:1i9rd795n81kj7hrfqs22p4k2wziyabzj87nch7iy0gsws3fwxcj") +
               optionalString isWindows (optionalString isx86_64  "sha256:1nv91i8457mazl35cd1z3nf45zd1s81s1gixka2c1zi76pjg9j41") +
               optionalString isDarwin  (optionalString isAarch64 "sha256:116vmlwail1ic3nk8zixlk79s4swc71ss2z2x3k2f27zdfxp7mr7");

    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp ${binary} $out/bin/${binary}
      chmod a+x $out/bin/${binary}

      runHook postInstall
    '';

    nativeBuildInputs = [ installShellFiles ];
    postInstall = ''
      $out/bin/${binary} completion bash > ${binary}.bash 2>/dev/null
      $out/bin/${binary} completion zsh > ${binary}.zsh 2>/dev/null
      installShellCompletion ${binary}.{bash,zsh}
    '';

    meta = with lib; {
      description = ''
        ocm is a command-line client for the Open Component Model (OCM).
        The OCM provides a standard for describing delivery artifacts
        that can be accessed from many types of component repositories.
      '';
      homepage = "https://github.com/open-component-model/ocm";
      license = licenses.asl20;
      platforms = with platforms; linux ++ darwin ++ windows;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }
  