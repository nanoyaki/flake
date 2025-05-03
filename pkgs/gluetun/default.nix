{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gluetun";
  version = "3.40.0";

  src = fetchFromGitHub {
    owner = "qdm12";
    repo = "gluetun";
    rev = "v${version}";
    hash = "sha256-CiA+vCKsjMx+LHVYzHh8x+RFY1rrkkZw5/XU/20it2A=";
  };

  patches = [ ./home.patch ];

  vendorHash = "sha256-T4WcdofzVr2LiUQaOtJbtRO3/6obCvT+hNQMQjUEHzk=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=${version}"
  ];

  meta = {
    description = "Lightweight swiss-army-knife-like VPN client to multiple VPN service providers";
    homepage = "https://github.com/qdm12/gluetun";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "gluetun";
  };
}
