class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://www.apache.org/dist/lucene/pylucene/pylucene-7.4.0-src.tar.gz"
  sha256 "bf02da82d9bc4a578b33871699aff1125020266f2299f2d6d6008edaf48591ca"

  option "with-shared", "build jcc as a shared library"
  option "without-python", "Build without python3 support"
  option "with-python@2", "Build with python2 support"

  depends_on "ant" => :build
  depends_on java: "1.8+"
  depends_on "python" => :recommended
  depends_on "python@2" => :optional

  def install
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      jcc = "JCC=python#{version} -m jcc --arch #{MacOS.preferred_arch}"
      if build.with? "shared"
        jcc << " --shared"
        opoo "shared option requires python to be built with the same compiler: #{ENV.compiler}"
      else
        ENV["NO_SHARED"] = "1"
      end

      cd "jcc" do
        system python, *Language::Python.setup_install_args(prefix)
      end
      ENV.deparallelize  # the jars must be built serially
      system "make", "all", "install", "INSTALL_OPT=--prefix #{prefix}", jcc, "ANT=ant", "PYTHON=python#{version}", "NUM_FILES=8"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_path "PYTHONPATH", HOMEBREW_PREFIX/"lib/python#{version}/site-packages"
      system python, "-c", "import lucene; assert lucene.initVM()"
    end
  end
end
