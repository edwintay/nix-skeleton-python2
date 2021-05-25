{
  sources ? import ./nix/sources.nix
}:

let
  pkgs = import sources.nixpkgs { };

  # build time dependencies like pip and linters
  python2-env = pkgs.python2.buildEnv.override {
    extraLibs = with pkgs.python2.pkgs; [
      # package
      pip
      setuptools
    ];

    # python2 packages don't honor PEP420 and might have modules with
    #__init__.py that collide
    ignoreCollisions = true;
  };
  # run time dependencies will be in ./requirements.txt
in

pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.bashInteractive

    python2-env
  ];

  shellHook = ''
    unset PIP_REQUIRE_VIRTUALENV

    export PIP_PREFIX=$PWD/pip
    export PYTHONPATH="$PIP_PREFIX/lib/python2.7/site-packages''${PYTHONPATH:+:$PYTHONPATH}"
    export PATH="$PIP_PREFIX/bin''${PATH:+:$PATH}"

    # nix clobbers this for reproducible builds but pip requires this to be
    # later than 1980
    unset SOURCE_DATE_EPOCH
  '';
}
