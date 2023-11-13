class Pylucene < Formula
  desc "Python extension for accessing Java Lucene"
  homepage "https://lucene.apache.org/pylucene/index.html"
  url "https://downloads.apache.org/lucene/pylucene/pylucene-9.7.0-src.tar.gz"
  sha256 "94193d0a5e87d32d6d21fc2a59a76a2e8c8afb5e8e6b24c9f50755ae17a81092"

  depends_on "python@3.12" => :recommended
  depends_on "python" => :optional

  def install
    ENV["JCC_JDK"] = ENV.fetch("HOMEBREW_JDK", Language::Java.java_home)
    ENV["NO_SHARED"] = "1"
    ENV.deparallelize  # the jars must be built serially
    version = Language::Python.major_minor_version "python"
    packages = lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", packages
    cd "jcc" do
      system "python", *Language::Python.setup_install_args(prefix)
    end
    system "make", "all", "install",
      "PYTHON=python#{version}",
      "JCC=python#{version} -m jcc",
      "NUM_FILES=16",
      "INSTALL_OPT=--prefix #{prefix} --install-dir #{packages}"
  end

  test do
    system "python", "-c", "import lucene; assert lucene.initVM()"
  end
end
