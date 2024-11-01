class Qlever < Formula
  desc "Very fast SPARQL engine for large knowledge graphs with context-sensitive SPARQL autocompletion and text search integration"
  homepage "https://github.com/ad-freiburg/qlever"
  license "Apache-2.0"
  #head "https://github.com/ad-freiburg/qlever.git"
  head "https://github.com/ktk/qlever.git"

  depends_on "cmake" => :build
  depends_on "llvm@16" => :build
  depends_on "conan@2" => :build
  depends_on "pkg-config"
  depends_on "icu4c"
  depends_on "python@3.9" # Adjust if different Python version is needed for E2E tests

  def install
    # Set environment variables for clang 16 and ICU
    ENV.prepend_path "PATH", Formula["llvm@16"].opt_bin
    ENV.prepend_path "PKG_CONFIG_PATH", "#{Formula["icu4c"].opt_lib}/pkgconfig"
    ENV["CXXFLAGS"] = "-I#{Formula["llvm@16"].opt_include} -fexperimental-library"
    ENV["LDFLAGS"] = "-L#{Formula["llvm@16"].opt_lib} -L#{Formula["llvm@16"].opt_lib}/c++ -Wl,-rpath,#{Formula["llvm@16"].opt_lib}/c++"

    # Set up Conan profile for dependency management
    system "mkdir", "build"
    system "conan", "install", ".", "-pr:b=conanprofiles/clang-16-macos", "-pr:h=conanprofiles/clang-16-macos", "-of=build", "--build=missing"

    # Configure and build with CMake
    system "cmake", "-B", "build", "-S", ".", *std_cmake_args,
                   "-DCMAKE_BUILD_TYPE=Release",
                   "-DCMAKE_TOOLCHAIN_FILE=build/conan_toolchain.cmake",
                   "-DUSE_PARALLEL=true",
                   "-DRUN_EXPENSIVE_TESTS=false",
                   "-DENABLE_EXPENSIVE_CHECKS=true",
                   "-DCMAKE_CXX_COMPILER=clang++",
                   "-DADDITIONAL_COMPILER_FLAGS=-fexperimental-library",
                   "-DADDITIONAL_LINKER_FLAGS=-L#{Formula["llvm@16"].opt_lib}/c++"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Basic functionality test: check version or another simple command
    system "#{bin}/qlever", "--version"
  end
end
