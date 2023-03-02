{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, buildGoModule ? pkgs.buildGoModule, fetchFromGitHub ? pkgs.fetchFromGitHub }:

buildGoModule rec {
  pname = "open-component-model";
  version = "0.2.0-rc.1";
  rev = "v0.2.0-rc.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = "ocm";
    rev = "${rev}";
    sha256 = "sha256-xVadHGagPKlJHfLkFwQIsNHP3m4+mnB5N/LVSomre4A=";
  };
  
  vendorSha256 = "sha256-0UpV1ktqy/o5C3NDDrF2n2rocxBlsCGgjHlrtoyWUxM=";

  CGO_ENABLED = 0;

  subPackages = [ "cmds/ocm" "cmds/demoplugin" "cmds/helminstaller" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/open-component-model/ocm/pkg/version.gitVersion=${version}"
  ];

  meta = with lib; {
    description =
      "CLI for interacting with Open-Component-Model";
    homepage = "https://ocm.software";
    license = licenses.asl20;
    maintainers = with maintainers; [ vasu1124 ];
    mainProgram = "ocm";
  };
}
