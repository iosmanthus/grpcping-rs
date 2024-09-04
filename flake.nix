{
  description = "Distributed transactional key-value database, originally created to complement TiDB";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          python = pkgs.python3;
          python-env = python.withPackages (p: with p; [
            redis
          ]);
        in
        {
          devShell = pkgs.mkShell {
            hardeningDisable = [ "all" ];
            nativeBuildInputs = with pkgs;[ cmake pkg-config ];
            buildInputs = with pkgs;[ autoreconfHook redis python-env gcc zsh git gnumake rustup protobuf3_8 perl zlib openssl mold ];
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            PROTOC = "${pkgs.protobuf3_8}/bin/protoc";
            shellHook = ''
              PYTHONPATH=${python-env}/${python-env.sitePackages}
            '';
          };
        }
      );
}
