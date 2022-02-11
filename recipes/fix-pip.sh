#! /bin/sh


pyversion="$(python -V 2>&1 | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)"
case ${pyversion} in
    # Fix `pip` in py32 so that it can identify tags inside containers.
    3.2)  sed -i '
        39 d
        40 a \    result = distutils.util.get_platform().replace(".", "_").replace("-", "_")
        40 a \    if result == "linux_x86_64" and sys.maxsize == 2147483647:
        40 a \        result = "linux_i686"
        40 a \    return result
    ' /opt/pyenv/versions/*/lib/python3.2/site-packages/pip/pep425tags.py
esac
