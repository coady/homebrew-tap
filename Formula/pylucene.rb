class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-9.10.0-src.tar.gz"
  sha256 "f41807c145cf57c8cc90134faa7e990d95c8a41f53d4b7478acec79bef64ece1"

  depends_on "python"

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home)
    ENV["NO_SHARED"] = "1"
    ENV.deparallelize  # the jars must be built serially
    version = Language::Python.major_minor_version "python"
    packages = lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", packages
    cd "jcc" do
      system "pip install --prefix #{prefix} build"
      system "python -m build -nw"
      system "pip install --prefix #{prefix} dist/JCC-*.whl"
    end
    system "make", "all", "install",
      "PYTHON=python",
      "JCC=python -m jcc",
      "NUM_FILES=16",
      "INSTALL_OPT=--prefix #{prefix} --install-dir #{packages}"
      "MODERN_PACKAGING=true"
  end

  test do
    system "python", "-c", "import lucene; assert lucene.initVM()"
  end
end
