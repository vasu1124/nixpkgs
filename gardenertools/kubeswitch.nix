{ pkgs ? import <nixpkgs> {}, stdenv ? pkgs.stdenv, lib ? pkgs.lib, installShellFiles ? pkgs.installShellFiles }:
let
  name = "kubeswitch";
  version = "0.7.2";
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
    
    switcher = with lib; with stdenv.targetPlatform; builtins.fetchurl {
      url = "https://github.com/danielfoehrKn/${name}/releases/download/${version}/${release}";
      # curlOpts = "-v -O";
      sha256 = optionalString isDarwin (optionalString isx86_64  "sha256:1qw6nmgb8f1n2bbji71wl4gn6k2njsi86y5kv1x43jmj47dms72y") +
               optionalString isLinux  (optionalString isx86_64  "sha256:0w6si9yj37afi0l9rn0nzv7cnvxf0qanvd46yjqshzmxlnd91s14") +
               optionalString isDarwin (optionalString isAarch64 "sha256:1a6l4w43bgcsfagyqghdzymk748h3hrny02cph2yb3jvb93nyy4l");
    };
    switch = builtins.fetchurl {
      url = "https://github.com/danielfoehrKn/${name}/releases/download/${version}/switch.sh";
      sha256 = "sha256:05j1dn10qwgzc21blw51ihv4x4yyk1njx0z1yqxw971jk2zas0cw";
    };
    completion = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/danielfoehrKn/${name}/master/scripts/_switch.bash";
      sha256 = "sha256:1hiigqrh28f7h4yin2vxpr7sdcj3v93ms8ll5zjib1qzsq9mcid4";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp $switcher $out/bin/${binary}
      chmod a+x $out/bin/${binary}
      
      runHook postInstall

      mkdir -p $out/share/bash
      cp $switch $out/share/bash/switch.sh
    '';

    nativeBuildInputs = [ installShellFiles ];
    postInstall = ''
      installShellCompletion --bash $completion
    '';

    shellHook = ''
      # HOW TO USE: append or source this script from your .zshrc file to clean the temporary kubeconfig file
      # set by KUBECONFIG env variable when exiting the shell
      
      trap kubeswitchCleanupHandler EXIT
      
      function kubeswitchCleanupHandler {
       if [ ! -z "$KUBECONFIG" ]
       then
          switchTmpDirectory="$HOME/.kube/.switch_tmp/config"
          if [[ $KUBECONFIG == *"$switchTmpDirectory"* ]]; then
            rm $KUBECONFIG
          fi
       fi
      }
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
