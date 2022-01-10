# Sodalite

![Screenshot of Sodalite](https://git.zio.sh/ducky/sodalite-lfs/raw/branch/main/screenshots/screenshot.png?u=1)

## Quickstart

You better know what you're doing, sparky. To get going:

1) Install an OSTree version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/).
2) Open a terminal and issue these commands:
	* `sudo ostree remote add --if-not-exists zio https://ostree.zio.sh/repo --no-gpg-verify`
	* `sudo ostree pull sodalite/stable/x86_64/default`
	* `sudo rpm-ostree rebase zio:sodalite/stable/x86_64/default`
3) Stick the kettle on and make yourself a cuppa. It'll take a while.
4) Reboot when prompted. Sit back in awe as the desktop loads up.
	* Updates will occur automatically if you update everything from Software (which runs in the background by default and notifies you). Alternatively, run `sudo rpm-ostree upgrade` from a terminal.

Confused? Head down to [Getting](#getting).

### Wait, what happened to `install.sh`?

Removed in [1cf0a1f](https://github.com/electricduck/sodalite/commit/1cf0a1fae31c49c797146c90854bc136fa105994), because:

* Fedora Silverblue itself is not for beginners, and you shouldn't really need an easy-peasy installer script to get this going.
* The script itself might possibly break with future versions of the tools it invokes.
* You'll learn how things work without blindly running random scripts, and possibly troubleshoot issues since you'll know _where_ something went wrong.
* It's literally three lines to install. 😜

## Background

Like most of us, I've been distro hopping since I was eating crayons, but as with anything in life there comes a point you need to settle down. I eventually found love for the fantastic [elementaryOS](https://elementary.io/): a beautifully crafted distro, packed with a few lovely apps and mated to the in-house Pantheon desktop. With very little customization, its not the experience for the most die-hard Linux fan, but I grew to love the workflow and UX patterns I found myself forced into.

Like every OS though, things begin to break down after years of abuse to its foundation. A tweak to something in /usr here, and a hack in /etc there: it piles up and I forget what I've done, leading to a grubby OS I'm going to need to eventually reinstall. _G r e a t_. Fedora had been something I'd been using on-and-off for the past year &mdash; installing Pantheon in place of GNOME, of course &mdash; leading me to eventually stumble across [Fedora Silverblue](https://silverblue.fedoraproject.org/) and [OSTree](https://ostreedev.github.io/ostree/). _Hm, a usable immutable OS, you say? Sounds glorious!_  And with that I give up a weekend to attempt to mate an old friend and a new idea, spending hours [searching through documentation](https://rpm-ostree.readthedocs.io/en/stable/manual/treefile/) and [peering at repositories](https://pagure.io/workstation-ostree-config), and soon stable platform with a charming desktop is born. Seems only right to share with the world.

So hello world, this is Sodalite: Fedora Silverblue and Pantheon.

As a sidenote, a similar configuration exists in the [workstation-ostree-config repository on Pagure](https://pagure.io/workstation-ostree-config) (specifically in `./fedora-pantheon.yaml`) but that is a barebones vanilla install. Sodalite was actually partially inspired by this and builds upon it, providing a more finished product with the trademark elementary flourish.

## Status

This project is still very much early days and there is plenty of things that are broken, mostly due to missing upstream elementary/Pantheon packages on Fedora &mdash; Pantheon is _mostly_ distro-agnostic but still some way from being complete &mdash; but also because ~~I'm a simpleton~~ I lack understanding of various components in OSTree and Fedora Silverblue. But we'll get there... eventually!

However, there's plenty of stuff that _does_ work rendering Sodalite entirely usable for day-to-day activites: I even used it to type up this README and build releases. Unless in this _Missing Apps_ list, every app included in elementaryOS comes with Sodalite and works 100% (probably)! That includes, **Music**, **Photos**, **Videos**, **Calendar**, **Files**, **Terminal**, **Code**, **Camera**, along with several other in-box utilities. AppCenter's Flatpak repository is also pre-installed giving you access to the ever-grown "curated" apps for elementaryOS.

### Missing Apps

* **AppCenter**<br />Although this builds on Fedora it refuses to work properly in Silverblue due to the nature of everything. Without proper support for OSTree, and a lack of PackageKit in the host, errors are thrown and nothing really loads in. _GNOME Software_ instead serves as a replacement, along with the AppCenter Flatpak repository being pre-installed.
* **Web**<br />As Fedora uses Firefox as the default browser, Web (Epiphany) is not installed by default. You can rectify this by running `sodalite-install-epiphany`.

### Other Issues

* Various System Settings (Switchboard) items are not included or do not work right.
* Various theming issues, due to be fixed in the upstream:
	* Some apps appear odd, such as Firefox which entirely lacks rounded corners.
	* Many Flatpak apps will not be themed and fallback to the Adwaita theme.
* Many Flatpak apps will be duplicated in the Dock: see [issue #64 on elementary/dock](https://github.com/elementary/dock/issues/64). Although this is one of many issues across elementary, I felt like I needed to bring this one up. Nothing broke on your end!
* ~~Not enough people are using this masterpiece.~~

<h2 id="getting">Getting</h2>

Ready? It's easy. Ish. Hold out your hand and I'll guide you.

An OSTree repository has already been setup for Sodalite, so you don't even need to build it yourself (hurrah!)

1) If you haven't already, install an OSTree version of Fedora, such as [Fedora Silverblue](https://silverblue.fedoraproject.org/download).
	* If you've never used OSTree or Fedora Silverblue before, **[read the docs](https://docs.fedoraproject.org/en-US/fedora-silverblue/)**. Get to know the OS, (try to) break it, reinstall it, repeat.
	* Custom partitioning is unsupported but does work from experience. The installer is flaky however, and will often stumble on basic problems and giving you very little guidance on what went wrong. For example, `fedora` still being present in the EFI partition if leftover from a previous install &mdash; just delete the directory!
	* If you're feeling adventurous, install [Fedora IoT](https://getfedora.org/iot/) instead &mdash; it's OSTree too, plus the ISO is over half the size.
2) Open a terminal and issue the following commands with superuser privileges (as `root`, or with `sudo`):
	1) `ostree remote add --if-not-exists zio https://ostree.zio.sh/repo --no-gpg-verify`<br />This adds the OSTree repository hosted on [zio.sh](https://zio.sh) (a group of servers partially ran by [@electricduck](https://github.com/electricduck) — it can be trusted). No GPG verification because I'm lazy as sin.
	2) `ostree pull sodalite/stable/x86_64/base`<br />This pulls the OSTree image for Sodalite, and is split up into four parts (similar to that of Fedora Silverblue). These parts can be substituted for other values:
		1) `sodalite`: The **name** of the image. That's _SOH-da-lyte_ not _sou-DA-lyte_ — I'm not making a sugar-free beverage here.
		2) `stable`: The **version** of the image. Possible values:
            * `stable`: Rolling-release version based on the current stable version of Fedora Linux (as of currently, Fedora Linux 35).
        1) `x86_64`: The **architecture** of the image. Possible values:
            * `x86_64`: For 64-bit CPUs (`x86_64`, `amd64`, or — please stop saying this — `x64`).
            * <s>`x86`: [What year is it!?](https://c.tenor.com/9OcQhlCBNG0AAAAd/what-year-is-it-jumanji.gif)</s>
        2) `base`: The **variant** of the image. Possible values:
            * `base`: Everything you'll need to get going (hopefully). Other variants are built on-top of this.
            * <s>`caral`: Stuff and things.</s> Coming soon™.
	3) `rpm-ostree rebase zio:sodalite/stable/x86_64/base`<br />This rebases the OS onto Sodalite's image. Remember to substitute any values from before into this one!
3) Reboot when prompted with `systemctl reboot`.
4) Once logged in, defaults should apply and everything should be as it should.
   	* Unless removed them beforehand, you'll have a tonne of GNOME apps still installed from Flatpak. As Flatpak apps are part of the "user" part of the OS they cannot be programatically removed during the rebase. Run to `sodalite-uninstall-gnome-apps` to remove them all.
   	* Some elementaryOS apps are provided via Flatpak itself. These will be installed on bootup but make take some time to appear in your Applications menu. Invoke it manually with `sodalite-install-appcenter-flatpak`.
   	* Updates will occur automatically if you update everything from Software (which runs in the background by default and notifies). Alternatively, run `rpm-ostree upgrade`.

### Post-install

(todo)

#### Included tools

For bits of housekeeping, Sodalite also includes a few tools:

* `sodalite-install-epiphany`<br />Installs Web (Epiphany); elementary's default browser.
* `sodalite-set-hostname [hostname] [description]`<br />Sets the system hostname.
* `sodalite-uninstall-gnome-apps`<br />Removes GNOME apps installed via Flatpak. You'll be presented with a list of apps and given a choice whether you want to remove them all. Although they play nicely in Pantheon, they look extremely out-of-place.
* `sodalite-update`<br />Updates the system!

_The below scripts are ran as services: you should never need to run them manually unless you disable the service (which has the same name)._

* `sodalite-generate-oem`<br />Generates the OEM file (`/etc/oem.conf`) to populate the _Hardware_ tab under _System_ in _System Settings_. This information comes from `dmidecode`, so if it looks messed up blame the manufacturer.
* `sodalite-install-appcenter-flatpak`<br />Installs the AppCenter Flatpak repository, giving you access to the ever-grown "curated" apps for elementaryOS. Also installs a few apps from the repository included in elementaryOS.

_The below scripts are run as autostart for the user: you should need need to run them manually unless you disable the autostart (which has the same name)._

* `sodalite-plank-wrapper`<br />Launches Plank with a wrapper to correct default settings (and update them if the user never changes items).

### Removal

(todo &mdash; OSTree has several ways and its dependant on your install!)

## Building

(todo)

## Contributing

(todo)

## Acknowledgements

* The contributors to [workstation-ostree-config](https://pagure.io/workstation-ostree-config), giving me a solid ground to work from.
* [Timothée Ravier](https://tim.siosm.fr), for his extensive guidance to the community concerning Fedora Silverblue.
* The [elementary team](https://elementary.io/team), for building their lovely stuff and getting it working everywhere.
* The contributors to [Ublue](https://github.com/castrojo/ublue), for showing me there's plenty niche-of-niches.
* The amazing photographers/artists of the included wallpapers:
	* [Adrien Olichon](https://unsplash.com/@adrienolichon)
	* [Austin Neill](https://unsplash.com/@arstyy)
	* [Cody Fitzgerald](https://unsplash.com/@cfitz)
	* [Karsten Würth](https://unsplash.com/@karsten_wuerth)
	* [Nathan Dumlao](https://unsplash.com/@nate_dumlao)
	* [Smaran Alva](https://unsplash.com/@smal)
	* [Willian Daigneault](https://unsplash.com/@williamdaigneault)
	* [Zara Walker](https://unsplash.com/@mojoblogs)
* The [Sodalite mineral](https://en.wikipedia.org/wiki/Sodalite), for the name. It's pronounced _SOH-da-lyte_ not _sou-DA-lyte_, you fool.
* The Omicron variant of COVID-19, for giving me the initial free time to make this thing. True story.

## License

See **[LICENSE](LICENSE)**. It's MIT, alright, like every awesome pile of code.
