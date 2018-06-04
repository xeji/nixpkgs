{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, file, python3, gettext
, gtk-doc, libxslt, docbook_xsl
, mpfr, pcre }:

stdenv.mkDerivation rec {
  name = "libbytesize-${version}";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "libbytesize";
    rev = version;
    sha256 = "1ys5d8rya8x4q34gn1hr96z7797s9gdzah0y0d7g84x5x6k50p30";
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [ autoreconfHook file pkgconfig python3 gettext gtk-doc libxslt docbook_xsl ];
  buildInputs = [ mpfr pcre ]; 

  # for python bindings
  propagatedBuildImports = with python3.pkgs; [ six ];

  preConfigure = ''
    sed -i "s:/usr/bin/file:${file}/bin/file:g" configure
  '';

  meta = with stdenv.lib; {
    homepage = src.meta.homepage;
    description = "A C library for reading, creating and modifying zip archives";
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ xeji ];
  };
}
