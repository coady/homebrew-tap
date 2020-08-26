class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-8.3.0-src.tar.gz"
  sha256 "2d135f4f412673ed580a00a1191dcaf5f179f4c2bb563c91359e1c9cccaa5224"
  head do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/8.6.1-rc1/pylucene-8.6.1-src.tar.gz"
    sha256 "194f2238912973c8cf78957da8643cc2ec0e5a03c49237abfd35ecedd70107e6"
  end

  depends_on "ant" => :build
  depends_on :java => "1.8+"
  depends_on "python" => :recommended
  depends_on "python@3.7" => :optional

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home)
    ENV["NO_SHARED"] = "1"
    ENV.deparallelize  # the jars must be built serially
    version = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
    cd "jcc" do
      system "python3", *Language::Python.setup_install_args(prefix)
    end
    system "make", "all", "install",
      "ANT=ant",
      "PYTHON=python#{version}",
      "JCC=python#{version} -m jcc",
      "NUM_FILES=8",
      "INSTALL_OPT=--prefix #{prefix}"
  end

  test do
    system "python3", "-c", "import lucene; assert lucene.initVM()"
  end
end
