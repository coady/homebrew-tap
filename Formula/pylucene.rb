class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-8.9.0-src.tar.gz"
  sha256 "bb13ac205bf75ff191b649e30ed480ec7723cc8a2114106eb6963c28ad5bf8fa"
  head do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/8.11.0-rc2/pylucene-8.11.0-src.tar.gz"
    sha256 "70894afe0a1d48efa404adb2a4d6f6f951d9f3d193027e649c536bbf1b9304aa"
  end

  depends_on "ant" => :build
  depends_on "openjdk"
  depends_on "python" => :recommended
  depends_on "python@3.10" => :optional

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
      "NUM_FILES=10",
      "INSTALL_OPT=--prefix #{prefix}"
  end

  test do
    system "python3", "-c", "import lucene; assert lucene.initVM()"
  end
end
