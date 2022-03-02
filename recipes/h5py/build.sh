#! /bin/sh
here=$(readlink -f "$0" | xargs dirname)
cwd=$(pwd)

pkgname=h5py
pyversion="$(python -V 2>&1 | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)"
case ${pyversion} in
    2.6|3.3)             maxversion=2.9;  maxnumpyversion=1.12 ;;
    3.2)                 maxversion=2.7;  maxnumpyversion=1.12 ;;
    2.7|3.4)             maxversion=3.0;  maxnumpyversion=1.17 ;;
    3.5)                 maxversion=3.0;  maxnumpyversion=1.19 ;;
    3.6)                 maxversion=3.2;  maxnumpyversion=1.20 ;;
    3.7|3.8|3.9)         maxversion=3.7;  maxnumpyversion=1.22 ;;
    3.10)                maxversion=3.7;  maxnumpyversion=1.22 ;;
    *)
        echo 1>&2 "E: unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac

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

pip install "numpy < ${maxnumpyversion}"
pip ${download} --no-deps --no-binary="${pkgname}" "${pkgname} < ${maxversion}"

tar -xf $(ls)
cd $(ls | head -n1)

# Apply patches.
if [ -d "${here}/patches" ]; then
    for patchfile in $(find "${here}/patches" -type f); do
        patch < ${patchfile}
    done
fi
# Copy licenses of bundled libraries.
if [ -d "${here}/licenses" ]; then
    for licensefile in $(find "${here}/licenses" -type f); do
        cp ${licensefile} ./
    done
fi

pip ${wheel} -w ${cwd}/dist --no-deps .

rm -rf ${tmpdir}
