#!/usr/bin/python3
# Usage: ./comps-sync.py /path/to/comps-f35.xml.in
#
# Can both remove packages from the manifest
# which are not mentioned in comps, and add packages from
# comps.

import os, sys, subprocess, argparse, shlex, json, yaml, re
import libcomps

def fatal(msg):
    print >>sys.stderr, msg
    sys.exit(1)

def format_pkgtype(n):
    if n == libcomps.PACKAGE_TYPE_DEFAULT:
        return 'default'
    elif n == libcomps.PACKAGE_TYPE_MANDATORY:
        return 'mandatory'
    else:
        assert False

def write_manifest(fpath, pkgs, include=None):
    with open(fpath, 'w') as f:
        f.write("# DO NOT EDIT! This content is generated from comps-sync.py\n")
        if include is not None:
            f.write("include: {}\n".format(include))
        f.write("packages:\n")
        for pkg in sorted(pkgs):
            f.write("  - {}\n".format(pkg))
        print("Wrote {}".format(fpath))

parser = argparse.ArgumentParser()
parser.add_argument("--save", help="Write changes", action='store_true')
parser.add_argument("src", help="Source path")

args = parser.parse_args()

print("Syncing packages common to all desktops:")

base_pkgs_path = 'fedora-common-ostree-pkgs.yaml'
with open(base_pkgs_path) as f:
    manifest = yaml.safe_load(f)
manifest_packages = set(manifest['packages'])

with open('comps-sync-exclude-list.yml') as f:
    doc = yaml.safe_load(f)
    comps_exclude_list = doc['exclude_list']
    comps_include_list = doc['include_list']
    comps_exclude_list_groups = doc['exclude_list_groups']
    comps_desktop_exclude_list = doc['desktop_exclude_list']
    comps_exclude_list_all = [re.compile(x) for x in doc['exclude_list_all_regexp']]

def is_exclude_listed(pkgname):
    for br in comps_exclude_list_all:
        if br.match(pkgname):
            return True
    return False

# Parse comps, and build up a set of all packages so we
# can find packages not listed in comps *at all*, beyond
# just the workstation environment.
comps = libcomps.Comps()
comps.fromxml_f(args.src)

# Parse the workstation-product environment, gathering
# default or mandatory packages.
ws_env_name = 'workstation-product-environment'
ws_ostree_name = 'workstation-ostree-support'
ws_environ = comps.environments[ws_env_name]
ws_pkgs = {}
for gid in ws_environ.group_ids:
    group = comps.groups_match(id=gid.name)[0]
    if gid.name in comps_exclude_list_groups:
        continue
    exclude_list = comps_exclude_list.get(gid.name, set())
    for pkg in group.packages:
        pkgname = pkg.name
        if pkg.type not in (libcomps.PACKAGE_TYPE_DEFAULT,
                            libcomps.PACKAGE_TYPE_MANDATORY):
            continue
        if pkgname in exclude_list or is_exclude_listed(pkgname):
            continue
        pkgdata = ws_pkgs.get(pkgname)
        if pkgdata is None:
            ws_pkgs[pkgname] = pkgdata = (pkg.type, set([gid.name]))
        if (pkgdata[0] == libcomps.PACKAGE_TYPE_DEFAULT and
            pkg.type == libcomps.PACKAGE_TYPE_MANDATORY):
            ws_pkgs[pkgname] = pkgdata = (pkg.type, pkgdata[1])
        pkgdata[1].add(gid.name)

ws_ostree_pkgs = set()
for pkg in comps.groups_match(id=ws_ostree_name)[0].packages:
    if not is_exclude_listed(pkg.name):
        ws_ostree_pkgs.add(pkg.name)

comps_unknown = set()
for pkg in manifest_packages:
    if (pkg not in comps_include_list and
        pkg not in ws_pkgs and
        pkg not in ws_ostree_pkgs):
        comps_unknown.add(pkg)

# Look for packages in the manifest but not in comps at all
n_manifest_new = len(comps_unknown)
if n_manifest_new == 0:
    print("  - All manifest packages are already listed in comps.")
else:
    print("  - {} packages not in {}:".format(n_manifest_new, ws_env_name))
    for pkg in sorted(comps_unknown):
        print('    {}'.format(pkg))
        manifest_packages.remove(pkg)

# Look for packages in workstation but not in the manifest
ws_added = {}
for (pkg,data) in ws_pkgs.items():
    if pkg not in manifest_packages:
        ws_added[pkg] = data
        manifest_packages.add(pkg)

n_comps_new = len(ws_added)
if n_comps_new == 0:
    print("  - All comps packages are already listed in manifest.")
else:
    print("  - {} packages not in manifest:".format(n_comps_new))
    for pkg in sorted(ws_added):
        (req, groups) = ws_added[pkg]
        print('    {} ({}, groups: {})'.format(pkg, format_pkgtype(req), ', '.join(groups)))

if (n_manifest_new > 0 or n_comps_new > 0) and args.save:
    write_manifest(base_pkgs_path, manifest_packages)

# Generate treefiles for all desktops
for desktop in [ 'gnome-desktop', 'kde-desktop', 'xfce-desktop',
        'lxqt-desktop', 'deepin-desktop', 'pantheon-desktop', 'mate-desktop']:
    print()
    print("Syncing packages for {}:".format(desktop))

    manifest_path = '{}-pkgs.yaml'.format(desktop)
    with open(manifest_path) as f:
        manifest = yaml.safe_load(f)
    manifest_packages = set(manifest['packages'])

    # Filter packages in the comps desktop group using the exclude_list
    comps_group_pkgs = set()
    for pkg in comps.groups_match(id=desktop)[0].packages:
        pkgname = pkg.name
        exclude_list = comps_desktop_exclude_list.get(desktop, set())
        if pkgname in exclude_list or is_exclude_listed(pkgname):
            continue
        comps_group_pkgs.add(pkg.name)

    # Look for packages in the manifest but not in comps group
    comps_unknown = set()
    for pkg in manifest_packages:
        if pkg not in comps_group_pkgs:
            comps_unknown.add(pkg)

    n_manifest_new = len(comps_unknown)
    if n_manifest_new == 0:
        print("  - All manifest packages are already listed in comps.")
    else:
        print("  - {} packages not in {} comps group:".format(n_manifest_new, desktop))
        for pkg in sorted(comps_unknown):
            print('    {}'.format(pkg))
            manifest_packages.remove(pkg)

    # Look for packages in comps but not in the manifest
    desktop_pkgs_added = set()
    for pkg in comps_group_pkgs:
        if pkg not in manifest_packages:
            desktop_pkgs_added.add(pkg)

    n_comps_new = len(desktop_pkgs_added)
    if n_comps_new == 0:
        print("  - All comps packages are already listed in manifest.")
    else:
        print("  - {} packages not in {} manifest:".format(n_comps_new, desktop))
        for pkg in sorted(desktop_pkgs_added):
            print('    {}'.format(pkg))
            manifest_packages.add(pkg)

    # Update manifest
    if (n_manifest_new > 0 or n_comps_new > 0) and args.save:
        write_manifest(manifest_path, manifest_packages, include="fedora-common-ostree.yaml")
