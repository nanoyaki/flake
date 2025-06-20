# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  lidarr = {
    pname = "lidarr";
    version = "2.13.0.4664";
    src = fetchurl {
      url = "https://lidarr.servarr.com/v1/update/develop/updatefile?version=2.13.0.4664&os=linux&runtime=netcore&arch=x64";
      name = "lidarr-src-2.13.0.4664.tar.gz";
      sha256 = "sha256-ODIPtlpzZcZWZxTBXt5r5xpJ4ZWbpGnJ2Na7QVEvrlw=";
    };
  };
  midnight-theme = {
    pname = "midnight-theme";
    version = "dd66b6554edb71457d28e896c521b16844e909c7";
    src = fetchgit {
      url = "https://github.com/refact0r/midnight-discord.git";
      rev = "dd66b6554edb71457d28e896c521b16844e909c7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-r1WFJHxyBQfqlHZML8zxzHS/tmn2sY6Jzg4TD1YRWrI=";
    };
    date = "2025-06-10";
  };
  openrgb = {
    pname = "openrgb";
    version = "6793d4a3a0b8b6b785d4b85b8af0acd7fdea76e9";
    src = fetchgit {
      url = "https://gitlab.com/CalcProgrammer1/OpenRGB.git";
      rev = "6793d4a3a0b8b6b785d4b85b8af0acd7fdea76e9";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-5crtFhMAJnYqHsKi2t9GYIM0eIZ+deWpZMyKLMY/k3E=";
    };
    date = "2025-06-04";
  };
  osu-lazer-bin = {
    pname = "osu-lazer-bin";
    version = "2025.607.1";
    src = fetchurl {
      url = "https://github.com/ppy/osu/releases/download/2025.607.1/osu.AppImage";
      sha256 = "sha256-xLniL2fogWFAaEADvX2YL7lRGHGew7kc3Ni1fhPzs1c=";
    };
  };
  prowlarr = {
    pname = "prowlarr";
    version = "2.0.0.5094";
    src = fetchurl {
      url = "https://prowlarr.servarr.com/v1/update/develop/updatefile?version=2.0.0.5094&os=linux&runtime=netcore&arch=x64";
      name = "prowlarr-src-2.0.0.5094.tar.gz";
      sha256 = "sha256-JiKCR4OEzJCcOeTg05DtC4EddkDu+nDHvhz+lMFrumk=";
    };
  };
  radarr = {
    pname = "radarr";
    version = "5.27.0.10101";
    src = fetchurl {
      url = "https://radarr.servarr.com/v1/update/develop/updatefile?version=5.27.0.10101&os=linux&runtime=netcore&arch=x64";
      name = "radarr-src-5.27.0.10101.tar.gz";
      sha256 = "sha256-EzY5IENQtwHqRb/blpIc72F6+KF7tQhaTqlzxrXsevw=";
    };
  };
  rofi-themes = {
    pname = "rofi-themes";
    version = "fb7011ec48bd065f398f2ff26d76e301aff1dc22";
    src = fetchgit {
      url = "https://github.com/adi1090x/rofi.git";
      rev = "fb7011ec48bd065f398f2ff26d76e301aff1dc22";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-wwLcb7z5jCKgKPY5mNhYIoPvKbVO3PwULrJ+Lm3Ra7g=";
    };
    date = "2025-06-09";
  };
  shoko = {
    pname = "shoko";
    version = "5.1.0-dev.92";
    src = fetchTarball {
      url = "https://github.com/ShokoAnime/ShokoServer/archive/refs/tags/v5.1.0-dev.92.tar.gz";
      sha256 = "sha256-6i8Xyz/tv0DCtjbyiAa73WNgPO9j9v4kNKEs68mKxYQ=";
    };
  };
  shoko-webui = {
    pname = "shoko-webui";
    version = "2.3.0-dev.2";
    src = fetchTarball {
      url = "https://github.com/ShokoAnime/Shoko-WebUI/archive/refs/tags/v2.3.0-dev.2.tar.gz";
      sha256 = "sha256-x34o8sFNHkUhoD1SzCkTGJvFmA5IclFMk3H7vrlBtn0=";
    };
  };
  shokofin = {
    pname = "shokofin";
    version = "5.0.3-dev.10";
    src = fetchTarball {
      url = "https://github.com/ShokoAnime/Shokofin/archive/refs/tags/v5.0.3-dev.10.tar.gz";
      sha256 = "sha256-eujJvjPf3qFrqJ6BBmX6RwT2hqevttKDq9JPfF4i/Ec=";
    };
  };
  suwayomi-server = {
    pname = "suwayomi-server";
    version = "0b021e6c42024d15a9311fd70861b79f18339cf2";
    src = fetchgit {
      url = "https://github.com/Suwayomi/Suwayomi-Server.git";
      rev = "0b021e6c42024d15a9311fd70861b79f18339cf2";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-ZkSE16Epb9innZUGeip56MMS8FrRCgnKif/H95cCCus=";
    };
    date = "2025-06-20";
  };
  suwayomi-webui = {
    pname = "suwayomi-webui";
    version = "781d89a75aad8e1aa4d4b4568d52c8e05b3e4e2f";
    src = fetchgit {
      url = "https://github.com/Suwayomi/Suwayomi-WebUI.git";
      rev = "781d89a75aad8e1aa4d4b4568d52c8e05b3e4e2f";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sparseCheckout = [ ];
      sha256 = "sha256-y/9R+gcmxvCoxRldA2LXFKWtPKBfiClmq3V9323bkMY=";
    };
    date = "2025-06-10";
  };
  whisparr = {
    pname = "whisparr";
    version = "3.0.0.1134";
    src = fetchurl {
      url = "https://whisparr.servarr.com/v1/update/eros/updatefile?version=3.0.0.1134&os=linux&runtime=netcore&arch=x64";
      name = "whisparr-src-3.0.0.1134.tar.gz";
      sha256 = "sha256-bkAmxTIMaGr8G+kHhmgLpOKKzmlDay5+OzKbwCj5ZX4=";
    };
  };
}
