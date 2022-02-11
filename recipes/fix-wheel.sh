#! /bin/sh


pyversion="$(python -V 2>&1 | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)"
case ${pyversion} in
    # Fix `wheel` in py26 so that it can identify tags inside containers.
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
