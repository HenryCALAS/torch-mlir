set -e

# The absolute path to the directory of this script.
TORCH_MLIR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Got to the build directory.
cd "${TORCH_MLIR_DIR}"
mkdir -p build
cd build

cmake -G Ninja \
  ../externals/llvm-project/llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_FIND_VIRTUALENV=ONLY \
  -DLLVM_ENABLE_PROJECTS=mlir \
  -DLLVM_EXTERNAL_PROJECTS="torch-mlir;torch-mlir-dialects" \
  -DLLVM_EXTERNAL_TORCH_MLIR_SOURCE_DIR="$TORCH_MLIR_DIR" \
  -DLLVM_EXTERNAL_TORCH_MLIR_DIALECTS_SOURCE_DIR="$TORCH_MLIR_DIR"/externals/llvm-external-projects/torch-mlir-dialects \
  -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
  -DLLVM_TARGETS_TO_BUILD=host \
  -DLLVM_USE_LINKER=lld \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++

cd $TORCH_MLIR_DIR
# Build just torch-mlir (not all of LLVM)
cmake --build build --target tools/torch-mlir/all

# Run unit tests.
cmake --build build --target check-torch-mlir

# Run Python regression tests.
cmake --build build --target check-torch-mlir-python
