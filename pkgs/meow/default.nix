{
  meow,
}:

meow.overrideAttrs {
  patches = [ ./ominous-cats.patch ];
}
