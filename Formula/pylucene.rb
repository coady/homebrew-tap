class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/7.4.0-rc1/pylucene-7.4.0-src.tar.gz"
  sha256 "bf02da82d9bc4a578b33871699aff1125020266f2299f2d6d6008edaf48591ca"

  option "with-shared", "build jcc as a shared library"

  depends_on "ant" => :build
  depends_on java: "1.8+"
  depends_on "python"

  def install
    ENV.prepend_create_path "PYTHONPATH", lib/"python3.7/site-packages"
    jcc = "JCC=python3 -m jcc --arch #{MacOS.preferred_arch}"
    if build.with? "shared"
      jcc << " --shared"
      opoo "shared option requires python to be built with the same compiler: #{ENV.compiler}"
    else
      ENV["NO_SHARED"] = "1"
    end

    cd "jcc" do
      system "python3", "setup.py", "install", "--prefix=#{prefix}"
    end
    ENV.deparallelize  # the jars must be built serially
    system "make", "all", "install", "INSTALL_OPT=--prefix #{prefix}", jcc, "ANT=ant", "PYTHON=python3", "NUM_FILES=8"
  end

  test do
    ENV.prepend_path "PYTHONPATH", HOMEBREW_PREFIX/"lib/python3.7/site-packages"
    system "python3", "-c", "import lucene; assert lucene.initVM()"
  end
end
