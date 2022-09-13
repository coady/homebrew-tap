class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-9.1.0-src.tar.gz"
  sha256 "e8552f3577d4d03dbf417428ac24aa17cae984b2d42790f2c6db18133db0710f"

  depends_on "openjdk"
  depends_on "python" => :recommended
  depends_on "python@3.9" => :optional

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
      "PYTHON=python#{version}",
      "JCC=python#{version} -m jcc",
      "NUM_FILES=16",
      "INSTALL_OPT=--prefix #{prefix}"
  end

  test do
    system "python3", "-c", "import lucene; assert lucene.initVM()"
  end
end
