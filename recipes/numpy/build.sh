#! /bin/sh
here=$(readlink -f "$0" | xargs dirname)
cwd=$(pwd)

pkgname=numpy
pyversion="$(python -V 2>&1 | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)"
case ${pyversion} in
    2.6|3.2)          maxversion=1.12; maxcythonversion=3.0 ;;
    3.2)              maxversion=1.12; maxcythonversion=0.27 ;;
    3.3)              maxversion=1.12; maxcythonversion=3.0 ;;
    2.7|3.4)          maxversion=1.17; maxcythonversion=3.0 ;;
    3.5)              maxversion=1.19; maxcythonversion=3.1 ;;
    3.6)              maxversion=1.20; maxcythonversion=3.1 ;;
    3.7|3.8|3.9|3.10) maxversion=1.22; maxcythonversion=3.1 ;;
    *)
        echo 1>&2 "E: unsupported Python version: '${pyversion}'"
        exit 1
    ;;
esac

# Needed by Python 3.2 as long as it uses pip 7.x.
case ${pyversion} in
    3.2)  download="install --download ." ;;
    *)    download="download" ;;
esac

# Needed this upgrade because otherwise `wheel` sets wrong tags for containers.
case ${pyversion} in
    3.3)  pip install "wheel < 0.31" --upgrade;;
    2.6)  sed -i '
        103 d
        104 a \    result = distutils.util.get_platform().replace(".", "_").replace("-", "_")
        104 a \    if result.startswith("macosx") and archive_root is not None:
        104 a \        result = calculate_macosx_platform_tag(archive_root, result)
        104 a \    if result == "linux_x86_64" and sys.maxsize == 2147483647:
        104 a \        result = "linux_i686"
        104 a \    return result
    ' /opt/pyenv/versions/*/lib/python2.6/site-packages/wheel/pep425tags.py
          sed -i '
          6 a \import sys
        141 a \            if plat_name in ("linux-x86_64", "linux_x86_64") and sys.maxsize == 2147483647:
        141 a \                plat_name = "linux_i686"
    ' /opt/pyenv/versions/*/lib/python2.6/site-packages/wheel/bdist_wheel.py
esac

# NumPy < 1.12 needs `xlocale.h`.
if [ "${maxversion}" = "1.12" ]; then
    if [ ! -f /usr/include/xlocale.h ]; then
        ln -s /usr/include/locale.h /usr/include/xlocale.h
    fi
fi

tmpdir=/tmp/$(mktemp -d tmp-${pkgname}-XXXXXX)
mkdir -p ${tmpdir}
cd ${tmpdir}

pip install "pip < 21"
pip install "cython < ${maxcythonversion}"
pip ${download} --no-deps --no-binary=:all: "${pkgname} < ${maxversion}"

unzip -q $(ls)
cd $(ls | head -n1)

# Apply patches.
for patchfile in $(find "${here}/patches" -type f); do
    patch -p1 < ${patchfile}
done
# Copy licenses of bundled libraries.
mv LICENSE.txt LICENSE
for licensefile in $(find "${here}/licenses" -type f); do
    cp ${licensefile} ./
done

python setup.py bdist_wheel --dist-dir=${cwd}/dist

rm -rf ${tmpdir}
