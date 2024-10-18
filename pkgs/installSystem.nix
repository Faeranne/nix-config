{
  python312Packages,
  age,
  age-plugin-yubikey,
  dialog
}: python312Packages.buildPythonApplication rec {
  pname = "installSystem";
  version = "0.1.0";
  format = "other";
  propagatedBuildInputs = (with python312Packages; [
    diskinfo
    pythondialog
    pyparted
    requests
    netifaces
  ]) ++ [
    age
    age-plugin-yubikey
    dialog
  ];
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${./${pname}.py} $out/bin/${pname}
  '';
}
