class Qlever < Formula
  desc "High-performance graph database implementing the RDF and SPARQL standards"
  homepage "https://github.com/ad-freiburg/qlever"
  version "0.5.45"
  license "Apache-2.0"
  
  url "https://packages.qlever.dev/mac/qlever_0.5.45_macos_arm64.tar.gz"
  sha256 "cd88971f01188cc5ef954687ea4bc6838f52385046ec1de52d5051eb96311064"

  head do
    url "https://github.com/ad-freiburg/qlever.git", branch: "master"
    depends_on "cmake" => :build
    depends_on "ninja" => :build
    depends_on "pkg-config" => :build
    depends_on "zstd"
  end

  depends_on "boost"
  depends_on "icu4c"
  depends_on "jemalloc"
  depends_on "openssl@3"
  depends_on "qlever-control"
  depends_on :macos

  def install
    if build.head?
      args = [
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0",
        "-DLOGLEVEL=INFO",
        "-DUSE_PARALLEL=false",
        "-D_NO_TIMING_TESTS=ON",
        "-DCOMPILER_SUPPORTS_MARCH_NATIVE=FALSE",
        "-DICU_ROOT=#{Formula["icu4c"].opt_prefix}",
        "-GNinja",
      ]
      system "cmake", "-S", ".", "-B", "build", *args
      system "cmake", "--build", "build", "--config", "Release", "-j", Hardware::CPU.cores.to_s
      bin.install "build/qlever-index"
      bin.install "build/qlever-server"
    else
      bin.install "qlever-index"
      bin.install "qlever-server"
    end
  end

  def caveats
    <<~EOS
      QLever binaries have been installed:
        - qlever-index: for loading and indexing data
        - qlever-server: start a SPARQL endpoint and query data
        - qlever: CLI tool for controlling (almost) everything QLever can do

      For more information: https://github.com/ad-freiburg/qlever-control
    EOS
  end

  test do
    if build.stable?
      assert_match version.to_s, shell_output("#{bin}/qlever-index --version")
      assert_match version.to_s, shell_output("#{bin}/qlever-server --version")
    else
      assert_match "QLever", shell_output("#{bin}/qlever-index --version")
      assert_match "QLever", shell_output("#{bin}/qlever-server --version")
    end
  end
end
