{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "gardenctl-v2";
  version = "2.5.0";
  binary = "gardenctl";
  release = with lib; with stdenv.targetPlatform;
           "gardenctl_v2_" +
           optionalString isWindows "windows" +
           optionalString isLinux "linux" +
           optionalString isDarwin "darwin" +
           "_" + 
           optionalString isx86_64 "amd64" +
           optionalString isAarch64 "arm64" +
           optionalString isWindows ".exe";
in stdenv.mkDerivation {
    name = "${binary}-${version}";
    version = "${version}";
    dontUnpack = true;
    sourceRoot = ".";
    
    src = with lib; with stdenv.targetPlatform; builtins.fetchurl {
      url = "https://github.com/gardener/${name}/releases/download/v${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = optionalString isDarwin  (optionalString isx86_64  "sha256:0nixv4lmfsvpaldxzg87225z9vcaijzkzr931564p4ijgx428zrm") +
               optionalString isLinux   (optionalString isx86_64  "sha256:1i9rd795n81kj7hrfqs22p4k2wziyabzj87nch7iy0gsws3fwxcj") +
               optionalString isWindows (optionalString isx86_64  "sha256:1nv91i8457mazl35cd1z3nf45zd1s81s1gixka2c1zi76pjg9j41") +
               optionalString isDarwin  (optionalString isAarch64 "sha256:1q2bnv1gniaj6psp33ck1xrrv9kr3qhhw98c22c35id2kfg2asha");

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
      $out/bin/${binary} completion bash > ${binary}.bash 2>/dev/null
      $out/bin/${binary} completion zsh > ${binary}.zsh 2>/dev/null
      installShellCompletion ${binary}.{bash,zsh}
    '';

    meta = with lib; {
      description = ''
        gardenctl is a command-line client for the Gardener.
        It facilitates the administration of one or many garden, seed and shoot clusters.
        Use this tool to configure access to clusters and configure cloud provider CLI tools.
        It also provides support for accessing cluster nodes via ssh.
      '';
      homepage = "https://github.com/gardener/gardenctl-v2";
      license = licenses.asl20;
      platforms = with platforms; linux ++ darwin ++ windows;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }
