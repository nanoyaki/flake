{
  osu-lazer-bin,
  appimageTools,

  _sources,
}:

osu-lazer-bin.override {
  appimageTools = appimageTools // {
    wrapType2 =
      args: appimageTools.wrapType2 (args // { inherit (_sources.osu-lazer-bin) version src; });
  };
}
