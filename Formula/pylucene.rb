class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://www.apache.org/dist/lucene/pylucene/pylucene-8.1.1-src.tar.gz"
  sha256 "f8fa67b897539e3a105de964ead935fb09b4334cd237d6fe5c65b987e7f1703f"
  devel do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/8.3.0-rc1/pylucene-8.3.0-src.tar.gz"
    sha256 "2d135f4f412673ed580a00a1191dcaf5f179f4c2bb563c91359e1c9cccaa5224"
  end

  option "with-shared", "build jcc as a shared library"
  option "without-python", "Build without python3 support"
  option "with-python@2", "Build with python2 support"

  depends_on "ant" => :build
  depends_on :java => "1.8+"
  depends_on "python" => :recommended
  depends_on "python@2" => :optional

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home) if OS.linux?
    if build.with? "shared"
      opoo "shared option requires python to be built with the same compiler: #{ENV.compiler}"
    else
      ENV["NO_SHARED"] = "1"
    end
    ENV.deparallelize  # the jars must be built serially
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      cd "jcc" do
        system python, *Language::Python.setup_install_args(prefix)
      end
      jcc = "JCC=python#{version} -m jcc"
      jcc << " --shared" if build.with? "shared"
      system "make", "all", "install", "INSTALL_OPT=--prefix #{prefix}", jcc, "ANT=ant", "PYTHON=python#{version}", "NUM_FILES=8"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import lucene; assert lucene.initVM()"
    end
  end
end
