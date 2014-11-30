require "formula"

class EnigmaGame < Formula
  homepage ""
  url "http://downloads.sourceforge.net/project/enigma-game/Release%201.21-alpha/enigma-1.21-alpha.tar.gz"
  sha1 "449f47971cf78e8165de1b3c582ee15426e35172"

  option "make-preview", "Generate and cache the level previews (slow)"
  option "make-gmo", "Generate the gmo files (default for --HEAD)"

  head do
    url "http://svn.code.sf.net/p/enigma-game/source/trunk"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    patch :p0, :DATA
  end

  depends_on "pkg-config" => :build
  depends_on "sdl" => :build
  depends_on "sdl_image" => :build
  depends_on "sdl_mixer" => :build
  depends_on "sdl_ttf" => :build
  depends_on "gettext" => :build
  depends_on "freetype" => :build
  depends_on "xerces-c" => :build
  depends_on "libjpeg"
  depends_on "libpng" => :build
  depends_on "imagemagick" => :build
  depends_on "osxutils" => :build
  depends_on "texi2html" => :build

  def install
    ENV.deparallelize
    # Also add gettext include so that libintl.h can be found when installing packages.
    ENV.append "CPPFLAGS", "-I#{Formula["gettext"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["gettext"].opt_lib}"
    # Also add gettext binaries to PATH as they are used by the build
    ENV.prepend_path "PATH", "#{Formula["gettext"].opt_bin}"
    # and libpng, which is keg-only in MacOS before Mountain Lion
    ENV.append "CPPFLAGS", "-I#{Formula["libpng"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["libpng"].opt_lib}"
    if build.head?
      system "./autogen.sh"
    end
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
      			  "--with-libintl-prefix=#{Formula['gettext'].opt_prefix}",
                          "--prefix=#{prefix}"
    if build.head? or build.include? "make-gmo"
      system "make", "gmo"
    end
    system "make"
    system "make", "macapp"
    if build.head? or build.include? "make-preview"
      system "etc/macfiles/Enigma.app/Contents/MacOS//enigma", "--makepreview"
    end
    system "make", "macdmg"
    share.install "etc/enigma.dmg"
  end

  test do
    system "hdiutil detach -quiet /Volumes/Enigma || true"
    system "hdiutil attach -quiet /usr/local/share/enigma.dmg"
    system "/Volumes/Enigma/Enigma.app/Contents/MacOS/enigma --version"
    system "hdiutil detach -quiet /Volumes/Enigma"
  end
end
__END__
Index: Makefile.am
===================================================================
--- Makefile.am	(revision 2487)
+++ Makefile.am	(working copy)
@@ -29,8 +29,12 @@
 
 .PHONY: macapp
 macapp:
-	cd src && $(MAKE) $(AM_MAKEFLAGS) bundle && $(MAKE) $(AM_MAKEFLAGS) bundle-fw && $(MAKE) $(AM_MAKEFLAGS) bundle-doc && $(MAKE) $(AM_MAKEFLAGS) bundle-dmg
+	cd src && $(MAKE) $(AM_MAKEFLAGS) bundle && $(MAKE) $(AM_MAKEFLAGS) bundle-fw && $(MAKE) $(AM_MAKEFLAGS) bundle-doc
 
+.PHONY: macdmg
+macdmg:
+	cd src && $(MAKE) $(AM_MAKEFLAGS) bundle-dmg
+
 .PHONY: pdf
 pdf:
 	cd doc/manual/images && $(MAKE) pdf
