#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH=/home/cqh/custom_install/gcc_12.4/bin:$PATH
export LD_LIBRARY_PATH=/home/cqh/custom_install/gcc_12.4/lib64:${LD_LIBRARY_PATH:-}

if [[ -z "${CONDA_PREFIX:-}" ]]; then
	if ! command -v conda >/dev/null 2>&1; then
		echo "conda is not available; please activate the target conda environment first." >&2
		exit 1
	fi

	source "$(conda info --base)/etc/profile.d/conda.sh"
	if [[ -n "${CONDA_ENV_NAME:-}" ]]; then
		conda activate "${CONDA_ENV_NAME}"
	else
		echo "No active conda environment found. Activate one first or set CONDA_ENV_NAME." >&2
		exit 1
	fi
fi

if [[ -z "${CONDA_PREFIX:-}" ]]; then
	echo "Failed to resolve CONDA_PREFIX after activation." >&2
	exit 1
fi

CONDA_BASE_PREFIX="$(conda info --base)"

cmake -S "$SCRIPT_DIR" -B "$SCRIPT_DIR/build" \
	-DCMAKE_PREFIX_PATH="$CONDA_PREFIX;$CONDA_BASE_PREFIX" \
	-DGTest_DIR="$CONDA_BASE_PREFIX/lib/cmake/GTest" \
	-DGTEST_INCLUDE_DIR="$CONDA_BASE_PREFIX/include" \
	-DGTEST_LIBRARY_DIR="$CONDA_BASE_PREFIX/lib"
cmake --build "$SCRIPT_DIR/build" --target disk_manager_test lru_replacer_test buffer_pool_manager_test record_manager_test -j4

"$SCRIPT_DIR/build/bin/disk_manager_test"
"$SCRIPT_DIR/build/bin/lru_replacer_test"
"$SCRIPT_DIR/build/bin/buffer_pool_manager_test"
"$SCRIPT_DIR/build/bin/record_manager_test"