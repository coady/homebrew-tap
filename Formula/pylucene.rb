class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://www.apache.org/dist/lucene/pylucene/pylucene-7.7.1-src.tar.gz"
  sha256 "67f84ad6faba900bb35a6a492453e96ea484249ea9e8576ee71facbd05bade84"
  devel do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/8.1.1-rc1/pylucene-8.1.1-src.tar.gz"
    sha256 "0900cb00aa7a246df9dc8e262b1fda9365182a77647a448aaceaa3900da7f3ad"
  end

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
      system python, "-c", "import lucene; assert lucene.initVM()"
    end
  end
end
