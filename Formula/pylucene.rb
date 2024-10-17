class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-9.12.0-src.tar.gz"
  sha256 "5d7223e87883e64ec0cd3e62a983a4bf50dce68c997081c8989e233b90cee115"
  head do
    url "https://dist.apache.org/repos/dist/dev/lucene/pylucene/10.0.0-rc1/pylucene-10.0.0-src.tar.gz"
    sha256 "100c3d61d6799ac16b7b8c1826cddf07fb1715141ebdb0d7b8119cdd96b24574"
  end

  depends_on "python"

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home)
    ENV["NO_SHARED"] = "1"
    ENV.deparallelize  # the jars must be built serially
    version = Language::Python.major_minor_version "python"
    packages = lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", packages
    cd "jcc" do
      system "pip install --prefix #{prefix} build setuptools"
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
