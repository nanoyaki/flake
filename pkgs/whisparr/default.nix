{
  whisparr,
  fetchurl,
}:

whisparr.overrideAttrs rec {
  version = "3.0.0.1038";
  src = fetchurl {
    name = "whisparr-x64-linux-${version}.tar.gz";
    url = "https://whisparr.servarr.com/v1/update/eros/updatefile?version=${version}&os=linux&runtime=netcore&arch=x64";
    sha256 = "sha256-Mn3Gbgh3xni9JsM5dvKerTJAJv6sOot32826Ku5CbO4=";
  };
}
