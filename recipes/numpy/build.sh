#! /bin/sh
here=$(readlink -f "$0" | xargs dirname)
cwd=$(pwd)

pkgname=numpy
pyversion="$(python -V 2>&1 | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)"
case ${pyversion} in
    2.6)               maxversion=1.12;   maxcythonversion=3.0  ;;
    3.2)               maxversion=1.12;   maxcythonversion=0.27 ;;
    3.3)               maxversion=1.12;   maxcythonversion=3.0  ;;
    2.7|3.4)           maxversion=1.17;   maxcythonversion=3.0  ;;
    3.5)               maxversion=1.19;   maxcythonversion=3.1  ;;
    3.6)               maxversion=1.20;   maxcythonversion=3.1  ;;
    3.7|3.8|3.9|3.10)  maxversion=1.21.5; maxcythonversion=3.1  ;;
    3.11)              maxversion=1.23.4; maxcythonversion=3.1  ;;
    3.12)              maxversion=1.26.1; maxcythonversion=3.1  ;;
    *)
        echo 1>&2 "E: unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac

# NumPy < 1.12 needs `xlocale.h`.
if [ "${maxversion}" = "1.12" ]; then
    if [ ! -f /usr/include/xlocale.h ]; then
        ln -s /usr/include/locale.h /usr/include/xlocale.h
    fi
fi

# NumPy compilation may fail with newer setuptools:
# https://github.com/pypa/setuptools/issues/3549
pip install "setuptools < 64"

# Needed by Python 3.2 as long as it uses pip 7.x.
case ${pyversion} in
    2.6)  download="download" ;;
    3.2)  download="install --download ." ;;
    *)    download="download --no-build-isolation" ;;
esac
case ${pyversion} in
    2.6)  wheel="wheel" ;;
    3.2)  wheel="wheel" ;;
    *)    wheel="wheel --no-build-isolation" ;;
esac

tmpdir=/tmp/$(mktemp -d tmp-${pkgname}-XXXXXX)
mkdir -p ${tmpdir}
cd ${tmpdir}

pip install "cython < ${maxcythonversion}"
case ${pyversion} in
    3.12)  pip install "packaging < 24" "pyproject-metadata < 0.8" "ninja < 1.12" ;;
esac
pip ${download} --no-deps --no-binary="${pkgname}" "${pkgname} < ${maxversion}"

sdistpkg=$(ls)
if [ ! -z $(echo "${sdistpkg}" | grep -e .zip$ || true) ]; then
    unzip -q "${sdistpkg}"
elif [ ! -z $(echo "${sdistpkg}" | grep -e .tar.gz$ || true) ]; then
    tar -xf "${sdistpkg}"
else
    echo 1>&2 "E: unsupported sdist file: '${sdistpkg}'"
    exit 1
fi
cd $(ls | head -n1)

# Apply patches.
if [ -d "${here}/patches" ]; then
    for patchfile in $(find "${here}/patches" -type f); do
        patch -p0 < ${patchfile}
    done
fi
# Copy licenses of bundled libraries.
mv LICENSE.txt LICENSE
if [ -d "${here}/licenses" ]; then
    for licensefile in $(find "${here}/licenses" -type f); do
        cp ${licensefile} ./
    done
fi

pip ${wheel} -w ${cwd}/dist --no-deps .

rm -rf ${tmpdir}
