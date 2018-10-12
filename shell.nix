with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "phoenix";

  buildInputs = [
    elixir
    nodejs-8_x
    inotify-tools
  ];
}
