export BNB_CUDA_VERSION=126
export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH

git clone https://github.com/timdettmers/bitsandbytes.git
cd bitsandbytes

mkdir -p build
cd build
cmake .. -DCOMPUTE_BACKEND=cuda -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-12.4
make -j$(nproc)

cd ..
python setup.py install