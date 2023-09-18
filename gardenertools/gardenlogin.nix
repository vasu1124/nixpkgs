{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "gardenlogin";
  version = "0.4.0";
  binary = "gardenlogin";
  release = with lib; with stdenv.targetPlatform;
           "gardenlogin_" +
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
      sha256 = optionalString isDarwin  (optionalString isx86_64  "sha256:0v5rjx9d8zp3y3cd13786lwc0y1nvgcyb7fmgdz8w7y9cs63ki8m") +
               optionalString isLinux   (optionalString isx86_64  "sha256:0q4cs1riii19283cp8z0lxp971km8nhsk1srnnqgb8xbczc2x9p1") +
               optionalString isWindows (optionalString isx86_64  "sha256:0lgj262iaf2iqldnka1ppdwyc5nn5cnn2f057hwa7mv43za7izya") +
               optionalString isDarwin  (optionalString isAarch64 "sha256:0cbd45dm5lyrcf2gv6vawkj2309zi7jz0ajaff0hvc7a1gi6cn8v");
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
        gardenlogin is a kubectl credential plugin for Gardener shoot cluster authentication.
      '';
      homepage = "https://github.com/gardener/gardenlogin";
      license = licenses.asl20;
      platforms = with platforms; linux ++ darwin ++ windows;
      maintainers = with maintainers; [ vasu1124 ];
    };
  }



