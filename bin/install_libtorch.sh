#!/bin/bash

# ==============================================================================
# PyTorch/LibTorch Clean Rebuild Script (Fully Configurable & Verified)
#
# This script performs a full, clean rebuild of LibTorch with a custom
# toolchain and a configurable C++ standard and build type.
#
# It includes post-build verification for:
#   1. Correct C++ standard ABI (by checking for standard-specific symbols).
#   2. Confirmation that the C++20 Modules feature is NOT in use.
# ==============================================================================

# Exit immediately if any command fails.
set -e

# --- Configuration ---
USER_ROOT_DIR="/Users/shantanusardesai/Desktop/code/projects"
PROJECT_ROOT_DIR="${USER_ROOT_DIR}/macroexpand/third-party/pytorch"
BUILD_CONFIGURATION="Debug"
EXPECTED_CXX_STANDARD="20" # Can be changed to "17", "20", etc.

# --- Derived & Verification Variables (No need to edit below this line) ---
BUILD_CONFIGURATION_LOWER=$(echo "$BUILD_CONFIGURATION" | tr '[:upper:]' '[:lower:]')
BUILD_DIR="${PROJECT_ROOT_DIR}/build_cpp${EXPECTED_CXX_STANDARD}_${BUILD_CONFIGURATION_LOWER}"
INSTALL_PATH="${PROJECT_ROOT_DIR}/libtorch_install_cpp${EXPECTED_CXX_STANDARD}_${BUILD_CONFIGURATION_LOWER}"
TOOLCHAIN_PATH="/opt/homebrew/opt/llvm"
BUILD_TYPE_MESSAGE="C++${EXPECTED_CXX_STANDARD}"

# Set the symbol to check for based on the C++ standard for ABI verification
SYMBOL_TO_CHECK=""
if [ "$EXPECTED_CXX_STANDARD" == "17" ]; then
    SYMBOL_TO_CHECK="std::optional"
elif [ "$EXPECTED_CXX_STANDARD" == "20" ]; then
    SYMBOL_TO_CHECK="std::ranges"
fi

# --- Helper Function for Confirmation ---
confirm_action() {
  local message="$1"
  read -p "$message [y/N]: " -r
  echo
  if [[ ! $REPLY =~ ^[Yy] ]]; then
    echo "Aborted by user."
    exit 1
  fi
}

# --- Main Build Logic ---
cd "$PROJECT_ROOT_DIR"
echo "✅ Working directory: $(pwd)"
echo "Targeting C++ Standard: ${EXPECTED_CXX_STANDARD}"
echo "Build Configuration:    ${BUILD_CONFIGURATION}"

# --- Step 1: Clean Up ---
echo "🧹 Starting cleanup for ${BUILD_TYPE_MESSAGE} ${BUILD_CONFIGURATION} build..."
if [ -d "$BUILD_DIR" ]; then
  confirm_action "-> Found existing build directory '$BUILD_DIR'. OK to delete?"
  echo "   Deleting '$BUILD_DIR'..."
  rm -rf "$BUILD_DIR"
fi
if [ -d "$INSTALL_PATH" ]; then
  confirm_action "-> Found existing install directory '$INSTALL_PATH'. OK to delete?"
  echo "   Deleting '$INSTALL_PATH'..."
  rm -rf "$INSTALL_PATH"
fi
echo "✅ Cleanup complete."

# --- Step 2: Configure ---
echo "⚙️  Configuring the ${BUILD_TYPE_MESSAGE} ${BUILD_CONFIGURATION} build with CMake..."
export CC="${TOOLCHAIN_PATH}/bin/clang"
export CXX="${TOOLCHAIN_PATH}/bin/clang++"
LINKER_FLAGS="-L${TOOLCHAIN_PATH}/lib -Wl,-rpath,${TOOLCHAIN_PATH}/lib"

cmake \
  -S "$PROJECT_ROOT_DIR" \
  -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE="$BUILD_CONFIGURATION" \
  -DCMAKE_CXX_STANDARD="$EXPECTED_CXX_STANDARD" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" \
  -DBUILD_SHARED_LIBS=ON \
  -DPYTHON_EXECUTABLE="$(which python3)" \
  -DUSE_OPENMP=OFF \
  -DCMAKE_CXX_FLAGS="-isystem ${TOOLCHAIN_PATH}/include/c++/v1 -include cstdlib" \
  -DCMAKE_EXE_LINKER_FLAGS="${LINKER_FLAGS}" \
  -DCMAKE_SHARED_LINKER_FLAGS="${LINKER_FLAGS}"
echo "✅ Configuration complete."

# --- Step 3: Verify ---
echo
echo "🔎 Verifying configuration before starting build..."
ACTUAL_CXX_STANDARD=$(grep "CMAKE_CXX_STANDARD:STRING" "${BUILD_DIR}/CMakeCache.txt" | cut -d'=' -f2 || true)
echo "   -------------------------------------------"
echo "   Expected C++ Standard: ${EXPECTED_CXX_STANDARD}"
echo "   Found in build cache:  ${ACTUAL_CXX_STANDARD}"
echo "   -------------------------------------------"
if [[ "$ACTUAL_CXX_STANDARD" == "$EXPECTED_CXX_STANDARD" ]]; then
  echo "   ✅ Verification successful."
  confirm_action "Configuration looks correct. Proceed with the ${BUILD_TYPE_MESSAGE} ${BUILD_CONFIGURATION} build?"
else
  echo "   ❌ ERROR: C++ Standard mismatch detected!"
  confirm_action "   WARNING: Configuration is INCORRECT. Proceed anyway?"
fi

# --- Step 4: Build and Install ---
echo "🚀 Building and installing LibTorch (${BUILD_TYPE_MESSAGE}, ${BUILD_CONFIGURATION})... (This will take a long time)"
cmake --build "$BUILD_DIR" --target install --config "$BUILD_CONFIGURATION" -j "$(nproc 2>/dev/null || sysctl -n hw.ncpu)"
echo "🎉 LibTorch (${BUILD_TYPE_MESSAGE}, ${BUILD_CONFIGURATION}) has been successfully built and installed to: $INSTALL_PATH"

# --- Step 5: Post-Build Verification ---
echo
echo "🔎 Verifying the installed library..."
VERIFY_LIB_PATH="${INSTALL_PATH}/lib/libtorch_cpu.dylib"
if [ ! -f "$VERIFY_LIB_PATH" ]; then
    echo "   ❌ ERROR: Could not find installed library at '$VERIFY_LIB_PATH' to verify."
    exit 1
fi

# --- Verification 5a: Check for C++20 Module Artifacts ---
if [ "$EXPECTED_CXX_STANDARD" -ge 20 ]; then
    echo
    echo "   Verifying that C++20 Modules were NOT used..."
    # Search for .pcm files, which are artifacts of module compilation.
    # Note: Clang's older module system might cache system headers, but a clean
    # PyTorch build should not generate any .pcm files for its own source.
    PCM_FILE_COUNT=$(find "$BUILD_DIR" -name "*.pcm" | wc -l || true)
    echo "   -------------------------------------------------------------------"
    echo "   Checking for C++20 Module artifacts (.pcm files)..."
    echo "   Found ${PCM_FILE_COUNT} '.pcm' files in the build directory."
    echo "   -------------------------------------------------------------------"
    if [ "$PCM_FILE_COUNT" -gt 0 ]; then
        echo "   ❌ ERROR: C++20 Module artifacts (.pcm) were found!"
        echo "   This indicates the build may have incorrectly enabled the C++20 modules feature."
        echo "   The following files were found:"
        find "$BUILD_DIR" -name "*.pcm"
        exit 1
    else
        echo "   ✅ Verification successful. C++20 Modules were not used."
    fi
fi

# --- Verification 5b: Check for Correct C++ Standard ABI ---
if [ -z "$SYMBOL_TO_CHECK" ]; then
    echo "   ⚠️  WARNING: No specific symbol check for ${BUILD_TYPE_MESSAGE}. Skipping ABI verification."
else
    echo
    echo "   Verifying correct ${BUILD_TYPE_MESSAGE} ABI..."
    SYMBOL_COUNT=$(nm -gC "$VERIFY_LIB_PATH" | grep "${SYMBOL_TO_CHECK}" | grep ' U ' | wc -l || true)
    echo "   -------------------------------------------------------------------"
    echo "   Checking for UNDEFINED REFERENCES to ${BUILD_TYPE_MESSAGE} symbols (${SYMBOL_TO_CHECK})..."
    echo "   Found ${SYMBOL_COUNT} matching symbol references in '$VERIFY_LIB_PATH'."
    echo "   -------------------------------------------------------------------"
    if [ "$SYMBOL_COUNT" -gt 0 ]; then
      echo "   ✅ Verification successful. The library was compiled with ${BUILD_TYPE_MESSAGE}."
    else
      echo "   ❌ ERROR: Post-build verification failed for ABI check."
      echo "   No references to ${BUILD_TYPE_MESSAGE} symbols were found in the final library."
      exit 1
    fi
fi

echo
echo "🎉 LibTorch has been successfully built with ${BUILD_TYPE_MESSAGE} and installed to: $INSTALL_PATH"
