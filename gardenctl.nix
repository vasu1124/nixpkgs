{ stdenv, lib, fetchurl, installShellFiles }:
let
  name = "gardenctl-v2";
  version = "2.1.1";
  binary = "gardenctl";
  release = with lib; with stdenv.targetPlatform;
           "gardenctl_v2_" +
           optionalString isWindows "windows" +
           optionalString isLinux "linux" +
           optionalString isDarwin "darwin" +
           "_" + 
           optionalString isx86_64 "amd64" +
           optionalString isWindows ".exe";
in stdenv.mkDerivation {
    name = "${binary}-${version}";
    version = "${version}";
    dontUnpack = true;
    
    src = fetchurl {
      url = "https://github.com/gardener/${name}/releases/download/v${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = "sha256-gKfz/tDO+VDZyuAq+4wWaIVM6N8ssVD5RVWNR5U8Nn8=";
      #showURLs = false;
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
      $out/bin/${binary} completion bash > ${binary}.bash
      $out/bin/${binary} completion zsh > ${binary}.zsh
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
