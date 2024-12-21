{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
	pname = "thecus_it87";
	version = "1.0-93";

	src = fetchFromGitHub {
		owner = "system1357";
		repo = "Thecus_tools";
		rev = "f269d4fc9b30a0ab66541e3e3b3aa283ef713b3c";
		sha256 = "sha256-N+kEeaphmdVCs9NKq2HwkEInnKMgvfWpe4PIlzKxI2Y=";
	};

	setSourceRoot = ''
		export sourceRoot=$(pwd)/${src.name}/thecus_it87
	'';

	nativeBuildInputs = kernel.moduleBuildDependencies;

	makeFlags = kernel.makeFlags ++ [
		"-C"
		"${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
		"M=$(sourceRoot)"
	];

	buildFlags = [ "modules" ];
	installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
	installTargets = [ "modules_install" ];

	meta = with lib; {
		description = "thecus patched it8616 module";
		homepage = "https://github.com/system1357/Thecus_tools";
		platforms = platforms.linux;
	};
}
