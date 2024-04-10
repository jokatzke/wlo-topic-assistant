{
  mkShell,
  python3,
  wlo-topic-assistant,
  pyright,
  nix-init,
  nix-template,
  nix-tree,
}:
mkShell {
  packages = [
    (python3.withPackages (
      py-pkgs:
      with py-pkgs;
      [
        ipython
        jupyter
        black
        isort
        mypy
      ]
      ++ wlo-topic-assistant.propagatedBuildInputs
    ))
    pyright
    nix-init
    nix-template
    nix-tree
  ];
}
