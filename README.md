![Screenshot of Sodalite](https://git.zio.sh/sodaliterocks/lfs/media/branch/main/graphics/screenshot/screenshot.png?u=7)

<h1 align="center">
    Sodalite
</h1>

**Sodalite** is an immutable desktop OS built with [rpm-ostree](https://coreos.github.io/rpm-ostree/) and on-top of [Fedora](https://getfedora.org/) &mdash; similar to [Fedora Silverblue](https://silverblue.fedoraproject.org/) &mdash; making use of the [Pantheon desktop](https://elementary.io/docs/learning-the-basics), sticking closely to the ethos and workflow perpetrated by [elementary](https://elementary.io/open-source). A work-in-progress but entirely usable as a production desktop.

This is mostly a developer-orientated README; you're probably better off heading to [Sodalite Docs](https://docs.sodalite.rocks) if you're a user, or you can head down to <b><a href="#-quickstart">🎉 Quickstart</a></b> to get going.

## 🎉 Quickstart

Know what you're in for? Here goes:

1. Install an rpm-ostree-based version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/), or use an already-existing install
2. Fire up a terminal and issue these commands:
   - `sudo ostree remote add --if-not-exists sodalite https://ostree.sodalite.rocks --no-gpg-verify`
   - `sudo ostree pull sodalite:sodalite/stable/x86_64/desktop`
   - `sudo rpm-ostree rebase sodalite:sodalite/stable/x86_64/desktop`
3. Stick the kettle on and make yourself a cuppa. It'll take a while
4. Reboot when prompted. Use it, enjoy it, make something cool with it, (try to) break it &mdash; [submit a ticket if you do](https://github.com/sodaliterocks/sodalite/issues/new)!

### Updating

Performing a system update can be done by either:

* Running `sudo rpm-ostree upgrade` in a shell
* Opening **Software**, selecting **Updates** from the headerbar, and pressing **Update All**
  - As Software runs in the background and periodically checks for updates, you may also receive a notification of a new update; clicking on this opens the appropriate page
  - An update for the OS may take a while to appear in Software (which will appear as "Operating System Updates"), so the above method is preferred

Reboot after either method has finished. You can verify the version installed by opening **System Settings** and navigating to **System ➔ Operating System**: the version proceeds the word "Sodalite"

If something breaks, you can rollback by running `sudo rpm-ostree rollback` at a terminal. Remember to also [create a new issue](https://github.com/sodaliterocks/sodalite/issues/new) if appropriate!

#### Update Schedule

Updates are built on the build server commencing **4:00 GMT** every **Wednesday** and **Saturday**.

#### `f<version>` Versions

If you chose to use a `f<version>` "long-term" branch (see <a href="#branches">Branches</a> below), you will need to rebase whenever the base Fedora Linux version reaches end-of-life. This can be done with `sudo rpm-ostree rebase sodalite:sodalite/f<version>/<arch>/<edition>`, where `<version>` is the version you're wanting to rebase to and other values are your current values.

It's vital you carry out this process as updates stop the day the base version reaches end-of-life and you will be left without updates to vital system components (however, Flatpak apps will continue to update). See [Fedora Docs Fedora ➔ Linux Release Life Cycle](https://docs.fedoraproject.org/en-US/releases/lifecycle/) for more.

### Branches

To allow for several versions to co-exist and be developed in tandem with each other, Sodalite &mdash; like any other rpm-ostree distro &mdash; carries a ref to distinguish itself. Where `<name>/<version>/<arch>/<edition>`, the format and possible values are as follows:

* `<name>`: **Name** of the branch; always `sodalite`
* `<version>`: **Version** of the branch. Possible values:
  - `stable`:  Rolling-release version based on the current stable release of Fedora Linux (currently 37)
  - `f<version>`: "Long-term" versions based on specific versions of Fedora Linux, which require manual intervention to rebase to a newer version when said version reaches end-of-life. Possible values for `<version>`:
    - `36`: Fedora Linux 36. Reaches end-of-life on 16th May 2023 (2023-05-16)
    - `37`: Fedora Linux 37. Reaches end-of-life on 14th Nov 2023 (2023-11-14)
  - `next`: Rolling-release version based on the next upcoming version of Fedora Linux (currently 38)
  - `devel`: Current development code (on `main`). **Do not use on production systems!**
* `<arch>`: **Architecture** of the branch. Possible values:
  - `x86_64`: For 64-bit CPUs (`x86_64`, `amd64`, or `x64`)
  - ~~`x86`: [What year is it!?](https://c.tenor.com/9OcQhlCBNG0AAAAd/what-year-is-it-jumanji.gif)~~
* `<edition>`: **Edition** (or variant) of the branch: Possible values:
  - `desktop`: Standard Pantheon desktop
  - `desktop-gnome`: Alternate GNOME desktop
  - `base`: Legacy version of `desktop`. **Do not use!**

**As mentioned above, most users will want `sodalite/stable/x86_64/desktop`.**

#### Available Branches

Possible combinations built on the OSTree remote (`ostree.sodalite.rocks`) are as follows:

|Name|Version(s)|Arch.(s)|Edition(s)|
|-|-|-|-|
|`sodalite`|`stable`|`x86_64`|`desktop`|
|`sodalite`|`f36`|`x86_64`|`desktop`|
|`sodalite`|`f37`|`x86_64`|`desktop`|
|`sodalite`|`next`|`x86_64`|`desktop`|
|`sodalite`|`devel`|`x86_64`|`desktop`<br />`desktop-gnome`|

_For example, `sodalite/stable/x86_64/desktop` exists on the build server and can be pulled, but `sodalite/f37/x86_64/desktop-gnome` does not._

### Versioning

Versioning is as follows, where `<base>-<year>.<release>[.<update>][+<commit>]`:

* `<base>`: Base version of **Fedora Linux**
* `<year>`: Year of release using just two digits (i.e. 2023 becomes `23`)
* `<release>` Incremental release version; for additions, changes, and removals. Resets when a new year occurs, but **does not** reset on a new base version of Fedora Linux
  - An example progression would be: `39-23.0` ➔ `39-23.1` ➔ `40-23.2`  ➔ `40-23.3` ➔ `40-24.0`
* `<update>` _(optional)_: Incremental update version that occurs when the server rebuilds the exact same release version to update packages
  - An example progression would be: `39-23.0` ➔ `39-23.0.1` ➔ `39-23.0.2` ➔ `39-23.1` ➔ `39-23.1.1`
  - As builds are not created if no changes are present, this may drift out-of-sync between branches
* `<commit>` _(optional)_: Git commit (short version) for non-production versions
  - This will only appear from:
    - Rebasing to the `devel` version (see <a href="#branches">Branches</a> above)
    - Building Sodalite yourself with a commit that has not been tagged
    - A mistake, usually occuring from a tag that hasn't been pushed (oops!)

---

<p align="center">
    <s><b>See <a href="https://docs.sodalite.rocks)">Sodalite Docs</a> for more information</b></s> <i>(Docs are still a work-in-progress)</i> &mdash; the README beyond this is intended mostly for developers.
</p>

<!--
## ✨ Status

_(todo)_
-->

## 🏗️ Building

### 1. Prerequisites

#### Software

* [Fedora Linux](https://getfedora.org/) (or other Fedora-based/compatible distros)
* [rpm-ostree](https://coreos.github.io/rpm-ostree/)
  - On most Fedora-based distros, this can be installed with `dnf install rpm-ostree`
* Bash
* [Git LFS](https://git-lfs.com/)
  - As well as including pretty wallpapers, the LFS also includes vital binaries that Sodalite needs to work properly, so don't miss installing this!
  - Unsure if you have LFS support? Tpe `git lfs`: a help output prints if installed

#### Environment
* Permission to `sudo`
  - `rpm-ostree` needs superuser access to work: there's no way around this.
* &gt;10GiB disk space
  - The repository itself (including submodules) takes up ~300MiB
  - Initial builds will take up ~4GiB, with subsequent builds adding to this
* Unlimited Internet
  - The build process caches **a lot** of Fedora packages (around 2.5GiB), so think carefully about doing this on mobile broadband or any other service that imposes a small data allowance on you
* An rpm-ostree-based distro, such as such as [Fedora Silverblue](https://silverblue.fedoraproject.org/) &mdash; on either a virtual machine, another physical machine, or your current install (careful!) &mdash; to test builds on
* A cuppa _(optional)_ &mdash; this can take a while

### 2. Getting

```sh
git clone https://github.com/sodaliterocks/sodalite.git
cd sodalite
git submodule sync
git submodule update --init --recursive
```

#### Future Pulls

When updating in the future, don't forget to update submodules with:

```sh
git submodule update --recursive
```

**Do not** use `git submodule foreach git pull`: this blindly updates all submodules to their latest version, not the commit this parent repo has checked out. This is important for some submodules that are checked out at specific tags/commits (such as `./lib/sodaliterocks.firefox`).

The `./lib/workstation-ostree-config_f*` submodules &mdash; serving as a basis for Sodalite for its various different Fedora-based versions &mdash; are removed every so often so make sure you delete them accordingly. For example, when Fedora 36 reaches EoL, `./lib/workstation-ostree-config_f36` will be removed shortly afterwards. You can use `git clean -i` to do the work for you.

#### LFS

An LFS submodule is located at `./lfs`. It's important to note this is not hosted on GitHub, but [Zio Git](https://git.zio.sh) &mdash; a server we control &mdash; as GitHub's LFS allowances are tight ([only 1GiB bandwidth and storage](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-storage-and-bandwidth-usage)).

Any issues regarding the LFS should be submitted to [sodaliterocks/sodalite on GitHub](https://github.com/sodaliterocks/sodalite). Currently, as Zio Git does not allow for arbitrary sign-ups, PRs cannot be directly submitted.

#### Usage of GitHub

Unless the world collectively favours GitLab, or anything else, Sodalite will stay on GitHub as it makes everyone's lives easier. Microsoft is just another company; they're not going to hurt you.

### 3. Building

```sh
sudo ./build.sh [<edition>] [<working-dir>]
```

This will usually take 10-15 minutes. Remember when I told you to grab a cuppa? Or maybe a cold one?

##### Arguments

* `<edition>` _(optional)_ Edition/variant of Sodalite (defaults to `custom`)
  - This is any of the `sodalite-<edition>.yaml` files listed in `./src/treefiles/`. Either use `sodalite-<edition>` or just `<edition>` as the argument. Currently, there is:
    - `desktop`: Standard Pantheon desktop
    - `desktop-gnome`: Alternate GNOME desktop, intended for possible future versions
	- `base`: Old legacy version sourcing `desktop`, purely there for compatibility and will be removed soon
    - `custom`: See below point
  - `sodalite-custom.yaml` is a good place to employ your own changes instead of modifying any of the other treefiles
* `<working-dir>` _(optional)_ Directory for build output (defaults to `./build`)

#### Additional Notes

##### NTFS/FAT partitions

Build failures are inevitable on drives formatted as NTFS, FAT, or anything other filesystems that do not support Unix-like permissions, as `build.sh` sets permissions on various objects.

###### WSL2

On WSL2, do not build to any `/mnt/<drive-letter>` directories as these will be formatted as NTFS or FAT. Instead, run the build somewhere else on the Linux distro itself (like `$HOME` or `/usr/local/src`).

##### Not using `build.sh`

Most rpm-ostree distros can be built just be simply doing `rpm-ostree compose`, but `build.sh` provided with Sodalite does some extra steps which are required for the post-build script (which **will** fail without these being ran). It is therefore not recommended to do it this way: any issues building the distro this way will be closed and marked as invalid.

##### Without `--unified-core` deprecation warning

During the build you will face this warning:

```sh
NOTICE: Running rpm-ostree compose tree without --unified-core is deprecated.
 Please add --unified-core to the command line and ensure your content
 works with it.  For more information, see https://github.com/coreos/rpm-ostree/issues/729
```

You can safely ignore this: Sodalite builds without `--unified-core` due to historical reasons. Adding `--unified-core` to the compose command in `build.sh` has not been tested for some time and may cause problems.

#### Cleaning Up

Build contents is located at `./build/` (or whatever you set `<working-dir>` to), which can be deleted to start afresh. Specifically this holds the following files/directories (of which can be individually deleted instead):

* `./build/repo/` &mdash; OSTree repository for Sodalite
* `./build/cache/` &mdash; Cache for Fedora packages

Unless stopped manually, `build.sh` will clean itself up whenever it exits (on both success and failure). It will correct permissions (to your user) for the `./build/` directory, as well as removing the following files/directories:

* `./src/sysroot/common/usr/lib/sodalite-buildinfo`
* `/var/tmp/rpm-ostree.*/`
  - This can get large quickly; watch out if you're not letting `build.sh` exit

### 4. Using

_(todo)_

## 🤝 Acknowledgements

### Individuals

* [Fabio "decathorpe" Valentini](https://decathorpe.com/), for providing the extra packages for elementary on Fedora via the [elementary-staging Copr repository](https://copr.fedorainfracloud.org/coprs/decathorpe/elementary-staging/)
* [Jorge O. Castro](https://github.com/castrojo), for including Sodalite in [awesome-immutable](https://github.com/castrojo/awesome-immutable)
* [Timothée Ravier](https://tim.siosm.fr), for their extensive guidance to the community concerning Fedora Silverblue
* ["Topfi"](https://github.com/ACertainTopfi), for their various contributions
* The amazing photographers/artists of the included wallpapers &mdash; [Adrien Olichon](https://unsplash.com/@adrienolichon), [Austin Neill](https://unsplash.com/@arstyy), [Cody Fitzgerald](https://unsplash.com/@cfitz), [Dustin Humes](https://unsplash.com/@dustinhumes_photography), [Jack B.](https://unsplash.com/@nervum), [Jeremy Gerritsen](https://unsplash.com/@jeremygerritsen), [Karsten Würth](https://unsplash.com/@karsten_wuerth), [Max Okhrimenko](https://unsplash.com/@maxokhrimenko), [Nathan Dumlao](https://unsplash.com/@nate_dumlao), [Ryan Stone](https://unsplash.com/@rstone_design), [Smaran Alva](https://unsplash.com/@smal), [Willian Daigneault](https://unsplash.com/@williamdaigneault), and [Zara Walker](https://unsplash.com/@mojoblogs)

### Teams & Organizations

* [elementary](https://elementary.io/team), for building lovely stuff
* [Fyra Labs](https://fyralabs.com), for maintaining [Terra](https://terra.fyralabs.com/)
  * The official Fedora repos ran into issues (see [#44](https://github.com/sodaliterocks/sodalite/issues/44)) with Pantheon packages for f37+, potentially dooming Sodalite after f36 reached EoL: Terra solved this
* The contributors to [workstation-ostree-config](https://pagure.io/workstation-ostree-config), for a solid ground to work from

### Miscellaneous

* The [Sodalite mineral](https://en.wikipedia.org/wiki/Sodalite), for the name. [It's a mineral, not a rock, Jesus](https://www.youtube.com/watch?v=r1yYJBzf1VQ)!
* The [Omicron variant of SARS-CoV-2](https://en.wikipedia.org/wiki/SARS-CoV-2_Omicron_variant), for giving [Ducky](https://github.com/electriduck) the initial free time to make this thing

## 👀 See Also

* **[📄 Code of Conduct](CODE_OF_CONDUCT.md)** &mdash; Contributor Covenant CoC
* **[📄 Contributing](CONTRIBUTING.md)**
* **[🔗 Docs](https://docs.sodalite.rocks)**
* **[📄 License](LICENSE)** &mdash; MIT, &copy; 2023 Sodalite contributors

### Related

* **[🔗 Fedora Docs ➔ Fedora Silverblue User Guide](https://docs.fedoraproject.org/en-US/fedora-silverblue/)**

---

<p align="center">
  This README was entirely overhauled on 27-Dec-2022, and removed a lot of fluff that was no longer needed, but if you're looking for the previous version see <a href="https://github.com/sodaliterocks/sodalite/blob/d482f66c7dfe300f02d0cc045bbe22a0720e6858/README.md">README.md@d482f66</a>.
</p>

<p align="center">
  <a href="README.md">🇬🇧</a>
  <!--a href="docs/README.de.md">🇩🇪</a-->
</p>
