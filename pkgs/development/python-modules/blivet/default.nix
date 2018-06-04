{ stdenv, fetchFromGitHub, pythonPackages 
, libselinux, cryptsetup
, lsof
, multipath-tools
, utillinux
, enum
}:

let
  cryptsetupWithPython = cryptsetup.override { enablePython = true; };
in pythonPackages.buildPythonPackage rec {
  pname = "blivet";
  name = "${pname}-${version}";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "blivet";
    rev = name;
    sha256 = "182kkh4fnja109vx6bgwgrgg3qsajhkw2bl1kji84ni0agqll5q5";
  };

  postPatch = ''
  #  sed -i \
  #    -e 's|"multipath"|"${multipath-tools}/sbin/multipath"|' \
  #    -e '/^def set_friendly_names/a \    return False' \
  #    blivet/devicelibs/mpath.py
  #  sed -i -e '/"wipefs"/ {
  #    s|wipefs|${utillinux}/sbin/wipefs|
  #    s/-f/--force/
  #  }' blivet/formats/__init__.py
  #  sed -i -e 's|"lsof"|"${lsof}/bin/lsof"|' blivet/formats/fs.py
  #  sed -i -r -e 's|"(u?mount)"|"${utillinux}/bin/\1"|' blivet/util.py
  '';

  propagatedBuildInputs = with pythonPackages; [
    six
    pyudev
    pyparted
    libselinux
    pygobject3
    dbus-python
    enum
# unclear, test these
   # pykickstart
    pyblock
    cryptsetupWithPython
    # parted
    # python-blockdev
    # libblockdev
    # python-bytesize
    # python-hawkey
  ];

  # Cannot test in sanbox, need a VM. Tests are in nixos/tests/blivet.nix.
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/storaged-project/blivet;
    description = "A python module for system storage configuration";
    license = with licenses; [ gpl2Plus lgpl21Plus ];
    platforms = platforms.linux;
  };
}
