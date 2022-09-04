{ stdenv, lib, fetchurl, installShellFiles }:
let
  name = "gardenlogin";
  version = "0.3.0";
  binary = "gardenlogin";
  release = with lib; with stdenv.targetPlatform;
           "gardenlogin_" +
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
      sha256 = "sha256-FcU5jGbJH45+e9Wd5dnbNnjAODXojNDY8ON+1FKXuWw=";
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
        gardenlogin is a kubectl credential plugin for Gardener shoot cluster authentication.
      '';
      homepage = "https://github.com/gardener/gardenlogin";
      license = licenses.asl20;
      platforms = with platforms; linux ++ darwin ++ windows;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }



