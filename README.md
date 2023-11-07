![Screenshot of Sodalite](https://git.zio.sh/sodaliterocks/lfs/media/branch/main/graphics/screenshot/screenshot.png?u=7)

<h1 align="center">
    Sodalite
</h1>

<p align="centeR">
<strong>Sodalite</strong> is an immutable desktop OS built with <a href="https://coreos.github.io/rpm-ostree/">rpm-ostree</a> and on-top of <a href="https://getfedora.org/">Fedora</a> &mdash; similar to <a href="https://silverblue.fedoraproject.org/">Fedora Silverblue</a> &mdash; making use of the <a href="https://elementary.io/docs/learning-the-basics">Pantheon desktop</a>, sticking closely to the ethos and workflow perpetrated by <a href="https://elementary.io/open-source">elementary</a>. A work-in-progress but entirely usable as a production desktop.
</p>

---

<h4 align="center">
    Hmm, it's been X days since the last commit; is this still active?
</h4>

<p align="center">
    <strong>Yes.</strong>
</p>

<p align="center">
    Despite a <em>very</em> active commit history, Sodalite is fairly self-sustaining these days &mdash; mostly thanks to the awesome people at <a href="https://fyralabs.com">Fyra Labs</a> &mdash; and thus the repository will go months without any activity. This does not mean the project is abandoned, especially since <a href="https://github.com/electricduck">it's developer</a> uses it as their main OS. Regardless of repository activity, updates are built twice every week from the repository: logs are available at <a href="https://github.com/sodaliterocks/sodalite/actions">Actions</a>.
</p>

<p align="center">
    Psst! We're on <a href="https://t.me/sodalitechat">Telegram</a> too. While you're free to use <a href="https://github.com/sodaliterocks/sodalite/discussions">Discussions</a>, the majority of the discussion relating to this project will happen over on Telegram.
</p>

---

## 🎉 Installing

> As rpm-ostree is an ever-evolving technology, and ISO installs are currently a low priority, **ISOs are currently not available**. An existing rpm-ostree-based OS, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/), is required: this OS will be used to "rebase" to Sodalite.

1. Install an rpm-ostree-based version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/), or use an already-existing install
2. Fire up a terminal and issue these commands:
   - `sudo ostree remote add --if-not-exists sodalite https://ostree.sodalite.rocks --no-gpg-verify`
   - `sudo ostree pull sodalite:sodalite/current/x86_64/desktop`*
   - `sudo rpm-ostree rebase sodalite:sodalite/current/x86_64/desktop`
3. Stick the kettle on and make yourself a cuppa. It'll take a while
4. Reboot when prompted. Use it, enjoy it, make something cool with it, (try to) break it &mdash; [submit a ticket if you do](https://github.com/sodaliterocks/sodalite/issues/new)!

_* There are multiple branches available; see [Branches](#branches)_.

### Branches

Several branches (or images) of Sodalite co-exist and are developed side-by-side; these are distinguished by their ref &mdash; like any other rpm-ostree distro &mdash; where `sodalite/<version>/<arch>/<edition>`:

#### Current

|**`<version>`**|**`<arch>`**|**`<edition>`**|Release|Base|EOL|
|-|-|-|-|-|-|
|`current`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;|[Fedora&#160;38](https://docs.fedoraproject.org/en-US/releases/f38/)|∞|

#### Long

|**`<version>`**|**`<arch>`**|**`<edition>`**|Release|Base|EOL|
|-|-|-|-|-|-|
|`long-6`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;(Long)|[Fedora&#160;39](https://docs.fedoraproject.org/en-US/releases/f39/)|12-Nov-2024|
|`long-5`|`x86_64`|`desktop`|**5&#160;Iberia**&#160;(Long)|[Fedora&#160;38](https://docs.fedoraproject.org/en-US/releases/f38/)|14-May-2024|
|`long-4`|`x86_64`|`desktop`|**4.2&#160;Bantu**&#160;(Long)|[Fedora&#160;37](https://docs.fedoraproject.org/en-US/releases/f37/)|14-Nov-2023|

> Unlike **Current** (`current`), these branches do not update to the current major release: **updates will stop the same day as the base Fedora version**. Only use these if neccessary (i.e. problematic drivers requiring certain versions, critical systems, etc.)

#### Next

|**`<version>`**|**`<arch>`**|**`<edition>`**|Release|Base|EOL|
|-|-|-|-|-|-|
|`next`|`x86_64`|`desktop`|**6&#160;Kutai**&#160;(Next)&#160;|[Fedora&#160;39](https://docs.fedoraproject.org/en-US/releases/f39/)|∞|

> Early versions of upcoming releases. Unstable. Here be dragons. Abandon all hope. You know the drill.
>
> This may sometimes be at the same version as **Current** (`current`), but be aware you'll be bumped to an upcoming release without warning if/when released to this branch.

### Versioning

_(Todo)_

## 🔄 Updating

Performing a system update can be done by either:

* Running `sudo rpm-ostree upgrade` in a shell
* Opening **Software**, selecting **Updates** from the headerbar, and pressing **Update All**
  - As Software runs in the background and periodically checks for updates, you may also receive a notification of a new update; clicking on this opens the appropriate page
  - An update for the OS may take a while to appear in Software (which will appear as "Operating System Updates"), so the above method is preferred

Reboot after either method has finished. You can verify the version installed by opening **System Settings** and navigating to **System ➔ Operating System**: the version proceeds the word "Sodalite"

If something breaks, you can rollback by running `sudo rpm-ostree rollback` at a terminal. Remember to also [create a new issue](https://github.com/sodaliterocks/sodalite/issues/new) if appropriate!

#### Update Schedule

Updates are built on the build server commencing **6:00 GMT/±0** **(22:00 PT/-8)** every **Wednesday** and **Saturday**.

#### "Long-term" Branches

If you chose to use a "long-term" branch (see <a href="#branches">Branches</a> above), you will need to rebase whenever the Sodalite version reaches end-of-life. This can be done with `sudo rpm-ostree rebase sodalite:sodalite/<version>/<arch>/<edition>`, where `<version>` is the version you're wanting to rebase to and other values are your current values.

It's vital you carry out this process as updates stop the day the base version reaches end-of-life (at the same time as the base Fedora Linux version) and you will be left without updates to vital system components.

---

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
  - `rpm-ostree` needs superuser access to work: there's no way around this
  - Building in a container, however, is possible and supported: just pass the `-c`/`--container` flag to `build.sh` (mentioned below)
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
sudo ./build.sh [-t <edition>] [-w <working-dir>]
```

_See `build.sh --help` for more options._

This will usually take 10-15 minutes. Remember when I told you to grab a cuppa? Or maybe a cold one?

##### Arguments

* `<edition>` _(optional)_ Edition/variant of Sodalite (defaults to `custom`)
  - This is any of the `sodalite-<edition>.yaml` files listed in `./src/treefiles/`. Either use `sodalite-<edition>` or just `<edition>` as the argument. Currently, there is:
    - `desktop`: Standard Pantheon desktop
    - `desktop-budgie`: Alternate Budgie desktop, intended for possible future versions
    - `desktop-deepin`: Alternate Deepin desktop, intended for possible future versions
    - `desktop-gnome`: Alternate GNOME desktop, intended for possible future versions
    - `custom`: See below point
  - `sodalite-custom.yaml` is a good place to employ your own changes instead of modifying any of the other treefiles
* `<working-dir>` _(optional)_ Directory for build output (defaults to `./build`)

#### Additional Notes

##### Building in a Container

If you have [Podman](https://podman.io/), you can build Sodalite entirely in a container: just use `-c`/`--container`. This is in fact how builds are done on the release server! However, this will add an extra few minutes for the build to complete as the Fedora container needs to install packages first.

##### NTFS/FAT partitions

Build failures are inevitable on drives formatted as NTFS, FAT, or anything other filesystems that do not support Unix-like permissions, as `build.sh` sets permissions on various objects.

###### WSL2

On WSL2, do not build to any `/mnt/<drive-letter>` directories as these will be formatted as NTFS or FAT. Instead, run the build somewhere else on the Linux distro itself (like `$HOME` or `/usr/local/src`).

##### Not using `build.sh`

Most rpm-ostree distros can be built just be simply doing `rpm-ostree compose`, but `build.sh` provided with Sodalite does some extra steps which are required for the post-build script (which **will** fail without these being ran). It is therefore not recommended to do it this way: any issues building the distro this way will be closed and marked as invalid.

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

---

## 🤝 Acknowledgements

### Individuals

* [Jorge O. Castro](https://github.com/castrojo), for including Sodalite in [awesome-immutable](https://github.com/castrojo/awesome-immutable)
* [Timothée Ravier](https://tim.siosm.fr), for their extensive guidance to the community concerning Fedora Silverblue
* The amazing photographers/artists of the included wallpapers &mdash; [Adrien Olichon](https://unsplash.com/@adrienolichon), [Ashwini Chaudhary](https://unsplash.com/@suicide_chewbacca), [Austin Neill](https://unsplash.com/@arstyy), [Cody Fitzgerald](https://unsplash.com/@cfitz), [David Becker](https://unsplash.com/@beckerworks), [Dustin Humes](https://unsplash.com/@dustinhumes_photography), [Eugene Golovesov](https://unsplash.com/@eugene_golovesov), [Jack B.](https://unsplash.com/@nervum), [Jeremy Gerritsen](https://unsplash.com/@jeremygerritsen), [Karsten Würth](https://unsplash.com/@karsten_wuerth), [Marek Piwnicki](https://unsplash.com/@marekpiwnicki), [Max Okhrimenko](https://unsplash.com/@maxokhrimenko), [Nathan Dumlao](https://unsplash.com/@nate_dumlao), [Piermanuele Sberni](https://unsplash.com/@piermanuele_sberni), [Phil Botha](https://unsplash.com/@philbotha), [Ryan Stone](https://unsplash.com/@rstone_design), [Smaran Alva](https://unsplash.com/@smal), [Takashi Miyazaki](https://unsplash.com/@miyatankun), [Willian Daigneault](https://unsplash.com/@williamdaigneault), and [Zara Walker](https://unsplash.com/@mojoblogs)

#### Past Individuals

_These fine folks' work is no longer included in, or relevant to, Sodalite, but they're still worth a shout-out!_

* [Fabio "decathorpe" Valentini](https://decathorpe.com/), for maintaining elementary/Pantheon packages on Fedora
  * Due to various packaging issues with Pantheon on Fedora's official repos (see [#44](https://github.com/sodaliterocks/sodalite/issues/44), and [writing (about) code ➔ elementary-stable](https://decathorpe.com/fedora-elementary-stable-status.html)), these packages were dropped entirely (including the addtional ~~[elementary-staging](https://copr.fedorainfracloud.org/coprs/decathorpe/elementary-staging/)~~ and ~~[elementary-nightly](https://copr.fedorainfracloud.org/coprs/decathorpe/elementary-nightly/)~~ Copr repos, dropped in Feb '23). Despite this, decathorpe's contributions are essentially what sparked Sodalite in the first place.
* ["Topfi"](https://github.com/ACertainTopfi), for their various contributions

### Teams & Organizations

* [elementary](https://elementary.io/team), for building lovely stuff
* [Fyra Labs](https://fyralabs.com), for maintaining [Terra](https://terra.fyralabs.com/)
  * Due to various packaging issues with Pantheon on Fedora's official repos (see [#44](https://github.com/sodaliterocks/sodalite/issues/44)), Sodalite was almost doomed after f36+ reached EoL. However, Terra maintains builds of Pantheon and effectively keeps the lights on here!
* The contributors to [workstation-ostree-config](https://pagure.io/workstation-ostree-config), for a solid ground to work from

### Miscellaneous

* The [Sodalite mineral](https://en.wikipedia.org/wiki/Sodalite), for the name. [It's a mineral, not a rock, Jesus](https://www.youtube.com/watch?v=r1yYJBzf1VQ)!
* The [Omicron variant of SARS-CoV-2](https://en.wikipedia.org/wiki/SARS-CoV-2_Omicron_variant), for giving [Ducky](https://github.com/electricduck) the initial free time to make this thing

## 👀 See Also

* **[📄 Code of Conduct](CODE_OF_CONDUCT.md)** &mdash; Contributor Covenant CoC
* **[📄 Contributing](CONTRIBUTING.md)**
* **[📄 License](LICENSE)** &mdash; MIT, &copy; 2023 Sodalite contributors

### Related

* **[🔗 Fedora Docs ➔ Fedora Silverblue User Guide](https://docs.fedoraproject.org/en-US/fedora-silverblue/)**

---

<p align="center">
  <a href="README.md">🇬🇧</a>
  <!--a href="docs/README.de.md">🇩🇪</a-->
</p>
