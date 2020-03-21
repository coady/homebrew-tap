class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-8.1.1-src.tar.gz"
  sha256 "f8fa67b897539e3a105de964ead935fb09b4334cd237d6fe5c65b987e7f1703f"
  devel do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/8.3.0-rc1/pylucene-8.3.0-src.tar.gz"
    sha256 "2d135f4f412673ed580a00a1191dcaf5f179f4c2bb563c91359e1c9cccaa5224"
  end

  option "without-python", "Build without python support"
  option "with-python@3.8", "Build with python@3.8 support"

  depends_on "ant" => :build
  depends_on :java => "1.8+"
  depends_on "python" => :recommended
  depends_on "python@3.8" => :optional

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home)
    ENV["NO_SHARED"] = "1"
    ENV.deparallelize  # the jars must be built serially
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      cd "jcc" do
        system python, *Language::Python.setup_install_args(prefix)
      end
      system "make", "all", "install",
        "ANT=ant",
        "PYTHON=python#{version}",
        "JCC=python#{version} -m jcc",
        "NUM_FILES=8",
        "INSTALL_OPT=--prefix #{prefix}"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import lucene; assert lucene.initVM()"
    end
  end
end
