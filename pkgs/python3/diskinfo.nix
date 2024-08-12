{ fetchPypi,
  buildPythonPackage,
  setuptools,
  pysmart
}: buildPythonPackage rec {
  pname = "diskinfo";
  version = "3.1.2";

  format = "pyproject";

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    pysmart
  ];

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-P2Cm97ctvwecf4KFQNOAeOl3ql9XiqgKblC1hg/+qqE=";
  };

  pythonImportsCheck = [ "diskinfo" ];
}
